-- | Canvas2D drawing with raylib-style names, via the GHC wasm JS FFI.
module Web.Canvas (
  Color,
  rgba,
  gray,
  pink,
  red,
  green,
  brown,
  black,
  clearBackground,
  drawRectangle,
  drawCircleV,
  drawLineEx,
  drawText,
) where

import GHC.Wasm.Prim (JSString (..), JSVal, toJSString)
import Linear (V2 (..))
import Relude

-- | A CSS color string, built once per color.
newtype Color = Color JSString

rgba :: Int -> Int -> Int -> Int -> Color
rgba r g b a = Color . toJSString $ "rgba(" <> intercalate "," (map show [r, g, b]) <> "," <> show (fromIntegral a / 255 :: Double) <> ")"

gray, pink, red, green, brown, black :: Color
gray = rgba 130 130 130 255
pink = rgba 255 109 194 255
red = rgba 230 41 55 255
green = rgba 0 228 48 255
brown = rgba 127 106 79 255
black = rgba 0 0 0 255

foreign import javascript unsafe "document.getElementById('screen').getContext('2d')"
  ctx :: JSVal

foreign import javascript unsafe "$1.fillStyle = $2; $1.fillRect(0, 0, $1.canvas.width, $1.canvas.height)"
  js_clear :: JSVal -> Color -> IO ()

foreign import javascript unsafe "$1.fillStyle = $6; $1.fillRect($2, $3, $4, $5)"
  js_rect :: JSVal -> Int -> Int -> Int -> Int -> Color -> IO ()

foreign import javascript unsafe "$1.fillStyle = $5; $1.beginPath(); $1.arc($2, $3, $4, 0, 2 * Math.PI); $1.fill()"
  js_circle :: JSVal -> Float -> Float -> Float -> Color -> IO ()

foreign import javascript unsafe "$1.strokeStyle = $7; $1.lineWidth = $6; $1.beginPath(); $1.moveTo($2, $3); $1.lineTo($4, $5); $1.stroke()"
  js_line :: JSVal -> Float -> Float -> Float -> Float -> Float -> Color -> IO ()

foreign import javascript unsafe "$1.fillStyle = $6; $1.font = $5 + 'px monospace'; $1.textBaseline = 'top'; $1.fillText($2, $3, $4)"
  js_text :: JSVal -> JSString -> Int -> Int -> Int -> Color -> IO ()

clearBackground :: Color -> IO ()
clearBackground = js_clear ctx

drawRectangle :: Int -> Int -> Int -> Int -> Color -> IO ()
drawRectangle = js_rect ctx

drawCircleV :: V2 Float -> Float -> Color -> IO ()
drawCircleV (V2 x y) = js_circle ctx x y

drawLineEx :: V2 Float -> V2 Float -> Float -> Color -> IO ()
drawLineEx (V2 x1 y1) (V2 x2 y2) = js_line ctx x1 y1 x2 y2

-- | Text with its top-left corner at (x, y), like raylib's default font.
drawText :: Text -> Int -> Int -> Int -> Color -> IO ()
drawText t = js_text ctx (toJSString (toString t))
