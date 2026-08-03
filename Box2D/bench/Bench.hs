{-# LANGUAGE PatternSynonyms #-}

module Main (main) where

import Control.Monad (forM_)

import Test.Tasty.Bench

import Box2D.Body (BodyDef (..), defaultBodyDef, pattern DynamicBody)
import Box2D.Body qualified as Body
import Box2D.Geometry (Circle (..), Segment (..))
import Box2D.Id (WorldId)
import Box2D.MathTypes
import Box2D.Shape (defaultShapeDef)
import Box2D.Shape qualified as Shape
import Box2D.World (WorldDef (..), defaultWorldDef)
import Box2D.World qualified as World

{- | Build a world holding @n@ dynamic circles dropped onto a static ground
segment, so that a step exercises broad phase, narrow phase and the solver.
-}
setupWorld :: Int -> IO WorldId
setupWorld n = do
  wd <- defaultWorldDef
  -- keep the pile awake: a settled world would otherwise fall asleep and
  -- the stepping benchmarks would measure an idle no-op step
  w <- World.create wd{gravity = Vec2 0 (-10), enableSleep = 0}

  gd <- defaultBodyDef
  ground <- Body.create w gd
  gsd <- defaultShapeDef
  _ <- Shape.createSegment ground gsd (Segment (Vec2 (-40) 0) (Vec2 40 0))

  bd <- defaultBodyDef
  sd <- defaultShapeDef
  forM_ [0 .. n - 1] $ \i -> do
    let
      col = fromIntegral (i `mod` 16)
      row = fromIntegral (i `div` 16)
      position = Vec2 (col - 8) (2 + row)
    b <- Body.create w bd{type_ = DynamicBody, position = position}
    _ <- Shape.createCircle b sd (Circle vec2Zero 0.5)
    pure ()

  -- let the pile settle so steps hit a steady contact load
  forM_ [1 .. 120 :: Int] $ \_ -> World.step w (1 / 60) 4
  pure w

main :: IO ()
main = do
  emptyDef <- defaultWorldDef
  world64 <- setupWorld 64
  world256 <- setupWorld 256
  defaultMain
    [ bench "World.create + World.destroy" $
        whnfIO (World.create emptyDef >>= World.destroy)
    , bench "step 64 circles" $
        whnfIO (World.step world64 (1 / 60) 4)
    , bench "step 256 circles" $
        whnfIO (World.step world256 (1 / 60) 4)
    ]
