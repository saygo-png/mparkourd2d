-- | Timing a game loop to the browser's frames.
module Web.Frame (nextFrame) where

import Control.Exception (evaluate)

foreign import javascript safe "new Promise(requestAnimationFrame)"
  js_nextFrame :: IO Double

-- | Waits for the browser's next frame and returns its timestamp in seconds.
nextFrame :: IO Double
nextFrame = (/ 1000) <$> (evaluate =<< js_nextFrame) -- the promise is awaited when its result is forced
