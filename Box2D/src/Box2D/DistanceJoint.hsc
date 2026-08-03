{-# LANGUAGE ForeignFunctionInterface #-}
{-# LANGUAGE PatternSynonyms #-}
{-# LANGUAGE GeneralizedNewtypeDeriving #-}

-- Produced by boxnd-gen; edit the generator, not this file.

module Box2D.DistanceJoint
  ( DistanceJointDef (..)
  , defaultDistanceJointDef
  , create
  , setLength
  , getLength
  , enableSpring
  , isSpringEnabled
  , setSpringForceRange
  , getSpringForceRange
  , setSpringHertz
  , setSpringDampingRatio
  , getSpringHertz
  , getSpringDampingRatio
  , enableLimit
  , isLimitEnabled
  , setLengthRange
  , getMinLength
  , getMaxLength
  , getCurrentLength
  , enableMotor
  , isMotorEnabled
  , setMotorSpeed
  , getMotorSpeed
  , setMaxMotorForce
  , getMaxMotorForce
  , getMotorForce
  )
  where

import Foreign
import Foreign.C.Types (CBool (..), CInt (..))
import Box2D.Internal (allocaOut)
import Box2D.Id (JointId (..), WorldId (..))
import Box2D.Joint (JointDef)

#include "box2d/box2d.h"


-- | Distance joint definition
data DistanceJointDef = DistanceJointDef
  { base :: JointDef
  , length :: Float
  , enableSpring :: CBool
  , lowerSpringForce :: Float
  , upperSpringForce :: Float
  , hertz :: Float
  , dampingRatio :: Float
  , enableLimit :: CBool
  , minLength :: Float
  , maxLength :: Float
  , enableMotor :: CBool
  , maxMotorForce :: Float
  , motorSpeed :: Float
  , internalValue :: CInt
  }
  deriving (Eq, Show)

instance Storable DistanceJointDef where
  sizeOf _ = #{size b2DistanceJointDef}
  alignment _ = #{alignment b2DistanceJointDef}
  peek p =
    DistanceJointDef
      <$> #{peek b2DistanceJointDef, base} p
      <*> #{peek b2DistanceJointDef, length} p
      <*> #{peek b2DistanceJointDef, enableSpring} p
      <*> #{peek b2DistanceJointDef, lowerSpringForce} p
      <*> #{peek b2DistanceJointDef, upperSpringForce} p
      <*> #{peek b2DistanceJointDef, hertz} p
      <*> #{peek b2DistanceJointDef, dampingRatio} p
      <*> #{peek b2DistanceJointDef, enableLimit} p
      <*> #{peek b2DistanceJointDef, minLength} p
      <*> #{peek b2DistanceJointDef, maxLength} p
      <*> #{peek b2DistanceJointDef, enableMotor} p
      <*> #{peek b2DistanceJointDef, maxMotorForce} p
      <*> #{peek b2DistanceJointDef, motorSpeed} p
      <*> #{peek b2DistanceJointDef, internalValue} p
  poke p (DistanceJointDef f1 f2 f3 f4 f5 f6 f7 f8 f9 f10 f11 f12 f13 f14) = do
    #{poke b2DistanceJointDef, base} p f1
    #{poke b2DistanceJointDef, length} p f2
    #{poke b2DistanceJointDef, enableSpring} p f3
    #{poke b2DistanceJointDef, lowerSpringForce} p f4
    #{poke b2DistanceJointDef, upperSpringForce} p f5
    #{poke b2DistanceJointDef, hertz} p f6
    #{poke b2DistanceJointDef, dampingRatio} p f7
    #{poke b2DistanceJointDef, enableLimit} p f8
    #{poke b2DistanceJointDef, minLength} p f9
    #{poke b2DistanceJointDef, maxLength} p f10
    #{poke b2DistanceJointDef, enableMotor} p f11
    #{poke b2DistanceJointDef, maxMotorForce} p f12
    #{poke b2DistanceJointDef, motorSpeed} p f13
    #{poke b2DistanceJointDef, internalValue} p f14

foreign import ccall unsafe "hs_b2DefaultDistanceJointDef"
  c_b2DefaultDistanceJointDef :: Ptr DistanceJointDef -> IO ()

defaultDistanceJointDef :: IO DistanceJointDef
defaultDistanceJointDef = allocaOut c_b2DefaultDistanceJointDef


foreign import ccall unsafe "b2CreateDistanceJoint"
  c_b2CreateDistanceJoint :: WorldId -> Ptr DistanceJointDef -> IO JointId

foreign import ccall unsafe "b2DistanceJoint_SetLength"
  c_b2DistanceJoint_SetLength :: JointId -> Float -> IO ()

foreign import ccall unsafe "b2DistanceJoint_GetLength"
  c_b2DistanceJoint_GetLength :: JointId -> IO Float

foreign import ccall unsafe "b2DistanceJoint_EnableSpring"
  c_b2DistanceJoint_EnableSpring :: JointId -> CBool -> IO ()

foreign import ccall unsafe "b2DistanceJoint_IsSpringEnabled"
  c_b2DistanceJoint_IsSpringEnabled :: JointId -> IO CBool

foreign import ccall unsafe "b2DistanceJoint_SetSpringForceRange"
  c_b2DistanceJoint_SetSpringForceRange :: JointId -> Float -> Float -> IO ()

foreign import ccall unsafe "b2DistanceJoint_GetSpringForceRange"
  c_b2DistanceJoint_GetSpringForceRange :: JointId -> Ptr Float -> Ptr Float -> IO ()

foreign import ccall unsafe "b2DistanceJoint_SetSpringHertz"
  c_b2DistanceJoint_SetSpringHertz :: JointId -> Float -> IO ()

foreign import ccall unsafe "b2DistanceJoint_SetSpringDampingRatio"
  c_b2DistanceJoint_SetSpringDampingRatio :: JointId -> Float -> IO ()

foreign import ccall unsafe "b2DistanceJoint_GetSpringHertz"
  c_b2DistanceJoint_GetSpringHertz :: JointId -> IO Float

foreign import ccall unsafe "b2DistanceJoint_GetSpringDampingRatio"
  c_b2DistanceJoint_GetSpringDampingRatio :: JointId -> IO Float

foreign import ccall unsafe "b2DistanceJoint_EnableLimit"
  c_b2DistanceJoint_EnableLimit :: JointId -> CBool -> IO ()

foreign import ccall unsafe "b2DistanceJoint_IsLimitEnabled"
  c_b2DistanceJoint_IsLimitEnabled :: JointId -> IO CBool

foreign import ccall unsafe "b2DistanceJoint_SetLengthRange"
  c_b2DistanceJoint_SetLengthRange :: JointId -> Float -> Float -> IO ()

foreign import ccall unsafe "b2DistanceJoint_GetMinLength"
  c_b2DistanceJoint_GetMinLength :: JointId -> IO Float

foreign import ccall unsafe "b2DistanceJoint_GetMaxLength"
  c_b2DistanceJoint_GetMaxLength :: JointId -> IO Float

foreign import ccall unsafe "b2DistanceJoint_GetCurrentLength"
  c_b2DistanceJoint_GetCurrentLength :: JointId -> IO Float

foreign import ccall unsafe "b2DistanceJoint_EnableMotor"
  c_b2DistanceJoint_EnableMotor :: JointId -> CBool -> IO ()

foreign import ccall unsafe "b2DistanceJoint_IsMotorEnabled"
  c_b2DistanceJoint_IsMotorEnabled :: JointId -> IO CBool

foreign import ccall unsafe "b2DistanceJoint_SetMotorSpeed"
  c_b2DistanceJoint_SetMotorSpeed :: JointId -> Float -> IO ()

foreign import ccall unsafe "b2DistanceJoint_GetMotorSpeed"
  c_b2DistanceJoint_GetMotorSpeed :: JointId -> IO Float

foreign import ccall unsafe "b2DistanceJoint_SetMaxMotorForce"
  c_b2DistanceJoint_SetMaxMotorForce :: JointId -> Float -> IO ()

foreign import ccall unsafe "b2DistanceJoint_GetMaxMotorForce"
  c_b2DistanceJoint_GetMaxMotorForce :: JointId -> IO Float

foreign import ccall unsafe "b2DistanceJoint_GetMotorForce"
  c_b2DistanceJoint_GetMotorForce :: JointId -> IO Float

{- | Create a distance joint
See also b2DistanceJointDef for details.

Binds @b2CreateDistanceJoint@.
-}
create
  :: WorldId
  -> DistanceJointDef
  -> IO JointId
create a0 a1 =
  with a1 $ \p1 ->
  c_b2CreateDistanceJoint a0 p1

{- | Set the rest length of a distance joint

Binds @b2DistanceJoint_SetLength@.
-}
setLength
  :: JointId
  -- ^ @jointId@: The id for a distance joint
  -> Float
  -- ^ @length@: The new distance joint length
  -> IO ()
setLength a0 a1 =
  c_b2DistanceJoint_SetLength a0 a1

{- | Get the rest length of a distance joint

Binds @b2DistanceJoint_GetLength@.
-}
getLength
  :: JointId
  -> IO Float
getLength a0 =
  c_b2DistanceJoint_GetLength a0

{- | Enable\/disable the distance joint spring. When disabled the distance joint is rigid.

Binds @b2DistanceJoint_EnableSpring@.
-}
enableSpring
  :: JointId
  -> Bool
  -- ^ @enableSpring@
  -> IO ()
enableSpring a0 a1 =
  c_b2DistanceJoint_EnableSpring a0 (fromBool a1)

{- | Is the distance joint spring enabled?

Binds @b2DistanceJoint_IsSpringEnabled@.
-}
isSpringEnabled
  :: JointId
  -> IO Bool
isSpringEnabled a0 =
  toBool <$> (c_b2DistanceJoint_IsSpringEnabled a0)

{- | Set the force range for the spring.

Binds @b2DistanceJoint_SetSpringForceRange@.
-}
setSpringForceRange
  :: JointId
  -> Float
  -- ^ @lowerForce@
  -> Float
  -- ^ @upperForce@
  -> IO ()
setSpringForceRange a0 a1 a2 =
  c_b2DistanceJoint_SetSpringForceRange a0 a1 a2

{- | Get the force range for the spring.

Binds @b2DistanceJoint_GetSpringForceRange@.
-}
getSpringForceRange
  :: JointId
  -> Ptr Float
  -- ^ @lowerForce@
  -> Ptr Float
  -- ^ @upperForce@
  -> IO ()
getSpringForceRange a0 a1 a2 =
  c_b2DistanceJoint_GetSpringForceRange a0 a1 a2

{- | Set the spring stiffness in Hertz

Binds @b2DistanceJoint_SetSpringHertz@.
-}
setSpringHertz
  :: JointId
  -> Float
  -- ^ @hertz@
  -> IO ()
setSpringHertz a0 a1 =
  c_b2DistanceJoint_SetSpringHertz a0 a1

{- | Set the spring damping ratio, non-dimensional

Binds @b2DistanceJoint_SetSpringDampingRatio@.
-}
setSpringDampingRatio
  :: JointId
  -> Float
  -- ^ @dampingRatio@
  -> IO ()
setSpringDampingRatio a0 a1 =
  c_b2DistanceJoint_SetSpringDampingRatio a0 a1

{- | Get the spring Hertz

Binds @b2DistanceJoint_GetSpringHertz@.
-}
getSpringHertz
  :: JointId
  -> IO Float
getSpringHertz a0 =
  c_b2DistanceJoint_GetSpringHertz a0

{- | Get the spring damping ratio

Binds @b2DistanceJoint_GetSpringDampingRatio@.
-}
getSpringDampingRatio
  :: JointId
  -> IO Float
getSpringDampingRatio a0 =
  c_b2DistanceJoint_GetSpringDampingRatio a0

{- | Enable joint limit. The limit only works if the joint spring is enabled. Otherwise the joint is rigid
and the limit has no effect.

Binds @b2DistanceJoint_EnableLimit@.
-}
enableLimit
  :: JointId
  -> Bool
  -- ^ @enableLimit@
  -> IO ()
enableLimit a0 a1 =
  c_b2DistanceJoint_EnableLimit a0 (fromBool a1)

{- | Is the distance joint limit enabled?

Binds @b2DistanceJoint_IsLimitEnabled@.
-}
isLimitEnabled
  :: JointId
  -> IO Bool
isLimitEnabled a0 =
  toBool <$> (c_b2DistanceJoint_IsLimitEnabled a0)

{- | Set the minimum and maximum length parameters of a distance joint

Binds @b2DistanceJoint_SetLengthRange@.
-}
setLengthRange
  :: JointId
  -> Float
  -- ^ @minLength@
  -> Float
  -- ^ @maxLength@
  -> IO ()
setLengthRange a0 a1 a2 =
  c_b2DistanceJoint_SetLengthRange a0 a1 a2

{- | Get the distance joint minimum length

Binds @b2DistanceJoint_GetMinLength@.
-}
getMinLength
  :: JointId
  -> IO Float
getMinLength a0 =
  c_b2DistanceJoint_GetMinLength a0

{- | Get the distance joint maximum length

Binds @b2DistanceJoint_GetMaxLength@.
-}
getMaxLength
  :: JointId
  -> IO Float
getMaxLength a0 =
  c_b2DistanceJoint_GetMaxLength a0

{- | Get the current length of a distance joint

Binds @b2DistanceJoint_GetCurrentLength@.
-}
getCurrentLength
  :: JointId
  -> IO Float
getCurrentLength a0 =
  c_b2DistanceJoint_GetCurrentLength a0

{- | Enable\/disable the distance joint motor

Binds @b2DistanceJoint_EnableMotor@.
-}
enableMotor
  :: JointId
  -> Bool
  -- ^ @enableMotor@
  -> IO ()
enableMotor a0 a1 =
  c_b2DistanceJoint_EnableMotor a0 (fromBool a1)

{- | Is the distance joint motor enabled?

Binds @b2DistanceJoint_IsMotorEnabled@.
-}
isMotorEnabled
  :: JointId
  -> IO Bool
isMotorEnabled a0 =
  toBool <$> (c_b2DistanceJoint_IsMotorEnabled a0)

{- | Set the distance joint motor speed, usually in meters per second

Binds @b2DistanceJoint_SetMotorSpeed@.
-}
setMotorSpeed
  :: JointId
  -> Float
  -- ^ @motorSpeed@
  -> IO ()
setMotorSpeed a0 a1 =
  c_b2DistanceJoint_SetMotorSpeed a0 a1

{- | Get the distance joint motor speed, usually in meters per second

Binds @b2DistanceJoint_GetMotorSpeed@.
-}
getMotorSpeed
  :: JointId
  -> IO Float
getMotorSpeed a0 =
  c_b2DistanceJoint_GetMotorSpeed a0

{- | Set the distance joint maximum motor force, usually in newtons

Binds @b2DistanceJoint_SetMaxMotorForce@.
-}
setMaxMotorForce
  :: JointId
  -> Float
  -- ^ @force@
  -> IO ()
setMaxMotorForce a0 a1 =
  c_b2DistanceJoint_SetMaxMotorForce a0 a1

{- | Get the distance joint maximum motor force, usually in newtons

Binds @b2DistanceJoint_GetMaxMotorForce@.
-}
getMaxMotorForce
  :: JointId
  -> IO Float
getMaxMotorForce a0 =
  c_b2DistanceJoint_GetMaxMotorForce a0

{- | Get the distance joint current motor force, usually in newtons

Binds @b2DistanceJoint_GetMotorForce@.
-}
getMotorForce
  :: JointId
  -> IO Float
getMotorForce a0 =
  c_b2DistanceJoint_GetMotorForce a0
