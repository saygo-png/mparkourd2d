{-# LANGUAGE FunctionalDependencies #-}
{-# LANGUAGE LambdaCase #-}
{-# LANGUAGE PatternSynonyms #-}
{-# LANGUAGE TemplateHaskell #-}

module Main where

import Box2D.Body (BodyDef (..), defaultBodyDef, pattern DynamicBody, pattern StaticBody)
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

toV2 :: Vec2 -> V2 Float
toV2 (Vec2 x y) = V2 x (-y)

toVec2 :: V2 Float -> Vec2
toVec2 (V2 x y) = Vec2 x (-y)

v2 :: Float -> Float -> Vec2
v2 x y = Vec2 x (-y)

data Player = Player
  { _playerBodyID :: BodyId
  , _playerShapeID :: ShapeId
  }
  deriving stock (Show)

data GaTarget = GaTarget
  { _gaTargetVisible :: Bool
  , _gaTargetPosition :: V2 Float
  }
  deriving stock (Show)

data World = World
  { _physicsWorldID :: WorldId
  , _worldPlayer :: Player
  , _worldWindowResources :: WindowResources
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
    keyBinding :: Action -> (KeyboardKey, Trigger)
    keyBinding MoveLeft = (KeyA, OnDown)
    keyBinding MoveRight = (KeyD, OnDown)
    keyBinding Jump = (KeySpace, OnDown)
    keyBinding GetPos = (KeyP, OnDown)

applyAction :: World -> Action -> IO ()
applyAction w MoveLeft = Body.applyForceToCenter (w ^. player . bodyID) (v2 (-3000) 0) True
applyAction w MoveRight = Body.applyForceToCenter (w ^. player . bodyID) (v2 3000 0) True
applyAction w Jump = Body.applyForceToCenter (w ^. player . bodyID) (v2 0 (-9000)) True
applyAction w GetPos = print =<< getMousePosition

startup :: IO World
startup = do
  dWorldDef <- defaultWorldDef
  dBodyDef <- defaultBodyDef
  dShapeDef <- defaultShapeDef

  physicsWorldID <- World.create dWorldDef{gravity = Vec2 0 (-gravityAccel), enableSleep = 0}
  groundBodyID <- Body.create physicsWorldID dBodyDef{type_ = StaticBody}
  _groundID <- Shape.createSegment groundBodyID dShapeDef $ Segment (v2 (-999) 1000) (v2 999 1000)
  body <- Body.create physicsWorldID dBodyDef{type_ = DynamicBody, position = toVec2 playerOrigin}
  shape <- Shape.createCircle body dShapeDef $ Circle (v2 0 0) 10
  Shape.setRestitution shape 0.8

  window <- initWindow windowWidth windowHeight "raylib [core] example - basic window"

  let spacing :: Float = 400
      coord n start = map ((start +) . (* spacing)) [0 .. n - 1]
      gaTargets' = liftA2 V2 (coord 8 (-2000)) (coord 50 300) & map (GaTarget True)

  setTargetFPS 144
  pure $ World physicsWorldID (Player body shape) window gaTargets'

mainLoop :: World -> IO World
mainLoop world = do
  showCursor
  actions <- filterM checkAction universe
  mousePosition <- getMousePosition
  dt <- getFrameTime

  traverse_ (applyAction world) actions
  World.step world._physicsWorldID (dt * 10) 4

  let playerBodyID = world ^. player . bodyID

  originPosB2 <- Body.getPosition playerBodyID
  playerTransform <- Body.getTransform playerBodyID
  let Transform preppos rot = traceShowId playerTransform
  let ppos = toV2 preppos

  let
    drawPlayerSprite = do
      drawCircleV (toV2 originPosB2) 10 green
      drawText "PLAYER" (round $ ppos ^. _x - 17) (round $ ppos ^. _y - 20) 20 black

    drawGround = drawLineEx (V2 (-999) 1000) (V2 999 1000) 4 black

  drawing $ do
    clearBackground gray
    drawCircleV mousePosition 100 pink
    drawCircleV playerOrigin 30 red
    drawText ("Player height: " <> show (round $ ppos ^. _y & negate :: Int)) 20 20 20 black

    drawRectangle (div windowWidth 2) (div windowHeight 2) 200 200 black
    traverse_ (\gaTarget -> drawCircleV (gaTarget ^. position) 10 brown) (world ^. gaTargets)
    drawGround
    drawPlayerSprite
    drawText "Basic raylib window" 30 40 18 black

  pure world

shouldClose :: World -> IO Bool
shouldClose _ = windowShouldClose

teardown :: World -> IO ()
teardown = closeWindow . Just . (^. windowResources)

$(raylibApplication 'startup 'mainLoop 'shouldClose 'teardown)
