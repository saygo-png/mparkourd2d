{-# LANGUAGE ForeignFunctionInterface #-}
{-# LANGUAGE PatternSynonyms #-}
{-# LANGUAGE GeneralizedNewtypeDeriving #-}

-- Produced by boxnd-gen; edit the generator, not this file.

module Box2D.WheelJoint
  ( WheelJointDef (..)
  , defaultWheelJointDef
  , create
  , enableSpring
  , isSpringEnabled
  , setSpringHertz
  , getSpringHertz
  , setSpringDampingRatio
  , getSpringDampingRatio
  , enableLimit
  , isLimitEnabled
  , getLowerLimit
  , getUpperLimit
  , setLimits
  , enableMotor
  , isMotorEnabled
  , setMotorSpeed
  , getMotorSpeed
  , setMaxMotorTorque
  , getMaxMotorTorque
  , getMotorTorque
  )
  where

import Foreign
import Foreign.C.Types (CBool (..), CInt (..))
import Box2D.Internal (allocaOut)
import Box2D.Id (JointId (..), WorldId (..))
import Box2D.Joint (JointDef)

#include "box2d/box2d.h"


-- | Wheel joint definition
data WheelJointDef = WheelJointDef
  { base :: JointDef
  , enableSpring :: CBool
  , hertz :: Float
  , dampingRatio :: Float
  , enableLimit :: CBool
  , lowerTranslation :: Float
  , upperTranslation :: Float
  , enableMotor :: CBool
  , maxMotorTorque :: Float
  , motorSpeed :: Float
  , internalValue :: CInt
  }
  deriving (Eq, Show)

instance Storable WheelJointDef where
  sizeOf _ = #{size b2WheelJointDef}
  alignment _ = #{alignment b2WheelJointDef}
  peek p =
    WheelJointDef
      <$> #{peek b2WheelJointDef, base} p
      <*> #{peek b2WheelJointDef, enableSpring} p
      <*> #{peek b2WheelJointDef, hertz} p
      <*> #{peek b2WheelJointDef, dampingRatio} p
      <*> #{peek b2WheelJointDef, enableLimit} p
      <*> #{peek b2WheelJointDef, lowerTranslation} p
      <*> #{peek b2WheelJointDef, upperTranslation} p
      <*> #{peek b2WheelJointDef, enableMotor} p
      <*> #{peek b2WheelJointDef, maxMotorTorque} p
      <*> #{peek b2WheelJointDef, motorSpeed} p
      <*> #{peek b2WheelJointDef, internalValue} p
  poke p (WheelJointDef f1 f2 f3 f4 f5 f6 f7 f8 f9 f10 f11) = do
    #{poke b2WheelJointDef, base} p f1
    #{poke b2WheelJointDef, enableSpring} p f2
    #{poke b2WheelJointDef, hertz} p f3
    #{poke b2WheelJointDef, dampingRatio} p f4
    #{poke b2WheelJointDef, enableLimit} p f5
    #{poke b2WheelJointDef, lowerTranslation} p f6
    #{poke b2WheelJointDef, upperTranslation} p f7
    #{poke b2WheelJointDef, enableMotor} p f8
    #{poke b2WheelJointDef, maxMotorTorque} p f9
    #{poke b2WheelJointDef, motorSpeed} p f10
    #{poke b2WheelJointDef, internalValue} p f11

foreign import ccall unsafe "hs_b2DefaultWheelJointDef"
  c_b2DefaultWheelJointDef :: Ptr WheelJointDef -> IO ()

defaultWheelJointDef :: IO WheelJointDef
defaultWheelJointDef = allocaOut c_b2DefaultWheelJointDef


foreign import ccall unsafe "b2CreateWheelJoint"
  c_b2CreateWheelJoint :: WorldId -> Ptr WheelJointDef -> IO JointId

foreign import ccall unsafe "b2WheelJoint_EnableSpring"
  c_b2WheelJoint_EnableSpring :: JointId -> CBool -> IO ()

foreign import ccall unsafe "b2WheelJoint_IsSpringEnabled"
  c_b2WheelJoint_IsSpringEnabled :: JointId -> IO CBool

foreign import ccall unsafe "b2WheelJoint_SetSpringHertz"
  c_b2WheelJoint_SetSpringHertz :: JointId -> Float -> IO ()

foreign import ccall unsafe "b2WheelJoint_GetSpringHertz"
  c_b2WheelJoint_GetSpringHertz :: JointId -> IO Float

foreign import ccall unsafe "b2WheelJoint_SetSpringDampingRatio"
  c_b2WheelJoint_SetSpringDampingRatio :: JointId -> Float -> IO ()

foreign import ccall unsafe "b2WheelJoint_GetSpringDampingRatio"
  c_b2WheelJoint_GetSpringDampingRatio :: JointId -> IO Float

foreign import ccall unsafe "b2WheelJoint_EnableLimit"
  c_b2WheelJoint_EnableLimit :: JointId -> CBool -> IO ()

foreign import ccall unsafe "b2WheelJoint_IsLimitEnabled"
  c_b2WheelJoint_IsLimitEnabled :: JointId -> IO CBool

foreign import ccall unsafe "b2WheelJoint_GetLowerLimit"
  c_b2WheelJoint_GetLowerLimit :: JointId -> IO Float

foreign import ccall unsafe "b2WheelJoint_GetUpperLimit"
  c_b2WheelJoint_GetUpperLimit :: JointId -> IO Float

foreign import ccall unsafe "b2WheelJoint_SetLimits"
  c_b2WheelJoint_SetLimits :: JointId -> Float -> Float -> IO ()

foreign import ccall unsafe "b2WheelJoint_EnableMotor"
  c_b2WheelJoint_EnableMotor :: JointId -> CBool -> IO ()

foreign import ccall unsafe "b2WheelJoint_IsMotorEnabled"
  c_b2WheelJoint_IsMotorEnabled :: JointId -> IO CBool

foreign import ccall unsafe "b2WheelJoint_SetMotorSpeed"
  c_b2WheelJoint_SetMotorSpeed :: JointId -> Float -> IO ()

foreign import ccall unsafe "b2WheelJoint_GetMotorSpeed"
  c_b2WheelJoint_GetMotorSpeed :: JointId -> IO Float

foreign import ccall unsafe "b2WheelJoint_SetMaxMotorTorque"
  c_b2WheelJoint_SetMaxMotorTorque :: JointId -> Float -> IO ()

foreign import ccall unsafe "b2WheelJoint_GetMaxMotorTorque"
  c_b2WheelJoint_GetMaxMotorTorque :: JointId -> IO Float

foreign import ccall unsafe "b2WheelJoint_GetMotorTorque"
  c_b2WheelJoint_GetMotorTorque :: JointId -> IO Float

{- | Create a wheel joint
See also b2WheelJointDef for details.

Binds @b2CreateWheelJoint@.
-}
create
  :: WorldId
  -> WheelJointDef
  -> IO JointId
create a0 a1 =
  with a1 $ \p1 ->
  c_b2CreateWheelJoint a0 p1

{- | Enable\/disable the wheel joint spring

Binds @b2WheelJoint_EnableSpring@.
-}
enableSpring
  :: JointId
  -> Bool
  -- ^ @enableSpring@
  -> IO ()
enableSpring a0 a1 =
  c_b2WheelJoint_EnableSpring a0 (fromBool a1)

{- | Is the wheel joint spring enabled?

Binds @b2WheelJoint_IsSpringEnabled@.
-}
isSpringEnabled
  :: JointId
  -> IO Bool
isSpringEnabled a0 =
  toBool <$> (c_b2WheelJoint_IsSpringEnabled a0)

{- | Set the wheel joint stiffness in Hertz

Binds @b2WheelJoint_SetSpringHertz@.
-}
setSpringHertz
  :: JointId
  -> Float
  -- ^ @hertz@
  -> IO ()
setSpringHertz a0 a1 =
  c_b2WheelJoint_SetSpringHertz a0 a1

{- | Get the wheel joint stiffness in Hertz

Binds @b2WheelJoint_GetSpringHertz@.
-}
getSpringHertz
  :: JointId
  -> IO Float
getSpringHertz a0 =
  c_b2WheelJoint_GetSpringHertz a0

{- | Set the wheel joint damping ratio, non-dimensional

Binds @b2WheelJoint_SetSpringDampingRatio@.
-}
setSpringDampingRatio
  :: JointId
  -> Float
  -- ^ @dampingRatio@
  -> IO ()
setSpringDampingRatio a0 a1 =
  c_b2WheelJoint_SetSpringDampingRatio a0 a1

{- | Get the wheel joint damping ratio, non-dimensional

Binds @b2WheelJoint_GetSpringDampingRatio@.
-}
getSpringDampingRatio
  :: JointId
  -> IO Float
getSpringDampingRatio a0 =
  c_b2WheelJoint_GetSpringDampingRatio a0

{- | Enable\/disable the wheel joint limit

Binds @b2WheelJoint_EnableLimit@.
-}
enableLimit
  :: JointId
  -> Bool
  -- ^ @enableLimit@
  -> IO ()
enableLimit a0 a1 =
  c_b2WheelJoint_EnableLimit a0 (fromBool a1)

{- | Is the wheel joint limit enabled?

Binds @b2WheelJoint_IsLimitEnabled@.
-}
isLimitEnabled
  :: JointId
  -> IO Bool
isLimitEnabled a0 =
  toBool <$> (c_b2WheelJoint_IsLimitEnabled a0)

{- | Get the wheel joint lower limit

Binds @b2WheelJoint_GetLowerLimit@.
-}
getLowerLimit
  :: JointId
  -> IO Float
getLowerLimit a0 =
  c_b2WheelJoint_GetLowerLimit a0

{- | Get the wheel joint upper limit

Binds @b2WheelJoint_GetUpperLimit@.
-}
getUpperLimit
  :: JointId
  -> IO Float
getUpperLimit a0 =
  c_b2WheelJoint_GetUpperLimit a0

{- | Set the wheel joint limits

Binds @b2WheelJoint_SetLimits@.
-}
setLimits
  :: JointId
  -> Float
  -- ^ @lower@
  -> Float
  -- ^ @upper@
  -> IO ()
setLimits a0 a1 a2 =
  c_b2WheelJoint_SetLimits a0 a1 a2

{- | Enable\/disable the wheel joint motor

Binds @b2WheelJoint_EnableMotor@.
-}
enableMotor
  :: JointId
  -> Bool
  -- ^ @enableMotor@
  -> IO ()
enableMotor a0 a1 =
  c_b2WheelJoint_EnableMotor a0 (fromBool a1)

{- | Is the wheel joint motor enabled?

Binds @b2WheelJoint_IsMotorEnabled@.
-}
isMotorEnabled
  :: JointId
  -> IO Bool
isMotorEnabled a0 =
  toBool <$> (c_b2WheelJoint_IsMotorEnabled a0)

{- | Set the wheel joint motor speed in radians per second

Binds @b2WheelJoint_SetMotorSpeed@.
-}
setMotorSpeed
  :: JointId
  -> Float
  -- ^ @motorSpeed@
  -> IO ()
setMotorSpeed a0 a1 =
  c_b2WheelJoint_SetMotorSpeed a0 a1

{- | Get the wheel joint motor speed in radians per second

Binds @b2WheelJoint_GetMotorSpeed@.
-}
getMotorSpeed
  :: JointId
  -> IO Float
getMotorSpeed a0 =
  c_b2WheelJoint_GetMotorSpeed a0

{- | Set the wheel joint maximum motor torque, usually in newton-meters

Binds @b2WheelJoint_SetMaxMotorTorque@.
-}
setMaxMotorTorque
  :: JointId
  -> Float
  -- ^ @torque@
  -> IO ()
setMaxMotorTorque a0 a1 =
  c_b2WheelJoint_SetMaxMotorTorque a0 a1

{- | Get the wheel joint maximum motor torque, usually in newton-meters

Binds @b2WheelJoint_GetMaxMotorTorque@.
-}
getMaxMotorTorque
  :: JointId
  -> IO Float
getMaxMotorTorque a0 =
  c_b2WheelJoint_GetMaxMotorTorque a0

{- | Get the wheel joint current motor torque, usually in newton-meters

Binds @b2WheelJoint_GetMotorTorque@.
-}
getMotorTorque
  :: JointId
  -> IO Float
getMotorTorque a0 =
  c_b2WheelJoint_GetMotorTorque a0
