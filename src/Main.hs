{-# LANGUAGE TemplateHaskell #-}

module Main where

import Control.Lens hiding (universe)
import Linear
import Raylib.Core
import Raylib.Core.Shapes
import Raylib.Core.Text (drawText)
import Raylib.Types (Camera2D (Camera2D))
import Raylib.Types.Core
import Raylib.Util
import Raylib.Util.Camera (cameraMove)
import Raylib.Util.Colors
import Relude

fi :: forall a b. (Integral a, Num b) => a -> b
fi = fromIntegral

data Player = Player
  { _velocity :: V2 Float
  , _position :: V2 Float
  }

data GaTarget = GaTarget
  { _visible :: Bool
  , _position :: V2 Float
  }

data World = World
  { _player :: Player
  , _windowResources :: WindowResources
  , _gaTargets :: [GaTarget]
  }

data Action
  = MoveLeft
  | MoveRight
  | Jump
  deriving stock (Eq, Show, Enum, Bounded)

$(makeLenses ''Player)
$(makeLenses ''World)

windowWidth, windowHeight :: Int
windowWidth = 700
windowHeight = 700

friction :: Float
friction = 0.999

gravity :: Float
gravity = 2

playerHeight :: Float
playerHeight = 80

keyBinding :: Action -> KeyboardKey
keyBinding MoveLeft = KeyA
keyBinding MoveRight = KeyD
keyBinding Jump = KeySpace

applyAction :: Action -> State World ()
applyAction MoveLeft = player . velocity . _x -= 10
applyAction MoveRight = player . velocity . _x += 10
applyAction Jump = do
  grounded <- gets isOnGround
  if grounded then player . velocity . _y += 1000 else pass

applyVelocity :: Float -> State World ()
applyVelocity dt = do
  v <- use (player . velocity)
  player . position += dt *^ v
  player . velocity %= (^* ((1 - friction) ** dt))

applyGravity :: Float -> State World ()
applyGravity dt = player . velocity . _y -= (gravity * 1000 * dt)

-- | Flip the y coordinate for raylib. I like -y = down.
toScreenWorld :: World -> World
toScreenWorld = player . position %~ toScreen
  where
    toScreen (V2 x y) = V2 x (-y)

isOnGround :: World -> Bool
isOnGround w = w ^. player . position . _y - playerHeight <= 0

startup :: IO World
startup = do
  window <- initWindow windowWidth windowHeight "raylib [core] example - basic window"
  setTargetFPS 144
  return
    $ World
      { _player = Player{_velocity = V2 0 0, _position = V2 0 300}
      , _windowResources = window
      , _gaTargets = []
      }

mainLoop :: World -> IO World
mainLoop world = do
  let grounded = isOnGround world
  showCursor
  pressedActions <- filterM (isKeyDown . keyBinding) universe
  mousePosition <- getMousePosition
  dt <- getFrameTime

  let newWorld = flip execState world $ do
        if not grounded then applyGravity dt else pass
        if grounded then player . velocity . _y .= 0 else pass
        traverse_ applyAction pressedActions
        applyVelocity dt

  let rWorld = toScreenWorld newWorld
      mainCam = Camera2D (V2 (fi windowWidth / 2) (fi windowHeight / 2)) rWorld._player._position 0 1
      _worldCam = Camera2D (V2 0 0) (V2 0 0) 0 1
      ppos = rWorld ^. player . position
      playerSprite = do
        drawRectangleV ppos (V2 50 playerHeight) green
        drawText "PLAYER" (round $ ppos ^. _x - 17) (round $ ppos ^. _y - 20) 20 black
      ground = drawLineV (V2 (-999) 0) (V2 999 0) black

  drawing $ do
    clearBackground gray
    mode2D mainCam $ do
      drawRectangle 0 0 200 200 red
      drawRectangle (div windowWidth 2) (div windowHeight 2) 200 200 black
      ground
      playerSprite
      drawText "Basic raylib window" 30 40 18 black
    drawCircleV mousePosition 20 red

  return newWorld

shouldClose :: World -> IO Bool
shouldClose _ = windowShouldClose

teardown :: World -> IO ()
teardown = closeWindow . Just . (._windowResources)

$(raylibApplication 'startup 'mainLoop 'shouldClose 'teardown)
