{-# LANGUAGE CPP #-}
{-# LANGUAGE LambdaCase #-}
{-# LANGUAGE TemplateHaskell #-}

module Main (main) where

import Box2D qualified
import Control.Lens hiding (universe, view, (#))
import Data.IntSet qualified as IntSet
import Data.Map qualified as Map
import Linear (R2 (_y), V2 (..), (^*))
import Miso (App, Component (mount, subs), DecodeTarget (..), Decoder (..), Effect, Phase (BUBBLE), View, component, defaultEvents, io, on, startApp)
import Miso.CSS.Color (Color, rgb)
import Miso.Canvas (Canvas)
import Miso.Canvas qualified as Canvas
import Miso.Html.Property (height_, width_)
import Miso.JSON (withArray, withObject, (.:))
import Miso.String (ms)
import Miso.Subscription.Keyboard (keyboardSub)
import Miso.Subscription.RAF (rAFSub)
import Relude hiding (on)

-- | Box2D is y-up, the screen is y-down.
flipY :: V2 Double -> V2 Double
flipY (V2 x y) = V2 x (-y)

v2 :: Double -> Double -> V2 Double
v2 x y = V2 x (-y)

data Physics = Physics
  { _world :: Box2D.World
  , _player :: Box2D.Body
  }
  deriving stock (Eq)

data Model = Model
  { _physics :: Maybe Physics
  -- ^ Set up when the game starts.
  , _playerPosition :: V2 Double
  , _gaTargets :: [V2 Double]
  , _keysDown :: IntSet
  , _mousePosition :: V2 Double
  , _lastFrame :: Double
  -- ^ Timestamp of the last frame, in milliseconds.
  }
  deriving stock (Eq)

data Msg
  = Start
  | Started Physics
  | Frame Double
  | Stepped Double (V2 Double)
  | KeysDown IntSet
  | MouseMoved (V2 Double)

data Action = MoveLeft | MoveRight | Jump | GetPos
  deriving stock (Eq, Show, Enum, Bounded)

$(makeLenses ''Physics)
$(makeLenses ''Model)

-- | The key code that triggers each action while held.
keyBinding :: Action -> Int
keyBinding MoveLeft = 65 -- A
keyBinding MoveRight = 68 -- D
keyBinding Jump = 32 -- Space
keyBinding GetPos = 80 -- P

screenWidth, screenHeight :: Double
screenWidth = 1920
screenHeight = 1080

gravityAccel :: Double
gravityAccel = 10

playerOrigin :: V2 Double
playerOrigin = V2 585 500

gray, pink, red, green, brown, black :: Color
gray = rgb 130 130 130
pink = rgb 255 109 194
red = rgb 230 41 55
green = rgb 0 228 48
brown = rgb 127 106 79
black = rgb 0 0 0

initialModel :: Model
initialModel =
  Model
    { _physics = Nothing
    , _playerPosition = playerOrigin
    , _gaTargets = liftA2 V2 (coord 8 (-2000)) (coord 50 300)
    , _keysDown = mempty
    , _mousePosition = V2 0 0
    , _lastFrame = 0
    }
  where
    coord n start = map ((start +) . (* 400)) [0 .. n - 1]

startup :: IO Physics
startup = do
  world' <- Box2D.createWorld (V2 0 (-gravityAccel))
  ground <- Box2D.createBody world' Box2D.StaticBody (V2 0 0)
  _ <- Box2D.createSegment ground (v2 (-999) 1000) (v2 999 1000)
  body <- Box2D.createBody world' Box2D.DynamicBody (flipY playerOrigin)
  shape <- Box2D.createCircle body (v2 0 0) 10
  Box2D.setRestitution shape 0.8
  pure (Physics world' body)

applyAction :: Physics -> V2 Double -> Action -> IO ()
applyAction p _ MoveLeft = Box2D.applyForceToCenter (p ^. player) (v2 (-3000) 0)
applyAction p _ MoveRight = Box2D.applyForceToCenter (p ^. player) (v2 3000 0)
applyAction p _ Jump = Box2D.applyForceToCenter (p ^. player) (v2 0 (-9000))
applyAction _ mouse GetPos = print mouse

update :: Msg -> Effect () () Model Msg
update = \case
  Start -> io (Started <$> startup)
  Started p -> physics ?= p
  KeysDown keys -> keysDown .= keys
  MouseMoved position -> mousePosition .= position
  Frame time -> do
    model <- get
    for_ (model ^. physics) $ \p -> do
      -- In seconds, capped so a backgrounded tab doesn't cause one huge step.
      let dt = min 0.05 ((time - model ^. lastFrame) / 1000)
          actions = filter (\a -> IntSet.member (keyBinding a) (model ^. keysDown)) universe
      io $ do
        traverse_ (applyAction p (model ^. mousePosition)) actions
        Box2D.step (p ^. world) (dt * 10) 4
        Stepped time . flipY <$> Box2D.getPosition (p ^. player)
  Stepped time position -> do
    lastFrame .= time
    playerPosition .= position

view :: Model -> View () () Model Msg
view model =
  Canvas.canvas
    [ width_ (ms screenWidth)
    , height_ (ms screenHeight)
    , on "pointermove" canvasPointer (\position _ _ -> MouseMoved position)
    ]
    (\_ -> pure ())
    (\() -> draw model)

draw :: Model -> Canvas ()
draw model = do
  let ppos = model ^. playerPosition
  fillRect gray (V2 0 0) (V2 screenWidth screenHeight)
  fillCircle pink (model ^. mousePosition) 100
  fillCircle red playerOrigin 30
  fillText black 20 (V2 20 20) ("Player height: " <> show (round (negate (ppos ^. _y)) :: Int))
  fillRect black (V2 (screenWidth / 2) (screenHeight / 2)) (V2 200 200)
  for_ (model ^. gaTargets) $ \target -> fillCircle brown target 10
  strokeLine black 4 (V2 (-999) 1000) (V2 999 1000)
  fillCircle green ppos 10
  fillText black 20 (ppos - V2 17 20) "PLAYER"
  fillText black 18 (V2 30 40) "Basic canvas window"

{- | The pointer position in canvas pixels, from a pointer event on the canvas.
The page scales the canvas with CSS, so the event's offset is scaled back.
-}
canvasPointer :: Decoder (V2 Double)
canvasPointer =
  Decoder
    { decodeAt = DecodeTargets [[], ["target"]]
    , decoder = withArray "[event, canvas]" $ \case
        [event, canvas] -> do
          offset <- withObject "event" (\e -> V2 <$> e .: "offsetX" <*> e .: "offsetY") event
          scale <- withObject "canvas" (\c -> (/) <$> c .: "width" <*> c .: "clientWidth") canvas
          pure (offset ^* scale)
        _ -> fail "expected the event and its target"
    }

fillRect :: Color -> V2 Double -> V2 Double -> Canvas ()
fillRect color (V2 x y) (V2 w h) = do
  Canvas.fillStyle (Canvas.color color)
  Canvas.fillRect (x, y, w, h)

fillCircle :: Color -> V2 Double -> Double -> Canvas ()
fillCircle color (V2 x y) radius = do
  Canvas.fillStyle (Canvas.color color)
  Canvas.beginPath ()
  Canvas.arc (x, y, radius, 0, 2 * pi)
  Canvas.fill ()

strokeLine :: Color -> Double -> V2 Double -> V2 Double -> Canvas ()
strokeLine color width (V2 x1 y1) (V2 x2 y2) = do
  Canvas.strokeStyle (Canvas.color color)
  Canvas.lineWidth width
  Canvas.beginPath ()
  Canvas.moveTo (x1, y1)
  Canvas.lineTo (x2, y2)
  Canvas.stroke ()

fillText :: Color -> Int -> V2 Double -> Text -> Canvas ()
fillText color size (V2 x y) text = do
  Canvas.fillStyle (Canvas.color color)
  Canvas.font (ms size <> "px monospace")
  Canvas.textBaseline Canvas.TextBaselineTop
  Canvas.fillText (ms text, x, y)

main :: IO ()
main = startApp (Map.insert "pointermove" BUBBLE defaultEvents) app

app :: App Model Msg
app = (component initialModel update view){subs = [rAFSub Frame, keyboardSub KeysDown], mount = Just Start}

#ifdef wasm32_HOST_ARCH
-- | web/index.html calls this once the module is loaded.
foreign export javascript "start" main :: IO ()
#endif
