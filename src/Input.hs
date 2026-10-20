{- | Keyboard and mouse state, kept up to date by DOM event listeners. Keys are
@KeyboardEvent.code@ names such as "KeyA" or "Space".
-}
module Input (
  Input,
  newInput,
  endFrame,
  isKeyDown,
  isKeyPressed,
  isKeyReleased,
  getMousePosition,
) where

import Data.Set qualified as Set
import GHC.Wasm.Prim (JSString (..), JSVal, fromJSString, toJSString)
import Linear (V2 (..))
import Relude

data Input = Input
  { down :: IORef (Set Text)
  , pressed :: IORef (Set Text) -- since the last 'endFrame'
  , released :: IORef (Set Text) -- since the last 'endFrame'
  , mouse :: IORef (V2 Float)
  }

foreign import javascript "wrapper sync"
  js_callback :: (JSVal -> IO ()) -> IO JSVal

foreign import javascript unsafe "addEventListener($1, $2)"
  js_addEventListener :: JSString -> JSVal -> IO ()

foreign import javascript unsafe "$1.code"
  js_code :: JSVal -> IO JSString

-- Pointer position in canvas pixels; CSS scales the canvas to the window.
foreign import javascript unsafe "const c = document.querySelector('canvas'); return ($1.clientX - c.getBoundingClientRect().left) * c.width / c.clientWidth"
  js_canvasX :: JSVal -> IO Float

foreign import javascript unsafe "const c = document.querySelector('canvas'); return ($1.clientY - c.getBoundingClientRect().top) * c.height / c.clientHeight"
  js_canvasY :: JSVal -> IO Float

newInput :: IO Input
newInput = do
  input <- Input <$> newIORef mempty <*> newIORef mempty <*> newIORef mempty <*> newIORef (V2 0 0)
  listen "keydown" $ \e -> do
    key <- code e
    isDown <- isKeyDown input key -- held keys repeat keydown
    unless isDown $ modifyIORef' input.down (Set.insert key) >> modifyIORef' input.pressed (Set.insert key)
  listen "keyup" $ \e -> do
    key <- code e
    modifyIORef' input.down (Set.delete key) >> modifyIORef' input.released (Set.insert key)
  listen "blur" $ \_ -> writeIORef input.down mempty
  listen "pointermove" $ \e -> writeIORef input.mouse =<< (V2 <$> js_canvasX e <*> js_canvasY e)
  pure input
  where
    listen :: String -> (JSVal -> IO ()) -> IO ()
    listen event handler = js_addEventListener (toJSString event) =<< js_callback handler
    code e = toText . fromJSString <$> js_code e

-- | Forgets the presses and releases seen so far; call once per frame.
endFrame :: Input -> IO ()
endFrame input = writeIORef input.pressed mempty >> writeIORef input.released mempty

isKeyDown, isKeyPressed, isKeyReleased :: Input -> Text -> IO Bool
isKeyDown input key = Set.member key <$> readIORef input.down
isKeyPressed input key = Set.member key <$> readIORef input.pressed
isKeyReleased input key = Set.member key <$> readIORef input.released

getMousePosition :: Input -> IO (V2 Float)
getMousePosition input = readIORef input.mouse
