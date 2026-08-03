{-# LANGUAGE FunctionalDependencies #-}
{-# LANGUAGE LambdaCase #-}
{-# LANGUAGE PatternSynonyms #-}
{-# LANGUAGE TemplateHaskell #-}

module Main where

import Box2D.Body (BodyDef (..), defaultBodyDef, pattern DynamicBody)
import Box2D.Body qualified as Body
import Box2D.Geometry (Capsule (..), Circle (..), Segment (..))
import Box2D.Id (BodyId, ShapeId, WorldId)
import Box2D.MathTypes
import Box2D.Shape (defaultShapeDef)
import Box2D.Shape qualified as Shape
import Box2D.Tags (DebugDraw)
import Box2D.World (WorldDef (..), defaultWorldDef)
import Box2D.World qualified as World
import Control.Lens hiding (universe)
import Linear
import Linear.V2
import Raylib.Core
import Raylib.Core.Shapes
import Raylib.Core.Text (drawText)
import Raylib.Types (Camera2D (Camera2D))
import Raylib.Types.Core
import Raylib.Util
import Raylib.Util.Colors
import Relude

fi :: forall a b. (Integral a, Num b) => a -> b
fi = fromIntegral

vtv :: Iso' Vec2 (V2 Float)
vtv = iso toV2 toVec2
  where
    toV2 (Vec2 x y) = V2 x y
    toVec2 (V2 x y) = Vec2 x y

data Player = Player
  { _playerVelocity :: V2 Float
  , _playerPosition :: V2 Float
  , _playerBodyID :: BodyId
  , _playerShapeID :: ShapeId
  }
  deriving stock (Show)

data GaTarget = GaTarget
  { _gaTargetVisible :: Bool
  , _gaTargetPosition :: V2 Float
  }
  deriving stock (Show)

data GaPhase
  = GaReady
  | GaDashing (V2 Float)
  | GaArrived Float
  deriving stock (Show)

data World = World
  { _physicsWorldID :: WorldId
  , _worldPlayer :: Player
  , _worldWindowResources :: WindowResources
  , _worldGaTargets :: [GaTarget]
  , _worldGaPhase :: GaPhase
  , _worldGaCooldown :: Float
  , _worldSelectedGaTarget :: Maybe (V2 Float)
  , _worldGaDashDebug :: Maybe (V2 Float, V2 Float)
  , _worldGaJumpDebug :: Maybe (V2 Float, V2 Float, Float)
  }

data Action = MoveLeft | MoveRight | Jump | GaStart
  deriving stock (Eq, Show, Enum, Bounded)

data Trigger = OnDown | OnPressed | OnReleased

$(makeFields ''Player)
$(makeFields ''GaTarget)
$(makeFields ''World)

windowWidth, windowHeight :: Int
windowWidth = 1920
windowHeight = 1080

playerHeight, gaLockonRange :: Float
playerHeight = 80
gaLockonRange = 120

gravityAccel, moveAccel, frictionDecel :: Float
gravityAccel = 10
moveAccel = 1500
frictionDecel = 700

gaCooldownTime, gaJumpCooldownPenalty, gaDashSpeed, gaArrivalThreshold, gaArrivedDuration, gaJumpImpulse, gaJumpDebugDuration :: Float
gaCooldownTime = 1.5
gaJumpCooldownPenalty = 0
gaDashSpeed = 700
gaArrivalThreshold = 40
gaArrivedDuration = 0.3
gaJumpImpulse = 2000
gaJumpDebugDuration = 0.5

checkAction :: Action -> IO Bool
checkAction a = case keyBinding a of
  (key, OnDown) -> isKeyDown key
  (key, OnPressed) -> isKeyPressed key
  (key, OnReleased) -> isKeyReleased key
  where
    keyBinding :: Action -> (KeyboardKey, Trigger)
    keyBinding MoveLeft = (KeyA, OnDown)
    keyBinding MoveRight = (KeyD, OnDown)
    keyBinding Jump = (KeySpace, OnDown)
    keyBinding GaStart = (KeyLeftShift, OnDown)

whenReady :: State World () -> State World ()
whenReady action =
  use gaPhase >>= \case
    GaReady -> action
    _ -> pass

-- | mouseWorld is only needed for the Jump-during-GA cancel.
applyAction :: Float -> V2 Float -> Action -> State World ()
applyAction dt _ MoveLeft = whenReady $ player . velocity . _x -= moveAccel * dt
applyAction dt _ MoveRight = whenReady $ player . velocity . _x += moveAccel * dt
applyAction _ mouseWorld Jump =
  use gaPhase >>= \case
    GaReady -> do
      grounded <- gets isOnGround
      when grounded $ player . velocity . _y += 400
    _ -> do
      ppos <- use (player . position)
      player . velocity .= gaJumpImpulse *^ normalize (mouseWorld - ppos)
      gaPhase .= GaReady
      gaCooldown += gaJumpCooldownPenalty
      gaJumpDebug .= Just (ppos, mouseWorld, gaJumpDebugDuration)
applyAction _ _ GaStart = do
  phase <- use gaPhase
  cooldownReady <- (<= 0) <$> use gaCooldown
  target <- use selectedGaTarget
  case (phase, cooldownReady, target) of
    (GaReady, True, Just t) -> do
      origin <- use (player . position)
      gaPhase .= GaDashing t
      gaCooldown .= gaCooldownTime
      gaDashDebug .= Just (origin, t)
    _ -> pass

applyVelocity :: Float -> State World ()
applyVelocity dt = do
  v <- use (player . velocity)
  player . position += dt *^ v

applyGravity :: Float -> State World ()
applyGravity dt = player . velocity . _y -= gravityAccel * dt

{- | Decelerates horizontal velocity at a constant rate, clamped so it
settles at exactly zero instead of overshooting into the opposite sign.
-}
applyFriction :: Float -> State World ()
applyFriction dt = player . velocity . _x %= decel
  where
    step = frictionDecel * dt
    decel vx
      | abs vx <= step = 0
      | otherwise = vx - signum vx * step

{- | Sets this frame's velocity based on the current GA phase, then
integrates position and resolves arrival/cooldown transitions.
-}
tick :: Float -> V2 Float -> [Action] -> State World ()
tick dt mouseWorld actions = do
  gaCooldown %= max 0 . subtract dt
  traverse_ (applyAction dt mouseWorld) actions

  use gaPhase >>= \case
    GaReady -> applyGravity dt
    GaArrived _ -> applyGravity dt
    GaDashing target -> do
      ppos <- use (player . position)
      player . velocity .= gaDashSpeed *^ normalize (target - ppos)

  applyVelocity dt
  applyFriction dt
  groundCollision
  resolveGaPhase dt
  tickGaJumpDebug dt

resolveGaPhase :: Float -> State World ()
resolveGaPhase dt = do
  phase <- use gaPhase
  ppos <- use (player . position)
  case phase of
    GaDashing target | inRange gaArrivalThreshold ppos target -> do
      gaPhase .= GaArrived gaArrivedDuration
    GaArrived remaining
      | remaining - dt <= 0 -> gaPhase .= GaReady
      | otherwise -> gaPhase .= GaArrived (remaining - dt)
    _ -> pass

tickGaJumpDebug :: Float -> State World ()
tickGaJumpDebug dt = gaJumpDebug %= (>>= expire)
  where
    expire (origin, aimedAt, remaining)
      | remaining - dt <= 0 = Nothing
      | otherwise = Just (origin, aimedAt, remaining - dt)

groundCollision :: State World ()
groundCollision = do
  y <- use (player . position . _y)
  when (y - playerHeight <= 0) $ do
    player . position . _y .= playerHeight
    player . velocity . _y .= 0

-- | Flip the y coordinate for raylib. I like -y = down.
toScreenWorld :: World -> World
toScreenWorld = player . position %~ toScreen >>> gaTargets . traverse . position %~ toScreen
  where
    toScreen (V2 x y) = V2 x (-y)

isOnGround :: World -> Bool
isOnGround w = w ^. player . position . _y - playerHeight <= 0

inRange :: Float -> V2 Float -> V2 Float -> Bool
inRange range p1 p2 = qd p1 p2 <= range ** 2

camera :: World -> Camera2D
camera w = Camera2D (V2 (fi windowWidth / 2) (fi windowHeight / 2)) (w ^. player . position) 0 1

gaStatusText :: GaPhase -> Float -> String
gaStatusText GaReady cd
  | cd > 0 = "GA cooldown: " <> show (round cd :: Int) <> "s"
  | otherwise = "GA ready"
gaStatusText (GaDashing _) _ = "GA dashing"
gaStatusText (GaArrived _) _ = "GA arrived"

startup :: IO World
startup = do
  dWorldDef <- defaultWorldDef
  dBodyDef <- defaultBodyDef
  dShapeDef <- defaultShapeDef

  physicsWorldID <- World.create dWorldDef{gravity = Vec2 0 (-gravityAccel), enableSleep = 0}
  groundBodyID <- Body.create physicsWorldID dBodyDef
  _groundID <- Shape.createSegment groundBodyID dShapeDef (Segment (Vec2 (-999) 0) (Vec2 999 0))
  body <- Body.create physicsWorldID dBodyDef{type_ = DynamicBody, position = Vec2 0 (-300)}
  shape <- Shape.createCapsule body dShapeDef (Capsule (Vec2 2 2) (Vec2 2 2) 20)

  window <- initWindow windowWidth windowHeight "raylib [core] example - basic window"

  let spacing :: Float = 400
      coord n start = map ((start +) . (* spacing)) [0 .. n - 1]
      gaTargets' = liftA2 V2 (coord 8 (-2000)) (coord 50 300) & map (GaTarget True)

  setTargetFPS 144
  pure $ World physicsWorldID (Player (V2 0 0) (V2 0 300) body shape) window gaTargets' GaReady 0 Nothing Nothing Nothing

mainLoop :: World -> IO World
mainLoop world = do
  showCursor
  actions <- filterM checkAction universe
  mousePosition <- getMousePosition
  dt <- getFrameTime
  Body.applyForceToCenter (world ^. player . bodyID) (Vec2 (-20) 200) True
  World.step world._physicsWorldID 60 4
  let playerBodyID = world ^. player . bodyID

  originPos <- view vtv <$> Body.getPosition playerBodyID
  playerTransform <- Body.getTransform playerBodyID
  let Transform preppos rot = traceShowId $ playerTransform
  let ppos = preppos ^. vtv

  let mouseWorld = getScreenToWorld2D mousePosition (camera (toScreenWorld world)) & _y %~ negate
      newWorld = execState (tick dt mouseWorld actions) world
      displayWorld = toScreenWorld newWorld
      mainCam = camera displayWorld
      worldToScreen p = getWorldToScreen2D p mainCam
      screenToWorld p = getScreenToWorld2D p mainCam
      -- ppos = displayWorld ^. player . position
      toDisplay = _y %~ negate -- mirrors toScreenWorld's flip, for points not stored in World
      drawPlayerSprite = do
        drawRectangleV ppos (V2 50 playerHeight) green
        drawText "PLAYER" (round $ ppos ^. _x - 17) (round $ ppos ^. _y - 20) 20 black

      drawGround = drawLineEx (V2 (-999) 0) (V2 999 0) 4 black

      drawGaDashDebug = case newWorld ^. gaPhase of
        GaDashing _ ->
          traverse_
            (\(origin, target) -> drawLineEx (toDisplay origin) (toDisplay target) 2 blue)
            (newWorld ^. gaDashDebug)
        _ -> pass

      drawGaJumpDebug =
        traverse_
          (\(origin, aimedAt, _) -> drawLineEx (toDisplay origin) (toDisplay aimedAt) 2 orange)
          (newWorld ^. gaJumpDebug)

      targetInRange =
        displayWorld ^. gaTargets
          & filter (inRange gaLockonRange mousePosition . screenPosition)
          & sortOn (distance mousePosition . screenPosition)
          & nonEmpty
          <&> head
        where
          screenPosition = worldToScreen . view position

  drawing $ do
    clearBackground gray
    drawCircleV mousePosition gaLockonRange pink
    drawCircleV (traceShowId originPos) 30 red
    drawText ("Player height: " <> show (round $ ppos ^. _y & negate :: Int)) 20 20 20 black
    drawText (gaStatusText (displayWorld ^. gaPhase) (displayWorld ^. gaCooldown)) 20 50 20 black
    mode2D mainCam $ do
      drawRectangle 0 0 200 200 red
      drawRectangle (div windowWidth 2) (div windowHeight 2) 200 200 black
      traverse_ (\gaTarget -> drawCircleV (gaTarget ^. position) 10 brown) (displayWorld ^. gaTargets)
      traverse_ (\t -> drawLineEx (screenToWorld mousePosition) (t ^. position) 4 darkBrown) targetInRange
      drawGaDashDebug
      drawGaJumpDebug
      drawGround
      drawPlayerSprite
      drawText "Basic raylib window" 30 40 18 black

  pure
    . flip execState newWorld
    $ selectedGaTarget
    .= (targetInRange <&> (view position >>> _y %~ negate))

shouldClose :: World -> IO Bool
shouldClose _ = windowShouldClose

teardown :: World -> IO ()
teardown = closeWindow . Just . (^. windowResources)

$(raylibApplication 'startup 'mainLoop 'shouldClose 'teardown)
