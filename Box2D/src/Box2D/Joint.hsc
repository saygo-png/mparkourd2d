{-# LANGUAGE ForeignFunctionInterface #-}
{-# LANGUAGE PatternSynonyms #-}
{-# LANGUAGE GeneralizedNewtypeDeriving #-}

-- Produced by boxnd-gen; edit the generator, not this file.

module Box2D.Joint
  ( JointDef (..)
  , JointType (..)
  , pattern DistanceJoint
  , pattern FilterJoint
  , pattern MotorJoint
  , pattern PrismaticJoint
  , pattern RevoluteJoint
  , pattern WeldJoint
  , pattern WheelJoint
  , destroy
  , isValid
  , getType
  , getBodyA
  , getBodyB
  , getWorld
  , setLocalFrameA
  , getLocalFrameA
  , getLocalFrameAInto
  , setLocalFrameB
  , getLocalFrameB
  , getLocalFrameBInto
  , setCollideConnected
  , getCollideConnected
  , setUserData
  , getUserData
  , wakeBodies
  , getConstraintForce
  , getConstraintForceInto
  , getConstraintTorque
  , getLinearSeparation
  , getAngularSeparation
  , setConstraintTuning
  , getConstraintTuning
  , setForceThreshold
  , getForceThreshold
  , setTorqueThreshold
  , getTorqueThreshold
  )
  where

import Foreign
import Foreign.C.Types (CBool (..), CInt (..))
import Data.Coerce (coerce)
import Box2D.Id (BodyId (..), JointId (..), WorldId (..))
import Box2D.MathTypes (Transform, Vec2)

#include "box2d/box2d.h"


-- | Base joint definition used by all joint types.
data JointDef = JointDef
  { userData :: Ptr ()
  , bodyIdA :: BodyId
  , bodyIdB :: BodyId
  , localFrameA :: Transform
  , localFrameB :: Transform
  , forceThreshold :: Float
  , torqueThreshold :: Float
  , constraintHertz :: Float
  , constraintDampingRatio :: Float
  , drawScale :: Float
  , collideConnected :: CBool
  }
  deriving (Eq, Show)

instance Storable JointDef where
  sizeOf _ = #{size b2JointDef}
  alignment _ = #{alignment b2JointDef}
  peek p =
    JointDef
      <$> #{peek b2JointDef, userData} p
      <*> #{peek b2JointDef, bodyIdA} p
      <*> #{peek b2JointDef, bodyIdB} p
      <*> #{peek b2JointDef, localFrameA} p
      <*> #{peek b2JointDef, localFrameB} p
      <*> #{peek b2JointDef, forceThreshold} p
      <*> #{peek b2JointDef, torqueThreshold} p
      <*> #{peek b2JointDef, constraintHertz} p
      <*> #{peek b2JointDef, constraintDampingRatio} p
      <*> #{peek b2JointDef, drawScale} p
      <*> #{peek b2JointDef, collideConnected} p
  poke p (JointDef f1 f2 f3 f4 f5 f6 f7 f8 f9 f10 f11) = do
    #{poke b2JointDef, userData} p f1
    #{poke b2JointDef, bodyIdA} p f2
    #{poke b2JointDef, bodyIdB} p f3
    #{poke b2JointDef, localFrameA} p f4
    #{poke b2JointDef, localFrameB} p f5
    #{poke b2JointDef, forceThreshold} p f6
    #{poke b2JointDef, torqueThreshold} p f7
    #{poke b2JointDef, constraintHertz} p f8
    #{poke b2JointDef, constraintDampingRatio} p f9
    #{poke b2JointDef, drawScale} p f10
    #{poke b2JointDef, collideConnected} p f11

-- | Joint type enumeration
newtype JointType = JointType CInt
  deriving (Eq, Show, Storable)

pattern DistanceJoint :: JointType
pattern FilterJoint :: JointType
pattern MotorJoint :: JointType
pattern PrismaticJoint :: JointType
pattern RevoluteJoint :: JointType
pattern WeldJoint :: JointType
pattern WheelJoint :: JointType
pattern DistanceJoint = JointType #{const b2_distanceJoint}
pattern FilterJoint = JointType #{const b2_filterJoint}
pattern MotorJoint = JointType #{const b2_motorJoint}
pattern PrismaticJoint = JointType #{const b2_prismaticJoint}
pattern RevoluteJoint = JointType #{const b2_revoluteJoint}
pattern WeldJoint = JointType #{const b2_weldJoint}
pattern WheelJoint = JointType #{const b2_wheelJoint}

{-# COMPLETE DistanceJoint, FilterJoint, MotorJoint, PrismaticJoint, RevoluteJoint, WeldJoint, WheelJoint #-}


foreign import ccall unsafe "b2DestroyJoint"
  c_b2DestroyJoint :: JointId -> CBool -> IO ()

foreign import ccall unsafe "b2Joint_IsValid"
  c_b2Joint_IsValid :: JointId -> IO CBool

foreign import ccall unsafe "b2Joint_GetType"
  c_b2Joint_GetType :: JointId -> IO CInt

foreign import ccall unsafe "b2Joint_GetBodyA"
  c_b2Joint_GetBodyA :: JointId -> IO BodyId

foreign import ccall unsafe "b2Joint_GetBodyB"
  c_b2Joint_GetBodyB :: JointId -> IO BodyId

foreign import ccall unsafe "b2Joint_GetWorld"
  c_b2Joint_GetWorld :: JointId -> IO WorldId

foreign import ccall unsafe "hsg_b2Joint_SetLocalFrameA"
  c_b2Joint_SetLocalFrameA :: JointId -> Ptr Transform -> IO ()

foreign import ccall unsafe "hsg_b2Joint_GetLocalFrameA"
  c_b2Joint_GetLocalFrameA :: JointId -> Ptr Transform -> IO ()

foreign import ccall unsafe "hsg_b2Joint_SetLocalFrameB"
  c_b2Joint_SetLocalFrameB :: JointId -> Ptr Transform -> IO ()

foreign import ccall unsafe "hsg_b2Joint_GetLocalFrameB"
  c_b2Joint_GetLocalFrameB :: JointId -> Ptr Transform -> IO ()

foreign import ccall unsafe "b2Joint_SetCollideConnected"
  c_b2Joint_SetCollideConnected :: JointId -> CBool -> IO ()

foreign import ccall unsafe "b2Joint_GetCollideConnected"
  c_b2Joint_GetCollideConnected :: JointId -> IO CBool

foreign import ccall unsafe "b2Joint_SetUserData"
  c_b2Joint_SetUserData :: JointId -> Ptr () -> IO ()

foreign import ccall unsafe "b2Joint_GetUserData"
  c_b2Joint_GetUserData :: JointId -> IO (Ptr ())

foreign import ccall unsafe "b2Joint_WakeBodies"
  c_b2Joint_WakeBodies :: JointId -> IO ()

foreign import ccall unsafe "hsg_b2Joint_GetConstraintForce"
  c_b2Joint_GetConstraintForce :: JointId -> Ptr Vec2 -> IO ()

foreign import ccall unsafe "b2Joint_GetConstraintTorque"
  c_b2Joint_GetConstraintTorque :: JointId -> IO Float

foreign import ccall unsafe "b2Joint_GetLinearSeparation"
  c_b2Joint_GetLinearSeparation :: JointId -> IO Float

foreign import ccall unsafe "b2Joint_GetAngularSeparation"
  c_b2Joint_GetAngularSeparation :: JointId -> IO Float

foreign import ccall unsafe "b2Joint_SetConstraintTuning"
  c_b2Joint_SetConstraintTuning :: JointId -> Float -> Float -> IO ()

foreign import ccall unsafe "b2Joint_GetConstraintTuning"
  c_b2Joint_GetConstraintTuning :: JointId -> Ptr Float -> Ptr Float -> IO ()

foreign import ccall unsafe "b2Joint_SetForceThreshold"
  c_b2Joint_SetForceThreshold :: JointId -> Float -> IO ()

foreign import ccall unsafe "b2Joint_GetForceThreshold"
  c_b2Joint_GetForceThreshold :: JointId -> IO Float

foreign import ccall unsafe "b2Joint_SetTorqueThreshold"
  c_b2Joint_SetTorqueThreshold :: JointId -> Float -> IO ()

foreign import ccall unsafe "b2Joint_GetTorqueThreshold"
  c_b2Joint_GetTorqueThreshold :: JointId -> IO Float

{- | Destroy a joint. Optionally wake attached bodies.

Binds @b2DestroyJoint@.
-}
destroy
  :: JointId
  -> Bool
  -- ^ @wakeAttached@
  -> IO ()
destroy a0 a1 =
  c_b2DestroyJoint a0 (fromBool a1)

{- | Joint identifier validation. Provides validation for up to 64K allocations.

Binds @b2Joint_IsValid@.
-}
isValid
  :: JointId
  -> IO Bool
isValid a0 =
  toBool <$> (c_b2Joint_IsValid a0)

{- | Get the joint type

Binds @b2Joint_GetType@.
-}
getType
  :: JointId
  -> IO JointType
getType a0 =
  coerce <$> (c_b2Joint_GetType a0)

{- | Get body A id on a joint

Binds @b2Joint_GetBodyA@.
-}
getBodyA
  :: JointId
  -> IO BodyId
getBodyA a0 =
  c_b2Joint_GetBodyA a0

{- | Get body B id on a joint

Binds @b2Joint_GetBodyB@.
-}
getBodyB
  :: JointId
  -> IO BodyId
getBodyB a0 =
  c_b2Joint_GetBodyB a0

{- | Get the world that owns this joint

Binds @b2Joint_GetWorld@.
-}
getWorld
  :: JointId
  -> IO WorldId
getWorld a0 =
  c_b2Joint_GetWorld a0

{- | Set the local frame on bodyA

Binds @b2Joint_SetLocalFrameA@.
-}
setLocalFrameA
  :: JointId
  -> Transform
  -- ^ @localFrame@
  -> IO ()
setLocalFrameA a0 a1 =
  with a1 $ \p1 ->
  c_b2Joint_SetLocalFrameA a0 p1

{- | Get the local frame on bodyA

Binds @b2Joint_GetLocalFrameA@.
-}
getLocalFrameA
  :: JointId
  -> IO Transform
getLocalFrameA a0 =
  alloca $ \pOut -> c_b2Joint_GetLocalFrameA a0 pOut >> peek pOut

-- | Like 'getLocalFrameA', but the result is written into a caller-supplied buffer.
getLocalFrameAInto
  :: JointId
  -> Ptr Transform
  -- ^ Result buffer.
  -> IO ()
getLocalFrameAInto a0 out =
  c_b2Joint_GetLocalFrameA a0 out

{- | Set the local frame on bodyB

Binds @b2Joint_SetLocalFrameB@.
-}
setLocalFrameB
  :: JointId
  -> Transform
  -- ^ @localFrame@
  -> IO ()
setLocalFrameB a0 a1 =
  with a1 $ \p1 ->
  c_b2Joint_SetLocalFrameB a0 p1

{- | Get the local frame on bodyB

Binds @b2Joint_GetLocalFrameB@.
-}
getLocalFrameB
  :: JointId
  -> IO Transform
getLocalFrameB a0 =
  alloca $ \pOut -> c_b2Joint_GetLocalFrameB a0 pOut >> peek pOut

-- | Like 'getLocalFrameB', but the result is written into a caller-supplied buffer.
getLocalFrameBInto
  :: JointId
  -> Ptr Transform
  -- ^ Result buffer.
  -> IO ()
getLocalFrameBInto a0 out =
  c_b2Joint_GetLocalFrameB a0 out

{- | Toggle collision between connected bodies

Binds @b2Joint_SetCollideConnected@.
-}
setCollideConnected
  :: JointId
  -> Bool
  -- ^ @shouldCollide@
  -> IO ()
setCollideConnected a0 a1 =
  c_b2Joint_SetCollideConnected a0 (fromBool a1)

{- | Is collision allowed between connected bodies?

Binds @b2Joint_GetCollideConnected@.
-}
getCollideConnected
  :: JointId
  -> IO Bool
getCollideConnected a0 =
  toBool <$> (c_b2Joint_GetCollideConnected a0)

{- | Set the user data on a joint

Binds @b2Joint_SetUserData@.
-}
setUserData
  :: JointId
  -> Ptr ()
  -- ^ @userData@
  -> IO ()
setUserData a0 a1 =
  c_b2Joint_SetUserData a0 a1

{- | Get the user data on a joint

Binds @b2Joint_GetUserData@.
-}
getUserData
  :: JointId
  -> IO (Ptr ())
getUserData a0 =
  c_b2Joint_GetUserData a0

{- | Wake the bodies connect to this joint

Binds @b2Joint_WakeBodies@.
-}
wakeBodies
  :: JointId
  -> IO ()
wakeBodies a0 =
  c_b2Joint_WakeBodies a0

{- | Get the current constraint force for this joint. Usually in Newtons.

Binds @b2Joint_GetConstraintForce@.
-}
getConstraintForce
  :: JointId
  -> IO Vec2
getConstraintForce a0 =
  alloca $ \pOut -> c_b2Joint_GetConstraintForce a0 pOut >> peek pOut

-- | Like 'getConstraintForce', but the result is written into a caller-supplied buffer.
getConstraintForceInto
  :: JointId
  -> Ptr Vec2
  -- ^ Result buffer.
  -> IO ()
getConstraintForceInto a0 out =
  c_b2Joint_GetConstraintForce a0 out

{- | Get the current constraint torque for this joint. Usually in Newton * meters.

Binds @b2Joint_GetConstraintTorque@.
-}
getConstraintTorque
  :: JointId
  -> IO Float
getConstraintTorque a0 =
  c_b2Joint_GetConstraintTorque a0

{- | Get the current linear separation error for this joint. Does not consider admissible movement. Usually in meters.

Binds @b2Joint_GetLinearSeparation@.
-}
getLinearSeparation
  :: JointId
  -> IO Float
getLinearSeparation a0 =
  c_b2Joint_GetLinearSeparation a0

{- | Get the current angular separation error for this joint. Does not consider admissible movement. Usually in meters.

Binds @b2Joint_GetAngularSeparation@.
-}
getAngularSeparation
  :: JointId
  -> IO Float
getAngularSeparation a0 =
  c_b2Joint_GetAngularSeparation a0

{- | Set the joint constraint tuning. Advanced feature.

Binds @b2Joint_SetConstraintTuning@.
-}
setConstraintTuning
  :: JointId
  -- ^ @jointId@: the joint
  -> Float
  -- ^ @hertz@: the stiffness in Hertz (cycles per second)
  -> Float
  -- ^ @dampingRatio@: the non-dimensional damping ratio (one for critical damping)
  -> IO ()
setConstraintTuning a0 a1 a2 =
  c_b2Joint_SetConstraintTuning a0 a1 a2

{- | Get the joint constraint tuning. Advanced feature.

Binds @b2Joint_GetConstraintTuning@.
-}
getConstraintTuning
  :: JointId
  -> Ptr Float
  -- ^ @hertz@
  -> Ptr Float
  -- ^ @dampingRatio@
  -> IO ()
getConstraintTuning a0 a1 a2 =
  c_b2Joint_GetConstraintTuning a0 a1 a2

{- | Set the force threshold for joint events (Newtons)

Binds @b2Joint_SetForceThreshold@.
-}
setForceThreshold
  :: JointId
  -> Float
  -- ^ @threshold@
  -> IO ()
setForceThreshold a0 a1 =
  c_b2Joint_SetForceThreshold a0 a1

{- | Get the force threshold for joint events (Newtons)

Binds @b2Joint_GetForceThreshold@.
-}
getForceThreshold
  :: JointId
  -> IO Float
getForceThreshold a0 =
  c_b2Joint_GetForceThreshold a0

{- | Set the torque threshold for joint events (N-m)

Binds @b2Joint_SetTorqueThreshold@.
-}
setTorqueThreshold
  :: JointId
  -> Float
  -- ^ @threshold@
  -> IO ()
setTorqueThreshold a0 a1 =
  c_b2Joint_SetTorqueThreshold a0 a1

{- | Get the torque threshold for joint events (N-m)

Binds @b2Joint_GetTorqueThreshold@.
-}
getTorqueThreshold
  :: JointId
  -> IO Float
getTorqueThreshold a0 =
  c_b2Joint_GetTorqueThreshold a0
