-- | Drawing on the page's canvas. Colors are CSS color strings.
module Web.Canvas (Context, getContext, fillRect, fillCircle, strokeLine, fillText) where

import Data.Text (Text)
import Data.Text qualified as Text
import GHC.Wasm.Prim (JSString (..), JSVal, toJSString)
import Linear (V2 (..))

newtype Context = Context JSVal

-- | The 2D context of the page's first @<canvas>@.
foreign import javascript unsafe "document.querySelector('canvas').getContext('2d')"
  getContext :: IO Context

foreign import javascript unsafe
  """
  $1.fillStyle = $2;
  $1.fillRect($3, $4, $5, $6);
  """
  js_fillRect :: Context -> JSString -> Float -> Float -> Float -> Float -> IO ()

-- | @fillRect ctx color position size@
fillRect :: Context -> JSString -> V2 Float -> V2 Float -> IO ()
fillRect ctx color (V2 x y) (V2 w h) = js_fillRect ctx color x y w h

foreign import javascript unsafe
  """
  $1.fillStyle = $2;
  $1.beginPath();
  $1.arc($3, $4, $5, 0, 2 * Math.PI);
  $1.fill();
  """
  js_fillCircle :: Context -> JSString -> Float -> Float -> Float -> IO ()

-- | @fillCircle ctx color center radius@
fillCircle :: Context -> JSString -> V2 Float -> Float -> IO ()
fillCircle ctx color (V2 x y) = js_fillCircle ctx color x y

foreign import javascript unsafe
  """
  $1.strokeStyle = $2;
  $1.lineWidth = $3;
  $1.beginPath();
  $1.moveTo($4, $5);
  $1.lineTo($6, $7);
  $1.stroke();
  """
  js_strokeLine :: Context -> JSString -> Float -> Float -> Float -> Float -> Float -> IO ()

-- | @strokeLine ctx color width from to@
strokeLine :: Context -> JSString -> Float -> V2 Float -> V2 Float -> IO ()
strokeLine ctx color width (V2 x1 y1) (V2 x2 y2) = js_strokeLine ctx color width x1 y1 x2 y2

foreign import javascript unsafe
  """
  $1.fillStyle = $2;
  $1.font = $3 + 'px monospace';
  $1.textBaseline = 'top';
  $1.fillText($6, $4, $5);
  """
  js_fillText :: Context -> JSString -> Float -> Float -> Float -> JSString -> IO ()

-- | @fillText ctx color size topLeft text@
fillText :: Context -> JSString -> Float -> V2 Float -> Text -> IO ()
fillText ctx color size (V2 x y) text = js_fillText ctx color size x y (toJSString (Text.unpack text))
