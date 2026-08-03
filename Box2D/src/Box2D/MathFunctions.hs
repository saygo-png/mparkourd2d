{-# LANGUAGE ForeignFunctionInterface #-}

{-| Low-level bindings to the exported (non-@inline@) functions of
@box2d/math_functions.h@.

Box2D implements most of its vector math as @static inline@ helpers, which
have no linkable symbols and are therefore out of scope for FFI. Only the
handful of functions marked @B2_API@ are bound here: the validators (handy
as ABI oracles for the "Box2D.MathTypes" 'Foreign.Storable.Storable'
instances) and a couple of by-value constructors.
-}
module Box2D.MathFunctions
  ( isValidVec2
  , isValidRotation
  , isValidTransform
  , isValidAABB
  , isValidPlane
  , computeCosSin
  , makeRot
  , rotGetAngle
  , getLengthUnitsPerMeter
  , setLengthUnitsPerMeter
  ) where

import Foreign
import Foreign.C.Types (CBool (..))

import Box2D.Internal (allocaOut, withValid)
import Box2D.MathTypes

foreign import ccall unsafe "hs_b2IsValidVec2"
  c_b2IsValidVec2 :: Ptr Vec2 -> IO CBool

foreign import ccall unsafe "hs_b2IsValidRotation"
  c_b2IsValidRotation :: Ptr Rot -> IO CBool

foreign import ccall unsafe "hs_b2IsValidTransform"
  c_b2IsValidTransform :: Ptr Transform -> IO CBool

foreign import ccall unsafe "hs_b2IsValidAABB"
  c_b2IsValidAABB :: Ptr AABB -> IO CBool

foreign import ccall unsafe "hs_b2IsValidPlane"
  c_b2IsValidPlane :: Ptr Plane -> IO CBool

foreign import ccall unsafe "hs_b2ComputeCosSin"
  c_b2ComputeCosSin :: Float -> Ptr CosSin -> IO ()

foreign import ccall unsafe "hs_b2MakeRot"
  c_b2MakeRot :: Float -> Ptr Rot -> IO ()

-- | Is this a valid (finite, non-NaN) vector?
isValidVec2 :: Vec2 -> IO Bool
isValidVec2 = withValid c_b2IsValidVec2

-- | Is this a valid, normalized rotation?
isValidRotation :: Rot -> IO Bool
isValidRotation = withValid c_b2IsValidRotation

-- | Is this a valid rigid transform?
isValidTransform :: Transform -> IO Bool
isValidTransform = withValid c_b2IsValidTransform

-- | Is this a valid, bounded AABB?
isValidAABB :: AABB -> IO Bool
isValidAABB = withValid c_b2IsValidAABB

-- | Is this a valid plane (finite, unit normal)?
isValidPlane :: Plane -> IO Bool
isValidPlane = withValid c_b2IsValidPlane

-- | Compute a deterministic cosine/sine pair for the given angle in radians.
computeCosSin :: Float -> IO CosSin
computeCosSin radians = allocaOut (c_b2ComputeCosSin radians)

-- | Make a normalized rotation from an angle in radians.
makeRot :: Float -> IO Rot
makeRot radians = allocaOut (c_b2MakeRot radians)

{- | The angle of a rotation in radians, in @(-pi, pi]@; the inverse of
'makeRot'. Pure (upstream @b2Rot_GetAngle@ is an inline header function).
-}
rotGetAngle :: Rot -> Float
rotGetAngle (Rot c s) = atan2 s c

foreign import ccall unsafe "b2GetLengthUnitsPerMeter"
  c_b2GetLengthUnitsPerMeter :: IO Float

foreign import ccall unsafe "b2SetLengthUnitsPerMeter"
  c_b2SetLengthUnitsPerMeter :: Float -> IO ()

{- | The engine's current length units per meter (default 1). Tuning
constants scale with it: e.g. @B2_LINEAR_SLOP@ is 0.005 of this.
-}
getLengthUnitsPerMeter :: IO Float
getLengthUnitsPerMeter = c_b2GetLengthUnitsPerMeter

{- | Change the length units, e.g. 128 for pixels-as-units. Do this before
creating any world.
-}
setLengthUnitsPerMeter :: Float -> IO ()
setLengthUnitsPerMeter = c_b2SetLengthUnitsPerMeter
