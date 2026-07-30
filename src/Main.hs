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

data GaTarget = GaTarget
  { _gaTargetVisible :: Bool
  , _gaTargetPosition :: V2 Float
  }

data World = World
  { _worldPlayer :: Player
  , _worldWindowResources :: WindowResources
  , _worldGaTargets :: [GaTarget]
  }

data Action
  = MoveLeft
  | MoveRight
  | Jump
  deriving stock (Eq, Show, Enum, Bounded)

$(makeFields ''Player)
$(makeFields ''GaTarget)
$(makeFields ''World)

windowWidth, windowHeight :: Int
windowWidth = 700
windowHeight = 700

friction, gravity, playerHeight, gaLockonRange :: Float
friction = 0.999
gravity = 2
playerHeight = 80
gaLockonRange = 200

keyBinding :: Action -> KeyboardKey
keyBinding MoveLeft = KeyA
keyBinding MoveRight = KeyD
keyBinding Jump = KeySpace

applyAction :: Action -> State World ()
applyAction MoveLeft = player . velocity . _x -= 10
applyAction MoveRight = player . velocity . _x += 10
applyAction Jump = do
  grounded <- gets isOnGround
  if grounded then player . velocity . _y += 400 else pass

applyVelocity :: Float -> State World ()
applyVelocity dt = do
  v <- use (player . velocity)
  player . position += dt *^ v
  player . velocity . _x %= (* ((1 - friction) ** dt))

applyGravity :: Float -> State World ()
applyGravity dt = player . velocity . _y -= (gravity * 1000 * dt)

groundCollision :: State World ()
groundCollision = do
  y <- use (player . position . _y)
  when (y - playerHeight <= 0) $ do
    player . position . _y .= playerHeight
    player . velocity . _y .= 0

-- | Flip the y coordinate for raylib. I like -y = down.
toScreenWorld :: World -> World
toScreenWorld w =
  w
    & player . position %~ toScreen
    & gaTargets . traverse . position %~ toScreen
  where
    toScreen (V2 x y) = V2 x (-y)

isOnGround :: World -> Bool
isOnGround w = w ^. player . position . _y - playerHeight <= 0

inRange :: Float -> V2 Float -> V2 Float -> Bool
inRange range p1 p2 = qd p1 p2 <= range ** 2

startup :: IO World
startup = do
  window <- initWindow windowWidth windowHeight "raylib [core] example - basic window"
  let gaTargets' = map (`V2` 300) [-2000, -1800 ..] & take 50 & map (GaTarget True)

  setTargetFPS 144
  return $ World (Player (V2 0 0) (V2 0 300)) window gaTargets'

mainLoop :: World -> IO World
mainLoop world = do
  showCursor
  pressedActions <- filterM (isKeyDown . keyBinding) universe
  mousePosition <- getMousePosition
  dt <- getFrameTime

  let newWorld = flip execState world $ do
        applyGravity dt
        traverse_ applyAction pressedActions
        applyVelocity dt
        groundCollision

  let rWorld = toScreenWorld newWorld
      mainCam = Camera2D (V2 (fi windowWidth / 2) (fi windowHeight / 2)) (rWorld ^. player . position) 0 1
      _worldCam = Camera2D (V2 0 0) (V2 0 0) 0 1
      worldToScreen p = getWorldToScreen2D p mainCam
      screenToWorld p = getScreenToWorld2D p mainCam
      ppos = rWorld ^. player . position

      drawPlayerSprite = do
        drawRectangleV ppos (V2 50 playerHeight) green
        drawText "PLAYER" (round $ ppos ^. _x - 17) (round $ ppos ^. _y - 20) 20 black

      drawGround = drawLineEx (V2 (-999) 0) (V2 999 0) 4 black

      targetsInRange = filter (\t -> inRange gaLockonRange mousePosition (t ^. position & worldToScreen)) (rWorld ^. gaTargets)

  drawing $ do
    clearBackground gray
    drawCircleV mousePosition gaLockonRange pink
    -- traverse_ (\t -> drawLineV mousePosition (t ^. position & worldToScreen) darkBrown) targetsInRange
    mode2D mainCam $ do
      drawRectangle 0 0 200 200 red
      drawRectangle (div windowWidth 2) (div windowHeight 2) 200 200 black
      traverse_ (\gaTarget -> drawCircleV (gaTarget ^. position) 10 brown) (rWorld ^. gaTargets)
      traverse_ (\t -> drawLineEx (screenToWorld mousePosition) (t ^. position) 4 darkBrown) targetsInRange
      drawGround
      drawPlayerSprite
      drawText "Basic raylib window" 30 40 18 black

  return newWorld

shouldClose :: World -> IO Bool
shouldClose _ = windowShouldClose

teardown :: World -> IO ()
teardown = closeWindow . Just . (^. windowResources)

$(raylibApplication 'startup 'mainLoop 'shouldClose 'teardown)
