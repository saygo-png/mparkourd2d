{-# LANGUAGE ForeignFunctionInterface #-}
{-# LANGUAGE PatternSynonyms #-}
{-# LANGUAGE GeneralizedNewtypeDeriving #-}

-- Produced by boxnd-gen; edit the generator, not this file.

module Box2D.MotorJoint
  ( MotorJointDef (..)
  , defaultMotorJointDef
  , create
  , setLinearVelocity
  , getLinearVelocity
  , getLinearVelocityInto
  , setAngularVelocity
  , getAngularVelocity
  , setMaxVelocityForce
  , getMaxVelocityForce
  , setMaxVelocityTorque
  , getMaxVelocityTorque
  , setLinearHertz
  , getLinearHertz
  , setLinearDampingRatio
  , getLinearDampingRatio
  , setAngularHertz
  , getAngularHertz
  , setAngularDampingRatio
  , getAngularDampingRatio
  , setMaxSpringForce
  , getMaxSpringForce
  , setMaxSpringTorque
  , getMaxSpringTorque
  )
  where

import Foreign
import Foreign.C.Types (CInt (..))
import Box2D.Internal (allocaOut)
import Box2D.Id (JointId (..), WorldId (..))
import Box2D.Joint (JointDef)
import Box2D.MathTypes (Vec2)

#include "box2d/box2d.h"


-- | A motor joint is used to control the relative velocity and or transform between two bodies.
data MotorJointDef = MotorJointDef
  { base :: JointDef
  , linearVelocity :: Vec2
  , maxVelocityForce :: Float
  , angularVelocity :: Float
  , maxVelocityTorque :: Float
  , linearHertz :: Float
  , linearDampingRatio :: Float
  , maxSpringForce :: Float
  , angularHertz :: Float
  , angularDampingRatio :: Float
  , maxSpringTorque :: Float
  , internalValue :: CInt
  }
  deriving (Eq, Show)

instance Storable MotorJointDef where
  sizeOf _ = #{size b2MotorJointDef}
  alignment _ = #{alignment b2MotorJointDef}
  peek p =
    MotorJointDef
      <$> #{peek b2MotorJointDef, base} p
      <*> #{peek b2MotorJointDef, linearVelocity} p
      <*> #{peek b2MotorJointDef, maxVelocityForce} p
      <*> #{peek b2MotorJointDef, angularVelocity} p
      <*> #{peek b2MotorJointDef, maxVelocityTorque} p
      <*> #{peek b2MotorJointDef, linearHertz} p
      <*> #{peek b2MotorJointDef, linearDampingRatio} p
      <*> #{peek b2MotorJointDef, maxSpringForce} p
      <*> #{peek b2MotorJointDef, angularHertz} p
      <*> #{peek b2MotorJointDef, angularDampingRatio} p
      <*> #{peek b2MotorJointDef, maxSpringTorque} p
      <*> #{peek b2MotorJointDef, internalValue} p
  poke p (MotorJointDef f1 f2 f3 f4 f5 f6 f7 f8 f9 f10 f11 f12) = do
    #{poke b2MotorJointDef, base} p f1
    #{poke b2MotorJointDef, linearVelocity} p f2
    #{poke b2MotorJointDef, maxVelocityForce} p f3
    #{poke b2MotorJointDef, angularVelocity} p f4
    #{poke b2MotorJointDef, maxVelocityTorque} p f5
    #{poke b2MotorJointDef, linearHertz} p f6
    #{poke b2MotorJointDef, linearDampingRatio} p f7
    #{poke b2MotorJointDef, maxSpringForce} p f8
    #{poke b2MotorJointDef, angularHertz} p f9
    #{poke b2MotorJointDef, angularDampingRatio} p f10
    #{poke b2MotorJointDef, maxSpringTorque} p f11
    #{poke b2MotorJointDef, internalValue} p f12

foreign import ccall unsafe "hs_b2DefaultMotorJointDef"
  c_b2DefaultMotorJointDef :: Ptr MotorJointDef -> IO ()

defaultMotorJointDef :: IO MotorJointDef
defaultMotorJointDef = allocaOut c_b2DefaultMotorJointDef


foreign import ccall unsafe "b2CreateMotorJoint"
  c_b2CreateMotorJoint :: WorldId -> Ptr MotorJointDef -> IO JointId

foreign import ccall unsafe "hsg_b2MotorJoint_SetLinearVelocity"
  c_b2MotorJoint_SetLinearVelocity :: JointId -> Ptr Vec2 -> IO ()

foreign import ccall unsafe "hsg_b2MotorJoint_GetLinearVelocity"
  c_b2MotorJoint_GetLinearVelocity :: JointId -> Ptr Vec2 -> IO ()

foreign import ccall unsafe "b2MotorJoint_SetAngularVelocity"
  c_b2MotorJoint_SetAngularVelocity :: JointId -> Float -> IO ()

foreign import ccall unsafe "b2MotorJoint_GetAngularVelocity"
  c_b2MotorJoint_GetAngularVelocity :: JointId -> IO Float

foreign import ccall unsafe "b2MotorJoint_SetMaxVelocityForce"
  c_b2MotorJoint_SetMaxVelocityForce :: JointId -> Float -> IO ()

foreign import ccall unsafe "b2MotorJoint_GetMaxVelocityForce"
  c_b2MotorJoint_GetMaxVelocityForce :: JointId -> IO Float

foreign import ccall unsafe "b2MotorJoint_SetMaxVelocityTorque"
  c_b2MotorJoint_SetMaxVelocityTorque :: JointId -> Float -> IO ()

foreign import ccall unsafe "b2MotorJoint_GetMaxVelocityTorque"
  c_b2MotorJoint_GetMaxVelocityTorque :: JointId -> IO Float

foreign import ccall unsafe "b2MotorJoint_SetLinearHertz"
  c_b2MotorJoint_SetLinearHertz :: JointId -> Float -> IO ()

foreign import ccall unsafe "b2MotorJoint_GetLinearHertz"
  c_b2MotorJoint_GetLinearHertz :: JointId -> IO Float

foreign import ccall unsafe "b2MotorJoint_SetLinearDampingRatio"
  c_b2MotorJoint_SetLinearDampingRatio :: JointId -> Float -> IO ()

foreign import ccall unsafe "b2MotorJoint_GetLinearDampingRatio"
  c_b2MotorJoint_GetLinearDampingRatio :: JointId -> IO Float

foreign import ccall unsafe "b2MotorJoint_SetAngularHertz"
  c_b2MotorJoint_SetAngularHertz :: JointId -> Float -> IO ()

foreign import ccall unsafe "b2MotorJoint_GetAngularHertz"
  c_b2MotorJoint_GetAngularHertz :: JointId -> IO Float

foreign import ccall unsafe "b2MotorJoint_SetAngularDampingRatio"
  c_b2MotorJoint_SetAngularDampingRatio :: JointId -> Float -> IO ()

foreign import ccall unsafe "b2MotorJoint_GetAngularDampingRatio"
  c_b2MotorJoint_GetAngularDampingRatio :: JointId -> IO Float

foreign import ccall unsafe "b2MotorJoint_SetMaxSpringForce"
  c_b2MotorJoint_SetMaxSpringForce :: JointId -> Float -> IO ()

foreign import ccall unsafe "b2MotorJoint_GetMaxSpringForce"
  c_b2MotorJoint_GetMaxSpringForce :: JointId -> IO Float

foreign import ccall unsafe "b2MotorJoint_SetMaxSpringTorque"
  c_b2MotorJoint_SetMaxSpringTorque :: JointId -> Float -> IO ()

foreign import ccall unsafe "b2MotorJoint_GetMaxSpringTorque"
  c_b2MotorJoint_GetMaxSpringTorque :: JointId -> IO Float

{- | Create a motor joint
See also b2MotorJointDef for details.

Binds @b2CreateMotorJoint@.
-}
create
  :: WorldId
  -> MotorJointDef
  -> IO JointId
create a0 a1 =
  with a1 $ \p1 ->
  c_b2CreateMotorJoint a0 p1

{- | Set the desired relative linear velocity in meters per second

Binds @b2MotorJoint_SetLinearVelocity@.
-}
setLinearVelocity
  :: JointId
  -> Vec2
  -- ^ @velocity@
  -> IO ()
setLinearVelocity a0 a1 =
  with a1 $ \p1 ->
  c_b2MotorJoint_SetLinearVelocity a0 p1

{- | Get the desired relative linear velocity in meters per second

Binds @b2MotorJoint_GetLinearVelocity@.
-}
getLinearVelocity
  :: JointId
  -> IO Vec2
getLinearVelocity a0 =
  alloca $ \pOut -> c_b2MotorJoint_GetLinearVelocity a0 pOut >> peek pOut

-- | Like 'getLinearVelocity', but the result is written into a caller-supplied buffer.
getLinearVelocityInto
  :: JointId
  -> Ptr Vec2
  -- ^ Result buffer.
  -> IO ()
getLinearVelocityInto a0 out =
  c_b2MotorJoint_GetLinearVelocity a0 out

{- | Set the desired relative angular velocity in radians per second

Binds @b2MotorJoint_SetAngularVelocity@.
-}
setAngularVelocity
  :: JointId
  -> Float
  -- ^ @velocity@
  -> IO ()
setAngularVelocity a0 a1 =
  c_b2MotorJoint_SetAngularVelocity a0 a1

{- | Get the desired relative angular velocity in radians per second

Binds @b2MotorJoint_GetAngularVelocity@.
-}
getAngularVelocity
  :: JointId
  -> IO Float
getAngularVelocity a0 =
  c_b2MotorJoint_GetAngularVelocity a0

{- | Set the motor joint maximum force, usually in newtons

Binds @b2MotorJoint_SetMaxVelocityForce@.
-}
setMaxVelocityForce
  :: JointId
  -> Float
  -- ^ @maxForce@
  -> IO ()
setMaxVelocityForce a0 a1 =
  c_b2MotorJoint_SetMaxVelocityForce a0 a1

{- | Get the motor joint maximum force, usually in newtons

Binds @b2MotorJoint_GetMaxVelocityForce@.
-}
getMaxVelocityForce
  :: JointId
  -> IO Float
getMaxVelocityForce a0 =
  c_b2MotorJoint_GetMaxVelocityForce a0

{- | Set the motor joint maximum torque, usually in newton-meters

Binds @b2MotorJoint_SetMaxVelocityTorque@.
-}
setMaxVelocityTorque
  :: JointId
  -> Float
  -- ^ @maxTorque@
  -> IO ()
setMaxVelocityTorque a0 a1 =
  c_b2MotorJoint_SetMaxVelocityTorque a0 a1

{- | Get the motor joint maximum torque, usually in newton-meters

Binds @b2MotorJoint_GetMaxVelocityTorque@.
-}
getMaxVelocityTorque
  :: JointId
  -> IO Float
getMaxVelocityTorque a0 =
  c_b2MotorJoint_GetMaxVelocityTorque a0

{- | Set the spring linear hertz stiffness

Binds @b2MotorJoint_SetLinearHertz@.
-}
setLinearHertz
  :: JointId
  -> Float
  -- ^ @hertz@
  -> IO ()
setLinearHertz a0 a1 =
  c_b2MotorJoint_SetLinearHertz a0 a1

{- | Get the spring linear hertz stiffness

Binds @b2MotorJoint_GetLinearHertz@.
-}
getLinearHertz
  :: JointId
  -> IO Float
getLinearHertz a0 =
  c_b2MotorJoint_GetLinearHertz a0

{- | Set the spring linear damping ratio. Use 1.0 for critical damping.

Binds @b2MotorJoint_SetLinearDampingRatio@.
-}
setLinearDampingRatio
  :: JointId
  -> Float
  -- ^ @damping@
  -> IO ()
setLinearDampingRatio a0 a1 =
  c_b2MotorJoint_SetLinearDampingRatio a0 a1

{- | Get the spring linear damping ratio.

Binds @b2MotorJoint_GetLinearDampingRatio@.
-}
getLinearDampingRatio
  :: JointId
  -> IO Float
getLinearDampingRatio a0 =
  c_b2MotorJoint_GetLinearDampingRatio a0

{- | Set the spring angular hertz stiffness

Binds @b2MotorJoint_SetAngularHertz@.
-}
setAngularHertz
  :: JointId
  -> Float
  -- ^ @hertz@
  -> IO ()
setAngularHertz a0 a1 =
  c_b2MotorJoint_SetAngularHertz a0 a1

{- | Get the spring angular hertz stiffness

Binds @b2MotorJoint_GetAngularHertz@.
-}
getAngularHertz
  :: JointId
  -> IO Float
getAngularHertz a0 =
  c_b2MotorJoint_GetAngularHertz a0

{- | Set the spring angular damping ratio. Use 1.0 for critical damping.

Binds @b2MotorJoint_SetAngularDampingRatio@.
-}
setAngularDampingRatio
  :: JointId
  -> Float
  -- ^ @damping@
  -> IO ()
setAngularDampingRatio a0 a1 =
  c_b2MotorJoint_SetAngularDampingRatio a0 a1

{- | Get the spring angular damping ratio.

Binds @b2MotorJoint_GetAngularDampingRatio@.
-}
getAngularDampingRatio
  :: JointId
  -> IO Float
getAngularDampingRatio a0 =
  c_b2MotorJoint_GetAngularDampingRatio a0

{- | Set the maximum spring force in newtons.

Binds @b2MotorJoint_SetMaxSpringForce@.
-}
setMaxSpringForce
  :: JointId
  -> Float
  -- ^ @maxForce@
  -> IO ()
setMaxSpringForce a0 a1 =
  c_b2MotorJoint_SetMaxSpringForce a0 a1

{- | Get the maximum spring force in newtons.

Binds @b2MotorJoint_GetMaxSpringForce@.
-}
getMaxSpringForce
  :: JointId
  -> IO Float
getMaxSpringForce a0 =
  c_b2MotorJoint_GetMaxSpringForce a0

{- | Set the maximum spring torque in newtons * meters

Binds @b2MotorJoint_SetMaxSpringTorque@.
-}
setMaxSpringTorque
  :: JointId
  -> Float
  -- ^ @maxTorque@
  -> IO ()
setMaxSpringTorque a0 a1 =
  c_b2MotorJoint_SetMaxSpringTorque a0 a1

{- | Get the maximum spring torque in newtons * meters

Binds @b2MotorJoint_GetMaxSpringTorque@.
-}
getMaxSpringTorque
  :: JointId
  -> IO Float
getMaxSpringTorque a0 =
  c_b2MotorJoint_GetMaxSpringTorque a0
