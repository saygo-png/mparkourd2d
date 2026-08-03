{-# LANGUAGE ForeignFunctionInterface #-}
{-# LANGUAGE PatternSynonyms #-}

module Main (main) where

import Control.Exception (evaluate)
import Control.Monad (forM_, replicateM_)
import Data.IORef
import Data.Vector.Storable qualified as VS
import Foreign
import Foreign.C.Types (CBool (..))

import Test.Tasty
import Test.Tasty.HUnit
import Test.Tasty.Runners (NumThreads (..))

import Box2D.Base qualified as Base
import Box2D.Body qualified as Body
import Box2D.Callbacks qualified as CB
import Box2D.Chain qualified as Chain
import Box2D.Collision qualified as Collision
import Box2D.Contact qualified as Contact
import Box2D.DistanceJoint qualified as DistanceJoint
import Box2D.DynamicTree qualified as DynamicTree
import Box2D.Events qualified as Events
import Box2D.Extra (withShapeProxy)
import Box2D.Id (BodyId (..), ContactId (..), ShapeId (..), WorldId (..), nullBodyId, nullContactId, nullWorldId)
import Box2D.Joint qualified as Joint
import Box2D.MathFunctions
import Box2D.MathTypes
import Box2D.Mover qualified as Mover
import Box2D.Shape qualified as Shape
import Box2D.UserData qualified as UD
import Box2D.World qualified as World

import Box2D.Body (BodyDef (..), defaultBodyDef, pattern DynamicBody, pattern StaticBody)
import Box2D.Collision (CollisionPlane (..), Manifold (..), PlaneResult (..))
import Box2D.DistanceJoint (DistanceJointDef (..), defaultDistanceJointDef)
import Box2D.DynamicTree (dynamicTreeByteCount)
import Box2D.FilterJoint (defaultFilterJointDef)
import Box2D.Geometry (Capsule (..), CastOutput (..), Circle (..), Hull (..), MassData (..), Polygon (..), RayCastInput (..), Segment (..), ShapeProxy (..))
import Box2D.Joint (JointDef (..), pattern DistanceJoint)
import Box2D.MotorJoint (defaultMotorJointDef)
import Box2D.PrismaticJoint (defaultPrismaticJointDef)
import Box2D.RevoluteJoint (defaultRevoluteJointDef)
import Box2D.Shape (QueryFilter (..), ShapeDef (..), defaultChainDef, defaultFilter, defaultQueryFilter, defaultShapeDef, defaultSurfaceMaterial, pattern CapsuleShape, pattern ChainSegmentShape, pattern CircleShape, pattern PolygonShape, pattern SegmentShape)
import Box2D.WeldJoint (defaultWeldJointDef)
import Box2D.WheelJoint (defaultWheelJointDef)
import Box2D.World (BodyMoveEvent (..), ContactBeginTouchEvent (..), ContactData (..), ContactEndTouchEvent (..), ContactHitEvent (..), ExplosionDef (..), JointEvent (..), RayResult (..), SensorBeginTouchEvent (..), SensorEndTouchEvent (..), WorldDef (..), defaultExplosionDef, defaultWorldDef)

main :: IO ()
-- Box2D keeps a global registry of worlds and a world is single-threaded
-- state, so the suite must run sequentially rather than tasty's default
-- parallel execution.
main = defaultMain (localOption (NumThreads 1) tests)

tests :: TestTree
tests =
  testGroup
    "Box2D"
    [ testGroup "Base" baseTests
    , testGroup "MathTypes" mathTypesTests
    , testGroup "MathFunctions" mathFunctionsTests
    , testGroup "Id" idTests
    , testGroup "Types" typesTests
    , testGroup "Simulation" simulationTests
    , testGroup "Generated breadth" generatedTests
    , testGroup "Joints" jointTests
    , testGroup "Events" eventTests
    , testGroup "Queries" queryTests
    , testGroup "Polygons and chains" polygonTests
    , testGroup "Proxies, contacts and the mover" moverTests
    , testGroup "Callbacks" callbackTests
    ]

-- | Poke a value and read it back, exercising the 'Storable' instance.
roundTrip :: (Storable a) => a -> IO a
roundTrip x = alloca $ \p -> poke p x >> peek p

approx :: Float -> Float -> Assertion
approx expected actual =
  assertBool
    ("expected " <> show expected <> " but got " <> show actual)
    (abs (expected - actual) < 1e-5)

baseTests :: [TestTree]
baseTests =
  [ testCase "getVersion is 3.2.0" $ do
      v <- Base.getVersion
      v.major @?= 3
      v.minor @?= 2
      v.revision @?= 0
  , testCase "getByteCount is non-negative" $ do
      n <- Base.getByteCount
      assertBool "byte count >= 0" (n >= 0)
  , testCase "isDoublePrecision is False (single-precision build)" $ do
      dp <- Base.isDoublePrecision
      dp @?= False
  ]

mathTypesTests :: [TestTree]
mathTypesTests =
  [ testCase "type sizes match the C ABI" $ do
      sizeOf (Vec2 0 0) @?= 8
      sizeOf (Rot 1 0) @?= 8
      sizeOf (Transform vec2Zero rotIdentity) @?= 16
      sizeOf (Mat22 vec2Zero vec2Zero) @?= 16
      sizeOf (AABB vec2Zero vec2Zero) @?= 16
      sizeOf (Plane vec2Zero 0) @?= 12
  , testCase "Vec2 round-trips" $
      roundTrip (Vec2 1 2) >>= (@?= Vec2 1 2)
  , testCase "Transform round-trips" $ do
      let t = Transform (Vec2 1 2) (Rot 0.6 0.8)
      roundTrip t >>= (@?= t)
  , testCase "AABB round-trips" $ do
      let a = AABB (Vec2 (-1) (-2)) (Vec2 3 4)
      roundTrip a >>= (@?= a)
  ]

mathFunctionsTests :: [TestTree]
mathFunctionsTests =
  [ testCase "finite vector is valid" $
      isValidVec2 (Vec2 1 2) >>= (@?= True)
  , testCase "NaN vector is invalid" $
      isValidVec2 (Vec2 (0 / 0) 0) >>= (@?= False)
  , testCase "infinite vector is invalid" $
      isValidVec2 (Vec2 (1 / 0) 0) >>= (@?= False)
  , testCase "identity rotation is valid" $
      isValidRotation rotIdentity >>= (@?= True)
  , testCase "identity transform is valid" $
      isValidTransform transformIdentity >>= (@?= True)
  , testCase "computeCosSin 0 = (1, 0)" $ do
      CosSin c s <- computeCosSin 0
      approx 1 c
      approx 0 s
  , testCase "makeRot 0 is the identity" $ do
      Rot c s <- makeRot 0
      approx 1 c
      approx 0 s
  , testCase "rotGetAngle recovers the angle" $ do
      approx 1.2 (rotGetAngle (Rot (cos 1.2) (sin 1.2)))
      approx 0 . rotGetAngle =<< makeRot 0
      -- makeRot uses an approximate cos/sin, so its round-trip is loose
      r <- makeRot 1.2
      let a = rotGetAngle r
      assertBool ("~1.2 through makeRot, got " <> show a) (abs (a - 1.2) < 5e-3)
  , testCase "makeRot pi/2 is a quarter turn" $ do
      Rot c s <- makeRot (pi / 2)
      approx 0 c
      approx 1 s
  ]

idTests :: [TestTree]
idTests =
  [ testCase "id sizes match the C ABI" $ do
      sizeOf nullWorldId @?= 4
      sizeOf nullBodyId @?= 8
      sizeOf nullContactId @?= 12
  , testCase "WorldId round-trips" $
      roundTrip (WorldId 0x50009) >>= (@?= WorldId 0x50009)
  , testCase "BodyId round-trips" $
      roundTrip (BodyId 0x1122334455667788) >>= (@?= BodyId 0x1122334455667788)
  , testCase "ContactId round-trips" $
      roundTrip (ContactId 1 2 4) >>= (@?= ContactId 1 2 4)
  ]

typesTests :: [TestTree]
typesTests =
  [ testCase "default world def has expected fields" $ do
      d <- defaultWorldDef
      d.gravity @?= Vec2 0 (-10)
      d.contactHertz @?= 30
      d.enableSleep @?= 1
      assertBool "internalValue cookie is set" (d.internalValue /= 0)
  , testCase "default world def round-trips" $ do
      d <- defaultWorldDef
      roundTrip d >>= (@?= d)
  , testCase "default body def has expected fields" $ do
      d <- defaultBodyDef
      d.type_ @?= StaticBody
      d.rotation @?= rotIdentity
      d.gravityScale @?= 1
      assertBool "internalValue cookie is set" (d.internalValue /= 0)
  , testCase "default body def round-trips" $ do
      d <- defaultBodyDef
      roundTrip d >>= (@?= d)
  , testCase "default shape def has expected fields" $ do
      d <- defaultShapeDef
      d.density @?= 1
      d.updateBodyMass @?= 1
      assertBool "internalValue cookie is set" (d.internalValue /= 0)
  , testCase "default shape def round-trips" $ do
      d <- defaultShapeDef
      roundTrip d >>= (@?= d)
  , testCase "default filter round-trips" $ do
      f <- defaultFilter
      roundTrip f >>= (@?= f)
  , testCase "default surface material round-trips" $ do
      m <- defaultSurfaceMaterial
      roundTrip m >>= (@?= m)
  , testCase "Circle round-trips" $ do
      let c = Circle (Vec2 1 2) 0.5
      roundTrip c >>= (@?= c)
  , testCase "Capsule round-trips" $ do
      let c = Capsule (Vec2 0 0) (Vec2 0 1) 0.25
      roundTrip c >>= (@?= c)
  , testCase "Segment round-trips" $ do
      let s = Segment (Vec2 (-1) 0) (Vec2 1 0)
      roundTrip s >>= (@?= s)
  , testCase "shape types case as patterns (COMPLETE, no wildcard)" $
      withWorld (Vec2 0 0) $ \w -> do
        bd <- defaultBodyDef
        b <- Body.create w bd
        sd <- defaultShapeDef
        sh <- Shape.createCircle b sd (Circle vec2Zero 0.5)
        ty <- Shape.getType sh
        let name = case ty of
              CircleShape -> "circle"
              CapsuleShape -> "capsule"
              SegmentShape -> "segment"
              PolygonShape -> "polygon"
              ChainSegmentShape -> "chain segment"
        name @?= ("circle" :: String)
  ]

-- | Build a world with the given gravity and default settings.
withWorld :: Vec2 -> (WorldId -> IO a) -> IO a
withWorld gravity act = do
  wd <- defaultWorldDef
  w <- World.create wd{gravity}
  r <- act w
  World.destroy w
  pure r

-- | A dynamic body carrying a unit circle at the given position.
dynamicCircle :: WorldId -> Pos -> Float -> IO BodyId
dynamicCircle w position radius = do
  bd <- defaultBodyDef
  b <- Body.create w bd{type_ = DynamicBody, position = position}
  sd <- defaultShapeDef
  _ <- Shape.createCircle b sd (Circle vec2Zero radius)
  pure b

posY :: Vec2 -> Float
posY (Vec2 _ y) = y

simulationTests :: [TestTree]
simulationTests =
  [ testCase "world is valid until destroyed" $ do
      wd <- defaultWorldDef
      w <- World.create wd
      World.isValid w >>= (@?= True)
      World.destroy w
      World.isValid w >>= (@?= False)
  , testCase "gravity can be read and set" $
      withWorld (Vec2 0 (-10)) $ \w -> do
        World.getGravity w >>= (@?= Vec2 0 (-10))
        World.setGravity w (Vec2 0 (-20))
        World.getGravity w >>= (@?= Vec2 0 (-20))
  , testCase "a body and its shape wire up correctly" $
      withWorld (Vec2 0 (-10)) $ \w -> do
        bd <- defaultBodyDef
        b <- Body.create w bd{type_ = DynamicBody, position = Vec2 0 10}
        Body.isValid b >>= (@?= True)
        Body.getType b >>= (@?= DynamicBody)
        Body.getPosition b >>= (@?= Vec2 0 10)
        sd <- defaultShapeDef
        s <- Shape.createCircle b sd (Circle vec2Zero 0.5)
        Shape.isValid s >>= (@?= True)
        Shape.getType s >>= (@?= CircleShape)
        Shape.getBody s >>= (@?= b)
  , testCase "a dynamic body falls under gravity" $
      withWorld (Vec2 0 (-10)) $ \w -> do
        b <- dynamicCircle w (Vec2 0 10) 0.5
        replicateM_ 60 (World.step w (1 / 60) 4)
        y <- posY <$> Body.getPosition b
        -- one second of free fall from rest under g = -10 lands near y = 5
        assertBool ("body fell, y = " <> show y) (y > 4 && y < 6)
        vy <- posY <$> Body.getLinearVelocity b
        assertBool ("velocity is downward, vy = " <> show vy) (vy < -8)
  , testCase "a dynamic body rests on a static ground segment" $
      withWorld (Vec2 0 (-10)) $ \w -> do
        gd <- defaultBodyDef
        ground <- Body.create w gd
        gsd <- defaultShapeDef
        _ <- Shape.createSegment ground gsd (Segment (Vec2 (-20) 0) (Vec2 20 0))
        ball <- dynamicCircle w (Vec2 0 5) 0.5
        replicateM_ 240 (World.step w (1 / 60) 4)
        y <- posY <$> Body.getPosition ball
        -- the ball comes to rest on top of the segment: y ~= 0.5
        assertBool ("ball rests on the ground, y = " <> show y) (y > 0.3 && y < 0.7)
  ]

{- | Exercise a spread of functions that only exist thanks to the generator:
Tier A scalar/bool accessors, a coerced enum, and the @b2AABB@-returning
shim (b2World_GetBounds), none of which the hand-written layer bound.
-}
generatedTests :: [TestTree]
generatedTests =
  [ testCase "body mass, density and awake flag are readable" $
      withWorld (Vec2 0 (-10)) $ \w -> do
        b <- dynamicCircle w (Vec2 0 10) 0.5
        m <- Body.getMass b
        assertBool ("mass is positive, m = " <> show m) (m > 0)
        Body.getGravityScale b >>= approx 1
        Body.setAwake b True
        Body.isAwake b >>= (@?= True)
  , testCase "shape density defaults to 1" $
      withWorld (Vec2 0 (-10)) $ \w -> do
        bd <- defaultBodyDef
        b <- Body.create w bd{type_ = DynamicBody}
        sd <- defaultShapeDef
        shp <- Shape.createCircle b sd (Circle vec2Zero 0.5)
        Shape.getDensity shp >>= approx 1
        Shape.getType shp >>= (@?= CircleShape)
  , testCase "world reports awake bodies and finite bounds" $
      withWorld (Vec2 0 (-10)) $ \w -> do
        _ <- dynamicCircle w (Vec2 0 10) 0.5
        World.step w (1 / 60) 4
        n <- World.getAwakeBodyCount w
        assertBool ("at least one awake body, n = " <> show n) (n >= 1)
        World.isSleepingEnabled w >>= (@?= True)
        bounds <- World.getBounds w
        isValidAABB bounds >>= (@?= True)
  ]

{- | Exercise the Tier B path unlocked by the hand-written joint-def Storables:
build a @DistanceJointDef@ value (setting fields on the embedded base),
create the joint, and confirm it constrains the bodies.
-}
jointTests :: [TestTree]
jointTests =
  [ testCase "a rigid distance joint hangs a body below a static anchor" $
      withWorld (Vec2 0 (-10)) $ \w -> do
        gd <- defaultBodyDef
        anchor <- Body.create w gd{Body.position = Vec2 0 10}
        bd <- defaultBodyDef
        hanging <- Body.create w bd{type_ = DynamicBody, position = Vec2 0 8}
        sd <- defaultShapeDef
        _ <- Shape.createCircle hanging sd (Circle vec2Zero 0.25)
        djd <- defaultDistanceJointDef
        let
          base = djd.base
          def =
            djd
              { base =
                  base{bodyIdA = anchor, bodyIdB = hanging}
              , length = 2
              }
        j <- DistanceJoint.create w def
        Joint.isValid j >>= (@?= True)
        Joint.getType j >>= (@?= DistanceJoint)
        Joint.getBodyA j >>= (@?= anchor)
        Joint.getBodyB j >>= (@?= hanging)
        DistanceJoint.getLength j >>= approx 2
        replicateM_ 120 (World.step w (1 / 60) 4)
        -- rigid length 2 below the anchor at (0, 10): the body settles near y = 8
        y <- posY <$> Body.getPosition hanging
        assertBool ("body hangs ~2 below anchor, y = " <> show y) (y > 7.5 && y < 8.5)
  , testCase "default joint defs round-trip through their Storable" $ do
      let rt mk = mk >>= \x -> roundTrip x >>= (@?= x)
      rt defaultDistanceJointDef
      rt defaultMotorJointDef
      rt defaultPrismaticJointDef
      rt defaultRevoluteJointDef
      rt defaultWeldJointDef
      rt defaultWheelJointDef
      rt defaultFilterJointDef
  ]

{- | Exercise the hand-written event-buffer marshalling (roadmap phase 5): the
generated @World.getBodyEvents@ returns the raw buffer, "Box2D.Events" copies
the elements into a list.
-}
eventTests :: [TestTree]
eventTests =
  [ testCase "a moved body appears in the body move events" $
      withWorld (Vec2 0 (-10)) $ \w -> do
        b <- dynamicCircle w (Vec2 0 10) 0.5
        replicateM_ 4 (World.step w (1 / 60) 4)
        evs <- Events.bodyMoveEvents w
        assertBool "at least one move event" (not (VS.null evs))
        assertBool
          "the falling body is among the moved bodies"
          (b `VS.elem` VS.map (.bodyId) evs)
  , testCase "a body falling through a sensor produces begin and end events" $
      withWorld (Vec2 0 (-10)) $ \w -> do
        gd <- defaultBodyDef
        sensorBody <- Body.create w gd
        gsd <- defaultShapeDef
        sensor <-
          Shape.createCircle
            sensorBody
            gsd{isSensor = 1, enableSensorEvents = 1}
            (Circle vec2Zero 1)
        bd <- defaultBodyDef
        visitor <- Body.create w bd{type_ = DynamicBody, position = Vec2 0 4}
        sd <- defaultShapeDef
        _ <-
          Shape.createCircle
            visitor
            sd{enableSensorEvents = 1}
            (Circle vec2Zero 0.25)
        (begins, ends) <- collectEvents 240 w $ \acc -> do
          bs <- Events.sensorBeginTouchEvents w
          es <- Events.sensorEndTouchEvents w
          let (b0, e0) = acc
          pure (b0 <> bs, e0 <> es)
        assertBool
          "a begin touch event names the sensor"
          (sensor `VS.elem` VS.map (.sensorShapeId) begins)
        assertBool
          "an end touch event names the sensor"
          (sensor `VS.elem` VS.map (.sensorShapeId) ends)
  , testCase "a landing body produces contact begin, hit, and (once destroyed) end events" $
      withWorld (Vec2 0 (-10)) $ \w -> do
        gd <- defaultBodyDef
        ground <- Body.create w gd
        gsd <- defaultShapeDef
        _ <-
          Shape.createSegment
            ground
            gsd{enableContactEvents = 1, enableHitEvents = 1}
            (Segment (Vec2 (-10) 0) (Vec2 10 0))
        bd <- defaultBodyDef
        ball <- Body.create w bd{type_ = DynamicBody, position = Vec2 0 3}
        sd <- defaultShapeDef
        bshape <-
          Shape.createCircle
            ball
            sd{enableContactEvents = 1, enableHitEvents = 1}
            (Circle vec2Zero 0.5)
        (begins, hits) <- collectEvents 120 w $ \acc -> do
          bs <- Events.contactBeginTouchEvents w
          hs <- Events.contactHitEvents w
          let (b0, h0) = acc
          pure (b0 <> bs, h0 <> hs)
        let involves a b e = a e == bshape || b e == bshape
        assertBool
          "a contact begin event involves the ball"
          (VS.any (involves (.shapeIdA) (.shapeIdB)) begins)
        assertBool
          "a hit event involves the ball"
          (VS.any (involves (.shapeIdA) (.shapeIdB)) hits)
        assertBool
          "the hit approach speed is positive"
          (VS.all ((> 0) . (.approachSpeed)) hits && not (VS.null hits))
        -- destroying the touching body ends the contact on the next step
        Body.destroy ball
        World.step w (1 / 60) 4
        ends <- Events.contactEndTouchEvents w
        assertBool
          "a contact end event involves the (destroyed) ball shape"
          (VS.any (involves (.shapeIdA) (.shapeIdB)) ends)
  , testCase "a loaded joint with a low force threshold produces joint events" $
      withWorld (Vec2 0 (-10)) $ \w -> do
        gd <- defaultBodyDef
        anchor <- Body.create w gd{Body.position = Vec2 0 10}
        bd <- defaultBodyDef
        hanging <- Body.create w bd{type_ = DynamicBody, position = Vec2 0 8}
        sd <- defaultShapeDef
        _ <- Shape.createCircle hanging sd (Circle vec2Zero 0.25)
        djd <- defaultDistanceJointDef
        let
          base = djd.base
          def =
            djd
              { base =
                  base{bodyIdA = anchor, bodyIdB = hanging}
              , length = 2
              }
        j <- DistanceJoint.create w def
        -- the hanging body loads the joint with ~mg newtons; any tiny
        -- threshold guarantees an event
        Joint.setForceThreshold j 0.01
        (evs, _) <- collectEvents 60 w $ \acc -> do
          es <- Events.jointEvents w
          let (e0, u) = acc
          pure (e0 <> es, u :: ())
        assertBool
          "a joint event names the loaded joint"
          (j `VS.elem` VS.map (.jointId) evs)
  ]

{- | Step the world @n@ times, folding the per-step event buffers into an
accumulator (events only survive until the next step, so they must be
collected inside the loop).
-}
collectEvents :: (Monoid acc) => Int -> WorldId -> (acc -> IO acc) -> IO acc
collectEvents n w gather = go n mempty
  where
    go 0 acc = pure acc
    go k acc = do
      World.step w (1 / 60) 4
      acc' <- gather acc
      go (k - 1) acc'

{- | Exercise the Polygon/Hull/ChainDef/ExplosionDef value APIs requested by
downstream (apecs-box2d): boxes, arbitrary hulls, chain terrain, explosions
and integer user data.
-}
polygonTests :: [TestTree]
polygonTests =
  [ testCase "makeBox round-trips and gives a unit box the right mass" $
      withWorld (Vec2 0 0) $ \w -> do
        box <- Collision.makeBox 0.5 0.5
        VS.length (box.vertices) @?= 4
        VS.length (box.normals) @?= 4
        roundTrip box >>= (@?= box)
        bd <- defaultBodyDef
        b <- Body.create w bd{type_ = DynamicBody}
        sd <- defaultShapeDef
        sh <- Shape.createPolygon b sd box
        Shape.getType sh >>= (@?= PolygonShape)
        -- a 1x1 box at density 1
        md <- Body.getMassData b
        approx 1 (md.mass)
  , testCase "computeHull and makePolygon build a triangle" $
      VS.unsafeWith (VS.fromList [Vec2 0 0, Vec2 1 0, Vec2 0 1]) $ \pts -> do
        hull <- Collision.computeHull pts 3
        VS.length (hull.points) @?= 3
        tri <- Collision.makePolygon hull 0
        VS.length (tri.vertices) @?= 3
        tri.radius @?= 0
  , testCase "a chain assembles from a point array" $
      withWorld (Vec2 0 (-10)) $ \w -> do
        gd <- defaultBodyDef
        ground <- Body.create w gd
        cd <- defaultChainDef
        let points = VS.fromList [Vec2 (-6) 2, Vec2 (-4) 0, Vec2 0 0, Vec2 4 0, Vec2 6 2]
        c <- VS.unsafeWith points $ \pts ->
          Chain.create ground cd{Shape.points = pts, Shape.count = fromIntegral (VS.length points)}
        Chain.isValid c >>= (@?= True)
        n <- Chain.getSegmentCount c
        assertBool ("chain has segments, n = " <> show n) (n > 0)
        Chain.destroy c
  , testCase "an explosion pushes a nearby body away" $
      withWorld (Vec2 0 0) $ \w -> do
        b <- dynamicCircle w (Vec2 1 0) 0.5
        ed <- defaultExplosionDef
        World.explode
          w
          ed
            { position = Vec2 0 0
            , radius = 2
            , impulsePerLength = 5
            }
        Vec2 vx _ <- Body.getLinearVelocity b
        assertBool ("pushed away from the blast, vx = " <> show vx) (vx > 0)
  , testCase "user indices round-trip through body, shape and joint slots" $
      withWorld (Vec2 0 0) $ \w -> do
        bd <- defaultBodyDef
        b <- Body.create w bd
        sd <- defaultShapeDef
        sh <- Shape.createCircle b sd (Circle vec2Zero 0.5)
        UD.setUserIndex b 42
        UD.getUserIndex b >>= (@?= 42)
        UD.setUserIndex sh maxBound
        UD.getUserIndex sh >>= (@?= maxBound)
        -- negative ids survive the pointer pun
        UD.setUserIndex b (-7)
        UD.getUserIndex b >>= (@?= (-7))
  ]

-- | A static body carrying a circle at the given position.
staticCircle :: WorldId -> Pos -> Float -> IO ShapeId
staticCircle w position radius = do
  bd <- defaultBodyDef
  b <- Body.create w bd{Body.position = position}
  sd <- defaultShapeDef
  Shape.createCircle b sd (Circle vec2Zero radius)

{- | Exercise the query/cast structs upgraded to value APIs: 'RayResult',
'QueryFilter', 'MassData', 'RayCastInput' and 'CastOutput' cross the FFI
by value instead of as phantom pointers.
-}
queryTests :: [TestTree]
queryTests =
  [ testCase "the default query filter round-trips and accepts everything" $ do
      qf <- defaultQueryFilter
      roundTrip qf >>= (@?= qf)
      assertBool "mask accepts everything" (qf.maskBits /= 0)
  , testCase "castRayClosest reports the nearest shape, and misses cleanly" $
      withWorld (Vec2 0 0) $ \w -> do
        near <- staticCircle w (Vec2 2 0) 0.5
        _far <- staticCircle w (Vec2 4 0) 0.5
        qf <- defaultQueryFilter
        r <- World.castRayClosest w (Vec2 0 0) (Vec2 10 0) qf
        r.hit @?= 1
        r.shapeId @?= near
        -- the near circle's surface is at x = 1.5, 15% along the ray
        approx 0.15 (r.fraction)
        miss <- World.castRayClosest w (Vec2 0 0) (Vec2 (-10) 0) qf
        miss.hit @?= 0
  , testCase "body mass data matches the circle's area" $
      withWorld (Vec2 0 0) $ \w -> do
        b <- dynamicCircle w (Vec2 0 0) 0.5
        md <- Body.getMassData b
        -- density 1 * pi r^2
        approx (pi * 0.25) (md.mass)
  , testCase "a local-frame ray cast hits a circle" $ do
      out <- Collision.rayCastCircle (Circle vec2Zero 1) (RayCastInput (Vec2 (-3) 0) (Vec2 6 0) 1)
      out.hit @?= 1
      -- enters the unit circle at x = -1: a third of the way along (6, 0)
      approx (1 / 3) (out.fraction)
  ]

-- | The C custom-filter callback: @bool (b2ShapeId, b2ShapeId, void*)@.
type CustomFilterCb = ShapeId -> ShapeId -> Ptr () -> IO CBool

foreign import ccall "wrapper"
  mkCustomFilterCb :: CustomFilterCb -> IO (FunPtr CustomFilterCb)

{- | Exercise the raw-'FunPtr' callback passthrough: wrap a Haskell closure and
confirm the engine invokes it during the (safe) 'Box2D.World.step'.
-}
callbackTests :: [TestTree]
callbackTests =
  [ testCase "a custom-filter callback fires during the step" $
      withWorld (Vec2 0 0) $ \w -> do
        fired <- newIORef False
        cb <- mkCustomFilterCb $ \_ _ _ -> writeIORef fired True >> pure 1
        World.setCustomFilterCallback w (castFunPtr cb) nullPtr
        let overlappingCircle = do
              bd <- defaultBodyDef
              b <- Body.create w bd{type_ = DynamicBody}
              sd <- defaultShapeDef
              _ <- Shape.createCircle b sd{enableCustomFiltering = 1} (Circle vec2Zero 0.5)
              pure b
        _ <- overlappingCircle
        _ <- overlappingCircle
        replicateM_ 8 (World.step w (1 / 60) 4)
        -- unhook before freeing the wrapper so the world never dangles it
        World.setCustomFilterCallback w nullFunPtr nullPtr
        freeHaskellFunPtr cb
        readIORef fired >>= (@?= True)
  , testCase "overlap and cast-ray closures visit shapes (cast via the C trampoline)" $
      withWorld (Vec2 0 0) $ \w -> do
        _ <- staticCircle w (Vec2 2 0) 0.5
        _ <- staticCircle w (Vec2 4 0) 0.5
        _ <- staticCircle w (Vec2 40 0) 0.5
        qf <- defaultQueryFilter
        -- overlap: a plain scalar-args closure, no trampoline needed
        seen <- newIORef (0 :: Int)
        _ <- CB.withOverlapResultFcn (\_ -> modifyIORef' seen (+ 1) >> pure True) $ \fcn ctx ->
          World.overlapAABB w (Vec2 0 0) (AABB (Vec2 0 (-1)) (Vec2 5 1)) qf fcn ctx
        readIORef seen >>= (@?= 2)
        -- cast ray: the by-value point/normal cross through the trampoline
        hitsRef <- newIORef []
        _ <-
          CB.withCastResultFcn
            (\sid point normal frac -> modifyIORef' hitsRef ((sid, point, normal, frac) :) >> pure 1)
            (\fcn ctx -> World.castRay w (Vec2 0 0) (Vec2 10 0) qf fcn ctx)
        hits <- readIORef hitsRef
        length hits @?= 2
        let fracs = map (\(_, _, _, f) -> f) hits
        -- surfaces at x = 1.5 and x = 3.5 along a length-10 ray
        approx 0.15 (minimum fracs)
        approx 0.35 (maximum fracs)
        forM_ hits $ \(_, Vec2 px _, Vec2 nx _, _) -> do
          assertBool ("hit point on a surface, x = " <> show px) (px > 1 && px < 4)
          approx (-1) nx
  , testCase "a pre-solve gate disables contacts (via the C trampoline)" $
      withWorld (Vec2 0 (-10)) $ \w -> do
        gd <- defaultBodyDef
        ground <- Body.create w gd
        gsd <- defaultShapeDef
        _ <-
          Shape.createSegment
            ground
            gsd{enablePreSolveEvents = 1}
            (Segment (Vec2 (-10) 0) (Vec2 10 0))
        bd <- defaultBodyDef
        ball <- Body.create w bd{type_ = DynamicBody, position = Vec2 0 2}
        sd <- defaultShapeDef
        _ <-
          Shape.createCircle
            ball
            sd{enablePreSolveEvents = 1}
            (Circle vec2Zero 0.5)
        fired <- newIORef (0 :: Int)
        CB.withPreSolveFcn
          (\_ _ _ _ -> modifyIORef' fired (+ 1) >> pure False)
          $ \fcn ctx -> do
            World.setPreSolveCallback w fcn ctx
            replicateM_ 240 (World.step w (1 / 60) 4)
            World.setPreSolveCallback w nullFunPtr nullPtr
        readIORef fired >>= \n ->
          assertBool ("the gate fired, n = " <> show n) (n > 0)
        -- every contact was vetoed, so the ball fell through the ground
        y <- posY <$> Body.getPosition ball
        assertBool ("ball fell through, y = " <> show y) (y < 0)
  , testCase "friction and restitution mixing closures fire on contact" $
      withWorld (Vec2 0 (-10)) $ \w -> do
        fCount <- newIORef (0 :: Int)
        rCount <- newIORef (0 :: Int)
        CB.withFrictionCallback (\fa _ fb _ -> modifyIORef' fCount (+ 1) >> pure (max fa fb)) $ \ffcn ->
          CB.withRestitutionCallback (\ra _ rb _ -> modifyIORef' rCount (+ 1) >> pure (max ra rb)) $ \rfcn -> do
            World.setFrictionCallback w ffcn
            World.setRestitutionCallback w rfcn
            gd <- defaultBodyDef
            ground <- Body.create w gd
            gsd <- defaultShapeDef
            _ <- Shape.createSegment ground gsd (Segment (Vec2 (-10) 0) (Vec2 10 0))
            _ <- dynamicCircle w (Vec2 0 1) 0.5
            replicateM_ 60 (World.step w (1 / 60) 4)
            -- NULL resets the world to the default mixers before the wrappers die
            World.setFrictionCallback w nullFunPtr
            World.setRestitutionCallback w nullFunPtr
        readIORef fCount >>= \n ->
          assertBool ("friction mixer fired, n = " <> show n) (n > 0)
        readIORef rCount >>= \n ->
          assertBool ("restitution mixer fired, n = " <> show n) (n > 0)
  , testCase "a mover capsule gathers collision planes through the closure" $
      withWorld (Vec2 0 0) $ \w -> do
        _ <- staticCircle w (Vec2 0 0) 1
        qf <- defaultQueryFilter
        planes <- newIORef []
        CB.withPlaneResultFcn
          (\sid pr -> modifyIORef' planes ((sid, pr) :) >> pure True)
          (\fcn ctx -> World.collideMover w (Vec2 0 0) (Capsule (Vec2 1.2 0) (Vec2 1.2 0.5) 0.4) qf fcn ctx)
        ps <- readIORef planes
        assertBool "at least one plane gathered" (not (null ps))
        assertBool "a plane registered a hit" (any ((== 1) . (.hit) . snd) ps)
  , testCase "dynamic-tree query and ray-cast closures visit proxies" $
      allocaBytes dynamicTreeByteCount $ \tree -> do
        DynamicTree.create 16 tree
        p0 <- DynamicTree.createProxy tree (AABB (Vec2 0 0) (Vec2 1 1)) 1 42
        _ <- DynamicTree.createProxy tree (AABB (Vec2 3 0) (Vec2 4 1)) 1 43
        -- query: only the first box intersects the probe AABB
        seen <- newIORef []
        _ <- CB.withTreeQueryFcn (\pid ud -> modifyIORef' seen ((pid, ud) :) >> pure True) $ \fcn ctx ->
          DynamicTree.query tree (AABB (Vec2 (-0.5) 0.25) (Vec2 0.5 0.75)) maxBound fcn ctx
        readIORef seen >>= (@?= [(fromIntegral p0, 42)])
        -- a ray along y = 0.5 pierces both boxes
        hits <- newIORef (0 :: Int)
        _ <-
          CB.withTreeRayCastFcn
            ( \input _pid _ud -> do
                input.maxFraction @?= 1
                modifyIORef' hits (+ 1)
                pure 1
            )
            (\fcn ctx -> DynamicTree.rayCast tree (RayCastInput (Vec2 (-1) 0.5) (Vec2 6 0) 1) maxBound fcn ctx)
        readIORef hits >>= (@?= 2)
        DynamicTree.destroy tree
  , testCase "custom-filter closures survive concurrent hot-path invocation" $
      CB.withThreadPoolTaskSystem 4 $ \ts -> do
        total <- newIORef (0 :: Int)
        inFlight <- newIORef (0 :: Int)
        maxSeen <- newIORef (0 :: Int)
        -- track how many callback invocations overlap, and widen the window a
        -- little so genuine parallelism actually shows up
        let onFilter _ _ _ = do
              n <- atomicModifyIORef' inFlight (\x -> (x + 1, x + 1))
              atomicModifyIORef' maxSeen (\m -> (max m n, ()))
              spin 4000
              atomicModifyIORef' total (\x -> (x + 1, ()))
              atomicModifyIORef' inFlight (\x -> (x - 1, ()))
              pure True
        CB.withCustomFilterFcn onFilter $ \fcn -> do
          wd <- defaultWorldDef
          w <-
            World.create
              wd
                { gravity = Vec2 0 (-10)
                , enableSleep = 0
                , workerCount = fromIntegral ts.workerCount
                , enqueueTask = ts.enqueue
                , finishTask = ts.finish
                }
          World.setCustomFilterCallback w fcn nullPtr
          -- a static ground plus a 16x16 grid of custom-filtered circles: lots
          -- of broad-phase pairs churning through the parallel solver
          gd <- defaultBodyDef
          ground <- Body.create w gd
          gsd <- defaultShapeDef
          _ <- Shape.createSegment ground gsd (Segment (Vec2 (-40) 0) (Vec2 40 0))
          bd <- defaultBodyDef
          sd <- defaultShapeDef
          forM_ [0 .. 255 :: Int] $ \i -> do
            let
              col = fromIntegral (i `mod` 16)
              row = fromIntegral (i `div` 16)
              pos = Vec2 (col - 8) (1.5 + row * 1.1)
            b <- Body.create w bd{type_ = DynamicBody, position = pos}
            _ <- Shape.createCircle b sd{enableCustomFiltering = 1} (Circle vec2Zero 0.5)
            pure ()
          replicateM_ 300 (World.step w (1 / 60) 4)
          World.setCustomFilterCallback w nullFunPtr nullPtr
          World.isValid w >>= (@?= True)
          World.destroy w
        calls <- readIORef total
        peak <- readIORef maxSeen
        assertBool ("callback fired under load, calls = " <> show calls) (calls > 100)
        assertBool
          ("callback was invoked concurrently, peak overlap = " <> show peak)
          (peak >= 2)
  ]

-- | A tiny busy-wait that GHC will not optimise away, to widen a race window.
spin :: Int -> IO ()
spin = go
  where
    go 0 = pure ()
    go k = evaluate k >> go (k - 1)

moverTests :: [TestTree]
moverTests =
  [ testCase "makeProxy fills a peekable ShapeProxy and withShapeProxy pokes one back" $ do
      let points = VS.fromList [Vec2 0 0, Vec2 1 0, Vec2 0 1]
      proxy <- VS.unsafeWith points $ \pts -> Collision.makeProxy pts (VS.length points) 0.25
      proxy.points @?= points
      proxy.radius @?= 0.25
      roundTrip proxy >>= (@?= proxy)
      withShapeProxy points 0.25 $ \p -> peek p >>= (@?= proxy)
  , testCase "a begun contact exposes its manifold through Contact.getData" $
      withWorld (Vec2 0 (-10)) $ \w -> do
        gd <- defaultBodyDef
        ground <- Body.create w gd
        gsd <- defaultShapeDef
        _ <- Shape.createCircle ground gsd{enableContactEvents = 1} (Circle vec2Zero 5)
        bd <- defaultBodyDef
        ball <- Body.create w bd{type_ = DynamicBody, position = Vec2 0 5.6}
        sd <- defaultShapeDef
        bshape <- Shape.createCircle ball sd{enableContactEvents = 1} (Circle vec2Zero 0.5)
        let loop 0 = assertFailure "no contact begin event within 120 steps"
            loop n = do
              World.step w (1 / 60) 4
              evs <- Events.contactBeginTouchEvents w
              if VS.null evs then loop (n - 1 :: Int) else pure (VS.head evs)
        ev <- loop 120
        let cid = ev.contactId
        Contact.isValid cid >>= (@?= True)
        cd <- Contact.getData cid
        assertBool
          "the contact involves the ball shape"
          (cd.shapeIdA == bshape || cd.shapeIdB == bshape)
        let m = cd.manifold
        assertBool "the manifold has a contact point" (not (VS.null (m.points)))
        let Vec2 _ ny = m.normal
        assertBool ("the contact normal is vertical, " <> show (m.normal)) (abs ny > 0.9)
  , testCase "solvePlanes pushes a mover out and clipVector kills the inward velocity" $ do
      let plane = CollisionPlane (Plane (Vec2 0 1) 0) (1 / 0) 0 1
      (delta, planes', iters) <- Mover.solvePlanes (Vec2 0 (-1)) (VS.singleton plane)
      let Vec2 _ dy = delta
      assertBool ("the mover ends up at the plane, delta = " <> show delta) (abs dy < 0.01)
      assertBool ("the solver reports iterations, " <> show iters) (iters >= 1)
      assertBool "the plane accumulated push" ((VS.head planes').push > 0)
      clipped <- Mover.clipVector (Vec2 3 (-5)) planes'
      clipped @?= Vec2 3 0
  , testCase "chain contact and hit events toggle across all segments" $
      withWorld (Vec2 0 (-10)) $ \w -> do
        gd <- defaultBodyDef
        ground <- Body.create w gd
        cd <- defaultChainDef
        let points = VS.fromList [Vec2 (-6) 2, Vec2 (-4) 0, Vec2 4 0, Vec2 6 2]
        c <- VS.unsafeWith points $ \pts ->
          Chain.create ground cd{Shape.points = pts, Shape.count = fromIntegral (VS.length points)}
        n <- Chain.getSegmentCount c
        segments <- allocaArray n $ \buf -> do
          got <- Chain.getSegments c buf n
          peekArray got buf
        assertBool "the chain has segments" (not (null segments))
        mapM_ (\s -> Shape.areContactEventsEnabled s >>= (@?= False)) segments
        Chain.enableContactEvents c True
        Chain.enableHitEvents c True
        mapM_ (\s -> Shape.areContactEventsEnabled s >>= (@?= True)) segments
        mapM_ (\s -> Shape.areHitEventsEnabled s >>= (@?= True)) segments
  , testCase "the default length scale is one unit per meter" $
      getLengthUnitsPerMeter >>= (@?= 1)
  , testCase "the pure vector helpers follow the engine conventions" $ do
      vec2Add (Vec2 1 2) (Vec2 3 4) @?= Vec2 4 6
      vec2MulSub (Vec2 1 1) 2 (Vec2 0 1) @?= Vec2 1 (-1)
      vec2Cross (Vec2 1 0) (Vec2 0 1) @?= 1
      vec2Normalize (Vec2 3 4) @?= Vec2 0.6 0.8
      vec2Normalize vec2Zero @?= vec2Zero
      rotateVector rotIdentity (Vec2 5 6) @?= Vec2 5 6
      invRotateVector (rotMul rotIdentity (Rot 0 1)) (rotateVector (Rot 0 1) (Vec2 5 6)) @?= Vec2 5 6
      planeSeparation (Plane (Vec2 0 1) 2) (Vec2 0 5) @?= 3
  ]
