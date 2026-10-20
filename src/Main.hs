{-# LANGUAGE FunctionalDependencies #-}
{-# LANGUAGE LambdaCase #-}
{-# LANGUAGE TemplateHaskell #-}

module Main where

import Control.Lens hiding (universe)
import Linear
import Relude
import Web.Canvas
import Web.Input
import Web.Physics (BodyId, BodyType (..), ShapeId, WorldId)
import Web.Physics qualified as Physics

fi :: forall a b. (Integral a, Num b) => a -> b
fi = fromIntegral

-- | Box2D is y-up, the screen is y-down.
flipY :: V2 Float -> V2 Float
flipY (V2 x y) = V2 x (-y)

v2 :: Float -> Float -> V2 Float
v2 x y = V2 x (-y)

data Player = Player
  { _playerBodyID :: BodyId
  , _playerShapeID :: ShapeId
  }

data GaTarget = GaTarget
  { _gaTargetVisible :: Bool
  , _gaTargetPosition :: V2 Float
  }
  deriving stock (Show)

data World = World
  { _physicsWorldID :: WorldId
  , _worldPlayer :: Player
  , _worldGaTargets :: [GaTarget]
  }

data Action = MoveLeft | MoveRight | Jump | GetPos
  deriving stock (Eq, Show, Enum, Bounded)

data Trigger = OnDown | OnPressed | OnReleased

$(makeFields ''Player)
$(makeFields ''GaTarget)
$(makeFields ''World)

windowWidth, windowHeight :: Int
windowWidth = 1920
windowHeight = 1080

playerHeight :: Float
playerHeight = 80

gravityAccel :: Float
gravityAccel = 10

playerOrigin :: V2 Float
playerOrigin = V2 585 500

checkAction :: Action -> IO Bool
checkAction a = case keyBinding a of
  (key, OnDown) -> isKeyDown key
  (key, OnPressed) -> isKeyPressed key
  (key, OnReleased) -> isKeyReleased key
  where
    keyBinding :: Action -> (Text, Trigger)
    keyBinding MoveLeft = ("KeyA", OnDown)
    keyBinding MoveRight = ("KeyD", OnDown)
    keyBinding Jump = ("Space", OnDown)
    keyBinding GetPos = ("KeyP", OnDown)

applyAction :: World -> Action -> IO ()
applyAction w MoveLeft = Physics.applyForceToCenter (w ^. player . bodyID) (v2 (-3000) 0) True
applyAction w MoveRight = Physics.applyForceToCenter (w ^. player . bodyID) (v2 3000 0) True
applyAction w Jump = Physics.applyForceToCenter (w ^. player . bodyID) (v2 0 (-9000)) True
applyAction _ GetPos = print =<< getMousePosition

startup :: IO World
startup = do
  physicsWorldID <- Physics.createWorld (V2 0 (-gravityAccel))
  groundBodyID <- Physics.createBody physicsWorldID StaticBody (V2 0 0)
  _groundID <- Physics.createSegment groundBodyID (v2 (-999) 1000) (v2 999 1000)
  body <- Physics.createBody physicsWorldID DynamicBody (flipY playerOrigin)
  shape <- Physics.createCircle body (v2 0 0) 10
  Physics.setRestitution shape 0.8

  let spacing :: Float = 400
      coord n start = map ((start +) . (* spacing)) [0 .. n - 1]
      gaTargets' = liftA2 V2 (coord 8 (-2000)) (coord 50 300) & map (GaTarget True)

  pure $ World physicsWorldID (Player body shape) gaTargets'

mainLoop :: Float -> World -> IO World
mainLoop dt world = do
  actions <- filterM checkAction universe
  mousePosition <- getMousePosition

  traverse_ (applyAction world) actions
  Physics.step world._physicsWorldID (dt * 10) 4

  ppos <- flipY <$> Physics.getPosition (world ^. player . bodyID)

  let
    drawPlayerSprite = do
      drawCircleV ppos 10 green
      drawText "PLAYER" (round $ ppos ^. _x - 17) (round $ ppos ^. _y - 20) 20 black

    drawGround = drawLineEx (V2 (-999) 1000) (V2 999 1000) 4 black

  clearBackground gray
  drawCircleV mousePosition 100 pink
  drawCircleV playerOrigin 30 red
  drawText ("Player height: " <> show (round $ ppos ^. _y & negate :: Int)) 20 20 20 black

  drawRectangle (div windowWidth 2) (div windowHeight 2) 200 200 black
  traverse_ (\gaTarget -> drawCircleV (gaTarget ^. position) 10 brown) (world ^. gaTargets)
  drawGround
  drawPlayerSprite
  drawText "Basic canvas window" 30 40 18 black

  pure world

foreign import javascript safe "new Promise(requestAnimationFrame)"
  js_nextFrame :: IO Double

-- | Waits for the browser's next frame and returns its timestamp in seconds.
nextFrame :: IO Double
nextFrame = (/ 1000) <$> (evaluateWHNF =<< js_nextFrame)

-- | Called from web/index.html once the wasm module is loaded.
main :: IO ()
main = do
  Physics.loadBox2D
  listenForInput
  let loop t world = do
        t' <- nextFrame
        -- Clamped so a backgrounded tab doesn't hand the physics a huge step.
        world' <- mainLoop (realToFrac (min 0.05 (t' - t))) world
        endFrame
        loop t' world'
  join $ loop <$> nextFrame <*> startup

foreign export javascript "start" main :: IO ()
