{-# LANGUAGE CPP #-}
{-# LANGUAGE LambdaCase #-}
{-# LANGUAGE TemplateHaskell #-}

module Main (main) where

import Box2D qualified
import Control.Lens hiding (universe, view, (#))
import Data.IntSet qualified as IntSet
import Data.Map qualified as Map
import Linear (R2 (_y), V2 (..), distance, normalize, (*^), (^*), (^/))
import Miso (App, Component (mount, subs), DecodeTarget (..), Decoder (..), Effect, Phase (BUBBLE), View, component, defaultEvents, io, on, startApp, sync, sync_)
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

-- | The GA: a dash to the target nearest the mouse.
data GaPhase
  = GaReady
  | -- | To this target.
    GaDashing (V2 Double)
  | -- | For this many more seconds.
    GaArrived Double
  deriving stock (Eq)

data Model = Model
  { _physics :: Maybe Physics
  -- ^ Set up when the game starts.
  , _playerPosition :: V2 Double
  , _gaPhase :: GaPhase
  , _gaCooldown :: Double
  -- ^ Seconds until the GA can be used again.
  , _keysDown :: IntSet
  , _mousePosition :: V2 Double
  , _lastFrame :: Double
  -- ^ Timestamp of the last frame, in milliseconds.
  , _fps :: Double
  -- ^ Frames per second, smoothed.
  }
  deriving stock (Eq)

data Msg
  = Start
  | Started Physics
  | Frame Double
  | Stepped Double (V2 Double)
  | KeysDown IntSet
  | MouseMoved (V2 Double)

data Action = MoveLeft | MoveRight | Jump | GetPos | GaStart
  deriving stock (Eq, Show, Enum, Bounded)

$(makeLenses ''Physics)
$(makeLenses ''Model)

-- | The key code that triggers each action while held.
keyBinding :: Action -> Int
keyBinding MoveLeft = 65 -- A
keyBinding MoveRight = 68 -- D
keyBinding Jump = 32 -- Space
keyBinding GetPos = 80 -- P
keyBinding GaStart = 16 -- Shift

screenWidth, screenHeight :: Double
screenWidth = 1920
screenHeight = 1080

gravityAccel :: Double
gravityAccel = 10

-- | Physics runs this many times faster than real time.
timeScale :: Double
timeScale = 10

gaLockonRange, gaCooldownTime, gaDashSpeed, gaArrivalThreshold, gaArrivedDuration, gaJumpSpeed :: Double
gaLockonRange = 100 -- The pink circle around the mouse.
gaCooldownTime = 3
gaDashSpeed = 700 -- Pixels per second.
gaArrivalThreshold = 40
gaArrivedDuration = 0.3
gaJumpSpeed = 2000 -- Pixels per second.

playerOrigin :: V2 Double
playerOrigin = V2 585 500

screenCenter :: V2 Double
screenCenter = V2 (screenWidth / 2) (screenHeight / 2)

gray, pink, red, green, brown, darkBrown, black :: Color
gray = rgb 130 130 130
pink = rgb 255 109 194
red = rgb 230 41 55
green = rgb 0 228 48
brown = rgb 127 106 79
darkBrown = rgb 76 63 47
black = rgb 0 0 0

initialModel :: Model
initialModel =
  Model
    { _physics = Nothing
    , _playerPosition = playerOrigin
    , _gaPhase = GaReady
    , _gaCooldown = 0
    , _keysDown = mempty
    , _mousePosition = V2 0 0
    , _lastFrame = 0
    , _fps = 0
    }

gaTargets :: [V2 Double]
gaTargets = liftA2 V2 (coord 8 (-2000)) (coord 50 300)
  where
    coord n start = map ((start +) . (* 400)) [0 .. n - 1]

-- | The camera keeps the player in the middle of the screen.
worldToScreen, screenToWorld :: Model -> V2 Double -> V2 Double
worldToScreen model p = p - model ^. playerPosition + screenCenter
screenToWorld model p = p + model ^. playerPosition - screenCenter

-- | The mouse's position in the world.
mouseWorld :: Model -> V2 Double
mouseWorld model = screenToWorld model (model ^. mousePosition)

-- | The target the GA would dash to: the one nearest the mouse, if it's in range.
gaTarget :: Model -> Maybe (V2 Double)
gaTarget model =
  gaTargets
    & filter ((<= gaLockonRange) . distance mouse)
    & sortOn (distance mouse)
    & viaNonEmpty head
  where
    mouse = mouseWorld model

startup :: IO Physics
startup = do
  world' <- Box2D.createWorld (V2 0 (-gravityAccel))
  ground <- Box2D.createBody world' Box2D.StaticBody (V2 0 0)
  _ <- Box2D.createSegment ground (v2 (-999) 1000) (v2 999 1000)
  body <- Box2D.createBody world' Box2D.DynamicBody (flipY playerOrigin)
  shape <- Box2D.createCircle body (v2 0 0) 10
  Box2D.setRestitution shape 0.8
  pure (Physics world' body)

-- | Sets the player's velocity, in pixels per second on the screen.
setVelocity :: Physics -> V2 Double -> IO ()
setVelocity p velocity = Box2D.setLinearVelocity (p ^. player) (flipY velocity ^/ timeScale)

applyAction :: Physics -> Action -> Effect () () Model Msg
applyAction p action = do
  model <- get
  let ready = model ^. gaPhase == GaReady
      push = when ready . sync_ . Box2D.applyForceToCenter (p ^. player)
  case action of
    MoveLeft -> push (v2 (-3000) 0)
    MoveRight -> push (v2 3000 0)
    Jump
      | ready -> push (v2 0 (-9000))
      -- Jumping out of the GA launches the player towards the mouse.
      | otherwise -> do
          sync_ (setVelocity p (gaJumpSpeed *^ normalize (mouseWorld model - model ^. playerPosition)))
          gaPhase .= GaReady
    GetPos -> sync_ (print (model ^. mousePosition))
    GaStart -> case gaTarget model of
      Just target | ready && model ^. gaCooldown <= 0 -> do
        gaPhase .= GaDashing target
        gaCooldown .= gaCooldownTime
      _ -> pass

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
      gaCooldown %= max 0 . subtract dt
      gaPhase %= \case
        GaArrived remaining | remaining > dt -> GaArrived (remaining - dt)
        GaArrived _ -> GaReady
        phase -> phase
      traverse_ (applyAction p) actions
      phase <- use gaPhase
      -- sync, not io: io runs it in a new thread, which is slow every frame.
      sync $ do
        case phase of
          GaDashing target -> do
            Box2D.setGravityScale (p ^. player) 0
            setVelocity p (gaDashSpeed *^ normalize (target - model ^. playerPosition))
          _ -> Box2D.setGravityScale (p ^. player) 1
        Box2D.step (p ^. world) (dt * timeScale) 4
        Stepped time . flipY <$> Box2D.getPosition (p ^. player)
  Stepped time position -> do
    frameTime <- (time -) <$> use lastFrame
    fps %= \f -> 0.9 * f + 0.1 * (1000 / frameTime)
    lastFrame .= time
    playerPosition .= position
    gaPhase %= \case
      GaDashing target | distance position target <= gaArrivalThreshold -> GaArrived gaArrivedDuration
      phase -> phase

view :: Model -> View () () Model Msg
view model =
  Canvas.canvas
    [ width_ (ms screenWidth)
    , height_ (ms screenHeight)
    , on "pointermove" canvasPointer (\position _ _ -> MouseMoved position)
    ]
    (\_ -> pass)
    (\() -> draw model)

draw :: Model -> Canvas ()
draw model = do
  fillRect gray (V2 0 0) (V2 screenWidth screenHeight)
  fillCircle pink (model ^. mousePosition) gaLockonRange
  Canvas.save ()
  let V2 x y = worldToScreen model (V2 0 0) in Canvas.translate (x, y)
  drawWorld model
  Canvas.restore ()
  fillText black 20 (V2 20 20) ("Player height: " <> show (round (negate (model ^. playerPosition . _y)) :: Int))
  fillText black 20 (V2 20 50) (gaStatus model)
  fillTextRight black 20 (V2 (screenWidth - 20) 20) ("FPS: " <> show (round (model ^. fps) :: Int))

-- | Everything that moves with the camera, in world coordinates.
drawWorld :: Model -> Canvas ()
drawWorld model = do
  let ppos = model ^. playerPosition
      -- Each canvas call costs a few JS values, so only the targets on the
      -- screen are drawn.
      onScreen target = let V2 dx dy = abs (target - ppos) in dx < screenWidth / 2 + 10 && dy < screenHeight / 2 + 10
  fillCircle red playerOrigin 30
  fillRect black (V2 (screenWidth / 2) (screenHeight / 2)) (V2 200 200)
  for_ (filter onScreen gaTargets) $ \target -> fillCircle brown target 10
  for_ (gaTarget model) $ \target -> strokeLine darkBrown 4 (mouseWorld model) target
  strokeLine black 4 (V2 (-999) 1000) (V2 999 1000)
  fillCircle green ppos 10
  fillText black 20 (ppos - V2 17 20) "PLAYER"
  fillText black 18 (V2 30 40) "Basic canvas window"

gaStatus :: Model -> Text
gaStatus model = case model ^. gaPhase of
  GaReady
    | model ^. gaCooldown > 0 -> "GA cooldown: " <> show (round (model ^. gaCooldown) :: Int) <> "s"
    | otherwise -> "GA ready"
  GaDashing _ -> "GA dashing"
  GaArrived _ -> "GA arrived"

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

-- | Text with its top left corner at the position.
fillText :: Color -> Int -> V2 Double -> Text -> Canvas ()
fillText = fillTextAligned Canvas.TextAlignLeft

-- | Text with its top right corner at the position.
fillTextRight :: Color -> Int -> V2 Double -> Text -> Canvas ()
fillTextRight = fillTextAligned Canvas.TextAlignRight

fillTextAligned :: Canvas.TextAlignType -> Color -> Int -> V2 Double -> Text -> Canvas ()
fillTextAligned align color size (V2 x y) text = do
  Canvas.fillStyle (Canvas.color color)
  Canvas.font (ms size <> "px monospace")
  Canvas.textAlign align
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
