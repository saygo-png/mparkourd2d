-- | Low-level bindings to the value types in @box2d/math_functions.h@.
--
-- These are the small POD math structs that the Box2D API passes and returns
-- by value. Field order matches the C layout; 'Storable' offsets come straight
-- from the header via @hsc2hs@.
--
-- In single-precision builds (the default) @b2Pos@ and @b2WorldTransform@ are
-- typedefs for @b2Vec2@ and @b2Transform@, so 'Pos' and 'WorldTransform' are
-- type synonyms here.
module Box2D.MathTypes
  ( Vec2 (..)
  , CosSin (..)
  , Rot (..)
  , Transform (..)
  , Mat22 (..)
  , AABB (..)
  , Plane (..)
  , Pos
  , WorldTransform

    -- * Constants
  , vec2Zero
  , rotIdentity
  , transformIdentity

    -- * Vector math
  , vec2Add
  , vec2Sub
  , vec2Neg
  , vec2Scale
  , vec2MulAdd
  , vec2MulSub
  , vec2Dot
  , vec2Cross
  , vec2LengthSquared
  , vec2Length
  , vec2Normalize
  , vec2Lerp

    -- * Rotation and plane math
  , rotMul
  , rotateVector
  , invRotateVector
  , planeSeparation
  ) where

import Foreign

#include "box2d/box2d.h"

-- | A 2D vector.
data Vec2 = Vec2 Float Float
  deriving (Eq, Show)

-- | Cosine and sine pair (@cosine@, @sine@).
data CosSin = CosSin Float Float
  deriving (Eq, Show)

-- | A 2D rotation stored as a cosine/sine pair (@c@, @s@).
data Rot = Rot Float Float
  deriving (Eq, Show)

-- | A 2D rigid transform: position @p@ and rotation @q@.
data Transform = Transform Vec2 Rot
  deriving (Eq, Show)

-- | A 2x2 column-major matrix (columns @cx@, @cy@).
data Mat22 = Mat22 Vec2 Vec2
  deriving (Eq, Show)

-- | Axis-aligned bounding box (@lowerBound@, @upperBound@).
data AABB = AABB Vec2 Vec2
  deriving (Eq, Show)

-- | A plane: @normal@ and @offset@ where @separation = dot(normal, point) - offset@.
data Plane = Plane Vec2 Float
  deriving (Eq, Show)

-- | World position. In single-precision builds this is 'Vec2'.
type Pos = Vec2

-- | World transform. In single-precision builds this is 'Transform'.
type WorldTransform = Transform

instance Storable Vec2 where
  sizeOf _ = #{size b2Vec2}
  alignment _ = #{alignment b2Vec2}
  peek p = Vec2 <$> #{peek b2Vec2, x} p <*> #{peek b2Vec2, y} p
  poke p (Vec2 x y) = do
    #{poke b2Vec2, x} p x
    #{poke b2Vec2, y} p y

instance Storable CosSin where
  sizeOf _ = #{size b2CosSin}
  alignment _ = #{alignment b2CosSin}
  peek p = CosSin <$> #{peek b2CosSin, cosine} p <*> #{peek b2CosSin, sine} p
  poke p (CosSin c s) = do
    #{poke b2CosSin, cosine} p c
    #{poke b2CosSin, sine} p s

instance Storable Rot where
  sizeOf _ = #{size b2Rot}
  alignment _ = #{alignment b2Rot}
  peek p = Rot <$> #{peek b2Rot, c} p <*> #{peek b2Rot, s} p
  poke p (Rot c s) = do
    #{poke b2Rot, c} p c
    #{poke b2Rot, s} p s

instance Storable Transform where
  sizeOf _ = #{size b2Transform}
  alignment _ = #{alignment b2Transform}
  peek p = Transform <$> #{peek b2Transform, p} p <*> #{peek b2Transform, q} p
  poke ptr (Transform p q) = do
    #{poke b2Transform, p} ptr p
    #{poke b2Transform, q} ptr q

instance Storable Mat22 where
  sizeOf _ = #{size b2Mat22}
  alignment _ = #{alignment b2Mat22}
  peek p = Mat22 <$> #{peek b2Mat22, cx} p <*> #{peek b2Mat22, cy} p
  poke p (Mat22 cx cy) = do
    #{poke b2Mat22, cx} p cx
    #{poke b2Mat22, cy} p cy

instance Storable AABB where
  sizeOf _ = #{size b2AABB}
  alignment _ = #{alignment b2AABB}
  peek p = AABB <$> #{peek b2AABB, lowerBound} p <*> #{peek b2AABB, upperBound} p
  poke p (AABB lo hi) = do
    #{poke b2AABB, lowerBound} p lo
    #{poke b2AABB, upperBound} p hi

instance Storable Plane where
  sizeOf _ = #{size b2Plane}
  alignment _ = #{alignment b2Plane}
  peek p = Plane <$> #{peek b2Plane, normal} p <*> #{peek b2Plane, offset} p
  poke p (Plane n o) = do
    #{poke b2Plane, normal} p n
    #{poke b2Plane, offset} p o

vec2Zero :: Vec2
vec2Zero = Vec2 0 0

-- | The identity rotation (cosine 1, sine 0).
rotIdentity :: Rot
rotIdentity = Rot 1 0

transformIdentity :: Transform
transformIdentity = Transform vec2Zero rotIdentity

-- Vector math ---------------------------------------------------------------
--
-- Pure ports of the @static inline@ vector helpers of
-- @box2d/math_functions.h@, which have no linkable symbols and cannot be
-- bound by FFI. Each names its upstream original.

-- | @a + b@ (upstream @b2Add@).
vec2Add :: Vec2 -> Vec2 -> Vec2
vec2Add (Vec2 ax ay) (Vec2 bx by) = Vec2 (ax + bx) (ay + by)

-- | @a - b@ (upstream @b2Sub@).
vec2Sub :: Vec2 -> Vec2 -> Vec2
vec2Sub (Vec2 ax ay) (Vec2 bx by) = Vec2 (ax - bx) (ay - by)

-- | @-a@ (upstream @b2Neg@).
vec2Neg :: Vec2 -> Vec2
vec2Neg (Vec2 x y) = Vec2 (negate x) (negate y)

-- | @s * v@ (upstream @b2MulSV@).
vec2Scale :: Float -> Vec2 -> Vec2
vec2Scale s (Vec2 x y) = Vec2 (s * x) (s * y)

-- | @a + s * b@ (upstream @b2MulAdd@).
vec2MulAdd :: Vec2 -> Float -> Vec2 -> Vec2
vec2MulAdd a s b = vec2Add a (vec2Scale s b)

-- | @a - s * b@ (upstream @b2MulSub@).
vec2MulSub :: Vec2 -> Float -> Vec2 -> Vec2
vec2MulSub a s b = vec2Sub a (vec2Scale s b)

-- | Dot product (upstream @b2Dot@).
vec2Dot :: Vec2 -> Vec2 -> Float
vec2Dot (Vec2 ax ay) (Vec2 bx by) = ax * bx + ay * by

-- | 2D cross product, the signed area of the parallelogram (upstream
-- @b2Cross@).
vec2Cross :: Vec2 -> Vec2 -> Float
vec2Cross (Vec2 ax ay) (Vec2 bx by) = ax * by - ay * bx

-- | Squared length (upstream @b2LengthSquared@).
vec2LengthSquared :: Vec2 -> Float
vec2LengthSquared v = vec2Dot v v

-- | Length (upstream @b2Length@).
vec2Length :: Vec2 -> Float
vec2Length = sqrt . vec2LengthSquared

-- | A unit vector in the direction of @v@, or 'vec2Zero' when @v@ is too
-- short to normalize — below @FLT_EPSILON@, like upstream @b2Normalize@.
vec2Normalize :: Vec2 -> Vec2
vec2Normalize v
  | len < 1.1920929e-7 = vec2Zero
  | otherwise = vec2Scale (1 / len) v
  where
    len = vec2Length v

-- | Linear interpolation from @a@ at 0 to @b@ at 1 (upstream @b2Lerp@).
vec2Lerp :: Vec2 -> Vec2 -> Float -> Vec2
vec2Lerp (Vec2 ax ay) (Vec2 bx by) t =
  Vec2 (ax * (1 - t) + bx * t) (ay * (1 - t) + by * t)

-- | Compose two rotations: @q * r@ rotates by @r@ then @q@ (upstream
-- @b2MulRot@).
rotMul :: Rot -> Rot -> Rot
rotMul (Rot qc qs) (Rot rc rs) = Rot (qc * rc - qs * rs) (qs * rc + qc * rs)

-- | Rotate a vector (upstream @b2RotateVector@).
rotateVector :: Rot -> Vec2 -> Vec2
rotateVector (Rot c s) (Vec2 x y) = Vec2 (c * x - s * y) (s * x + c * y)

-- | Inverse-rotate a vector (upstream @b2InvRotateVector@).
invRotateVector :: Rot -> Vec2 -> Vec2
invRotateVector (Rot c s) (Vec2 x y) = Vec2 (c * x + s * y) (c * y - s * x)

-- | Signed distance of a point from a plane, using the engine's
-- @dot(normal, point) - offset@ convention (upstream @b2PlaneSeparation@).
planeSeparation :: Plane -> Vec2 -> Float
planeSeparation (Plane n o) p = vec2Dot n p - o
