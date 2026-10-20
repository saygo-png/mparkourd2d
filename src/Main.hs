{-# LANGUAGE FunctionalDependencies #-}
{-# LANGUAGE LambdaCase #-}
{-# LANGUAGE TemplateHaskell #-}

module Main where

import Canvas
import Control.Lens hiding (Context, universe)
import GHC.Wasm.Prim (JSString, toJSString)
import Input
import Linear
import Physics (BodyId, BodyType (..), ShapeId, WorldId)
import Physics qualified
import Relude

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

gray, pink, red, green, brown, black :: JSString
gray = toJSString "rgb(130 130 130)"
pink = toJSString "rgb(255 109 194)"
red = toJSString "rgb(230 41 55)"
green = toJSString "rgb(0 228 48)"
brown = toJSString "rgb(127 106 79)"
black = toJSString "rgb(0 0 0)"

checkAction :: Input -> Action -> IO Bool
checkAction input a = case keyBinding a of
  (key, OnDown) -> isKeyDown input key
  (key, OnPressed) -> isKeyPressed input key
  (key, OnReleased) -> isKeyReleased input key
  where
    keyBinding :: Action -> (Text, Trigger)
    keyBinding MoveLeft = ("KeyA", OnDown)
    keyBinding MoveRight = ("KeyD", OnDown)
    keyBinding Jump = ("Space", OnDown)
    keyBinding GetPos = ("KeyP", OnDown)

applyAction :: Input -> World -> Action -> IO ()
applyAction _ w MoveLeft = Physics.applyForceToCenter (w ^. player . bodyID) (v2 (-3000) 0) True
applyAction _ w MoveRight = Physics.applyForceToCenter (w ^. player . bodyID) (v2 3000 0) True
applyAction _ w Jump = Physics.applyForceToCenter (w ^. player . bodyID) (v2 0 (-9000)) True
applyAction input _ GetPos = print =<< getMousePosition input

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

mainLoop :: Context -> Input -> Float -> World -> IO World
mainLoop ctx input dt world = do
  actions <- filterM (checkAction input) universe
  mousePosition <- getMousePosition input

  traverse_ (applyAction input world) actions
  Physics.step world._physicsWorldID (dt * 10) 4

  ppos <- flipY <$> Physics.getPosition (world ^. player . bodyID)

  let
    drawPlayerSprite = do
      fillCircle ctx green ppos 10
      fillText ctx black 20 (V2 (ppos ^. _x - 17) (ppos ^. _y - 20)) "PLAYER"

    drawGround = strokeLine ctx black 4 (V2 (-999) 1000) (V2 999 1000)

  fillRect ctx gray (V2 0 0) (fi <$> V2 windowWidth windowHeight)
  fillCircle ctx pink mousePosition 100
  fillCircle ctx red playerOrigin 30
  fillText ctx black 20 (V2 20 20) ("Player height: " <> show (round $ ppos ^. _y & negate :: Int))

  fillRect ctx black (fi <$> V2 (div windowWidth 2) (div windowHeight 2)) (V2 200 200)
  traverse_ (\gaTarget -> fillCircle ctx brown (gaTarget ^. position) 10) (world ^. gaTargets)
  drawGround
  drawPlayerSprite
  fillText ctx black 18 (V2 30 40) "Basic canvas window"

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
  ctx <- getContext
  input <- newInput
  let loop t world = do
        t' <- nextFrame
        -- Clamped so a backgrounded tab doesn't hand the physics a huge step.
        world' <- mainLoop ctx input (realToFrac (min 0.05 (t' - t))) world
        endFrame input
        loop t' world'
  join $ loop <$> nextFrame <*> startup

foreign export javascript "start" main :: IO ()
