{-# LANGUAGE ForeignFunctionInterface #-}
{-# LANGUAGE PatternSynonyms #-}
{-# LANGUAGE GeneralizedNewtypeDeriving #-}

-- Produced by boxnd-gen; edit the generator, not this file.

module Box2D.PrismaticJoint
  ( PrismaticJointDef (..)
  , defaultPrismaticJointDef
  , create
  , enableSpring
  , isSpringEnabled
  , setSpringHertz
  , getSpringHertz
  , setSpringDampingRatio
  , getSpringDampingRatio
  , setTargetTranslation
  , getTargetTranslation
  , enableLimit
  , isLimitEnabled
  , getLowerLimit
  , getUpperLimit
  , setLimits
  , enableMotor
  , isMotorEnabled
  , setMotorSpeed
  , getMotorSpeed
  , setMaxMotorForce
  , getMaxMotorForce
  , getMotorForce
  , getTranslation
  , getSpeed
  )
  where

import Foreign
import Foreign.C.Types (CBool (..), CInt (..))
import Box2D.Internal (allocaOut)
import Box2D.Id (JointId (..), WorldId (..))
import Box2D.Joint (JointDef)

#include "box2d/box2d.h"


-- | Prismatic joint definition
data PrismaticJointDef = PrismaticJointDef
  { base :: JointDef
  , enableSpring :: CBool
  , hertz :: Float
  , dampingRatio :: Float
  , targetTranslation :: Float
  , enableLimit :: CBool
  , lowerTranslation :: Float
  , upperTranslation :: Float
  , enableMotor :: CBool
  , maxMotorForce :: Float
  , motorSpeed :: Float
  , internalValue :: CInt
  }
  deriving (Eq, Show)

instance Storable PrismaticJointDef where
  sizeOf _ = #{size b2PrismaticJointDef}
  alignment _ = #{alignment b2PrismaticJointDef}
  peek p =
    PrismaticJointDef
      <$> #{peek b2PrismaticJointDef, base} p
      <*> #{peek b2PrismaticJointDef, enableSpring} p
      <*> #{peek b2PrismaticJointDef, hertz} p
      <*> #{peek b2PrismaticJointDef, dampingRatio} p
      <*> #{peek b2PrismaticJointDef, targetTranslation} p
      <*> #{peek b2PrismaticJointDef, enableLimit} p
      <*> #{peek b2PrismaticJointDef, lowerTranslation} p
      <*> #{peek b2PrismaticJointDef, upperTranslation} p
      <*> #{peek b2PrismaticJointDef, enableMotor} p
      <*> #{peek b2PrismaticJointDef, maxMotorForce} p
      <*> #{peek b2PrismaticJointDef, motorSpeed} p
      <*> #{peek b2PrismaticJointDef, internalValue} p
  poke p (PrismaticJointDef f1 f2 f3 f4 f5 f6 f7 f8 f9 f10 f11 f12) = do
    #{poke b2PrismaticJointDef, base} p f1
    #{poke b2PrismaticJointDef, enableSpring} p f2
    #{poke b2PrismaticJointDef, hertz} p f3
    #{poke b2PrismaticJointDef, dampingRatio} p f4
    #{poke b2PrismaticJointDef, targetTranslation} p f5
    #{poke b2PrismaticJointDef, enableLimit} p f6
    #{poke b2PrismaticJointDef, lowerTranslation} p f7
    #{poke b2PrismaticJointDef, upperTranslation} p f8
    #{poke b2PrismaticJointDef, enableMotor} p f9
    #{poke b2PrismaticJointDef, maxMotorForce} p f10
    #{poke b2PrismaticJointDef, motorSpeed} p f11
    #{poke b2PrismaticJointDef, internalValue} p f12

foreign import ccall unsafe "hs_b2DefaultPrismaticJointDef"
  c_b2DefaultPrismaticJointDef :: Ptr PrismaticJointDef -> IO ()

defaultPrismaticJointDef :: IO PrismaticJointDef
defaultPrismaticJointDef = allocaOut c_b2DefaultPrismaticJointDef


foreign import ccall unsafe "b2CreatePrismaticJoint"
  c_b2CreatePrismaticJoint :: WorldId -> Ptr PrismaticJointDef -> IO JointId

foreign import ccall unsafe "b2PrismaticJoint_EnableSpring"
  c_b2PrismaticJoint_EnableSpring :: JointId -> CBool -> IO ()

foreign import ccall unsafe "b2PrismaticJoint_IsSpringEnabled"
  c_b2PrismaticJoint_IsSpringEnabled :: JointId -> IO CBool

foreign import ccall unsafe "b2PrismaticJoint_SetSpringHertz"
  c_b2PrismaticJoint_SetSpringHertz :: JointId -> Float -> IO ()

foreign import ccall unsafe "b2PrismaticJoint_GetSpringHertz"
  c_b2PrismaticJoint_GetSpringHertz :: JointId -> IO Float

foreign import ccall unsafe "b2PrismaticJoint_SetSpringDampingRatio"
  c_b2PrismaticJoint_SetSpringDampingRatio :: JointId -> Float -> IO ()

foreign import ccall unsafe "b2PrismaticJoint_GetSpringDampingRatio"
  c_b2PrismaticJoint_GetSpringDampingRatio :: JointId -> IO Float

foreign import ccall unsafe "b2PrismaticJoint_SetTargetTranslation"
  c_b2PrismaticJoint_SetTargetTranslation :: JointId -> Float -> IO ()

foreign import ccall unsafe "b2PrismaticJoint_GetTargetTranslation"
  c_b2PrismaticJoint_GetTargetTranslation :: JointId -> IO Float

foreign import ccall unsafe "b2PrismaticJoint_EnableLimit"
  c_b2PrismaticJoint_EnableLimit :: JointId -> CBool -> IO ()

foreign import ccall unsafe "b2PrismaticJoint_IsLimitEnabled"
  c_b2PrismaticJoint_IsLimitEnabled :: JointId -> IO CBool

foreign import ccall unsafe "b2PrismaticJoint_GetLowerLimit"
  c_b2PrismaticJoint_GetLowerLimit :: JointId -> IO Float

foreign import ccall unsafe "b2PrismaticJoint_GetUpperLimit"
  c_b2PrismaticJoint_GetUpperLimit :: JointId -> IO Float

foreign import ccall unsafe "b2PrismaticJoint_SetLimits"
  c_b2PrismaticJoint_SetLimits :: JointId -> Float -> Float -> IO ()

foreign import ccall unsafe "b2PrismaticJoint_EnableMotor"
  c_b2PrismaticJoint_EnableMotor :: JointId -> CBool -> IO ()

foreign import ccall unsafe "b2PrismaticJoint_IsMotorEnabled"
  c_b2PrismaticJoint_IsMotorEnabled :: JointId -> IO CBool

foreign import ccall unsafe "b2PrismaticJoint_SetMotorSpeed"
  c_b2PrismaticJoint_SetMotorSpeed :: JointId -> Float -> IO ()

foreign import ccall unsafe "b2PrismaticJoint_GetMotorSpeed"
  c_b2PrismaticJoint_GetMotorSpeed :: JointId -> IO Float

foreign import ccall unsafe "b2PrismaticJoint_SetMaxMotorForce"
  c_b2PrismaticJoint_SetMaxMotorForce :: JointId -> Float -> IO ()

foreign import ccall unsafe "b2PrismaticJoint_GetMaxMotorForce"
  c_b2PrismaticJoint_GetMaxMotorForce :: JointId -> IO Float

foreign import ccall unsafe "b2PrismaticJoint_GetMotorForce"
  c_b2PrismaticJoint_GetMotorForce :: JointId -> IO Float

foreign import ccall unsafe "b2PrismaticJoint_GetTranslation"
  c_b2PrismaticJoint_GetTranslation :: JointId -> IO Float

foreign import ccall unsafe "b2PrismaticJoint_GetSpeed"
  c_b2PrismaticJoint_GetSpeed :: JointId -> IO Float

{- | Create a prismatic (slider) joint.
See also b2PrismaticJointDef for details.

Binds @b2CreatePrismaticJoint@.
-}
create
  :: WorldId
  -> PrismaticJointDef
  -> IO JointId
create a0 a1 =
  with a1 $ \p1 ->
  c_b2CreatePrismaticJoint a0 p1

{- | Enable\/disable the joint spring.

Binds @b2PrismaticJoint_EnableSpring@.
-}
enableSpring
  :: JointId
  -> Bool
  -- ^ @enableSpring@
  -> IO ()
enableSpring a0 a1 =
  c_b2PrismaticJoint_EnableSpring a0 (fromBool a1)

{- | Is the prismatic joint spring enabled or not?

Binds @b2PrismaticJoint_IsSpringEnabled@.
-}
isSpringEnabled
  :: JointId
  -> IO Bool
isSpringEnabled a0 =
  toBool <$> (c_b2PrismaticJoint_IsSpringEnabled a0)

{- | Set the prismatic joint stiffness in Hertz.
This should usually be less than a quarter of the simulation rate. For example, if the simulation
runs at 60Hz then the joint stiffness should be 15Hz or less.

Binds @b2PrismaticJoint_SetSpringHertz@.
-}
setSpringHertz
  :: JointId
  -> Float
  -- ^ @hertz@
  -> IO ()
setSpringHertz a0 a1 =
  c_b2PrismaticJoint_SetSpringHertz a0 a1

{- | Get the prismatic joint stiffness in Hertz

Binds @b2PrismaticJoint_GetSpringHertz@.
-}
getSpringHertz
  :: JointId
  -> IO Float
getSpringHertz a0 =
  c_b2PrismaticJoint_GetSpringHertz a0

{- | Set the prismatic joint damping ratio (non-dimensional)

Binds @b2PrismaticJoint_SetSpringDampingRatio@.
-}
setSpringDampingRatio
  :: JointId
  -> Float
  -- ^ @dampingRatio@
  -> IO ()
setSpringDampingRatio a0 a1 =
  c_b2PrismaticJoint_SetSpringDampingRatio a0 a1

{- | Get the prismatic spring damping ratio (non-dimensional)

Binds @b2PrismaticJoint_GetSpringDampingRatio@.
-}
getSpringDampingRatio
  :: JointId
  -> IO Float
getSpringDampingRatio a0 =
  c_b2PrismaticJoint_GetSpringDampingRatio a0

{- | Set the prismatic joint spring target angle, usually in meters

Binds @b2PrismaticJoint_SetTargetTranslation@.
-}
setTargetTranslation
  :: JointId
  -> Float
  -- ^ @translation@
  -> IO ()
setTargetTranslation a0 a1 =
  c_b2PrismaticJoint_SetTargetTranslation a0 a1

{- | Get the prismatic joint spring target translation, usually in meters

Binds @b2PrismaticJoint_GetTargetTranslation@.
-}
getTargetTranslation
  :: JointId
  -> IO Float
getTargetTranslation a0 =
  c_b2PrismaticJoint_GetTargetTranslation a0

{- | Enable\/disable a prismatic joint limit

Binds @b2PrismaticJoint_EnableLimit@.
-}
enableLimit
  :: JointId
  -> Bool
  -- ^ @enableLimit@
  -> IO ()
enableLimit a0 a1 =
  c_b2PrismaticJoint_EnableLimit a0 (fromBool a1)

{- | Is the prismatic joint limit enabled?

Binds @b2PrismaticJoint_IsLimitEnabled@.
-}
isLimitEnabled
  :: JointId
  -> IO Bool
isLimitEnabled a0 =
  toBool <$> (c_b2PrismaticJoint_IsLimitEnabled a0)

{- | Get the prismatic joint lower limit

Binds @b2PrismaticJoint_GetLowerLimit@.
-}
getLowerLimit
  :: JointId
  -> IO Float
getLowerLimit a0 =
  c_b2PrismaticJoint_GetLowerLimit a0

{- | Get the prismatic joint upper limit

Binds @b2PrismaticJoint_GetUpperLimit@.
-}
getUpperLimit
  :: JointId
  -> IO Float
getUpperLimit a0 =
  c_b2PrismaticJoint_GetUpperLimit a0

{- | Set the prismatic joint limits

Binds @b2PrismaticJoint_SetLimits@.
-}
setLimits
  :: JointId
  -> Float
  -- ^ @lower@
  -> Float
  -- ^ @upper@
  -> IO ()
setLimits a0 a1 a2 =
  c_b2PrismaticJoint_SetLimits a0 a1 a2

{- | Enable\/disable a prismatic joint motor

Binds @b2PrismaticJoint_EnableMotor@.
-}
enableMotor
  :: JointId
  -> Bool
  -- ^ @enableMotor@
  -> IO ()
enableMotor a0 a1 =
  c_b2PrismaticJoint_EnableMotor a0 (fromBool a1)

{- | Is the prismatic joint motor enabled?

Binds @b2PrismaticJoint_IsMotorEnabled@.
-}
isMotorEnabled
  :: JointId
  -> IO Bool
isMotorEnabled a0 =
  toBool <$> (c_b2PrismaticJoint_IsMotorEnabled a0)

{- | Set the prismatic joint motor speed, usually in meters per second

Binds @b2PrismaticJoint_SetMotorSpeed@.
-}
setMotorSpeed
  :: JointId
  -> Float
  -- ^ @motorSpeed@
  -> IO ()
setMotorSpeed a0 a1 =
  c_b2PrismaticJoint_SetMotorSpeed a0 a1

{- | Get the prismatic joint motor speed, usually in meters per second

Binds @b2PrismaticJoint_GetMotorSpeed@.
-}
getMotorSpeed
  :: JointId
  -> IO Float
getMotorSpeed a0 =
  c_b2PrismaticJoint_GetMotorSpeed a0

{- | Set the prismatic joint maximum motor force, usually in newtons

Binds @b2PrismaticJoint_SetMaxMotorForce@.
-}
setMaxMotorForce
  :: JointId
  -> Float
  -- ^ @force@
  -> IO ()
setMaxMotorForce a0 a1 =
  c_b2PrismaticJoint_SetMaxMotorForce a0 a1

{- | Get the prismatic joint maximum motor force, usually in newtons

Binds @b2PrismaticJoint_GetMaxMotorForce@.
-}
getMaxMotorForce
  :: JointId
  -> IO Float
getMaxMotorForce a0 =
  c_b2PrismaticJoint_GetMaxMotorForce a0

{- | Get the prismatic joint current motor force, usually in newtons

Binds @b2PrismaticJoint_GetMotorForce@.
-}
getMotorForce
  :: JointId
  -> IO Float
getMotorForce a0 =
  c_b2PrismaticJoint_GetMotorForce a0

{- | Get the current joint translation, usually in meters.

Binds @b2PrismaticJoint_GetTranslation@.
-}
getTranslation
  :: JointId
  -> IO Float
getTranslation a0 =
  c_b2PrismaticJoint_GetTranslation a0

{- | Get the current joint translation speed, usually in meters per second.

Binds @b2PrismaticJoint_GetSpeed@.
-}
getSpeed
  :: JointId
  -> IO Float
getSpeed a0 =
  c_b2PrismaticJoint_GetSpeed a0
