{-# LANGUAGE ForeignFunctionInterface #-}
{-# LANGUAGE PatternSynonyms #-}
{-# LANGUAGE GeneralizedNewtypeDeriving #-}

-- Produced by boxnd-gen; edit the generator, not this file.

module Box2D.Geometry
  ( Hull (..)
  , ChainSegment (..)
  , Segment (..)
  , Polygon (..)
  , Capsule (..)
  , Circle (..)
  , MassData (..)
  , WorldCastOutput (..)
  , CastOutput (..)
  , ShapeCastInput (..)
  , ShapeProxy (..)
  , RayCastInput (..)
  , maxPolygonVertices
  )
  where

import Foreign
import Foreign.C.Types (CBool (..), CInt (..))
import Data.Vector.Storable qualified as VS
import Box2D.Internal (copyVector, pokeCountedVector)
import Box2D.MathTypes (Pos, Vec2)

#include "box2d/box2d.h"


-- | A convex hull. Used to create convex polygons.
data Hull = Hull
  { points :: VS.Vector Vec2
  }
  deriving (Eq, Show)

instance Storable Hull where
  sizeOf _ = #{size b2Hull}
  alignment _ = #{alignment b2Hull}
  peek p = do
    n <- #{peek b2Hull, count} p :: IO CInt
    Hull
      <$> copyVector (fromIntegral n) (#{ptr b2Hull, points} p)
  poke p x = do
    pokeCountedVector maxPolygonVertices (#{ptr b2Hull, points} p) (#{poke b2Hull, count} p) x.points

-- | A line segment with one-sided collision. Only collides on the right side.
data ChainSegment = ChainSegment
  { ghost1 :: Vec2
  , segment :: Segment
  , ghost2 :: Vec2
  , chainId :: CInt
  }
  deriving (Eq, Show)

instance Storable ChainSegment where
  sizeOf _ = #{size b2ChainSegment}
  alignment _ = #{alignment b2ChainSegment}
  peek p =
    ChainSegment
      <$> #{peek b2ChainSegment, ghost1} p
      <*> #{peek b2ChainSegment, segment} p
      <*> #{peek b2ChainSegment, ghost2} p
      <*> #{peek b2ChainSegment, chainId} p
  poke p (ChainSegment f1 f2 f3 f4) = do
    #{poke b2ChainSegment, ghost1} p f1
    #{poke b2ChainSegment, segment} p f2
    #{poke b2ChainSegment, ghost2} p f3
    #{poke b2ChainSegment, chainId} p f4

-- | A line segment with two-sided collision.
data Segment = Segment
  { point1 :: Vec2
  , point2 :: Vec2
  }
  deriving (Eq, Show)

instance Storable Segment where
  sizeOf _ = #{size b2Segment}
  alignment _ = #{alignment b2Segment}
  peek p =
    Segment
      <$> #{peek b2Segment, point1} p
      <*> #{peek b2Segment, point2} p
  poke p (Segment f1 f2) = do
    #{poke b2Segment, point1} p f1
    #{poke b2Segment, point2} p f2

-- | A solid convex polygon. It is assumed that the interior of the polygon is to
data Polygon = Polygon
  { vertices :: VS.Vector Vec2
  , normals :: VS.Vector Vec2
  , centroid :: Vec2
  , radius :: Float
  }
  deriving (Eq, Show)

instance Storable Polygon where
  sizeOf _ = #{size b2Polygon}
  alignment _ = #{alignment b2Polygon}
  peek p = do
    n <- #{peek b2Polygon, count} p :: IO CInt
    Polygon
      <$> copyVector (fromIntegral n) (#{ptr b2Polygon, vertices} p)
      <*> copyVector (fromIntegral n) (#{ptr b2Polygon, normals} p)
      <*> #{peek b2Polygon, centroid} p
      <*> #{peek b2Polygon, radius} p
  poke p x = do
    pokeCountedVector maxPolygonVertices (#{ptr b2Polygon, vertices} p) (#{poke b2Polygon, count} p) x.vertices
    pokeCountedVector maxPolygonVertices (#{ptr b2Polygon, normals} p) (#{poke b2Polygon, count} p) x.normals
    #{poke b2Polygon, centroid} p x.centroid
    #{poke b2Polygon, radius} p x.radius

-- | A solid capsule can be viewed as two semicircles connected
data Capsule = Capsule
  { center1 :: Vec2
  , center2 :: Vec2
  , radius :: Float
  }
  deriving (Eq, Show)

instance Storable Capsule where
  sizeOf _ = #{size b2Capsule}
  alignment _ = #{alignment b2Capsule}
  peek p =
    Capsule
      <$> #{peek b2Capsule, center1} p
      <*> #{peek b2Capsule, center2} p
      <*> #{peek b2Capsule, radius} p
  poke p (Capsule f1 f2 f3) = do
    #{poke b2Capsule, center1} p f1
    #{poke b2Capsule, center2} p f2
    #{poke b2Capsule, radius} p f3

-- | A solid circle
data Circle = Circle
  { center :: Vec2
  , radius :: Float
  }
  deriving (Eq, Show)

instance Storable Circle where
  sizeOf _ = #{size b2Circle}
  alignment _ = #{alignment b2Circle}
  peek p =
    Circle
      <$> #{peek b2Circle, center} p
      <*> #{peek b2Circle, radius} p
  poke p (Circle f1 f2) = do
    #{poke b2Circle, center} p f1
    #{poke b2Circle, radius} p f2

-- | This holds the mass data computed for a shape.
data MassData = MassData
  { mass :: Float
  , center :: Vec2
  , rotationalInertia :: Float
  }
  deriving (Eq, Show)

instance Storable MassData where
  sizeOf _ = #{size b2MassData}
  alignment _ = #{alignment b2MassData}
  peek p =
    MassData
      <$> #{peek b2MassData, mass} p
      <*> #{peek b2MassData, center} p
      <*> #{peek b2MassData, rotationalInertia} p
  poke p (MassData f1 f2 f3) = do
    #{poke b2MassData, mass} p f1
    #{poke b2MassData, center} p f2
    #{poke b2MassData, rotationalInertia} p f3

-- | World-space cast output. The hit point is a world position. The normal stays a float direction.
data WorldCastOutput = WorldCastOutput
  { normal :: Vec2
  , point :: Pos
  , fraction :: Float
  , iterations :: CInt
  , hit :: CBool
  }
  deriving (Eq, Show)

instance Storable WorldCastOutput where
  sizeOf _ = #{size b2WorldCastOutput}
  alignment _ = #{alignment b2WorldCastOutput}
  peek p =
    WorldCastOutput
      <$> #{peek b2WorldCastOutput, normal} p
      <*> #{peek b2WorldCastOutput, point} p
      <*> #{peek b2WorldCastOutput, fraction} p
      <*> #{peek b2WorldCastOutput, iterations} p
      <*> #{peek b2WorldCastOutput, hit} p
  poke p (WorldCastOutput f1 f2 f3 f4 f5) = do
    #{poke b2WorldCastOutput, normal} p f1
    #{poke b2WorldCastOutput, point} p f2
    #{poke b2WorldCastOutput, fraction} p f3
    #{poke b2WorldCastOutput, iterations} p f4
    #{poke b2WorldCastOutput, hit} p f5

-- | Low level ray cast or shape-cast output data. The hit point is in the local or relative frame
data CastOutput = CastOutput
  { normal :: Vec2
  , point :: Vec2
  , fraction :: Float
  , iterations :: CInt
  , hit :: CBool
  }
  deriving (Eq, Show)

instance Storable CastOutput where
  sizeOf _ = #{size b2CastOutput}
  alignment _ = #{alignment b2CastOutput}
  peek p =
    CastOutput
      <$> #{peek b2CastOutput, normal} p
      <*> #{peek b2CastOutput, point} p
      <*> #{peek b2CastOutput, fraction} p
      <*> #{peek b2CastOutput, iterations} p
      <*> #{peek b2CastOutput, hit} p
  poke p (CastOutput f1 f2 f3 f4 f5) = do
    #{poke b2CastOutput, normal} p f1
    #{poke b2CastOutput, point} p f2
    #{poke b2CastOutput, fraction} p f3
    #{poke b2CastOutput, iterations} p f4
    #{poke b2CastOutput, hit} p f5

-- | Low level shape cast input in generic form. This allows casting an arbitrary point
data ShapeCastInput = ShapeCastInput
  { proxy :: ShapeProxy
  , translation :: Vec2
  , maxFraction :: Float
  , canEncroach :: CBool
  }
  deriving (Eq, Show)

instance Storable ShapeCastInput where
  sizeOf _ = #{size b2ShapeCastInput}
  alignment _ = #{alignment b2ShapeCastInput}
  peek p =
    ShapeCastInput
      <$> #{peek b2ShapeCastInput, proxy} p
      <*> #{peek b2ShapeCastInput, translation} p
      <*> #{peek b2ShapeCastInput, maxFraction} p
      <*> #{peek b2ShapeCastInput, canEncroach} p
  poke p (ShapeCastInput f1 f2 f3 f4) = do
    #{poke b2ShapeCastInput, proxy} p f1
    #{poke b2ShapeCastInput, translation} p f2
    #{poke b2ShapeCastInput, maxFraction} p f3
    #{poke b2ShapeCastInput, canEncroach} p f4

-- | A distance proxy is used by the GJK algorithm. It encapsulates any shape.
data ShapeProxy = ShapeProxy
  { points :: VS.Vector Vec2
  , radius :: Float
  }
  deriving (Eq, Show)

instance Storable ShapeProxy where
  sizeOf _ = #{size b2ShapeProxy}
  alignment _ = #{alignment b2ShapeProxy}
  peek p = do
    n <- #{peek b2ShapeProxy, count} p :: IO CInt
    ShapeProxy
      <$> copyVector (fromIntegral n) (#{ptr b2ShapeProxy, points} p)
      <*> #{peek b2ShapeProxy, radius} p
  poke p x = do
    pokeCountedVector maxPolygonVertices (#{ptr b2ShapeProxy, points} p) (#{poke b2ShapeProxy, count} p) x.points
    #{poke b2ShapeProxy, radius} p x.radius

-- | Low level ray cast input data
data RayCastInput = RayCastInput
  { origin :: Vec2
  , translation :: Vec2
  , maxFraction :: Float
  }
  deriving (Eq, Show)

instance Storable RayCastInput where
  sizeOf _ = #{size b2RayCastInput}
  alignment _ = #{alignment b2RayCastInput}
  peek p =
    RayCastInput
      <$> #{peek b2RayCastInput, origin} p
      <*> #{peek b2RayCastInput, translation} p
      <*> #{peek b2RayCastInput, maxFraction} p
  poke p (RayCastInput f1 f2 f3) = do
    #{poke b2RayCastInput, origin} p f1
    #{poke b2RayCastInput, translation} p f2
    #{poke b2RayCastInput, maxFraction} p f3

-- | @B2_MAX_POLYGON_VERTICES@
maxPolygonVertices :: Int
maxPolygonVertices = #{const B2_MAX_POLYGON_VERTICES}




