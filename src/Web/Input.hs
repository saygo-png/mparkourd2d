{- | Keyboard and mouse state, fed by DOM event listeners. Keys are
@KeyboardEvent.code@ names such as "KeyA" or "Space".
-}
module Web.Input (
  listenForInput,
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
import System.IO.Unsafe (unsafePerformIO)

data Keys = Keys {down, pressed, released :: Set Text}

keysRef :: IORef Keys
keysRef = unsafePerformIO (newIORef (Keys mempty mempty mempty))
{-# NOINLINE keysRef #-}

mouseRef :: IORef (V2 Float)
mouseRef = unsafePerformIO (newIORef (V2 0 0))
{-# NOINLINE mouseRef #-}

foreign import javascript "wrapper sync"
  js_callback :: (JSVal -> IO ()) -> IO JSVal

foreign import javascript unsafe "addEventListener($1, $2)"
  js_onWindow :: JSString -> JSVal -> IO ()

foreign import javascript unsafe "document.getElementById('screen').addEventListener($1, $2)"
  js_onCanvas :: JSString -> JSVal -> IO ()

foreign import javascript unsafe "$1.code"
  js_code :: JSVal -> IO JSString

-- Pointer position in canvas pixels, undoing the CSS scaling of the canvas.
foreign import javascript unsafe "$1.offsetX * $1.target.width / $1.target.clientWidth"
  js_mouseX :: JSVal -> IO Float

foreign import javascript unsafe "$1.offsetY * $1.target.height / $1.target.clientHeight"
  js_mouseY :: JSVal -> IO Float

listenForInput :: IO ()
listenForInput = do
  onEvent js_onWindow "keydown" $ \e ->
    key e >>= \k -> modifyIORef' keysRef $ \ks ->
      if Set.member k ks.down then ks else ks{down = Set.insert k ks.down, pressed = Set.insert k ks.pressed}
  onEvent js_onWindow "keyup" $ \e ->
    key e >>= \k -> modifyIORef' keysRef $ \ks ->
      ks{down = Set.delete k ks.down, released = Set.insert k ks.released}
  onEvent js_onWindow "blur" $ \_ -> modifyIORef' keysRef $ \ks ->
    ks{down = mempty, released = ks.released <> ks.down}
  onEvent js_onCanvas "pointermove" $ \e -> writeIORef mouseRef =<< (V2 <$> js_mouseX e <*> js_mouseY e)
  where
    onEvent :: (JSString -> JSVal -> IO ()) -> String -> (JSVal -> IO ()) -> IO ()
    onEvent listen event f = js_callback f >>= listen (toJSString event)
    key e = toText . fromJSString <$> js_code e

-- | Forget this frame's presses and releases.
endFrame :: IO ()
endFrame = modifyIORef' keysRef $ \ks -> ks{pressed = mempty, released = mempty}

isKeyDown, isKeyPressed, isKeyReleased :: Text -> IO Bool
isKeyDown k = Set.member k . (.down) <$> readIORef keysRef
isKeyPressed k = Set.member k . (.pressed) <$> readIORef keysRef
isKeyReleased k = Set.member k . (.released) <$> readIORef keysRef

getMousePosition :: IO (V2 Float)
getMousePosition = readIORef mouseRef
