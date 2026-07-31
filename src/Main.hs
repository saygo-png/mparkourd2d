{-# LANGUAGE FunctionalDependencies #-}
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

data World = World
  { _worldPlayer :: Player
  , _worldWindowResources :: WindowResources
  , _worldGaTargets :: [GaTarget]
  , _worldGaActive :: Bool
  , _worldSelectedGaTarget :: Maybe (V2 Float)
  }

data Action
  = MoveLeft
  | MoveRight
  | Jump
  | GaStart
  | GaStop
  deriving stock (Eq, Show, Enum, Bounded)

-- | How an action's key should be sampled each frame.
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
    keyBinding GaStart = (KeyLeftShift, OnPressed)
    keyBinding GaStop = (KeyLeftShift, OnReleased)

applyAction :: Action -> State World ()
applyAction MoveLeft = player . velocity . _x -= 10
applyAction MoveRight = player . velocity . _x += 10
applyAction Jump = do
  grounded <- gets isOnGround
  if grounded then player . velocity . _y += 400 else pass
applyAction GaStart = gaActive .= True
applyAction GaStop = gaActive .= False

applyVelocity :: Float -> State World ()
applyVelocity dt = do
  v <- use (player . velocity)
  player . position += dt *^ v
  player . velocity . _x %= (* ((1 - friction) ** dt))

applyGravity :: Float -> State World ()
applyGravity dt = player . velocity . _y -= (gravity * 1000 * dt)

applyGA :: Float -> State World ()
applyGA dt = do
  ppos <- use (player . position)
  gaActive' <- use gaActive
  mTarget <- use selectedGaTarget
  whenJust (mTarget <* guard gaActive') $ \target ->
    player . velocity += (5000 * dt) *^ normalize (target - ppos)

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

startup :: IO World
startup = do
  window <- initWindow windowWidth windowHeight "raylib [core] example - basic window"
  let spacing :: Float = 400
      coord n start = map ((start +) . (* spacing)) [0 .. n - 1]
      gaTargets' = liftA2 V2 (coord 8 (-2000)) (coord 50 300) & map (GaTarget True)

  setTargetFPS 144
  return $ World (Player (V2 0 0) (V2 0 300)) window gaTargets' False Nothing

mainLoop :: World -> IO World
mainLoop world = do
  showCursor
  pressedActions <- filterM checkAction universe
  mousePosition <- getMousePosition
  dt <- getFrameTime

  let newWorld = flip execState world $ do
        applyGravity dt
        traverse_ applyAction pressedActions
        applyGA dt
        applyVelocity dt
        groundCollision

  let displayWorld = toScreenWorld newWorld
      mainCam = Camera2D (V2 (fi windowWidth / 2) (fi windowHeight / 2)) (displayWorld ^. player . position) 0 1
      _worldCam = Camera2D (V2 0 0) (V2 0 0) 0 1
      worldToScreen p = getWorldToScreen2D p mainCam
      screenToWorld p = getScreenToWorld2D p mainCam
      ppos = displayWorld ^. player . position

      drawPlayerSprite = do
        drawRectangleV ppos (V2 50 playerHeight) green
        drawText "PLAYER" (round $ ppos ^. _x - 17) (round $ ppos ^. _y - 20) 20 black

      drawGround = drawLineEx (V2 (-999) 0) (V2 999 0) 4 black

      targetInRange =
        displayWorld ^. gaTargets
          & traceShowId
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
    when (displayWorld ^. gaActive) (drawText "GA active" 20 50 20 black)
    mode2D mainCam $ do
      drawRectangle 0 0 200 200 red
      drawRectangle (div windowWidth 2) (div windowHeight 2) 200 200 black
      traverse_ (\gaTarget -> drawCircleV (gaTarget ^. position) 10 brown) (displayWorld ^. gaTargets)
      traverse_ (\t -> drawLineEx (screenToWorld mousePosition) (t ^. position) 4 darkBrown) targetInRange
      drawGround
      drawPlayerSprite
      drawText "Basic raylib window" 30 40 18 black

  pure . flip execState newWorld $ do
    selectedGaTarget .= (targetInRange <&> (view position >>> _y %~ negate))

shouldClose :: World -> IO Bool
shouldClose _ = windowShouldClose

teardown :: World -> IO ()
teardown = closeWindow . Just . (^. windowResources)

$(raylibApplication 'startup 'mainLoop 'shouldClose 'teardown)
