{-# LANGUAGE ForeignFunctionInterface #-}
{-# LANGUAGE PatternSynonyms #-}
{-# LANGUAGE GeneralizedNewtypeDeriving #-}

-- Produced by boxnd-gen; edit the generator, not this file.

module Box2D.Collision
  ( PlaneSolverResult (..)
  , CollisionPlane (..)
  , PlaneResult (..)
  , LocalManifoldPoint (..)
  , Manifold (..)
  , ManifoldPoint (..)
  , saveRecordingToFile
  , loadRecordingFromFile
  , validateReplay
  , isValidRay
  , makePolygon
  , makeOffsetPolygon
  , makeOffsetRoundedPolygon
  , makeSquare
  , makeSquareInto
  , makeBox
  , makeBoxInto
  , makeRoundedBox
  , makeRoundedBoxInto
  , makeOffsetBox
  , makeOffsetRoundedBox
  , transformPolygon
  , computeCircleMass
  , computeCapsuleMass
  , computePolygonMass
  , computeCircleAABB
  , computeCapsuleAABB
  , computePolygonAABB
  , computeSegmentAABB
  , pointInCircle
  , pointInCapsule
  , pointInPolygon
  , rayCastCircle
  , rayCastCapsule
  , rayCastSegment
  , rayCastPolygon
  , shapeCastCircle
  , shapeCastCapsule
  , shapeCastSegment
  , shapeCastPolygon
  , computeHull
  , computeHullInto
  , validateHull
  , segmentDistance
  , shapeDistance
  , shapeCast
  , shapeCastInto
  , makeProxy
  , makeProxyInto
  , makeOffsetProxy
  , getSweepTransform
  , timeOfImpact
  , collideCircles
  , collideCapsuleAndCircle
  , collideSegmentAndCircle
  , collidePolygonAndCircle
  , collideCapsules
  , collideSegmentAndCapsule
  , collidePolygonAndCapsule
  , collidePolygons
  , collideSegmentAndPolygon
  , collideChainSegmentAndCircle
  , collideChainSegmentAndCapsule
  , collideChainSegmentAndPolygon
  , solvePlanes
  , clipVector
  )
  where

import Foreign
import Foreign.C.Types (CBool (..), CInt (..))
import Foreign.C.String (CString)
import Data.Vector.Storable qualified as VS
import Box2D.Internal (copyVector, pokeCountedVector)
import Box2D.Distance (DistanceInput, DistanceOutput, SegmentDistanceResult, ShapeCastPairInput, Simplex, SimplexCache, Sweep, TOIInput, TOIOutput)
import Box2D.Geometry (Capsule, CastOutput, ChainSegment, Circle, Hull, MassData, Polygon, RayCastInput, Segment, ShapeCastInput, ShapeProxy)
import Box2D.MathTypes (AABB, Plane, Rot, Transform, Vec2, WorldTransform)
import Box2D.Tags (LocalManifold, Recording)

#include "box2d/box2d.h"


-- | Result returned by b2SolvePlanes
data PlaneSolverResult = PlaneSolverResult
  { translation :: Vec2
  , iterationCount :: CInt
  }
  deriving (Eq, Show)

instance Storable PlaneSolverResult where
  sizeOf _ = #{size b2PlaneSolverResult}
  alignment _ = #{alignment b2PlaneSolverResult}
  peek p =
    PlaneSolverResult
      <$> #{peek b2PlaneSolverResult, translation} p
      <*> #{peek b2PlaneSolverResult, iterationCount} p
  poke p (PlaneSolverResult f1 f2) = do
    #{poke b2PlaneSolverResult, translation} p f1
    #{poke b2PlaneSolverResult, iterationCount} p f2

-- | These are collision planes that can be fed to b2SolvePlanes. Normally
data CollisionPlane = CollisionPlane
  { plane :: Plane
  , pushLimit :: Float
  , push :: Float
  , clipVelocity :: CBool
  }
  deriving (Eq, Show)

instance Storable CollisionPlane where
  sizeOf _ = #{size b2CollisionPlane}
  alignment _ = #{alignment b2CollisionPlane}
  peek p =
    CollisionPlane
      <$> #{peek b2CollisionPlane, plane} p
      <*> #{peek b2CollisionPlane, pushLimit} p
      <*> #{peek b2CollisionPlane, push} p
      <*> #{peek b2CollisionPlane, clipVelocity} p
  poke p (CollisionPlane f1 f2 f3 f4) = do
    #{poke b2CollisionPlane, plane} p f1
    #{poke b2CollisionPlane, pushLimit} p f2
    #{poke b2CollisionPlane, push} p f3
    #{poke b2CollisionPlane, clipVelocity} p f4

-- | These are the collision planes returned from b2World_CollideMover.
data PlaneResult = PlaneResult
  { plane :: Plane
  , point :: Vec2
  , hit :: CBool
  }
  deriving (Eq, Show)

instance Storable PlaneResult where
  sizeOf _ = #{size b2PlaneResult}
  alignment _ = #{alignment b2PlaneResult}
  peek p =
    PlaneResult
      <$> #{peek b2PlaneResult, plane} p
      <*> #{peek b2PlaneResult, point} p
      <*> #{peek b2PlaneResult, hit} p
  poke p (PlaneResult f1 f2 f3) = do
    #{poke b2PlaneResult, plane} p f1
    #{poke b2PlaneResult, point} p f2
    #{poke b2PlaneResult, hit} p f3

-- | Contact manifold point in local coordinates (frame A).
data LocalManifoldPoint = LocalManifoldPoint
  { point :: Vec2
  , separation :: Float
  , id :: Word16
  }
  deriving (Eq, Show)

instance Storable LocalManifoldPoint where
  sizeOf _ = #{size b2LocalManifoldPoint}
  alignment _ = #{alignment b2LocalManifoldPoint}
  peek p =
    LocalManifoldPoint
      <$> #{peek b2LocalManifoldPoint, point} p
      <*> #{peek b2LocalManifoldPoint, separation} p
      <*> #{peek b2LocalManifoldPoint, id} p
  poke p (LocalManifoldPoint f1 f2 f3) = do
    #{poke b2LocalManifoldPoint, point} p f1
    #{poke b2LocalManifoldPoint, separation} p f2
    #{poke b2LocalManifoldPoint, id} p f3

-- | A contact manifold describes the contact points between colliding shapes.
data Manifold = Manifold
  { normal :: Vec2
  , rollingImpulse :: Float
  , points :: VS.Vector ManifoldPoint
  }
  deriving (Eq, Show)

instance Storable Manifold where
  sizeOf _ = #{size b2Manifold}
  alignment _ = #{alignment b2Manifold}
  peek p = do
    n <- #{peek b2Manifold, pointCount} p :: IO CInt
    Manifold
      <$> #{peek b2Manifold, normal} p
      <*> #{peek b2Manifold, rollingImpulse} p
      <*> copyVector (fromIntegral n) (#{ptr b2Manifold, points} p)
  poke p x = do
    #{poke b2Manifold, normal} p x.normal
    #{poke b2Manifold, rollingImpulse} p x.rollingImpulse
    pokeCountedVector (#{const 2}) (#{ptr b2Manifold, points} p) (#{poke b2Manifold, pointCount} p) x.points

-- | A manifold point is a contact point belonging to a contact manifold.
data ManifoldPoint = ManifoldPoint
  { anchorA :: Vec2
  , anchorB :: Vec2
  , separation :: Float
  , baseSeparation :: Float
  , normalImpulse :: Float
  , tangentImpulse :: Float
  , totalNormalImpulse :: Float
  , normalVelocity :: Float
  , id :: Word16
  , persisted :: CBool
  }
  deriving (Eq, Show)

instance Storable ManifoldPoint where
  sizeOf _ = #{size b2ManifoldPoint}
  alignment _ = #{alignment b2ManifoldPoint}
  peek p =
    ManifoldPoint
      <$> #{peek b2ManifoldPoint, anchorA} p
      <*> #{peek b2ManifoldPoint, anchorB} p
      <*> #{peek b2ManifoldPoint, separation} p
      <*> #{peek b2ManifoldPoint, baseSeparation} p
      <*> #{peek b2ManifoldPoint, normalImpulse} p
      <*> #{peek b2ManifoldPoint, tangentImpulse} p
      <*> #{peek b2ManifoldPoint, totalNormalImpulse} p
      <*> #{peek b2ManifoldPoint, normalVelocity} p
      <*> #{peek b2ManifoldPoint, id} p
      <*> #{peek b2ManifoldPoint, persisted} p
  poke p (ManifoldPoint f1 f2 f3 f4 f5 f6 f7 f8 f9 f10) = do
    #{poke b2ManifoldPoint, anchorA} p f1
    #{poke b2ManifoldPoint, anchorB} p f2
    #{poke b2ManifoldPoint, separation} p f3
    #{poke b2ManifoldPoint, baseSeparation} p f4
    #{poke b2ManifoldPoint, normalImpulse} p f5
    #{poke b2ManifoldPoint, tangentImpulse} p f6
    #{poke b2ManifoldPoint, totalNormalImpulse} p f7
    #{poke b2ManifoldPoint, normalVelocity} p f8
    #{poke b2ManifoldPoint, id} p f9
    #{poke b2ManifoldPoint, persisted} p f10


foreign import ccall unsafe "b2SaveRecordingToFile"
  c_b2SaveRecordingToFile :: Ptr Recording -> CString -> IO CBool

foreign import ccall unsafe "b2LoadRecordingFromFile"
  c_b2LoadRecordingFromFile :: CString -> IO (Ptr Recording)

foreign import ccall unsafe "b2ValidateReplay"
  c_b2ValidateReplay :: Ptr () -> CInt -> CInt -> IO CBool

foreign import ccall unsafe "b2IsValidRay"
  c_b2IsValidRay :: Ptr RayCastInput -> IO CBool

foreign import ccall unsafe "hsg_b2MakePolygon"
  c_b2MakePolygon :: Ptr Hull -> Float -> Ptr Polygon -> IO ()

foreign import ccall unsafe "hsg_b2MakeOffsetPolygon"
  c_b2MakeOffsetPolygon :: Ptr Hull -> Ptr Vec2 -> Ptr Rot -> Ptr Polygon -> IO ()

foreign import ccall unsafe "hsg_b2MakeOffsetRoundedPolygon"
  c_b2MakeOffsetRoundedPolygon :: Ptr Hull -> Ptr Vec2 -> Ptr Rot -> Float -> Ptr Polygon -> IO ()

foreign import ccall unsafe "hsg_b2MakeSquare"
  c_b2MakeSquare :: Float -> Ptr Polygon -> IO ()

foreign import ccall unsafe "hsg_b2MakeBox"
  c_b2MakeBox :: Float -> Float -> Ptr Polygon -> IO ()

foreign import ccall unsafe "hsg_b2MakeRoundedBox"
  c_b2MakeRoundedBox :: Float -> Float -> Float -> Ptr Polygon -> IO ()

foreign import ccall unsafe "hsg_b2MakeOffsetBox"
  c_b2MakeOffsetBox :: Float -> Float -> Ptr Vec2 -> Ptr Rot -> Ptr Polygon -> IO ()

foreign import ccall unsafe "hsg_b2MakeOffsetRoundedBox"
  c_b2MakeOffsetRoundedBox :: Float -> Float -> Ptr Vec2 -> Ptr Rot -> Float -> Ptr Polygon -> IO ()

foreign import ccall unsafe "hsg_b2TransformPolygon"
  c_b2TransformPolygon :: Ptr Transform -> Ptr Polygon -> Ptr Polygon -> IO ()

foreign import ccall unsafe "hsg_b2ComputeCircleMass"
  c_b2ComputeCircleMass :: Ptr Circle -> Float -> Ptr MassData -> IO ()

foreign import ccall unsafe "hsg_b2ComputeCapsuleMass"
  c_b2ComputeCapsuleMass :: Ptr Capsule -> Float -> Ptr MassData -> IO ()

foreign import ccall unsafe "hsg_b2ComputePolygonMass"
  c_b2ComputePolygonMass :: Ptr Polygon -> Float -> Ptr MassData -> IO ()

foreign import ccall unsafe "hsg_b2ComputeCircleAABB"
  c_b2ComputeCircleAABB :: Ptr Circle -> Ptr WorldTransform -> Ptr AABB -> IO ()

foreign import ccall unsafe "hsg_b2ComputeCapsuleAABB"
  c_b2ComputeCapsuleAABB :: Ptr Capsule -> Ptr WorldTransform -> Ptr AABB -> IO ()

foreign import ccall unsafe "hsg_b2ComputePolygonAABB"
  c_b2ComputePolygonAABB :: Ptr Polygon -> Ptr WorldTransform -> Ptr AABB -> IO ()

foreign import ccall unsafe "hsg_b2ComputeSegmentAABB"
  c_b2ComputeSegmentAABB :: Ptr Segment -> Ptr WorldTransform -> Ptr AABB -> IO ()

foreign import ccall unsafe "hsg_b2PointInCircle"
  c_b2PointInCircle :: Ptr Circle -> Ptr Vec2 -> IO CBool

foreign import ccall unsafe "hsg_b2PointInCapsule"
  c_b2PointInCapsule :: Ptr Capsule -> Ptr Vec2 -> IO CBool

foreign import ccall unsafe "hsg_b2PointInPolygon"
  c_b2PointInPolygon :: Ptr Polygon -> Ptr Vec2 -> IO CBool

foreign import ccall unsafe "hsg_b2RayCastCircle"
  c_b2RayCastCircle :: Ptr Circle -> Ptr RayCastInput -> Ptr CastOutput -> IO ()

foreign import ccall unsafe "hsg_b2RayCastCapsule"
  c_b2RayCastCapsule :: Ptr Capsule -> Ptr RayCastInput -> Ptr CastOutput -> IO ()

foreign import ccall unsafe "hsg_b2RayCastSegment"
  c_b2RayCastSegment :: Ptr Segment -> Ptr RayCastInput -> CBool -> Ptr CastOutput -> IO ()

foreign import ccall unsafe "hsg_b2RayCastPolygon"
  c_b2RayCastPolygon :: Ptr Polygon -> Ptr RayCastInput -> Ptr CastOutput -> IO ()

foreign import ccall unsafe "hsg_b2ShapeCastCircle"
  c_b2ShapeCastCircle :: Ptr Circle -> Ptr ShapeCastInput -> Ptr CastOutput -> IO ()

foreign import ccall unsafe "hsg_b2ShapeCastCapsule"
  c_b2ShapeCastCapsule :: Ptr Capsule -> Ptr ShapeCastInput -> Ptr CastOutput -> IO ()

foreign import ccall unsafe "hsg_b2ShapeCastSegment"
  c_b2ShapeCastSegment :: Ptr Segment -> Ptr ShapeCastInput -> Ptr CastOutput -> IO ()

foreign import ccall unsafe "hsg_b2ShapeCastPolygon"
  c_b2ShapeCastPolygon :: Ptr Polygon -> Ptr ShapeCastInput -> Ptr CastOutput -> IO ()

foreign import ccall unsafe "hsg_b2ComputeHull"
  c_b2ComputeHull :: Ptr Vec2 -> CInt -> Ptr Hull -> IO ()

foreign import ccall unsafe "b2ValidateHull"
  c_b2ValidateHull :: Ptr Hull -> IO CBool

foreign import ccall unsafe "hsg_b2SegmentDistance"
  c_b2SegmentDistance :: Ptr Vec2 -> Ptr Vec2 -> Ptr Vec2 -> Ptr Vec2 -> Ptr SegmentDistanceResult -> IO ()

foreign import ccall unsafe "hsg_b2ShapeDistance"
  c_b2ShapeDistance :: Ptr DistanceInput -> Ptr SimplexCache -> Ptr Simplex -> CInt -> Ptr DistanceOutput -> IO ()

foreign import ccall unsafe "hsg_b2ShapeCast"
  c_b2ShapeCast :: Ptr ShapeCastPairInput -> Ptr CastOutput -> IO ()

foreign import ccall unsafe "hsg_b2MakeProxy"
  c_b2MakeProxy :: Ptr Vec2 -> CInt -> Float -> Ptr ShapeProxy -> IO ()

foreign import ccall unsafe "hsg_b2MakeOffsetProxy"
  c_b2MakeOffsetProxy :: Ptr Vec2 -> CInt -> Float -> Ptr Vec2 -> Ptr Rot -> Ptr ShapeProxy -> IO ()

foreign import ccall unsafe "hsg_b2GetSweepTransform"
  c_b2GetSweepTransform :: Ptr Sweep -> Float -> Ptr Transform -> IO ()

foreign import ccall unsafe "hsg_b2TimeOfImpact"
  c_b2TimeOfImpact :: Ptr TOIInput -> Ptr TOIOutput -> IO ()

foreign import ccall unsafe "hsg_b2CollideCircles"
  c_b2CollideCircles :: Ptr Circle -> Ptr Circle -> Ptr Transform -> Ptr LocalManifold -> IO ()

foreign import ccall unsafe "hsg_b2CollideCapsuleAndCircle"
  c_b2CollideCapsuleAndCircle :: Ptr Capsule -> Ptr Circle -> Ptr Transform -> Ptr LocalManifold -> IO ()

foreign import ccall unsafe "hsg_b2CollideSegmentAndCircle"
  c_b2CollideSegmentAndCircle :: Ptr Segment -> Ptr Circle -> Ptr Transform -> Ptr LocalManifold -> IO ()

foreign import ccall unsafe "hsg_b2CollidePolygonAndCircle"
  c_b2CollidePolygonAndCircle :: Ptr Polygon -> Ptr Circle -> Ptr Transform -> Ptr LocalManifold -> IO ()

foreign import ccall unsafe "hsg_b2CollideCapsules"
  c_b2CollideCapsules :: Ptr Capsule -> Ptr Capsule -> Ptr Transform -> Ptr LocalManifold -> IO ()

foreign import ccall unsafe "hsg_b2CollideSegmentAndCapsule"
  c_b2CollideSegmentAndCapsule :: Ptr Segment -> Ptr Capsule -> Ptr Transform -> Ptr LocalManifold -> IO ()

foreign import ccall unsafe "hsg_b2CollidePolygonAndCapsule"
  c_b2CollidePolygonAndCapsule :: Ptr Polygon -> Ptr Capsule -> Ptr Transform -> Ptr LocalManifold -> IO ()

foreign import ccall unsafe "hsg_b2CollidePolygons"
  c_b2CollidePolygons :: Ptr Polygon -> Ptr Polygon -> Ptr Transform -> Ptr LocalManifold -> IO ()

foreign import ccall unsafe "hsg_b2CollideSegmentAndPolygon"
  c_b2CollideSegmentAndPolygon :: Ptr Segment -> Ptr Polygon -> Ptr Transform -> Ptr LocalManifold -> IO ()

foreign import ccall unsafe "hsg_b2CollideChainSegmentAndCircle"
  c_b2CollideChainSegmentAndCircle :: Ptr ChainSegment -> Ptr Circle -> Ptr Transform -> Ptr LocalManifold -> IO ()

foreign import ccall unsafe "hsg_b2CollideChainSegmentAndCapsule"
  c_b2CollideChainSegmentAndCapsule :: Ptr ChainSegment -> Ptr Capsule -> Ptr Transform -> Ptr SimplexCache -> Ptr LocalManifold -> IO ()

foreign import ccall unsafe "hsg_b2CollideChainSegmentAndPolygon"
  c_b2CollideChainSegmentAndPolygon :: Ptr ChainSegment -> Ptr Polygon -> Ptr Transform -> Ptr SimplexCache -> Ptr LocalManifold -> IO ()

foreign import ccall unsafe "hsg_b2SolvePlanes"
  c_b2SolvePlanes :: Ptr Vec2 -> Ptr CollisionPlane -> CInt -> Ptr PlaneSolverResult -> IO ()

foreign import ccall unsafe "hsg_b2ClipVector"
  c_b2ClipVector :: Ptr Vec2 -> Ptr CollisionPlane -> CInt -> Ptr Vec2 -> IO ()

{- | Save a recording buffer to a file. Convenience wrapper over your own file I\/O.

Returns: false if the file could not be written

Binds @b2SaveRecordingToFile@.
-}
saveRecordingToFile
  :: Ptr Recording
  -> CString
  -- ^ @path@
  -> IO Bool
saveRecordingToFile a0 a1 =
  toBool <$> (c_b2SaveRecordingToFile a0 a1)

{- | Load a recording from a file into a new recording buffer. Convenience wrapper over your own
file I\/O. Destroy the result with b2DestroyRecording.

Returns: NULL if the file is missing or unreadable

Binds @b2LoadRecordingFromFile@.
-}
loadRecordingFromFile
  :: CString
  -- ^ @path@
  -> IO (Ptr Recording)
loadRecordingFromFile a0 =
  c_b2LoadRecordingFromFile a0

{- | Replay a recording by re-running the engine and asserting recorded ids and state match.

Returns: true if replay completed without divergence, false on any mismatch

Binds @b2ValidateReplay@.
-}
validateReplay
  :: Ptr ()
  -- ^ @data@: Recorded bytes, e.g. from b2Recording_GetData or a loaded file
  -> Int
  -- ^ @size@: Number of recorded bytes
  -> Int
  -- ^ @workerCount@: Worker count to use for replay. 0 uses the serial single-worker fallback.
  -> IO Bool
validateReplay a0 a1 a2 =
  toBool <$> (c_b2ValidateReplay a0 (fromIntegral a1) (fromIntegral a2))

{- | Validate ray cast input data (NaN, etc)

Binds @b2IsValidRay@.
-}
isValidRay
  :: RayCastInput
  -> IO Bool
isValidRay a0 =
  with a0 $ \p0 ->
  toBool <$> (c_b2IsValidRay p0)

{- | Make a convex polygon from a convex hull. This will assert if the hull is not valid.
Warning: Do not manually fill in the hull data, it must come directly from b2ComputeHull

Binds @b2MakePolygon@.
-}
makePolygon
  :: Hull
  -> Float
  -- ^ @radius@
  -> IO Polygon
makePolygon a0 a1 =
  with a0 $ \p0 ->
  alloca $ \pOut -> c_b2MakePolygon p0 a1 pOut >> peek pOut

{- | Make an offset convex polygon from a convex hull. This will assert if the hull is not valid.
Warning: Do not manually fill in the hull data, it must come directly from b2ComputeHull

Binds @b2MakeOffsetPolygon@.
-}
makeOffsetPolygon
  :: Hull
  -> Vec2
  -- ^ @position@
  -> Rot
  -- ^ @rotation@
  -> IO Polygon
makeOffsetPolygon a0 a1 a2 =
  with a0 $ \p0 ->
  with a1 $ \p1 ->
  with a2 $ \p2 ->
  alloca $ \pOut -> c_b2MakeOffsetPolygon p0 p1 p2 pOut >> peek pOut

{- | Make an offset convex polygon from a convex hull. This will assert if the hull is not valid.
Warning: Do not manually fill in the hull data, it must come directly from b2ComputeHull

Binds @b2MakeOffsetRoundedPolygon@.
-}
makeOffsetRoundedPolygon
  :: Hull
  -> Vec2
  -- ^ @position@
  -> Rot
  -- ^ @rotation@
  -> Float
  -- ^ @radius@
  -> IO Polygon
makeOffsetRoundedPolygon a0 a1 a2 a3 =
  with a0 $ \p0 ->
  with a1 $ \p1 ->
  with a2 $ \p2 ->
  alloca $ \pOut -> c_b2MakeOffsetRoundedPolygon p0 p1 p2 a3 pOut >> peek pOut

{- | Make a square polygon, bypassing the need for a convex hull.

Binds @b2MakeSquare@.
-}
makeSquare
  :: Float
  -- ^ @halfWidth@: the half-width
  -> IO Polygon
makeSquare a0 =
  alloca $ \pOut -> c_b2MakeSquare a0 pOut >> peek pOut

-- | Like 'makeSquare', but the result is written into a caller-supplied buffer.
makeSquareInto
  :: Float
  -- ^ @halfWidth@: the half-width
  -> Ptr Polygon
  -- ^ Result buffer.
  -> IO ()
makeSquareInto a0 out =
  c_b2MakeSquare a0 out

{- | Make a box (rectangle) polygon, bypassing the need for a convex hull.

Binds @b2MakeBox@.
-}
makeBox
  :: Float
  -- ^ @halfWidth@: the half-width (x-axis)
  -> Float
  -- ^ @halfHeight@: the half-height (y-axis)
  -> IO Polygon
makeBox a0 a1 =
  alloca $ \pOut -> c_b2MakeBox a0 a1 pOut >> peek pOut

-- | Like 'makeBox', but the result is written into a caller-supplied buffer.
makeBoxInto
  :: Float
  -- ^ @halfWidth@: the half-width (x-axis)
  -> Float
  -- ^ @halfHeight@: the half-height (y-axis)
  -> Ptr Polygon
  -- ^ Result buffer.
  -> IO ()
makeBoxInto a0 a1 out =
  c_b2MakeBox a0 a1 out

{- | Make a rounded box, bypassing the need for a convex hull.

Binds @b2MakeRoundedBox@.
-}
makeRoundedBox
  :: Float
  -- ^ @halfWidth@: the half-width (x-axis)
  -> Float
  -- ^ @halfHeight@: the half-height (y-axis)
  -> Float
  -- ^ @radius@: the radius of the rounded extension
  -> IO Polygon
makeRoundedBox a0 a1 a2 =
  alloca $ \pOut -> c_b2MakeRoundedBox a0 a1 a2 pOut >> peek pOut

-- | Like 'makeRoundedBox', but the result is written into a caller-supplied buffer.
makeRoundedBoxInto
  :: Float
  -- ^ @halfWidth@: the half-width (x-axis)
  -> Float
  -- ^ @halfHeight@: the half-height (y-axis)
  -> Float
  -- ^ @radius@: the radius of the rounded extension
  -> Ptr Polygon
  -- ^ Result buffer.
  -> IO ()
makeRoundedBoxInto a0 a1 a2 out =
  c_b2MakeRoundedBox a0 a1 a2 out

{- | Make an offset box, bypassing the need for a convex hull.

Binds @b2MakeOffsetBox@.
-}
makeOffsetBox
  :: Float
  -- ^ @halfWidth@: the half-width (x-axis)
  -> Float
  -- ^ @halfHeight@: the half-height (y-axis)
  -> Vec2
  -- ^ @center@: the local center of the box
  -> Rot
  -- ^ @rotation@: the local rotation of the box
  -> IO Polygon
makeOffsetBox a0 a1 a2 a3 =
  with a2 $ \p2 ->
  with a3 $ \p3 ->
  alloca $ \pOut -> c_b2MakeOffsetBox a0 a1 p2 p3 pOut >> peek pOut

{- | Make an offset rounded box, bypassing the need for a convex hull.

Binds @b2MakeOffsetRoundedBox@.
-}
makeOffsetRoundedBox
  :: Float
  -- ^ @halfWidth@: the half-width (x-axis)
  -> Float
  -- ^ @halfHeight@: the half-height (y-axis)
  -> Vec2
  -- ^ @center@: the local center of the box
  -> Rot
  -- ^ @rotation@: the local rotation of the box
  -> Float
  -- ^ @radius@: the radius of the rounded extension
  -> IO Polygon
makeOffsetRoundedBox a0 a1 a2 a3 a4 =
  with a2 $ \p2 ->
  with a3 $ \p3 ->
  alloca $ \pOut -> c_b2MakeOffsetRoundedBox a0 a1 p2 p3 a4 pOut >> peek pOut

{- | Transform a polygon. This is useful for transferring a shape from one body to another.

Binds @b2TransformPolygon@.
-}
transformPolygon
  :: Transform
  -> Polygon
  -> IO Polygon
transformPolygon a0 a1 =
  with a0 $ \p0 ->
  with a1 $ \p1 ->
  alloca $ \pOut -> c_b2TransformPolygon p0 p1 pOut >> peek pOut

{- | Compute mass properties of a circle

Binds @b2ComputeCircleMass@.
-}
computeCircleMass
  :: Circle
  -- ^ @shape@
  -> Float
  -- ^ @density@
  -> IO MassData
computeCircleMass a0 a1 =
  with a0 $ \p0 ->
  alloca $ \pOut -> c_b2ComputeCircleMass p0 a1 pOut >> peek pOut

{- | Compute mass properties of a capsule

Binds @b2ComputeCapsuleMass@.
-}
computeCapsuleMass
  :: Capsule
  -- ^ @shape@
  -> Float
  -- ^ @density@
  -> IO MassData
computeCapsuleMass a0 a1 =
  with a0 $ \p0 ->
  alloca $ \pOut -> c_b2ComputeCapsuleMass p0 a1 pOut >> peek pOut

{- | Compute mass properties of a polygon

Binds @b2ComputePolygonMass@.
-}
computePolygonMass
  :: Polygon
  -- ^ @shape@
  -> Float
  -- ^ @density@
  -> IO MassData
computePolygonMass a0 a1 =
  with a0 $ \p0 ->
  alloca $ \pOut -> c_b2ComputePolygonMass p0 a1 pOut >> peek pOut

{- | Compute the bounding box of a transformed circle

Binds @b2ComputeCircleAABB@.
-}
computeCircleAABB
  :: Circle
  -- ^ @shape@
  -> WorldTransform
  -> IO AABB
computeCircleAABB a0 a1 =
  with a0 $ \p0 ->
  with a1 $ \p1 ->
  alloca $ \pOut -> c_b2ComputeCircleAABB p0 p1 pOut >> peek pOut

{- | Compute the bounding box of a transformed capsule

Binds @b2ComputeCapsuleAABB@.
-}
computeCapsuleAABB
  :: Capsule
  -- ^ @shape@
  -> WorldTransform
  -> IO AABB
computeCapsuleAABB a0 a1 =
  with a0 $ \p0 ->
  with a1 $ \p1 ->
  alloca $ \pOut -> c_b2ComputeCapsuleAABB p0 p1 pOut >> peek pOut

{- | Compute the bounding box of a transformed polygon

Binds @b2ComputePolygonAABB@.
-}
computePolygonAABB
  :: Polygon
  -- ^ @shape@
  -> WorldTransform
  -> IO AABB
computePolygonAABB a0 a1 =
  with a0 $ \p0 ->
  with a1 $ \p1 ->
  alloca $ \pOut -> c_b2ComputePolygonAABB p0 p1 pOut >> peek pOut

{- | Compute the bounding box of a transformed line segment

Binds @b2ComputeSegmentAABB@.
-}
computeSegmentAABB
  :: Segment
  -- ^ @shape@
  -> WorldTransform
  -> IO AABB
computeSegmentAABB a0 a1 =
  with a0 $ \p0 ->
  with a1 $ \p1 ->
  alloca $ \pOut -> c_b2ComputeSegmentAABB p0 p1 pOut >> peek pOut

{- | Test a point for overlap with a circle in local space

Binds @b2PointInCircle@.
-}
pointInCircle
  :: Circle
  -- ^ @shape@
  -> Vec2
  -- ^ @point@
  -> IO Bool
pointInCircle a0 a1 =
  with a0 $ \p0 ->
  with a1 $ \p1 ->
  toBool <$> (c_b2PointInCircle p0 p1)

{- | Test a point for overlap with a capsule in local space

Binds @b2PointInCapsule@.
-}
pointInCapsule
  :: Capsule
  -- ^ @shape@
  -> Vec2
  -- ^ @point@
  -> IO Bool
pointInCapsule a0 a1 =
  with a0 $ \p0 ->
  with a1 $ \p1 ->
  toBool <$> (c_b2PointInCapsule p0 p1)

{- | Test a point for overlap with a convex polygon in local space

Binds @b2PointInPolygon@.
-}
pointInPolygon
  :: Polygon
  -- ^ @shape@
  -> Vec2
  -- ^ @point@
  -> IO Bool
pointInPolygon a0 a1 =
  with a0 $ \p0 ->
  with a1 $ \p1 ->
  toBool <$> (c_b2PointInPolygon p0 p1)

{- | Ray cast versus circle shape in local space.

Binds @b2RayCastCircle@.
-}
rayCastCircle
  :: Circle
  -- ^ @shape@
  -> RayCastInput
  -> IO CastOutput
rayCastCircle a0 a1 =
  with a0 $ \p0 ->
  with a1 $ \p1 ->
  alloca $ \pOut -> c_b2RayCastCircle p0 p1 pOut >> peek pOut

{- | Ray cast versus capsule shape in local space.

Binds @b2RayCastCapsule@.
-}
rayCastCapsule
  :: Capsule
  -- ^ @shape@
  -> RayCastInput
  -> IO CastOutput
rayCastCapsule a0 a1 =
  with a0 $ \p0 ->
  with a1 $ \p1 ->
  alloca $ \pOut -> c_b2RayCastCapsule p0 p1 pOut >> peek pOut

{- | Ray cast versus segment shape in local space. Optionally treat the segment as one-sided with hits from
the left side being treated as a miss.

Binds @b2RayCastSegment@.
-}
rayCastSegment
  :: Segment
  -- ^ @shape@
  -> RayCastInput
  -> Bool
  -- ^ @oneSided@
  -> IO CastOutput
rayCastSegment a0 a1 a2 =
  with a0 $ \p0 ->
  with a1 $ \p1 ->
  alloca $ \pOut -> c_b2RayCastSegment p0 p1 (fromBool a2) pOut >> peek pOut

{- | Ray cast versus polygon shape in local space.

Binds @b2RayCastPolygon@.
-}
rayCastPolygon
  :: Polygon
  -- ^ @shape@
  -> RayCastInput
  -> IO CastOutput
rayCastPolygon a0 a1 =
  with a0 $ \p0 ->
  with a1 $ \p1 ->
  alloca $ \pOut -> c_b2RayCastPolygon p0 p1 pOut >> peek pOut

{- | Shape cast versus a circle.

Binds @b2ShapeCastCircle@.
-}
shapeCastCircle
  :: Circle
  -- ^ @shape@
  -> Ptr ShapeCastInput
  -> IO CastOutput
shapeCastCircle a0 a1 =
  with a0 $ \p0 ->
  alloca $ \pOut -> c_b2ShapeCastCircle p0 a1 pOut >> peek pOut

{- | Shape cast versus a capsule.

Binds @b2ShapeCastCapsule@.
-}
shapeCastCapsule
  :: Capsule
  -- ^ @shape@
  -> Ptr ShapeCastInput
  -> IO CastOutput
shapeCastCapsule a0 a1 =
  with a0 $ \p0 ->
  alloca $ \pOut -> c_b2ShapeCastCapsule p0 a1 pOut >> peek pOut

{- | Shape cast versus a line segment.

Binds @b2ShapeCastSegment@.
-}
shapeCastSegment
  :: Segment
  -- ^ @shape@
  -> Ptr ShapeCastInput
  -> IO CastOutput
shapeCastSegment a0 a1 =
  with a0 $ \p0 ->
  alloca $ \pOut -> c_b2ShapeCastSegment p0 a1 pOut >> peek pOut

{- | Shape cast versus a convex polygon.

Binds @b2ShapeCastPolygon@.
-}
shapeCastPolygon
  :: Polygon
  -- ^ @shape@
  -> Ptr ShapeCastInput
  -> IO CastOutput
shapeCastPolygon a0 a1 =
  with a0 $ \p0 ->
  alloca $ \pOut -> c_b2ShapeCastPolygon p0 a1 pOut >> peek pOut

{- | Compute the convex hull of a set of points. Returns an empty hull if it fails.
Some failure cases:
- all points very close together
- all points on a line
- less than 3 points
- more than B2_MAX_POLYGON_VERTICES points
This welds close points and removes collinear points.
Warning: Do not modify a hull once it has been computed

Binds @b2ComputeHull@.
-}
computeHull
  :: Ptr Vec2
  -- ^ @points@
  -> Int
  -- ^ @count@
  -> IO Hull
computeHull a0 a1 =
  alloca $ \pOut -> c_b2ComputeHull a0 (fromIntegral a1) pOut >> peek pOut

-- | Like 'computeHull', but the result is written into a caller-supplied buffer.
computeHullInto
  :: Ptr Vec2
  -- ^ @points@
  -> Int
  -- ^ @count@
  -> Ptr Hull
  -- ^ Result buffer.
  -> IO ()
computeHullInto a0 a1 out =
  c_b2ComputeHull a0 (fromIntegral a1) out

{- | This determines if a hull is valid. Checks for:
- convexity
- collinear points
This is expensive and should not be called at runtime.

Binds @b2ValidateHull@.
-}
validateHull
  :: Hull
  -> IO Bool
validateHull a0 =
  with a0 $ \p0 ->
  toBool <$> (c_b2ValidateHull p0)

{- | Compute the distance between two line segments, clamping at the end points if needed.

Binds @b2SegmentDistance@.
-}
segmentDistance
  :: Vec2
  -- ^ @p1@
  -> Vec2
  -- ^ @q1@
  -> Vec2
  -- ^ @p2@
  -> Vec2
  -- ^ @q2@
  -> Ptr SegmentDistanceResult
  -- ^ Result buffer.
  -> IO ()
segmentDistance a0 a1 a2 a3 out =
  with a0 $ \p0 ->
  with a1 $ \p1 ->
  with a2 $ \p2 ->
  with a3 $ \p3 ->
  c_b2SegmentDistance p0 p1 p2 p3 out

{- | Compute the closest points between two shapes represented as point clouds.
b2SimplexCache cache is input\/output. On the first call set b2SimplexCache.count to zero.
The underlying GJK algorithm may be debugged by passing in debug simplexes and capacity. You may pass in NULL and 0 for these.

Binds @b2ShapeDistance@.
-}
shapeDistance
  :: Ptr DistanceInput
  -> Ptr SimplexCache
  -> Ptr Simplex
  -- ^ @simplexes@
  -> Int
  -- ^ @simplexCapacity@
  -> Ptr DistanceOutput
  -- ^ Result buffer.
  -> IO ()
shapeDistance a0 a1 a2 a3 out =
  c_b2ShapeDistance a0 a1 a2 (fromIntegral a3) out

{- | Perform a linear shape cast of shape B moving and shape A fixed. Determines the hit point, normal, and translation fraction.
The query runs in frame A, so the hit point and normal are returned in frame A. Initially touching shapes are a miss.

Binds @b2ShapeCast@.
-}
shapeCast
  :: Ptr ShapeCastPairInput
  -> IO CastOutput
shapeCast a0 =
  alloca $ \pOut -> c_b2ShapeCast a0 pOut >> peek pOut

-- | Like 'shapeCast', but the result is written into a caller-supplied buffer.
shapeCastInto
  :: Ptr ShapeCastPairInput
  -> Ptr CastOutput
  -- ^ Result buffer.
  -> IO ()
shapeCastInto a0 out =
  c_b2ShapeCast a0 out

{- | Make a proxy for use in overlap, shape cast, and related functions. This is a deep copy of the points.

Binds @b2MakeProxy@.
-}
makeProxy
  :: Ptr Vec2
  -- ^ @points@
  -> Int
  -- ^ @count@
  -> Float
  -- ^ @radius@
  -> IO ShapeProxy
makeProxy a0 a1 a2 =
  alloca $ \pOut -> c_b2MakeProxy a0 (fromIntegral a1) a2 pOut >> peek pOut

-- | Like 'makeProxy', but the result is written into a caller-supplied buffer.
makeProxyInto
  :: Ptr Vec2
  -- ^ @points@
  -> Int
  -- ^ @count@
  -> Float
  -- ^ @radius@
  -> Ptr ShapeProxy
  -- ^ Result buffer.
  -> IO ()
makeProxyInto a0 a1 a2 out =
  c_b2MakeProxy a0 (fromIntegral a1) a2 out

{- | Make a proxy with a transform. This is a deep copy of the points.

Binds @b2MakeOffsetProxy@.
-}
makeOffsetProxy
  :: Ptr Vec2
  -- ^ @points@
  -> Int
  -- ^ @count@
  -> Float
  -- ^ @radius@
  -> Vec2
  -- ^ @position@
  -> Rot
  -- ^ @rotation@
  -> IO ShapeProxy
makeOffsetProxy a0 a1 a2 a3 a4 =
  with a3 $ \p3 ->
  with a4 $ \p4 ->
  alloca $ \pOut -> c_b2MakeOffsetProxy a0 (fromIntegral a1) a2 p3 p4 pOut >> peek pOut

{- | Evaluate the transform sweep at a specific time.

Binds @b2GetSweepTransform@.
-}
getSweepTransform
  :: Sweep
  -> Float
  -- ^ @time@
  -> IO Transform
getSweepTransform a0 a1 =
  with a0 $ \p0 ->
  alloca $ \pOut -> c_b2GetSweepTransform p0 a1 pOut >> peek pOut

{- | Compute the upper bound on time before two shapes penetrate. Time is represented as
a fraction between \[0,tMax\]. This uses a swept separating axis and may miss some intermediate,
non-tunneling collisions. If you change the time interval, you should call this function
again.

Binds @b2TimeOfImpact@.
-}
timeOfImpact
  :: Ptr TOIInput
  -> Ptr TOIOutput
  -- ^ Result buffer.
  -> IO ()
timeOfImpact a0 out =
  c_b2TimeOfImpact a0 out

{- | Compute the contact manifold between two circles

Binds @b2CollideCircles@.
-}
collideCircles
  :: Circle
  -- ^ @circleA@
  -> Circle
  -- ^ @circleB@
  -> Transform
  -- ^ @xf@
  -> Ptr LocalManifold
  -- ^ Result buffer.
  -> IO ()
collideCircles a0 a1 a2 out =
  with a0 $ \p0 ->
  with a1 $ \p1 ->
  with a2 $ \p2 ->
  c_b2CollideCircles p0 p1 p2 out

{- | Compute the contact manifold between a capsule and circle

Binds @b2CollideCapsuleAndCircle@.
-}
collideCapsuleAndCircle
  :: Capsule
  -- ^ @capsuleA@
  -> Circle
  -- ^ @circleB@
  -> Transform
  -- ^ @xf@
  -> Ptr LocalManifold
  -- ^ Result buffer.
  -> IO ()
collideCapsuleAndCircle a0 a1 a2 out =
  with a0 $ \p0 ->
  with a1 $ \p1 ->
  with a2 $ \p2 ->
  c_b2CollideCapsuleAndCircle p0 p1 p2 out

{- | Compute the contact manifold between an segment and a circle

Binds @b2CollideSegmentAndCircle@.
-}
collideSegmentAndCircle
  :: Segment
  -- ^ @segmentA@
  -> Circle
  -- ^ @circleB@
  -> Transform
  -- ^ @xf@
  -> Ptr LocalManifold
  -- ^ Result buffer.
  -> IO ()
collideSegmentAndCircle a0 a1 a2 out =
  with a0 $ \p0 ->
  with a1 $ \p1 ->
  with a2 $ \p2 ->
  c_b2CollideSegmentAndCircle p0 p1 p2 out

{- | Compute the contact manifold between a polygon and a circle

Binds @b2CollidePolygonAndCircle@.
-}
collidePolygonAndCircle
  :: Polygon
  -- ^ @polygonA@
  -> Circle
  -- ^ @circleB@
  -> Transform
  -- ^ @xf@
  -> Ptr LocalManifold
  -- ^ Result buffer.
  -> IO ()
collidePolygonAndCircle a0 a1 a2 out =
  with a0 $ \p0 ->
  with a1 $ \p1 ->
  with a2 $ \p2 ->
  c_b2CollidePolygonAndCircle p0 p1 p2 out

{- | Compute the contact manifold between a capsule and circle

Binds @b2CollideCapsules@.
-}
collideCapsules
  :: Capsule
  -- ^ @capsuleA@
  -> Capsule
  -- ^ @capsuleB@
  -> Transform
  -- ^ @xf@
  -> Ptr LocalManifold
  -- ^ Result buffer.
  -> IO ()
collideCapsules a0 a1 a2 out =
  with a0 $ \p0 ->
  with a1 $ \p1 ->
  with a2 $ \p2 ->
  c_b2CollideCapsules p0 p1 p2 out

{- | Compute the contact manifold between an segment and a capsule

Binds @b2CollideSegmentAndCapsule@.
-}
collideSegmentAndCapsule
  :: Segment
  -- ^ @segmentA@
  -> Capsule
  -- ^ @capsuleB@
  -> Transform
  -- ^ @xf@
  -> Ptr LocalManifold
  -- ^ Result buffer.
  -> IO ()
collideSegmentAndCapsule a0 a1 a2 out =
  with a0 $ \p0 ->
  with a1 $ \p1 ->
  with a2 $ \p2 ->
  c_b2CollideSegmentAndCapsule p0 p1 p2 out

{- | Compute the contact manifold between a polygon and capsule

Binds @b2CollidePolygonAndCapsule@.
-}
collidePolygonAndCapsule
  :: Polygon
  -- ^ @polygonA@
  -> Capsule
  -- ^ @capsuleB@
  -> Transform
  -- ^ @xf@
  -> Ptr LocalManifold
  -- ^ Result buffer.
  -> IO ()
collidePolygonAndCapsule a0 a1 a2 out =
  with a0 $ \p0 ->
  with a1 $ \p1 ->
  with a2 $ \p2 ->
  c_b2CollidePolygonAndCapsule p0 p1 p2 out

{- | Compute the contact manifold between two polygons

Binds @b2CollidePolygons@.
-}
collidePolygons
  :: Polygon
  -- ^ @polygonA@
  -> Polygon
  -- ^ @polygonB@
  -> Transform
  -- ^ @xf@
  -> Ptr LocalManifold
  -- ^ Result buffer.
  -> IO ()
collidePolygons a0 a1 a2 out =
  with a0 $ \p0 ->
  with a1 $ \p1 ->
  with a2 $ \p2 ->
  c_b2CollidePolygons p0 p1 p2 out

{- | Compute the contact manifold between an segment and a polygon

Binds @b2CollideSegmentAndPolygon@.
-}
collideSegmentAndPolygon
  :: Segment
  -- ^ @segmentA@
  -> Polygon
  -- ^ @polygonB@
  -> Transform
  -- ^ @xf@
  -> Ptr LocalManifold
  -- ^ Result buffer.
  -> IO ()
collideSegmentAndPolygon a0 a1 a2 out =
  with a0 $ \p0 ->
  with a1 $ \p1 ->
  with a2 $ \p2 ->
  c_b2CollideSegmentAndPolygon p0 p1 p2 out

{- | Compute the contact manifold between a chain segment and a circle

Binds @b2CollideChainSegmentAndCircle@.
-}
collideChainSegmentAndCircle
  :: Ptr ChainSegment
  -- ^ @segmentA@
  -> Circle
  -- ^ @circleB@
  -> Transform
  -- ^ @xf@
  -> Ptr LocalManifold
  -- ^ Result buffer.
  -> IO ()
collideChainSegmentAndCircle a0 a1 a2 out =
  with a1 $ \p1 ->
  with a2 $ \p2 ->
  c_b2CollideChainSegmentAndCircle a0 p1 p2 out

{- | Compute the contact manifold between a chain segment and a capsule

Binds @b2CollideChainSegmentAndCapsule@.
-}
collideChainSegmentAndCapsule
  :: Ptr ChainSegment
  -- ^ @segmentA@
  -> Capsule
  -- ^ @capsuleB@
  -> Transform
  -- ^ @xf@
  -> Ptr SimplexCache
  -> Ptr LocalManifold
  -- ^ Result buffer.
  -> IO ()
collideChainSegmentAndCapsule a0 a1 a2 a3 out =
  with a1 $ \p1 ->
  with a2 $ \p2 ->
  c_b2CollideChainSegmentAndCapsule a0 p1 p2 a3 out

{- | Compute the contact manifold between a chain segment and a rounded polygon

Binds @b2CollideChainSegmentAndPolygon@.
-}
collideChainSegmentAndPolygon
  :: Ptr ChainSegment
  -- ^ @segmentA@
  -> Polygon
  -- ^ @polygonB@
  -> Transform
  -- ^ @xf@
  -> Ptr SimplexCache
  -> Ptr LocalManifold
  -- ^ Result buffer.
  -> IO ()
collideChainSegmentAndPolygon a0 a1 a2 a3 out =
  with a1 $ \p1 ->
  with a2 $ \p2 ->
  c_b2CollideChainSegmentAndPolygon a0 p1 p2 a3 out

{- | Solves the position of a mover that satisfies the given collision planes.

Binds @b2SolvePlanes@.
-}
solvePlanes
  :: Vec2
  -- ^ @targetDelta@: the desired movement from the position used to generate the collision planes
  -> Ptr CollisionPlane
  -- ^ @planes@: the collision planes
  -> Int
  -- ^ @count@: the number of collision planes
  -> IO PlaneSolverResult
solvePlanes a0 a1 a2 =
  with a0 $ \p0 ->
  alloca $ \pOut -> c_b2SolvePlanes p0 a1 (fromIntegral a2) pOut >> peek pOut

{- | Clips the velocity against the given collision planes. Planes with zero push or clipVelocity
set to false are skipped.

Binds @b2ClipVector@.
-}
clipVector
  :: Vec2
  -- ^ @vector@
  -> Ptr CollisionPlane
  -- ^ @planes@
  -> Int
  -- ^ @count@
  -> IO Vec2
clipVector a0 a1 a2 =
  with a0 $ \p0 ->
  alloca $ \pOut -> c_b2ClipVector p0 a1 (fromIntegral a2) pOut >> peek pOut
