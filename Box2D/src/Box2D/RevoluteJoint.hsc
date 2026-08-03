{-# LANGUAGE ForeignFunctionInterface #-}
{-# LANGUAGE PatternSynonyms #-}
{-# LANGUAGE GeneralizedNewtypeDeriving #-}

-- Produced by boxnd-gen; edit the generator, not this file.

module Box2D.RevoluteJoint
  ( RevoluteJointDef (..)
  , defaultRevoluteJointDef
  , create
  , enableSpring
  , isSpringEnabled
  , setSpringHertz
  , getSpringHertz
  , setSpringDampingRatio
  , getSpringDampingRatio
  , setTargetAngle
  , getTargetAngle
  , getAngle
  , enableLimit
  , isLimitEnabled
  , getLowerLimit
  , getUpperLimit
  , setLimits
  , enableMotor
  , isMotorEnabled
  , setMotorSpeed
  , getMotorSpeed
  , getMotorTorque
  , setMaxMotorTorque
  , getMaxMotorTorque
  )
  where

import Foreign
import Foreign.C.Types (CBool (..), CInt (..))
import Box2D.Internal (allocaOut)
import Box2D.Id (JointId (..), WorldId (..))
import Box2D.Joint (JointDef)

#include "box2d/box2d.h"


-- | Revolute joint definition
data RevoluteJointDef = RevoluteJointDef
  { base :: JointDef
  , targetAngle :: Float
  , enableSpring :: CBool
  , hertz :: Float
  , dampingRatio :: Float
  , enableLimit :: CBool
  , lowerAngle :: Float
  , upperAngle :: Float
  , enableMotor :: CBool
  , maxMotorTorque :: Float
  , motorSpeed :: Float
  , internalValue :: CInt
  }
  deriving (Eq, Show)

instance Storable RevoluteJointDef where
  sizeOf _ = #{size b2RevoluteJointDef}
  alignment _ = #{alignment b2RevoluteJointDef}
  peek p =
    RevoluteJointDef
      <$> #{peek b2RevoluteJointDef, base} p
      <*> #{peek b2RevoluteJointDef, targetAngle} p
      <*> #{peek b2RevoluteJointDef, enableSpring} p
      <*> #{peek b2RevoluteJointDef, hertz} p
      <*> #{peek b2RevoluteJointDef, dampingRatio} p
      <*> #{peek b2RevoluteJointDef, enableLimit} p
      <*> #{peek b2RevoluteJointDef, lowerAngle} p
      <*> #{peek b2RevoluteJointDef, upperAngle} p
      <*> #{peek b2RevoluteJointDef, enableMotor} p
      <*> #{peek b2RevoluteJointDef, maxMotorTorque} p
      <*> #{peek b2RevoluteJointDef, motorSpeed} p
      <*> #{peek b2RevoluteJointDef, internalValue} p
  poke p (RevoluteJointDef f1 f2 f3 f4 f5 f6 f7 f8 f9 f10 f11 f12) = do
    #{poke b2RevoluteJointDef, base} p f1
    #{poke b2RevoluteJointDef, targetAngle} p f2
    #{poke b2RevoluteJointDef, enableSpring} p f3
    #{poke b2RevoluteJointDef, hertz} p f4
    #{poke b2RevoluteJointDef, dampingRatio} p f5
    #{poke b2RevoluteJointDef, enableLimit} p f6
    #{poke b2RevoluteJointDef, lowerAngle} p f7
    #{poke b2RevoluteJointDef, upperAngle} p f8
    #{poke b2RevoluteJointDef, enableMotor} p f9
    #{poke b2RevoluteJointDef, maxMotorTorque} p f10
    #{poke b2RevoluteJointDef, motorSpeed} p f11
    #{poke b2RevoluteJointDef, internalValue} p f12

foreign import ccall unsafe "hs_b2DefaultRevoluteJointDef"
  c_b2DefaultRevoluteJointDef :: Ptr RevoluteJointDef -> IO ()

defaultRevoluteJointDef :: IO RevoluteJointDef
defaultRevoluteJointDef = allocaOut c_b2DefaultRevoluteJointDef


foreign import ccall unsafe "b2CreateRevoluteJoint"
  c_b2CreateRevoluteJoint :: WorldId -> Ptr RevoluteJointDef -> IO JointId

foreign import ccall unsafe "b2RevoluteJoint_EnableSpring"
  c_b2RevoluteJoint_EnableSpring :: JointId -> CBool -> IO ()

foreign import ccall unsafe "b2RevoluteJoint_IsSpringEnabled"
  c_b2RevoluteJoint_IsSpringEnabled :: JointId -> IO CBool

foreign import ccall unsafe "b2RevoluteJoint_SetSpringHertz"
  c_b2RevoluteJoint_SetSpringHertz :: JointId -> Float -> IO ()

foreign import ccall unsafe "b2RevoluteJoint_GetSpringHertz"
  c_b2RevoluteJoint_GetSpringHertz :: JointId -> IO Float

foreign import ccall unsafe "b2RevoluteJoint_SetSpringDampingRatio"
  c_b2RevoluteJoint_SetSpringDampingRatio :: JointId -> Float -> IO ()

foreign import ccall unsafe "b2RevoluteJoint_GetSpringDampingRatio"
  c_b2RevoluteJoint_GetSpringDampingRatio :: JointId -> IO Float

foreign import ccall unsafe "b2RevoluteJoint_SetTargetAngle"
  c_b2RevoluteJoint_SetTargetAngle :: JointId -> Float -> IO ()

foreign import ccall unsafe "b2RevoluteJoint_GetTargetAngle"
  c_b2RevoluteJoint_GetTargetAngle :: JointId -> IO Float

foreign import ccall unsafe "b2RevoluteJoint_GetAngle"
  c_b2RevoluteJoint_GetAngle :: JointId -> IO Float

foreign import ccall unsafe "b2RevoluteJoint_EnableLimit"
  c_b2RevoluteJoint_EnableLimit :: JointId -> CBool -> IO ()

foreign import ccall unsafe "b2RevoluteJoint_IsLimitEnabled"
  c_b2RevoluteJoint_IsLimitEnabled :: JointId -> IO CBool

foreign import ccall unsafe "b2RevoluteJoint_GetLowerLimit"
  c_b2RevoluteJoint_GetLowerLimit :: JointId -> IO Float

foreign import ccall unsafe "b2RevoluteJoint_GetUpperLimit"
  c_b2RevoluteJoint_GetUpperLimit :: JointId -> IO Float

foreign import ccall unsafe "b2RevoluteJoint_SetLimits"
  c_b2RevoluteJoint_SetLimits :: JointId -> Float -> Float -> IO ()

foreign import ccall unsafe "b2RevoluteJoint_EnableMotor"
  c_b2RevoluteJoint_EnableMotor :: JointId -> CBool -> IO ()

foreign import ccall unsafe "b2RevoluteJoint_IsMotorEnabled"
  c_b2RevoluteJoint_IsMotorEnabled :: JointId -> IO CBool

foreign import ccall unsafe "b2RevoluteJoint_SetMotorSpeed"
  c_b2RevoluteJoint_SetMotorSpeed :: JointId -> Float -> IO ()

foreign import ccall unsafe "b2RevoluteJoint_GetMotorSpeed"
  c_b2RevoluteJoint_GetMotorSpeed :: JointId -> IO Float

foreign import ccall unsafe "b2RevoluteJoint_GetMotorTorque"
  c_b2RevoluteJoint_GetMotorTorque :: JointId -> IO Float

foreign import ccall unsafe "b2RevoluteJoint_SetMaxMotorTorque"
  c_b2RevoluteJoint_SetMaxMotorTorque :: JointId -> Float -> IO ()

foreign import ccall unsafe "b2RevoluteJoint_GetMaxMotorTorque"
  c_b2RevoluteJoint_GetMaxMotorTorque :: JointId -> IO Float

{- | Create a revolute joint
See also b2RevoluteJointDef for details.

Binds @b2CreateRevoluteJoint@.
-}
create
  :: WorldId
  -> RevoluteJointDef
  -> IO JointId
create a0 a1 =
  with a1 $ \p1 ->
  c_b2CreateRevoluteJoint a0 p1

{- | Enable\/disable the revolute joint spring

Binds @b2RevoluteJoint_EnableSpring@.
-}
enableSpring
  :: JointId
  -> Bool
  -- ^ @enableSpring@
  -> IO ()
enableSpring a0 a1 =
  c_b2RevoluteJoint_EnableSpring a0 (fromBool a1)

{- | It the revolute angular spring enabled?

Binds @b2RevoluteJoint_IsSpringEnabled@.
-}
isSpringEnabled
  :: JointId
  -> IO Bool
isSpringEnabled a0 =
  toBool <$> (c_b2RevoluteJoint_IsSpringEnabled a0)

{- | Set the revolute joint spring stiffness in Hertz

Binds @b2RevoluteJoint_SetSpringHertz@.
-}
setSpringHertz
  :: JointId
  -> Float
  -- ^ @hertz@
  -> IO ()
setSpringHertz a0 a1 =
  c_b2RevoluteJoint_SetSpringHertz a0 a1

{- | Get the revolute joint spring stiffness in Hertz

Binds @b2RevoluteJoint_GetSpringHertz@.
-}
getSpringHertz
  :: JointId
  -> IO Float
getSpringHertz a0 =
  c_b2RevoluteJoint_GetSpringHertz a0

{- | Set the revolute joint spring damping ratio, non-dimensional

Binds @b2RevoluteJoint_SetSpringDampingRatio@.
-}
setSpringDampingRatio
  :: JointId
  -> Float
  -- ^ @dampingRatio@
  -> IO ()
setSpringDampingRatio a0 a1 =
  c_b2RevoluteJoint_SetSpringDampingRatio a0 a1

{- | Get the revolute joint spring damping ratio, non-dimensional

Binds @b2RevoluteJoint_GetSpringDampingRatio@.
-}
getSpringDampingRatio
  :: JointId
  -> IO Float
getSpringDampingRatio a0 =
  c_b2RevoluteJoint_GetSpringDampingRatio a0

{- | Set the revolute joint spring target angle, radians

Binds @b2RevoluteJoint_SetTargetAngle@.
-}
setTargetAngle
  :: JointId
  -> Float
  -- ^ @angle@
  -> IO ()
setTargetAngle a0 a1 =
  c_b2RevoluteJoint_SetTargetAngle a0 a1

{- | Get the revolute joint spring target angle, radians

Binds @b2RevoluteJoint_GetTargetAngle@.
-}
getTargetAngle
  :: JointId
  -> IO Float
getTargetAngle a0 =
  c_b2RevoluteJoint_GetTargetAngle a0

{- | Get the revolute joint current angle in radians relative to the reference angle
See also b2RevoluteJointDef::referenceAngle.

Binds @b2RevoluteJoint_GetAngle@.
-}
getAngle
  :: JointId
  -> IO Float
getAngle a0 =
  c_b2RevoluteJoint_GetAngle a0

{- | Enable\/disable the revolute joint limit

Binds @b2RevoluteJoint_EnableLimit@.
-}
enableLimit
  :: JointId
  -> Bool
  -- ^ @enableLimit@
  -> IO ()
enableLimit a0 a1 =
  c_b2RevoluteJoint_EnableLimit a0 (fromBool a1)

{- | Is the revolute joint limit enabled?

Binds @b2RevoluteJoint_IsLimitEnabled@.
-}
isLimitEnabled
  :: JointId
  -> IO Bool
isLimitEnabled a0 =
  toBool <$> (c_b2RevoluteJoint_IsLimitEnabled a0)

{- | Get the revolute joint lower limit in radians

Binds @b2RevoluteJoint_GetLowerLimit@.
-}
getLowerLimit
  :: JointId
  -> IO Float
getLowerLimit a0 =
  c_b2RevoluteJoint_GetLowerLimit a0

{- | Get the revolute joint upper limit in radians

Binds @b2RevoluteJoint_GetUpperLimit@.
-}
getUpperLimit
  :: JointId
  -> IO Float
getUpperLimit a0 =
  c_b2RevoluteJoint_GetUpperLimit a0

{- | Set the revolute joint limits in radians. It is expected that lower \<= upper
and that -0.99 * B2_PI \<= lower && upper \<= -0.99 * B2_PI.

Binds @b2RevoluteJoint_SetLimits@.
-}
setLimits
  :: JointId
  -> Float
  -- ^ @lower@
  -> Float
  -- ^ @upper@
  -> IO ()
setLimits a0 a1 a2 =
  c_b2RevoluteJoint_SetLimits a0 a1 a2

{- | Enable\/disable a revolute joint motor

Binds @b2RevoluteJoint_EnableMotor@.
-}
enableMotor
  :: JointId
  -> Bool
  -- ^ @enableMotor@
  -> IO ()
enableMotor a0 a1 =
  c_b2RevoluteJoint_EnableMotor a0 (fromBool a1)

{- | Is the revolute joint motor enabled?

Binds @b2RevoluteJoint_IsMotorEnabled@.
-}
isMotorEnabled
  :: JointId
  -> IO Bool
isMotorEnabled a0 =
  toBool <$> (c_b2RevoluteJoint_IsMotorEnabled a0)

{- | Set the revolute joint motor speed in radians per second

Binds @b2RevoluteJoint_SetMotorSpeed@.
-}
setMotorSpeed
  :: JointId
  -> Float
  -- ^ @motorSpeed@
  -> IO ()
setMotorSpeed a0 a1 =
  c_b2RevoluteJoint_SetMotorSpeed a0 a1

{- | Get the revolute joint motor speed in radians per second

Binds @b2RevoluteJoint_GetMotorSpeed@.
-}
getMotorSpeed
  :: JointId
  -> IO Float
getMotorSpeed a0 =
  c_b2RevoluteJoint_GetMotorSpeed a0

{- | Get the revolute joint current motor torque, usually in newton-meters

Binds @b2RevoluteJoint_GetMotorTorque@.
-}
getMotorTorque
  :: JointId
  -> IO Float
getMotorTorque a0 =
  c_b2RevoluteJoint_GetMotorTorque a0

{- | Set the revolute joint maximum motor torque, usually in newton-meters

Binds @b2RevoluteJoint_SetMaxMotorTorque@.
-}
setMaxMotorTorque
  :: JointId
  -> Float
  -- ^ @torque@
  -> IO ()
setMaxMotorTorque a0 a1 =
  c_b2RevoluteJoint_SetMaxMotorTorque a0 a1

{- | Get the revolute joint maximum motor torque, usually in newton-meters

Binds @b2RevoluteJoint_GetMaxMotorTorque@.
-}
getMaxMotorTorque
  :: JointId
  -> IO Float
getMaxMotorTorque a0 =
  c_b2RevoluteJoint_GetMaxMotorTorque a0
