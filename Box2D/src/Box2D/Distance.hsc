{-# LANGUAGE ForeignFunctionInterface #-}
{-# LANGUAGE PatternSynonyms #-}
{-# LANGUAGE GeneralizedNewtypeDeriving #-}

-- Produced by boxnd-gen; edit the generator, not this file.

module Box2D.Distance
  ( TOIOutput (..)
  , TOIState (..)
  , pattern ToiStateUnknown
  , pattern ToiStateFailed
  , pattern ToiStateOverlapped
  , pattern ToiStateHit
  , pattern ToiStateSeparated
  , TOIInput (..)
  , Sweep (..)
  , ShapeCastPairInput (..)
  , Simplex (..)
  , SimplexVertex (..)
  , DistanceOutput (..)
  , DistanceInput (..)
  , SimplexCache (..)
  , SegmentDistanceResult (..)
  )
  where

import Foreign
import Foreign.C.Types (CBool (..), CInt (..))
import Data.Vector.Storable qualified as VS
import Box2D.Internal (copyVector, pokeCountedVector)
import Box2D.Geometry (ShapeProxy)
import Box2D.MathTypes (Rot, Transform, Vec2)

#include "box2d/box2d.h"


-- | Time of impact output
data TOIOutput = TOIOutput
  { state :: CInt
  , point :: Vec2
  , normal :: Vec2
  , fraction :: Float
  }
  deriving (Eq, Show)

instance Storable TOIOutput where
  sizeOf _ = #{size b2TOIOutput}
  alignment _ = #{alignment b2TOIOutput}
  peek p =
    TOIOutput
      <$> #{peek b2TOIOutput, state} p
      <*> #{peek b2TOIOutput, point} p
      <*> #{peek b2TOIOutput, normal} p
      <*> #{peek b2TOIOutput, fraction} p
  poke p (TOIOutput f1 f2 f3 f4) = do
    #{poke b2TOIOutput, state} p f1
    #{poke b2TOIOutput, point} p f2
    #{poke b2TOIOutput, normal} p f3
    #{poke b2TOIOutput, fraction} p f4

-- | Describes the TOI output
newtype TOIState = TOIState CInt
  deriving (Eq, Show, Storable)

pattern ToiStateUnknown :: TOIState
pattern ToiStateFailed :: TOIState
pattern ToiStateOverlapped :: TOIState
pattern ToiStateHit :: TOIState
pattern ToiStateSeparated :: TOIState
pattern ToiStateUnknown = TOIState #{const b2_toiStateUnknown}
pattern ToiStateFailed = TOIState #{const b2_toiStateFailed}
pattern ToiStateOverlapped = TOIState #{const b2_toiStateOverlapped}
pattern ToiStateHit = TOIState #{const b2_toiStateHit}
pattern ToiStateSeparated = TOIState #{const b2_toiStateSeparated}

{-# COMPLETE ToiStateUnknown, ToiStateFailed, ToiStateOverlapped, ToiStateHit, ToiStateSeparated #-}

-- | Time of impact input
data TOIInput = TOIInput
  { proxyA :: ShapeProxy
  , proxyB :: ShapeProxy
  , sweepA :: Sweep
  , sweepB :: Sweep
  , maxFraction :: Float
  }
  deriving (Eq, Show)

instance Storable TOIInput where
  sizeOf _ = #{size b2TOIInput}
  alignment _ = #{alignment b2TOIInput}
  peek p =
    TOIInput
      <$> #{peek b2TOIInput, proxyA} p
      <*> #{peek b2TOIInput, proxyB} p
      <*> #{peek b2TOIInput, sweepA} p
      <*> #{peek b2TOIInput, sweepB} p
      <*> #{peek b2TOIInput, maxFraction} p
  poke p (TOIInput f1 f2 f3 f4 f5) = do
    #{poke b2TOIInput, proxyA} p f1
    #{poke b2TOIInput, proxyB} p f2
    #{poke b2TOIInput, sweepA} p f3
    #{poke b2TOIInput, sweepB} p f4
    #{poke b2TOIInput, maxFraction} p f5

-- | This describes the motion of a body/shape for TOI computation. Shapes are defined with respect to the body origin,
data Sweep = Sweep
  { localCenter :: Vec2
  , c1 :: Vec2
  , c2 :: Vec2
  , q1 :: Rot
  , q2 :: Rot
  }
  deriving (Eq, Show)

instance Storable Sweep where
  sizeOf _ = #{size b2Sweep}
  alignment _ = #{alignment b2Sweep}
  peek p =
    Sweep
      <$> #{peek b2Sweep, localCenter} p
      <*> #{peek b2Sweep, c1} p
      <*> #{peek b2Sweep, c2} p
      <*> #{peek b2Sweep, q1} p
      <*> #{peek b2Sweep, q2} p
  poke p (Sweep f1 f2 f3 f4 f5) = do
    #{poke b2Sweep, localCenter} p f1
    #{poke b2Sweep, c1} p f2
    #{poke b2Sweep, c2} p f3
    #{poke b2Sweep, q1} p f4
    #{poke b2Sweep, q2} p f5

-- | Input parameters for b2ShapeCast
data ShapeCastPairInput = ShapeCastPairInput
  { proxyA :: ShapeProxy
  , proxyB :: ShapeProxy
  , transform :: Transform
  , translationB :: Vec2
  , maxFraction :: Float
  , canEncroach :: CBool
  }
  deriving (Eq, Show)

instance Storable ShapeCastPairInput where
  sizeOf _ = #{size b2ShapeCastPairInput}
  alignment _ = #{alignment b2ShapeCastPairInput}
  peek p =
    ShapeCastPairInput
      <$> #{peek b2ShapeCastPairInput, proxyA} p
      <*> #{peek b2ShapeCastPairInput, proxyB} p
      <*> #{peek b2ShapeCastPairInput, transform} p
      <*> #{peek b2ShapeCastPairInput, translationB} p
      <*> #{peek b2ShapeCastPairInput, maxFraction} p
      <*> #{peek b2ShapeCastPairInput, canEncroach} p
  poke p (ShapeCastPairInput f1 f2 f3 f4 f5 f6) = do
    #{poke b2ShapeCastPairInput, proxyA} p f1
    #{poke b2ShapeCastPairInput, proxyB} p f2
    #{poke b2ShapeCastPairInput, transform} p f3
    #{poke b2ShapeCastPairInput, translationB} p f4
    #{poke b2ShapeCastPairInput, maxFraction} p f5
    #{poke b2ShapeCastPairInput, canEncroach} p f6

-- | Simplex from the GJK algorithm
data Simplex = Simplex
  { v1 :: SimplexVertex
  , v2 :: SimplexVertex
  , v3 :: SimplexVertex
  , count :: CInt
  }
  deriving (Eq, Show)

instance Storable Simplex where
  sizeOf _ = #{size b2Simplex}
  alignment _ = #{alignment b2Simplex}
  peek p =
    Simplex
      <$> #{peek b2Simplex, v1} p
      <*> #{peek b2Simplex, v2} p
      <*> #{peek b2Simplex, v3} p
      <*> #{peek b2Simplex, count} p
  poke p (Simplex f1 f2 f3 f4) = do
    #{poke b2Simplex, v1} p f1
    #{poke b2Simplex, v2} p f2
    #{poke b2Simplex, v3} p f3
    #{poke b2Simplex, count} p f4

-- | Simplex vertex for debugging the GJK algorithm
data SimplexVertex = SimplexVertex
  { wA :: Vec2
  , wB :: Vec2
  , w :: Vec2
  , a :: Float
  , indexA :: CInt
  , indexB :: CInt
  }
  deriving (Eq, Show)

instance Storable SimplexVertex where
  sizeOf _ = #{size b2SimplexVertex}
  alignment _ = #{alignment b2SimplexVertex}
  peek p =
    SimplexVertex
      <$> #{peek b2SimplexVertex, wA} p
      <*> #{peek b2SimplexVertex, wB} p
      <*> #{peek b2SimplexVertex, w} p
      <*> #{peek b2SimplexVertex, a} p
      <*> #{peek b2SimplexVertex, indexA} p
      <*> #{peek b2SimplexVertex, indexB} p
  poke p (SimplexVertex f1 f2 f3 f4 f5 f6) = do
    #{poke b2SimplexVertex, wA} p f1
    #{poke b2SimplexVertex, wB} p f2
    #{poke b2SimplexVertex, w} p f3
    #{poke b2SimplexVertex, a} p f4
    #{poke b2SimplexVertex, indexA} p f5
    #{poke b2SimplexVertex, indexB} p f6

-- | Output for b2ShapeDistance
data DistanceOutput = DistanceOutput
  { pointA :: Vec2
  , pointB :: Vec2
  , normal :: Vec2
  , distance :: Float
  , iterations :: CInt
  , simplexCount :: CInt
  }
  deriving (Eq, Show)

instance Storable DistanceOutput where
  sizeOf _ = #{size b2DistanceOutput}
  alignment _ = #{alignment b2DistanceOutput}
  peek p =
    DistanceOutput
      <$> #{peek b2DistanceOutput, pointA} p
      <*> #{peek b2DistanceOutput, pointB} p
      <*> #{peek b2DistanceOutput, normal} p
      <*> #{peek b2DistanceOutput, distance} p
      <*> #{peek b2DistanceOutput, iterations} p
      <*> #{peek b2DistanceOutput, simplexCount} p
  poke p (DistanceOutput f1 f2 f3 f4 f5 f6) = do
    #{poke b2DistanceOutput, pointA} p f1
    #{poke b2DistanceOutput, pointB} p f2
    #{poke b2DistanceOutput, normal} p f3
    #{poke b2DistanceOutput, distance} p f4
    #{poke b2DistanceOutput, iterations} p f5
    #{poke b2DistanceOutput, simplexCount} p f6

-- | Input for b2ShapeDistance
data DistanceInput = DistanceInput
  { proxyA :: ShapeProxy
  , proxyB :: ShapeProxy
  , transform :: Transform
  , useRadii :: CBool
  }
  deriving (Eq, Show)

instance Storable DistanceInput where
  sizeOf _ = #{size b2DistanceInput}
  alignment _ = #{alignment b2DistanceInput}
  peek p =
    DistanceInput
      <$> #{peek b2DistanceInput, proxyA} p
      <*> #{peek b2DistanceInput, proxyB} p
      <*> #{peek b2DistanceInput, transform} p
      <*> #{peek b2DistanceInput, useRadii} p
  poke p (DistanceInput f1 f2 f3 f4) = do
    #{poke b2DistanceInput, proxyA} p f1
    #{poke b2DistanceInput, proxyB} p f2
    #{poke b2DistanceInput, transform} p f3
    #{poke b2DistanceInput, useRadii} p f4

-- | Used to warm start the GJK simplex. If you call this function multiple times with nearby
data SimplexCache = SimplexCache
  { indexA :: VS.Vector Word8
  , indexB :: VS.Vector Word8
  }
  deriving (Eq, Show)

instance Storable SimplexCache where
  sizeOf _ = #{size b2SimplexCache}
  alignment _ = #{alignment b2SimplexCache}
  peek p = do
    n <- #{peek b2SimplexCache, count} p :: IO CInt
    SimplexCache
      <$> copyVector (fromIntegral n) (#{ptr b2SimplexCache, indexA} p)
      <*> copyVector (fromIntegral n) (#{ptr b2SimplexCache, indexB} p)
  poke p x = do
    pokeCountedVector (#{const 3}) (#{ptr b2SimplexCache, indexA} p) (#{poke b2SimplexCache, count} p) x.indexA
    pokeCountedVector (#{const 3}) (#{ptr b2SimplexCache, indexB} p) (#{poke b2SimplexCache, count} p) x.indexB

-- | Result of computing the distance between two line segments
data SegmentDistanceResult = SegmentDistanceResult
  { closest1 :: Vec2
  , closest2 :: Vec2
  , fraction1 :: Float
  , fraction2 :: Float
  , distanceSquared :: Float
  }
  deriving (Eq, Show)

instance Storable SegmentDistanceResult where
  sizeOf _ = #{size b2SegmentDistanceResult}
  alignment _ = #{alignment b2SegmentDistanceResult}
  peek p =
    SegmentDistanceResult
      <$> #{peek b2SegmentDistanceResult, closest1} p
      <*> #{peek b2SegmentDistanceResult, closest2} p
      <*> #{peek b2SegmentDistanceResult, fraction1} p
      <*> #{peek b2SegmentDistanceResult, fraction2} p
      <*> #{peek b2SegmentDistanceResult, distanceSquared} p
  poke p (SegmentDistanceResult f1 f2 f3 f4 f5) = do
    #{poke b2SegmentDistanceResult, closest1} p f1
    #{poke b2SegmentDistanceResult, closest2} p f2
    #{poke b2SegmentDistanceResult, fraction1} p f3
    #{poke b2SegmentDistanceResult, fraction2} p f4
    #{poke b2SegmentDistanceResult, distanceSquared} p f5



