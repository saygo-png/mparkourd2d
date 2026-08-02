{-# LANGUAGE FunctionalDependencies #-}
{-# LANGUAGE LambdaCase #-}
{-# LANGUAGE TemplateHaskell #-}

module Main where

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

data Player = Player
  { _playerVelocity :: V2 Float
  , _playerPosition :: V2 Float
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
  { _worldPlayer :: Player
  , _worldWindowResources :: WindowResources
  , _worldGaTargets :: [GaTarget]
  , _worldGaPhase :: GaPhase
  , _worldGaCooldown :: Float
  , _worldSelectedGaTarget :: Maybe (V2 Float)
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

friction, gravity, playerHeight, gaLockonRange :: Float
friction = 0.999
gravity = 2
playerHeight = 80
gaLockonRange = 120

gaCooldownTime, gaJumpCooldownPenalty, gaDashSpeed, gaArrivalThreshold, gaArrivedDuration, gaJumpImpulse :: Float
gaCooldownTime = 3
gaJumpCooldownPenalty = 0
gaDashSpeed = 700
gaArrivalThreshold = 40
gaArrivedDuration = 0.3
gaJumpImpulse = 2000

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
applyAction :: V2 Float -> Action -> State World ()
applyAction _ MoveLeft = whenReady $ player . velocity . _x -= 10
applyAction _ MoveRight = whenReady $ player . velocity . _x += 10
applyAction mouseWorld Jump =
  use gaPhase >>= \case
    GaReady -> do
      grounded <- gets isOnGround
      when grounded $ player . velocity . _y += 400
    _ -> do
      ppos <- use (player . position)
      player . velocity .= gaJumpImpulse *^ normalize (mouseWorld - ppos)
      gaPhase .= GaReady
      gaCooldown += gaJumpCooldownPenalty
applyAction _ GaStart = do
  phase <- use gaPhase
  cooldownReady <- (<= 0) <$> use gaCooldown
  target <- use selectedGaTarget
  case (phase, cooldownReady, target) of
    (GaReady, True, Just t) -> do
      gaPhase .= GaDashing t
      gaCooldown .= gaCooldownTime
    _ -> pass

applyVelocity :: Float -> State World ()
applyVelocity dt = do
  v <- use (player . velocity)
  player . position += dt *^ v
  player . velocity . _x %= (* ((1 - friction) ** dt))

applyGravity :: Float -> State World ()
applyGravity dt = player . velocity . _y -= (gravity * 1000 * dt)

{- | Sets this frame's velocity based on the current GA phase, then
integrates position and resolves arrival/cooldown transitions.
-}
tick :: Float -> V2 Float -> [Action] -> State World ()
tick dt mouseWorld actions = do
  gaCooldown %= max 0 . subtract dt
  traverse_ (applyAction mouseWorld) actions

  use gaPhase >>= \case
    GaReady -> applyGravity dt
    GaArrived _ -> applyGravity dt
    GaDashing target -> do
      ppos <- use (player . position)
      player . velocity .= gaDashSpeed *^ normalize (target - ppos)

  applyVelocity dt
  groundCollision
  resolveGaPhase dt

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
  window <- initWindow windowWidth windowHeight "raylib [core] example - basic window"
  let spacing :: Float = 400
      coord n start = map ((start +) . (* spacing)) [0 .. n - 1]
      gaTargets' = liftA2 V2 (coord 8 (-2000)) (coord 50 300) & map (GaTarget True)

  setTargetFPS 144
  pure $ World (Player (V2 0 0) (V2 0 300)) window gaTargets' GaReady 0 Nothing

mainLoop :: World -> IO World
mainLoop world = do
  showCursor
  actions <- filterM checkAction universe
  mousePosition <- getMousePosition
  dt <- getFrameTime

  let mouseWorld = getScreenToWorld2D mousePosition (camera (toScreenWorld world)) & _y %~ negate
      newWorld = execState (tick dt mouseWorld actions) world
      displayWorld = toScreenWorld newWorld
      mainCam = camera displayWorld
      worldToScreen p = getWorldToScreen2D p mainCam
      screenToWorld p = getScreenToWorld2D p mainCam
      ppos = displayWorld ^. player . position

      drawPlayerSprite = do
        drawRectangleV ppos (V2 50 playerHeight) green
        drawText "PLAYER" (round $ ppos ^. _x - 17) (round $ ppos ^. _y - 20) 20 black

      drawGround = drawLineEx (V2 (-999) 0) (V2 999 0) 4 black

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
    drawText ("Player height: " <> show (round $ ppos ^. _y & negate :: Int)) 20 20 20 black
    drawText (gaStatusText (displayWorld ^. gaPhase) (displayWorld ^. gaCooldown)) 20 50 20 black
    mode2D mainCam $ do
      drawRectangle 0 0 200 200 red
      drawRectangle (div windowWidth 2) (div windowHeight 2) 200 200 black
      traverse_ (\gaTarget -> drawCircleV (gaTarget ^. position) 10 brown) (displayWorld ^. gaTargets)
      traverse_ (\t -> drawLineEx (screenToWorld mousePosition) (t ^. position) 4 darkBrown) targetInRange
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
