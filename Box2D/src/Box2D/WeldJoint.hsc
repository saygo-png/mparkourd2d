{-# LANGUAGE ForeignFunctionInterface #-}
{-# LANGUAGE PatternSynonyms #-}
{-# LANGUAGE GeneralizedNewtypeDeriving #-}

-- Produced by boxnd-gen; edit the generator, not this file.

module Box2D.WeldJoint
  ( WeldJointDef (..)
  , defaultWeldJointDef
  , create
  , setLinearHertz
  , getLinearHertz
  , setLinearDampingRatio
  , getLinearDampingRatio
  , setAngularHertz
  , getAngularHertz
  , setAngularDampingRatio
  , getAngularDampingRatio
  )
  where

import Foreign
import Foreign.C.Types (CInt (..))
import Box2D.Internal (allocaOut)
import Box2D.Id (JointId (..), WorldId (..))
import Box2D.Joint (JointDef)

#include "box2d/box2d.h"


-- | Weld joint definition
data WeldJointDef = WeldJointDef
  { base :: JointDef
  , linearHertz :: Float
  , angularHertz :: Float
  , linearDampingRatio :: Float
  , angularDampingRatio :: Float
  , internalValue :: CInt
  }
  deriving (Eq, Show)

instance Storable WeldJointDef where
  sizeOf _ = #{size b2WeldJointDef}
  alignment _ = #{alignment b2WeldJointDef}
  peek p =
    WeldJointDef
      <$> #{peek b2WeldJointDef, base} p
      <*> #{peek b2WeldJointDef, linearHertz} p
      <*> #{peek b2WeldJointDef, angularHertz} p
      <*> #{peek b2WeldJointDef, linearDampingRatio} p
      <*> #{peek b2WeldJointDef, angularDampingRatio} p
      <*> #{peek b2WeldJointDef, internalValue} p
  poke p (WeldJointDef f1 f2 f3 f4 f5 f6) = do
    #{poke b2WeldJointDef, base} p f1
    #{poke b2WeldJointDef, linearHertz} p f2
    #{poke b2WeldJointDef, angularHertz} p f3
    #{poke b2WeldJointDef, linearDampingRatio} p f4
    #{poke b2WeldJointDef, angularDampingRatio} p f5
    #{poke b2WeldJointDef, internalValue} p f6

foreign import ccall unsafe "hs_b2DefaultWeldJointDef"
  c_b2DefaultWeldJointDef :: Ptr WeldJointDef -> IO ()

defaultWeldJointDef :: IO WeldJointDef
defaultWeldJointDef = allocaOut c_b2DefaultWeldJointDef


foreign import ccall unsafe "b2CreateWeldJoint"
  c_b2CreateWeldJoint :: WorldId -> Ptr WeldJointDef -> IO JointId

foreign import ccall unsafe "b2WeldJoint_SetLinearHertz"
  c_b2WeldJoint_SetLinearHertz :: JointId -> Float -> IO ()

foreign import ccall unsafe "b2WeldJoint_GetLinearHertz"
  c_b2WeldJoint_GetLinearHertz :: JointId -> IO Float

foreign import ccall unsafe "b2WeldJoint_SetLinearDampingRatio"
  c_b2WeldJoint_SetLinearDampingRatio :: JointId -> Float -> IO ()

foreign import ccall unsafe "b2WeldJoint_GetLinearDampingRatio"
  c_b2WeldJoint_GetLinearDampingRatio :: JointId -> IO Float

foreign import ccall unsafe "b2WeldJoint_SetAngularHertz"
  c_b2WeldJoint_SetAngularHertz :: JointId -> Float -> IO ()

foreign import ccall unsafe "b2WeldJoint_GetAngularHertz"
  c_b2WeldJoint_GetAngularHertz :: JointId -> IO Float

foreign import ccall unsafe "b2WeldJoint_SetAngularDampingRatio"
  c_b2WeldJoint_SetAngularDampingRatio :: JointId -> Float -> IO ()

foreign import ccall unsafe "b2WeldJoint_GetAngularDampingRatio"
  c_b2WeldJoint_GetAngularDampingRatio :: JointId -> IO Float

{- | Create a weld joint
See also b2WeldJointDef for details.

Binds @b2CreateWeldJoint@.
-}
create
  :: WorldId
  -> WeldJointDef
  -> IO JointId
create a0 a1 =
  with a1 $ \p1 ->
  c_b2CreateWeldJoint a0 p1

{- | Set the weld joint linear stiffness in Hertz. 0 is rigid.

Binds @b2WeldJoint_SetLinearHertz@.
-}
setLinearHertz
  :: JointId
  -> Float
  -- ^ @hertz@
  -> IO ()
setLinearHertz a0 a1 =
  c_b2WeldJoint_SetLinearHertz a0 a1

{- | Get the weld joint linear stiffness in Hertz

Binds @b2WeldJoint_GetLinearHertz@.
-}
getLinearHertz
  :: JointId
  -> IO Float
getLinearHertz a0 =
  c_b2WeldJoint_GetLinearHertz a0

{- | Set the weld joint linear damping ratio (non-dimensional)

Binds @b2WeldJoint_SetLinearDampingRatio@.
-}
setLinearDampingRatio
  :: JointId
  -> Float
  -- ^ @dampingRatio@
  -> IO ()
setLinearDampingRatio a0 a1 =
  c_b2WeldJoint_SetLinearDampingRatio a0 a1

{- | Get the weld joint linear damping ratio (non-dimensional)

Binds @b2WeldJoint_GetLinearDampingRatio@.
-}
getLinearDampingRatio
  :: JointId
  -> IO Float
getLinearDampingRatio a0 =
  c_b2WeldJoint_GetLinearDampingRatio a0

{- | Set the weld joint angular stiffness in Hertz. 0 is rigid.

Binds @b2WeldJoint_SetAngularHertz@.
-}
setAngularHertz
  :: JointId
  -> Float
  -- ^ @hertz@
  -> IO ()
setAngularHertz a0 a1 =
  c_b2WeldJoint_SetAngularHertz a0 a1

{- | Get the weld joint angular stiffness in Hertz

Binds @b2WeldJoint_GetAngularHertz@.
-}
getAngularHertz
  :: JointId
  -> IO Float
getAngularHertz a0 =
  c_b2WeldJoint_GetAngularHertz a0

{- | Set weld joint angular damping ratio, non-dimensional

Binds @b2WeldJoint_SetAngularDampingRatio@.
-}
setAngularDampingRatio
  :: JointId
  -> Float
  -- ^ @dampingRatio@
  -> IO ()
setAngularDampingRatio a0 a1 =
  c_b2WeldJoint_SetAngularDampingRatio a0 a1

{- | Get the weld joint angular damping ratio, non-dimensional

Binds @b2WeldJoint_GetAngularDampingRatio@.
-}
getAngularDampingRatio
  :: JointId
  -> IO Float
getAngularDampingRatio a0 =
  c_b2WeldJoint_GetAngularDampingRatio a0
