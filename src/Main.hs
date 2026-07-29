{-# LANGUAGE TemplateHaskell #-}

module Main where

import Linear
import Raylib.Core (clearBackground, closeWindow, initWindow, setTargetFPS, showCursor, windowShouldClose)
import Raylib.Core.Shapes
import Raylib.Core.Text (drawText)
import Raylib.Types (Camera2D (Camera2D))
import Raylib.Util
import Raylib.Util.Camera (cameraMove)
import Raylib.Util.Colors
import Prelude

data Player = Player
  { velocity :: V2 Float
  , position :: V2 Float
  }

data World = World
  { player :: Player
  , windowResources :: WindowResources
  }

windowWidth, windowHeight :: Int
windowWidth = 1820
windowHeight = 980

startup :: IO World
startup = do
  window <- initWindow windowWidth windowHeight "raylib [core] example - basic window"
  let player = Player{velocity = V2 0 0, position = V2 0 0}
  setTargetFPS 144
  return $ World{player = player, windowResources = window}

mainLoop :: World -> IO World
mainLoop world = do
  showCursor
  let mainCam = Camera2D (V2 0 0) (V2 0 0) 0 0
  drawing
    ( do
        clearBackground gray
        drawRectangle (div windowWidth 2) (div windowHeight 2) 200 200 black
        drawRectangle 0 0 200 200 red
        drawText "Basic raylib window" 30 40 18 black
        mode2D
          mainCam
          ( do
              drawRectangle 0 0 200 200 red
          )
    )
  return world

shouldClose :: World -> IO Bool
shouldClose _ = windowShouldClose

teardown :: World -> IO ()
teardown = closeWindow . Just . (.windowResources)

$(raylibApplication 'startup 'mainLoop 'shouldClose 'teardown)
