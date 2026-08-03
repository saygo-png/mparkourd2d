{-# LANGUAGE ForeignFunctionInterface #-}
{-# LANGUAGE PatternSynonyms #-}
{-# LANGUAGE GeneralizedNewtypeDeriving #-}

-- Produced by boxnd-gen; edit the generator, not this file.

module Box2D.FilterJoint
  ( FilterJointDef (..)
  , defaultFilterJointDef
  , create
  )
  where

import Foreign
import Foreign.C.Types (CInt (..))
import Box2D.Internal (allocaOut)
import Box2D.Id (JointId (..), WorldId (..))
import Box2D.Joint (JointDef)

#include "box2d/box2d.h"


-- | A filter joint is used to disable collision between two specific bodies.
data FilterJointDef = FilterJointDef
  { base :: JointDef
  , internalValue :: CInt
  }
  deriving (Eq, Show)

instance Storable FilterJointDef where
  sizeOf _ = #{size b2FilterJointDef}
  alignment _ = #{alignment b2FilterJointDef}
  peek p =
    FilterJointDef
      <$> #{peek b2FilterJointDef, base} p
      <*> #{peek b2FilterJointDef, internalValue} p
  poke p (FilterJointDef f1 f2) = do
    #{poke b2FilterJointDef, base} p f1
    #{poke b2FilterJointDef, internalValue} p f2

foreign import ccall unsafe "hs_b2DefaultFilterJointDef"
  c_b2DefaultFilterJointDef :: Ptr FilterJointDef -> IO ()

defaultFilterJointDef :: IO FilterJointDef
defaultFilterJointDef = allocaOut c_b2DefaultFilterJointDef


foreign import ccall unsafe "b2CreateFilterJoint"
  c_b2CreateFilterJoint :: WorldId -> Ptr FilterJointDef -> IO JointId

{- | Create a filter joint.
See also b2FilterJointDef for details.

Binds @b2CreateFilterJoint@.
-}
create
  :: WorldId
  -> FilterJointDef
  -> IO JointId
create a0 a1 =
  with a1 $ \p1 ->
  c_b2CreateFilterJoint a0 p1
