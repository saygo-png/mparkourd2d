{-# LANGUAGE ForeignFunctionInterface #-}
{-# LANGUAGE PatternSynonyms #-}
{-# LANGUAGE GeneralizedNewtypeDeriving #-}

-- Produced by boxnd-gen; edit the generator, not this file.

module Box2D.Body
  ( BodyDef (..)
  , MotionLocks (..)
  , BodyType (..)
  , pattern StaticBody
  , pattern KinematicBody
  , pattern DynamicBody
  , defaultBodyDef
  , create
  , destroy
  , isValid
  , getType
  , setType
  , setName
  , getName
  , setUserData
  , getUserData
  , getPosition
  , getPositionInto
  , getRotation
  , getRotationInto
  , getTransform
  , getTransformInto
  , setTransform
  , getLocalPoint
  , getWorldPoint
  , getLocalVector
  , getWorldVector
  , getLinearVelocity
  , getLinearVelocityInto
  , getAngularVelocity
  , setLinearVelocity
  , setAngularVelocity
  , setTargetTransform
  , getLocalPointVelocity
  , getWorldPointVelocity
  , applyForce
  , applyForceToCenter
  , applyTorque
  , clearForces
  , applyLinearImpulse
  , applyLinearImpulseToCenter
  , applyAngularImpulse
  , getMass
  , getRotationalInertia
  , getLocalCenter
  , getLocalCenterInto
  , getWorldCenter
  , getWorldCenterInto
  , setMassData
  , getMassData
  , getMassDataInto
  , applyMassFromShapes
  , setLinearDamping
  , getLinearDamping
  , setAngularDamping
  , getAngularDamping
  , setGravityScale
  , getGravityScale
  , isAwake
  , setAwake
  , wakeTouching
  , enableSleep
  , isSleepEnabled
  , setSleepThreshold
  , getSleepThreshold
  , isEnabled
  , disable
  , enable
  , setMotionLocks
  , getMotionLocks
  , getMotionLocksInto
  , setBullet
  , isBullet
  , enableContactRecycling
  , isContactRecyclingEnabled
  , enableContactEvents
  , enableHitEvents
  , getWorld
  , getShapeCount
  , getShapes
  , getJointCount
  , getJoints
  , getContactCapacity
  , getContactData
  , computeAABB
  , computeAABBInto
  )
  where

import Foreign
import Foreign.C.Types (CBool (..), CInt (..))
import Foreign.C.String (CString)
import Data.Coerce (coerce)
import Box2D.Internal (allocaOut)
import Box2D.Geometry (MassData)
import Box2D.Id (BodyId (..), JointId (..), ShapeId (..), WorldId (..))
import Box2D.MathTypes (AABB, Pos, Rot, Vec2, WorldTransform)
import Box2D.World (ContactData)

#include "box2d/box2d.h"


-- | A body definition holds all the data needed to construct a rigid body.
data BodyDef = BodyDef
  { type_ :: BodyType
  , position :: Pos
  , rotation :: Rot
  , linearVelocity :: Vec2
  , angularVelocity :: Float
  , linearDamping :: Float
  , angularDamping :: Float
  , gravityScale :: Float
  , sleepThreshold :: Float
  , name :: CString
  , userData :: Ptr ()
  , motionLocks :: MotionLocks
  , enableSleep :: CBool
  , isAwake :: CBool
  , isBullet :: CBool
  , isEnabled :: CBool
  , allowFastRotation :: CBool
  , enableContactRecycling :: CBool
  , internalValue :: CInt
  }
  deriving (Eq, Show)

instance Storable BodyDef where
  sizeOf _ = #{size b2BodyDef}
  alignment _ = #{alignment b2BodyDef}
  peek p =
    BodyDef
      <$> #{peek b2BodyDef, type} p
      <*> #{peek b2BodyDef, position} p
      <*> #{peek b2BodyDef, rotation} p
      <*> #{peek b2BodyDef, linearVelocity} p
      <*> #{peek b2BodyDef, angularVelocity} p
      <*> #{peek b2BodyDef, linearDamping} p
      <*> #{peek b2BodyDef, angularDamping} p
      <*> #{peek b2BodyDef, gravityScale} p
      <*> #{peek b2BodyDef, sleepThreshold} p
      <*> #{peek b2BodyDef, name} p
      <*> #{peek b2BodyDef, userData} p
      <*> #{peek b2BodyDef, motionLocks} p
      <*> #{peek b2BodyDef, enableSleep} p
      <*> #{peek b2BodyDef, isAwake} p
      <*> #{peek b2BodyDef, isBullet} p
      <*> #{peek b2BodyDef, isEnabled} p
      <*> #{peek b2BodyDef, allowFastRotation} p
      <*> #{peek b2BodyDef, enableContactRecycling} p
      <*> #{peek b2BodyDef, internalValue} p
  poke p (BodyDef f1 f2 f3 f4 f5 f6 f7 f8 f9 f10 f11 f12 f13 f14 f15 f16 f17 f18 f19) = do
    #{poke b2BodyDef, type} p f1
    #{poke b2BodyDef, position} p f2
    #{poke b2BodyDef, rotation} p f3
    #{poke b2BodyDef, linearVelocity} p f4
    #{poke b2BodyDef, angularVelocity} p f5
    #{poke b2BodyDef, linearDamping} p f6
    #{poke b2BodyDef, angularDamping} p f7
    #{poke b2BodyDef, gravityScale} p f8
    #{poke b2BodyDef, sleepThreshold} p f9
    #{poke b2BodyDef, name} p f10
    #{poke b2BodyDef, userData} p f11
    #{poke b2BodyDef, motionLocks} p f12
    #{poke b2BodyDef, enableSleep} p f13
    #{poke b2BodyDef, isAwake} p f14
    #{poke b2BodyDef, isBullet} p f15
    #{poke b2BodyDef, isEnabled} p f16
    #{poke b2BodyDef, allowFastRotation} p f17
    #{poke b2BodyDef, enableContactRecycling} p f18
    #{poke b2BodyDef, internalValue} p f19

-- | Motion locks to restrict the body movement
data MotionLocks = MotionLocks
  { linearX :: CBool
  , linearY :: CBool
  , angularZ :: CBool
  }
  deriving (Eq, Show)

instance Storable MotionLocks where
  sizeOf _ = #{size b2MotionLocks}
  alignment _ = #{alignment b2MotionLocks}
  peek p =
    MotionLocks
      <$> #{peek b2MotionLocks, linearX} p
      <*> #{peek b2MotionLocks, linearY} p
      <*> #{peek b2MotionLocks, angularZ} p
  poke p (MotionLocks f1 f2 f3) = do
    #{poke b2MotionLocks, linearX} p f1
    #{poke b2MotionLocks, linearY} p f2
    #{poke b2MotionLocks, angularZ} p f3

-- | The body simulation type.
newtype BodyType = BodyType CInt
  deriving (Eq, Show, Storable)

pattern StaticBody :: BodyType
pattern KinematicBody :: BodyType
pattern DynamicBody :: BodyType
pattern StaticBody = BodyType #{const b2_staticBody}
pattern KinematicBody = BodyType #{const b2_kinematicBody}
pattern DynamicBody = BodyType #{const b2_dynamicBody}

{-# COMPLETE StaticBody, KinematicBody, DynamicBody #-}

foreign import ccall unsafe "hs_b2DefaultBodyDef"
  c_b2DefaultBodyDef :: Ptr BodyDef -> IO ()

defaultBodyDef :: IO BodyDef
defaultBodyDef = allocaOut c_b2DefaultBodyDef


foreign import ccall unsafe "b2CreateBody"
  c_b2CreateBody :: WorldId -> Ptr BodyDef -> IO BodyId

foreign import ccall unsafe "b2DestroyBody"
  c_b2DestroyBody :: BodyId -> IO ()

foreign import ccall unsafe "b2Body_IsValid"
  c_b2Body_IsValid :: BodyId -> IO CBool

foreign import ccall unsafe "b2Body_GetType"
  c_b2Body_GetType :: BodyId -> IO CInt

foreign import ccall unsafe "b2Body_SetType"
  c_b2Body_SetType :: BodyId -> CInt -> IO ()

foreign import ccall unsafe "b2Body_SetName"
  c_b2Body_SetName :: BodyId -> CString -> IO ()

foreign import ccall unsafe "b2Body_GetName"
  c_b2Body_GetName :: BodyId -> IO CString

foreign import ccall unsafe "b2Body_SetUserData"
  c_b2Body_SetUserData :: BodyId -> Ptr () -> IO ()

foreign import ccall unsafe "b2Body_GetUserData"
  c_b2Body_GetUserData :: BodyId -> IO (Ptr ())

foreign import ccall unsafe "hsg_b2Body_GetPosition"
  c_b2Body_GetPosition :: BodyId -> Ptr Pos -> IO ()

foreign import ccall unsafe "hsg_b2Body_GetRotation"
  c_b2Body_GetRotation :: BodyId -> Ptr Rot -> IO ()

foreign import ccall unsafe "hsg_b2Body_GetTransform"
  c_b2Body_GetTransform :: BodyId -> Ptr WorldTransform -> IO ()

foreign import ccall unsafe "hsg_b2Body_SetTransform"
  c_b2Body_SetTransform :: BodyId -> Ptr Pos -> Ptr Rot -> IO ()

foreign import ccall unsafe "hsg_b2Body_GetLocalPoint"
  c_b2Body_GetLocalPoint :: BodyId -> Ptr Pos -> Ptr Vec2 -> IO ()

foreign import ccall unsafe "hsg_b2Body_GetWorldPoint"
  c_b2Body_GetWorldPoint :: BodyId -> Ptr Vec2 -> Ptr Pos -> IO ()

foreign import ccall unsafe "hsg_b2Body_GetLocalVector"
  c_b2Body_GetLocalVector :: BodyId -> Ptr Vec2 -> Ptr Vec2 -> IO ()

foreign import ccall unsafe "hsg_b2Body_GetWorldVector"
  c_b2Body_GetWorldVector :: BodyId -> Ptr Vec2 -> Ptr Vec2 -> IO ()

foreign import ccall unsafe "hsg_b2Body_GetLinearVelocity"
  c_b2Body_GetLinearVelocity :: BodyId -> Ptr Vec2 -> IO ()

foreign import ccall unsafe "b2Body_GetAngularVelocity"
  c_b2Body_GetAngularVelocity :: BodyId -> IO Float

foreign import ccall unsafe "hsg_b2Body_SetLinearVelocity"
  c_b2Body_SetLinearVelocity :: BodyId -> Ptr Vec2 -> IO ()

foreign import ccall unsafe "b2Body_SetAngularVelocity"
  c_b2Body_SetAngularVelocity :: BodyId -> Float -> IO ()

foreign import ccall unsafe "hsg_b2Body_SetTargetTransform"
  c_b2Body_SetTargetTransform :: BodyId -> Ptr WorldTransform -> Float -> CBool -> IO ()

foreign import ccall unsafe "hsg_b2Body_GetLocalPointVelocity"
  c_b2Body_GetLocalPointVelocity :: BodyId -> Ptr Vec2 -> Ptr Vec2 -> IO ()

foreign import ccall unsafe "hsg_b2Body_GetWorldPointVelocity"
  c_b2Body_GetWorldPointVelocity :: BodyId -> Ptr Pos -> Ptr Vec2 -> IO ()

foreign import ccall unsafe "hsg_b2Body_ApplyForce"
  c_b2Body_ApplyForce :: BodyId -> Ptr Vec2 -> Ptr Pos -> CBool -> IO ()

foreign import ccall unsafe "hsg_b2Body_ApplyForceToCenter"
  c_b2Body_ApplyForceToCenter :: BodyId -> Ptr Vec2 -> CBool -> IO ()

foreign import ccall unsafe "b2Body_ApplyTorque"
  c_b2Body_ApplyTorque :: BodyId -> Float -> CBool -> IO ()

foreign import ccall unsafe "b2Body_ClearForces"
  c_b2Body_ClearForces :: BodyId -> IO ()

foreign import ccall unsafe "hsg_b2Body_ApplyLinearImpulse"
  c_b2Body_ApplyLinearImpulse :: BodyId -> Ptr Vec2 -> Ptr Pos -> CBool -> IO ()

foreign import ccall unsafe "hsg_b2Body_ApplyLinearImpulseToCenter"
  c_b2Body_ApplyLinearImpulseToCenter :: BodyId -> Ptr Vec2 -> CBool -> IO ()

foreign import ccall unsafe "b2Body_ApplyAngularImpulse"
  c_b2Body_ApplyAngularImpulse :: BodyId -> Float -> CBool -> IO ()

foreign import ccall unsafe "b2Body_GetMass"
  c_b2Body_GetMass :: BodyId -> IO Float

foreign import ccall unsafe "b2Body_GetRotationalInertia"
  c_b2Body_GetRotationalInertia :: BodyId -> IO Float

foreign import ccall unsafe "hsg_b2Body_GetLocalCenter"
  c_b2Body_GetLocalCenter :: BodyId -> Ptr Vec2 -> IO ()

foreign import ccall unsafe "hsg_b2Body_GetWorldCenter"
  c_b2Body_GetWorldCenter :: BodyId -> Ptr Pos -> IO ()

foreign import ccall unsafe "hsg_b2Body_SetMassData"
  c_b2Body_SetMassData :: BodyId -> Ptr MassData -> IO ()

foreign import ccall unsafe "hsg_b2Body_GetMassData"
  c_b2Body_GetMassData :: BodyId -> Ptr MassData -> IO ()

foreign import ccall unsafe "b2Body_ApplyMassFromShapes"
  c_b2Body_ApplyMassFromShapes :: BodyId -> IO ()

foreign import ccall unsafe "b2Body_SetLinearDamping"
  c_b2Body_SetLinearDamping :: BodyId -> Float -> IO ()

foreign import ccall unsafe "b2Body_GetLinearDamping"
  c_b2Body_GetLinearDamping :: BodyId -> IO Float

foreign import ccall unsafe "b2Body_SetAngularDamping"
  c_b2Body_SetAngularDamping :: BodyId -> Float -> IO ()

foreign import ccall unsafe "b2Body_GetAngularDamping"
  c_b2Body_GetAngularDamping :: BodyId -> IO Float

foreign import ccall unsafe "b2Body_SetGravityScale"
  c_b2Body_SetGravityScale :: BodyId -> Float -> IO ()

foreign import ccall unsafe "b2Body_GetGravityScale"
  c_b2Body_GetGravityScale :: BodyId -> IO Float

foreign import ccall unsafe "b2Body_IsAwake"
  c_b2Body_IsAwake :: BodyId -> IO CBool

foreign import ccall unsafe "b2Body_SetAwake"
  c_b2Body_SetAwake :: BodyId -> CBool -> IO ()

foreign import ccall unsafe "b2Body_WakeTouching"
  c_b2Body_WakeTouching :: BodyId -> IO ()

foreign import ccall unsafe "b2Body_EnableSleep"
  c_b2Body_EnableSleep :: BodyId -> CBool -> IO ()

foreign import ccall unsafe "b2Body_IsSleepEnabled"
  c_b2Body_IsSleepEnabled :: BodyId -> IO CBool

foreign import ccall unsafe "b2Body_SetSleepThreshold"
  c_b2Body_SetSleepThreshold :: BodyId -> Float -> IO ()

foreign import ccall unsafe "b2Body_GetSleepThreshold"
  c_b2Body_GetSleepThreshold :: BodyId -> IO Float

foreign import ccall unsafe "b2Body_IsEnabled"
  c_b2Body_IsEnabled :: BodyId -> IO CBool

foreign import ccall unsafe "b2Body_Disable"
  c_b2Body_Disable :: BodyId -> IO ()

foreign import ccall unsafe "b2Body_Enable"
  c_b2Body_Enable :: BodyId -> IO ()

foreign import ccall unsafe "hsg_b2Body_SetMotionLocks"
  c_b2Body_SetMotionLocks :: BodyId -> Ptr MotionLocks -> IO ()

foreign import ccall unsafe "hsg_b2Body_GetMotionLocks"
  c_b2Body_GetMotionLocks :: BodyId -> Ptr MotionLocks -> IO ()

foreign import ccall unsafe "b2Body_SetBullet"
  c_b2Body_SetBullet :: BodyId -> CBool -> IO ()

foreign import ccall unsafe "b2Body_IsBullet"
  c_b2Body_IsBullet :: BodyId -> IO CBool

foreign import ccall unsafe "b2Body_EnableContactRecycling"
  c_b2Body_EnableContactRecycling :: BodyId -> CBool -> IO ()

foreign import ccall unsafe "b2Body_IsContactRecyclingEnabled"
  c_b2Body_IsContactRecyclingEnabled :: BodyId -> IO CBool

foreign import ccall unsafe "b2Body_EnableContactEvents"
  c_b2Body_EnableContactEvents :: BodyId -> CBool -> IO ()

foreign import ccall unsafe "b2Body_EnableHitEvents"
  c_b2Body_EnableHitEvents :: BodyId -> CBool -> IO ()

foreign import ccall unsafe "b2Body_GetWorld"
  c_b2Body_GetWorld :: BodyId -> IO WorldId

foreign import ccall unsafe "b2Body_GetShapeCount"
  c_b2Body_GetShapeCount :: BodyId -> IO CInt

foreign import ccall unsafe "b2Body_GetShapes"
  c_b2Body_GetShapes :: BodyId -> Ptr ShapeId -> CInt -> IO CInt

foreign import ccall unsafe "b2Body_GetJointCount"
  c_b2Body_GetJointCount :: BodyId -> IO CInt

foreign import ccall unsafe "b2Body_GetJoints"
  c_b2Body_GetJoints :: BodyId -> Ptr JointId -> CInt -> IO CInt

foreign import ccall unsafe "b2Body_GetContactCapacity"
  c_b2Body_GetContactCapacity :: BodyId -> IO CInt

foreign import ccall unsafe "b2Body_GetContactData"
  c_b2Body_GetContactData :: BodyId -> Ptr ContactData -> CInt -> IO CInt

foreign import ccall unsafe "hsg_b2Body_ComputeAABB"
  c_b2Body_ComputeAABB :: BodyId -> Ptr AABB -> IO ()

{- | Create a rigid body given a definition. No reference to the definition is retained. So you can create the definition
on the stack and pass it as a pointer.
b2BodyDef bodyDef = b2DefaultBodyDef();
b2BodyId myBodyId = b2CreateBody(myWorldId, &bodyDef);
Warning: This function is locked during callbacks.

Binds @b2CreateBody@.
-}
create
  :: WorldId
  -> BodyDef
  -> IO BodyId
create a0 a1 =
  with a1 $ \p1 ->
  c_b2CreateBody a0 p1

{- | Destroy a rigid body given an id. This destroys all shapes and joints attached to the body.
Do not keep references to the associated shapes and joints.

Binds @b2DestroyBody@.
-}
destroy
  :: BodyId
  -> IO ()
destroy a0 =
  c_b2DestroyBody a0

{- | Body identifier validation. A valid body exists in a world and is non-null.
This can be used to detect orphaned ids. Provides validation for up to 64K allocations.

Binds @b2Body_IsValid@.
-}
isValid
  :: BodyId
  -> IO Bool
isValid a0 =
  toBool <$> (c_b2Body_IsValid a0)

{- | Get the body type: static, kinematic, or dynamic

Binds @b2Body_GetType@.
-}
getType
  :: BodyId
  -> IO BodyType
getType a0 =
  coerce <$> (c_b2Body_GetType a0)

{- | Change the body type. This is an expensive operation. This automatically updates the mass
properties regardless of the automatic mass setting.

Binds @b2Body_SetType@.
-}
setType
  :: BodyId
  -> BodyType
  -> IO ()
setType a0 a1 =
  c_b2Body_SetType a0 (coerce a1)

{- | Set the body name. Up to 31 characters excluding 0 termination.

Binds @b2Body_SetName@.
-}
setName
  :: BodyId
  -> CString
  -- ^ @name@
  -> IO ()
setName a0 a1 =
  c_b2Body_SetName a0 a1

{- | Get the body name.

Binds @b2Body_GetName@.
-}
getName
  :: BodyId
  -> IO CString
getName a0 =
  c_b2Body_GetName a0

{- | Set the user data for a body

Binds @b2Body_SetUserData@.
-}
setUserData
  :: BodyId
  -> Ptr ()
  -- ^ @userData@
  -> IO ()
setUserData a0 a1 =
  c_b2Body_SetUserData a0 a1

{- | Get the user data stored in a body

Binds @b2Body_GetUserData@.
-}
getUserData
  :: BodyId
  -> IO (Ptr ())
getUserData a0 =
  c_b2Body_GetUserData a0

{- | Get the world position of a body. This is the location of the body origin.

Binds @b2Body_GetPosition@.
-}
getPosition
  :: BodyId
  -> IO Pos
getPosition a0 =
  alloca $ \pOut -> c_b2Body_GetPosition a0 pOut >> peek pOut

-- | Like 'getPosition', but the result is written into a caller-supplied buffer.
getPositionInto
  :: BodyId
  -> Ptr Pos
  -- ^ Result buffer.
  -> IO ()
getPositionInto a0 out =
  c_b2Body_GetPosition a0 out

{- | Get the world rotation of a body as a cosine\/sine pair (complex number)

Binds @b2Body_GetRotation@.
-}
getRotation
  :: BodyId
  -> IO Rot
getRotation a0 =
  alloca $ \pOut -> c_b2Body_GetRotation a0 pOut >> peek pOut

-- | Like 'getRotation', but the result is written into a caller-supplied buffer.
getRotationInto
  :: BodyId
  -> Ptr Rot
  -- ^ Result buffer.
  -> IO ()
getRotationInto a0 out =
  c_b2Body_GetRotation a0 out

{- | Get the world transform of a body.

Binds @b2Body_GetTransform@.
-}
getTransform
  :: BodyId
  -> IO WorldTransform
getTransform a0 =
  alloca $ \pOut -> c_b2Body_GetTransform a0 pOut >> peek pOut

-- | Like 'getTransform', but the result is written into a caller-supplied buffer.
getTransformInto
  :: BodyId
  -> Ptr WorldTransform
  -- ^ Result buffer.
  -> IO ()
getTransformInto a0 out =
  c_b2Body_GetTransform a0 out

{- | Set the world transform of a body. This acts as a teleport and is fairly expensive.
Note: Generally you should create a body with then intended transform.
See also b2BodyDef::position and b2BodyDef::rotation.

Binds @b2Body_SetTransform@.
-}
setTransform
  :: BodyId
  -> Pos
  -- ^ @position@
  -> Rot
  -- ^ @rotation@
  -> IO ()
setTransform a0 a1 a2 =
  with a1 $ \p1 ->
  with a2 $ \p2 ->
  c_b2Body_SetTransform a0 p1 p2

{- | Get a local point on a body given a world point

Binds @b2Body_GetLocalPoint@.
-}
getLocalPoint
  :: BodyId
  -> Pos
  -- ^ @worldPoint@
  -> IO Vec2
getLocalPoint a0 a1 =
  with a1 $ \p1 ->
  alloca $ \pOut -> c_b2Body_GetLocalPoint a0 p1 pOut >> peek pOut

{- | Get a world point on a body given a local point

Binds @b2Body_GetWorldPoint@.
-}
getWorldPoint
  :: BodyId
  -> Vec2
  -- ^ @localPoint@
  -> IO Pos
getWorldPoint a0 a1 =
  with a1 $ \p1 ->
  alloca $ \pOut -> c_b2Body_GetWorldPoint a0 p1 pOut >> peek pOut

{- | Get a local vector on a body given a world vector

Binds @b2Body_GetLocalVector@.
-}
getLocalVector
  :: BodyId
  -> Vec2
  -- ^ @worldVector@
  -> IO Vec2
getLocalVector a0 a1 =
  with a1 $ \p1 ->
  alloca $ \pOut -> c_b2Body_GetLocalVector a0 p1 pOut >> peek pOut

{- | Get a world vector on a body given a local vector

Binds @b2Body_GetWorldVector@.
-}
getWorldVector
  :: BodyId
  -> Vec2
  -- ^ @localVector@
  -> IO Vec2
getWorldVector a0 a1 =
  with a1 $ \p1 ->
  alloca $ \pOut -> c_b2Body_GetWorldVector a0 p1 pOut >> peek pOut

{- | Get the linear velocity of a body\'s center of mass. Usually in meters per second.

Binds @b2Body_GetLinearVelocity@.
-}
getLinearVelocity
  :: BodyId
  -> IO Vec2
getLinearVelocity a0 =
  alloca $ \pOut -> c_b2Body_GetLinearVelocity a0 pOut >> peek pOut

-- | Like 'getLinearVelocity', but the result is written into a caller-supplied buffer.
getLinearVelocityInto
  :: BodyId
  -> Ptr Vec2
  -- ^ Result buffer.
  -> IO ()
getLinearVelocityInto a0 out =
  c_b2Body_GetLinearVelocity a0 out

{- | Get the angular velocity of a body in radians per second

Binds @b2Body_GetAngularVelocity@.
-}
getAngularVelocity
  :: BodyId
  -> IO Float
getAngularVelocity a0 =
  c_b2Body_GetAngularVelocity a0

{- | Set the linear velocity of a body. Usually in meters per second.

Binds @b2Body_SetLinearVelocity@.
-}
setLinearVelocity
  :: BodyId
  -> Vec2
  -- ^ @linearVelocity@
  -> IO ()
setLinearVelocity a0 a1 =
  with a1 $ \p1 ->
  c_b2Body_SetLinearVelocity a0 p1

{- | Set the angular velocity of a body in radians per second

Binds @b2Body_SetAngularVelocity@.
-}
setAngularVelocity
  :: BodyId
  -> Float
  -- ^ @angularVelocity@
  -> IO ()
setAngularVelocity a0 a1 =
  c_b2Body_SetAngularVelocity a0 a1

{- | Set the velocity to reach the given transform after a given time step.
The result will be close but maybe not exact. This is meant for kinematic bodies.
The target is not applied if the velocity would be below the sleep threshold and
the body is currently asleep.

Binds @b2Body_SetTargetTransform@.
-}
setTargetTransform
  :: BodyId
  -- ^ @bodyId@: The body id
  -> WorldTransform
  -- ^ @target@: The target transform for the body
  -> Float
  -- ^ @timeStep@: The time step of the next call to b2World_Step
  -> Bool
  -- ^ @wake@: Option to wake the body or not
  -> IO ()
setTargetTransform a0 a1 a2 a3 =
  with a1 $ \p1 ->
  c_b2Body_SetTargetTransform a0 p1 a2 (fromBool a3)

{- | Get the linear velocity of a local point attached to a body. Usually in meters per second.

Binds @b2Body_GetLocalPointVelocity@.
-}
getLocalPointVelocity
  :: BodyId
  -> Vec2
  -- ^ @localPoint@
  -> IO Vec2
getLocalPointVelocity a0 a1 =
  with a1 $ \p1 ->
  alloca $ \pOut -> c_b2Body_GetLocalPointVelocity a0 p1 pOut >> peek pOut

{- | Get the linear velocity of a world point attached to a body. Usually in meters per second.

Binds @b2Body_GetWorldPointVelocity@.
-}
getWorldPointVelocity
  :: BodyId
  -> Pos
  -- ^ @worldPoint@
  -> IO Vec2
getWorldPointVelocity a0 a1 =
  with a1 $ \p1 ->
  alloca $ \pOut -> c_b2Body_GetWorldPointVelocity a0 p1 pOut >> peek pOut

{- | Apply a force at a world point. If the force is not applied at the center of mass,
it will generate a torque and affect the angular velocity. This optionally wakes up the body.
The force is ignored if the body is not awake.

Binds @b2Body_ApplyForce@.
-}
applyForce
  :: BodyId
  -- ^ @bodyId@: The body id
  -> Vec2
  -- ^ @force@: The world force vector, usually in newtons (N)
  -> Pos
  -- ^ @point@: The world position of the point of application
  -> Bool
  -- ^ @wake@: Option to wake up the body
  -> IO ()
applyForce a0 a1 a2 a3 =
  with a1 $ \p1 ->
  with a2 $ \p2 ->
  c_b2Body_ApplyForce a0 p1 p2 (fromBool a3)

{- | Apply a force to the center of mass. This optionally wakes up the body.
The force is ignored if the body is not awake.

Binds @b2Body_ApplyForceToCenter@.
-}
applyForceToCenter
  :: BodyId
  -- ^ @bodyId@: The body id
  -> Vec2
  -- ^ @force@: the world force vector, usually in newtons (N).
  -> Bool
  -- ^ @wake@: also wake up the body
  -> IO ()
applyForceToCenter a0 a1 a2 =
  with a1 $ \p1 ->
  c_b2Body_ApplyForceToCenter a0 p1 (fromBool a2)

{- | Apply a torque. This affects the angular velocity without affecting the linear velocity.
This optionally wakes the body. The torque is ignored if the body is not awake.

Binds @b2Body_ApplyTorque@.
-}
applyTorque
  :: BodyId
  -- ^ @bodyId@: The body id
  -> Float
  -- ^ @torque@: about the z-axis (out of the screen), usually in N*m.
  -> Bool
  -- ^ @wake@: also wake up the body
  -> IO ()
applyTorque a0 a1 a2 =
  c_b2Body_ApplyTorque a0 a1 (fromBool a2)

{- | Clear the force and torque on this body. Forces and torques are automatically cleared after each world
step. So this only needs to be called if the application wants to remove the effect of previous
calls to apply forces and torques before the world step is called.

Binds @b2Body_ClearForces@.
-}
clearForces
  :: BodyId
  -- ^ @bodyId@: The body id
  -> IO ()
clearForces a0 =
  c_b2Body_ClearForces a0

{- | Apply an impulse at a point. This immediately modifies the velocity.
It also modifies the angular velocity if the point of application
is not at the center of mass. This optionally wakes the body.
The impulse is ignored if the body is not awake.
Warning: This should be used for one-shot impulses. If you need a steady force,
use a force instead, which will work better with the sub-stepping solver.

Binds @b2Body_ApplyLinearImpulse@.
-}
applyLinearImpulse
  :: BodyId
  -- ^ @bodyId@: The body id
  -> Vec2
  -- ^ @impulse@: the world impulse vector, usually in N*s or kg*m\/s.
  -> Pos
  -- ^ @point@: the world position of the point of application.
  -> Bool
  -- ^ @wake@: also wake up the body
  -> IO ()
applyLinearImpulse a0 a1 a2 a3 =
  with a1 $ \p1 ->
  with a2 $ \p2 ->
  c_b2Body_ApplyLinearImpulse a0 p1 p2 (fromBool a3)

{- | Apply an impulse to the center of mass. This immediately modifies the velocity.
The impulse is ignored if the body is not awake. This optionally wakes the body.
Warning: This should be used for one-shot impulses. If you need a steady force,
use a force instead, which will work better with the sub-stepping solver.

Binds @b2Body_ApplyLinearImpulseToCenter@.
-}
applyLinearImpulseToCenter
  :: BodyId
  -- ^ @bodyId@: The body id
  -> Vec2
  -- ^ @impulse@: the world impulse vector, usually in N*s or kg*m\/s.
  -> Bool
  -- ^ @wake@: also wake up the body
  -> IO ()
applyLinearImpulseToCenter a0 a1 a2 =
  with a1 $ \p1 ->
  c_b2Body_ApplyLinearImpulseToCenter a0 p1 (fromBool a2)

{- | Apply an angular impulse. The impulse is ignored if the body is not awake.
This optionally wakes the body.
Warning: This should be used for one-shot impulses. If you need a steady torque,
use a torque instead, which will work better with the sub-stepping solver.

Binds @b2Body_ApplyAngularImpulse@.
-}
applyAngularImpulse
  :: BodyId
  -- ^ @bodyId@: The body id
  -> Float
  -- ^ @impulse@: the angular impulse, usually in units of kg*m*m\/s
  -> Bool
  -- ^ @wake@: also wake up the body
  -> IO ()
applyAngularImpulse a0 a1 a2 =
  c_b2Body_ApplyAngularImpulse a0 a1 (fromBool a2)

{- | Get the mass of the body, usually in kilograms

Binds @b2Body_GetMass@.
-}
getMass
  :: BodyId
  -> IO Float
getMass a0 =
  c_b2Body_GetMass a0

{- | Get the rotational inertia of the body, usually in kg*m^2

Binds @b2Body_GetRotationalInertia@.
-}
getRotationalInertia
  :: BodyId
  -> IO Float
getRotationalInertia a0 =
  c_b2Body_GetRotationalInertia a0

{- | Get the center of mass position of the body in local space.

Binds @b2Body_GetLocalCenter@.
-}
getLocalCenter
  :: BodyId
  -> IO Vec2
getLocalCenter a0 =
  alloca $ \pOut -> c_b2Body_GetLocalCenter a0 pOut >> peek pOut

-- | Like 'getLocalCenter', but the result is written into a caller-supplied buffer.
getLocalCenterInto
  :: BodyId
  -> Ptr Vec2
  -- ^ Result buffer.
  -> IO ()
getLocalCenterInto a0 out =
  c_b2Body_GetLocalCenter a0 out

{- | Get the center of mass position of the body in world space.

Binds @b2Body_GetWorldCenter@.
-}
getWorldCenter
  :: BodyId
  -> IO Pos
getWorldCenter a0 =
  alloca $ \pOut -> c_b2Body_GetWorldCenter a0 pOut >> peek pOut

-- | Like 'getWorldCenter', but the result is written into a caller-supplied buffer.
getWorldCenterInto
  :: BodyId
  -> Ptr Pos
  -- ^ Result buffer.
  -> IO ()
getWorldCenterInto a0 out =
  c_b2Body_GetWorldCenter a0 out

{- | Override the body\'s mass properties. Normally this is computed automatically using the
shape geometry and density. This information is lost if a shape is added or removed or if the
body type changes.

Binds @b2Body_SetMassData@.
-}
setMassData
  :: BodyId
  -> MassData
  -> IO ()
setMassData a0 a1 =
  with a1 $ \p1 ->
  c_b2Body_SetMassData a0 p1

{- | Get the mass data for a body

Binds @b2Body_GetMassData@.
-}
getMassData
  :: BodyId
  -> IO MassData
getMassData a0 =
  alloca $ \pOut -> c_b2Body_GetMassData a0 pOut >> peek pOut

-- | Like 'getMassData', but the result is written into a caller-supplied buffer.
getMassDataInto
  :: BodyId
  -> Ptr MassData
  -- ^ Result buffer.
  -> IO ()
getMassDataInto a0 out =
  c_b2Body_GetMassData a0 out

{- | This updates the mass properties to the sum of the mass properties of the shapes.
This normally does not need to be called unless you called SetMassData to override
the mass and you later want to reset the mass.
You may also use this when automatic mass computation has been disabled.
You should call this regardless of body type.
Note that sensor shapes may have mass.

Binds @b2Body_ApplyMassFromShapes@.
-}
applyMassFromShapes
  :: BodyId
  -> IO ()
applyMassFromShapes a0 =
  c_b2Body_ApplyMassFromShapes a0

{- | Adjust the linear damping. Normally this is set in b2BodyDef before creation.

Binds @b2Body_SetLinearDamping@.
-}
setLinearDamping
  :: BodyId
  -> Float
  -- ^ @linearDamping@
  -> IO ()
setLinearDamping a0 a1 =
  c_b2Body_SetLinearDamping a0 a1

{- | Get the current linear damping.

Binds @b2Body_GetLinearDamping@.
-}
getLinearDamping
  :: BodyId
  -> IO Float
getLinearDamping a0 =
  c_b2Body_GetLinearDamping a0

{- | Adjust the angular damping. Normally this is set in b2BodyDef before creation.

Binds @b2Body_SetAngularDamping@.
-}
setAngularDamping
  :: BodyId
  -> Float
  -- ^ @angularDamping@
  -> IO ()
setAngularDamping a0 a1 =
  c_b2Body_SetAngularDamping a0 a1

{- | Get the current angular damping.

Binds @b2Body_GetAngularDamping@.
-}
getAngularDamping
  :: BodyId
  -> IO Float
getAngularDamping a0 =
  c_b2Body_GetAngularDamping a0

{- | Adjust the gravity scale. Normally this is set in b2BodyDef before creation.
See also b2BodyDef::gravityScale.

Binds @b2Body_SetGravityScale@.
-}
setGravityScale
  :: BodyId
  -> Float
  -- ^ @gravityScale@
  -> IO ()
setGravityScale a0 a1 =
  c_b2Body_SetGravityScale a0 a1

{- | Get the current gravity scale

Binds @b2Body_GetGravityScale@.
-}
getGravityScale
  :: BodyId
  -> IO Float
getGravityScale a0 =
  c_b2Body_GetGravityScale a0

{- | Returns: true if this body is awake

Binds @b2Body_IsAwake@.
-}
isAwake
  :: BodyId
  -> IO Bool
isAwake a0 =
  toBool <$> (c_b2Body_IsAwake a0)

{- | Wake a body from sleep. This wakes the entire island the body is touching.
Warning: Putting a body to sleep will put the entire island of bodies touching this body to sleep,
which can be expensive and possibly unintuitive.

Binds @b2Body_SetAwake@.
-}
setAwake
  :: BodyId
  -> Bool
  -- ^ @awake@
  -> IO ()
setAwake a0 a1 =
  c_b2Body_SetAwake a0 (fromBool a1)

{- | Wake bodies touching this body. Works for static bodies.

Binds @b2Body_WakeTouching@.
-}
wakeTouching
  :: BodyId
  -> IO ()
wakeTouching a0 =
  c_b2Body_WakeTouching a0

{- | Enable or disable sleeping for this body. If sleeping is disabled the body will wake (and the entire island).

Binds @b2Body_EnableSleep@.
-}
enableSleep
  :: BodyId
  -> Bool
  -- ^ @enableSleep@
  -> IO ()
enableSleep a0 a1 =
  c_b2Body_EnableSleep a0 (fromBool a1)

{- | Returns true if sleeping is enabled for this body

Binds @b2Body_IsSleepEnabled@.
-}
isSleepEnabled
  :: BodyId
  -> IO Bool
isSleepEnabled a0 =
  toBool <$> (c_b2Body_IsSleepEnabled a0)

{- | Set the sleep threshold, usually in meters per second

Binds @b2Body_SetSleepThreshold@.
-}
setSleepThreshold
  :: BodyId
  -> Float
  -- ^ @sleepThreshold@
  -> IO ()
setSleepThreshold a0 a1 =
  c_b2Body_SetSleepThreshold a0 a1

{- | Get the sleep threshold, usually in meters per second.

Binds @b2Body_GetSleepThreshold@.
-}
getSleepThreshold
  :: BodyId
  -> IO Float
getSleepThreshold a0 =
  c_b2Body_GetSleepThreshold a0

{- | Returns true if this body is enabled

Binds @b2Body_IsEnabled@.
-}
isEnabled
  :: BodyId
  -> IO Bool
isEnabled a0 =
  toBool <$> (c_b2Body_IsEnabled a0)

{- | Disable a body by removing it completely from the simulation. This is expensive.

Binds @b2Body_Disable@.
-}
disable
  :: BodyId
  -> IO ()
disable a0 =
  c_b2Body_Disable a0

{- | Enable a body by adding it to the simulation. This is expensive.

Binds @b2Body_Enable@.
-}
enable
  :: BodyId
  -> IO ()
enable a0 =
  c_b2Body_Enable a0

{- | Set the motion locks on this body.

Binds @b2Body_SetMotionLocks@.
-}
setMotionLocks
  :: BodyId
  -> MotionLocks
  -> IO ()
setMotionLocks a0 a1 =
  with a1 $ \p1 ->
  c_b2Body_SetMotionLocks a0 p1

{- | Get the motion locks for this body.

Binds @b2Body_GetMotionLocks@.
-}
getMotionLocks
  :: BodyId
  -> IO MotionLocks
getMotionLocks a0 =
  alloca $ \pOut -> c_b2Body_GetMotionLocks a0 pOut >> peek pOut

-- | Like 'getMotionLocks', but the result is written into a caller-supplied buffer.
getMotionLocksInto
  :: BodyId
  -> Ptr MotionLocks
  -- ^ Result buffer.
  -> IO ()
getMotionLocksInto a0 out =
  c_b2Body_GetMotionLocks a0 out

{- | Set this body to be a bullet. A bullet does continuous collision detection
against dynamic bodies (but not other bullets).

Binds @b2Body_SetBullet@.
-}
setBullet
  :: BodyId
  -> Bool
  -- ^ @flag@
  -> IO ()
setBullet a0 a1 =
  c_b2Body_SetBullet a0 (fromBool a1)

{- | Is this body a bullet?

Binds @b2Body_IsBullet@.
-}
isBullet
  :: BodyId
  -> IO Bool
isBullet a0 =
  toBool <$> (c_b2Body_IsBullet a0)

{- | Enable or disable contact recycling for this body. Contact recycling is a performance optimization
that reuses contact manifolds when bodies move slightly. Disabling it can avoid ghost collisions
on characters at the cost of higher per-step work. Existing contacts retain their prior setting;
only contacts created after this call see the new value.
See also b2BodyDef::enableContactRecycling.

Binds @b2Body_EnableContactRecycling@.
-}
enableContactRecycling
  :: BodyId
  -> Bool
  -- ^ @flag@
  -> IO ()
enableContactRecycling a0 a1 =
  c_b2Body_EnableContactRecycling a0 (fromBool a1)

{- | Is contact recycling enabled on this body?

Binds @b2Body_IsContactRecyclingEnabled@.
-}
isContactRecyclingEnabled
  :: BodyId
  -> IO Bool
isContactRecyclingEnabled a0 =
  toBool <$> (c_b2Body_IsContactRecyclingEnabled a0)

{- | Enable\/disable contact events on all shapes.
See also b2ShapeDef::enableContactEvents.
Warning: changing this at runtime may cause mismatched begin\/end touch events

Binds @b2Body_EnableContactEvents@.
-}
enableContactEvents
  :: BodyId
  -> Bool
  -- ^ @flag@
  -> IO ()
enableContactEvents a0 a1 =
  c_b2Body_EnableContactEvents a0 (fromBool a1)

{- | Enable\/disable hit events on all shapes
See also b2ShapeDef::enableHitEvents.

Binds @b2Body_EnableHitEvents@.
-}
enableHitEvents
  :: BodyId
  -> Bool
  -- ^ @flag@
  -> IO ()
enableHitEvents a0 a1 =
  c_b2Body_EnableHitEvents a0 (fromBool a1)

{- | Get the world that owns this body

Binds @b2Body_GetWorld@.
-}
getWorld
  :: BodyId
  -> IO WorldId
getWorld a0 =
  c_b2Body_GetWorld a0

{- | Get the number of shapes on this body

Binds @b2Body_GetShapeCount@.
-}
getShapeCount
  :: BodyId
  -> IO Int
getShapeCount a0 =
  fromIntegral <$> (c_b2Body_GetShapeCount a0)

{- | Get the shape ids for all shapes on this body, up to the provided capacity.

Returns: the number of shape ids stored in the user array

Binds @b2Body_GetShapes@.
-}
getShapes
  :: BodyId
  -> Ptr ShapeId
  -- ^ @shapeArray@
  -> Int
  -- ^ @capacity@
  -> IO Int
getShapes a0 a1 a2 =
  fromIntegral <$> (c_b2Body_GetShapes a0 a1 (fromIntegral a2))

{- | Get the number of joints on this body

Binds @b2Body_GetJointCount@.
-}
getJointCount
  :: BodyId
  -> IO Int
getJointCount a0 =
  fromIntegral <$> (c_b2Body_GetJointCount a0)

{- | Get the joint ids for all joints on this body, up to the provided capacity

Returns: the number of joint ids stored in the user array

Binds @b2Body_GetJoints@.
-}
getJoints
  :: BodyId
  -> Ptr JointId
  -- ^ @jointArray@
  -> Int
  -- ^ @capacity@
  -> IO Int
getJoints a0 a1 a2 =
  fromIntegral <$> (c_b2Body_GetJoints a0 a1 (fromIntegral a2))

{- | Get the maximum capacity required for retrieving all the touching contacts on a body

Binds @b2Body_GetContactCapacity@.
-}
getContactCapacity
  :: BodyId
  -> IO Int
getContactCapacity a0 =
  fromIntegral <$> (c_b2Body_GetContactCapacity a0)

{- | Get the touching contact data for a body.
Note: Box2D uses speculative collision so some contact points may be separated.
Warning: do not ignore the return value, it specifies the valid number of elements

Returns: the number of elements filled in the provided array

Binds @b2Body_GetContactData@.
-}
getContactData
  :: BodyId
  -> Ptr ContactData
  -> Int
  -- ^ @capacity@
  -> IO Int
getContactData a0 a1 a2 =
  fromIntegral <$> (c_b2Body_GetContactData a0 a1 (fromIntegral a2))

{- | Get the current world AABB that contains all the attached shapes. Note that this may not encompass the body origin.
If there are no shapes attached then the returned AABB is empty and centered on the body origin.

Binds @b2Body_ComputeAABB@.
-}
computeAABB
  :: BodyId
  -> IO AABB
computeAABB a0 =
  alloca $ \pOut -> c_b2Body_ComputeAABB a0 pOut >> peek pOut

-- | Like 'computeAABB', but the result is written into a caller-supplied buffer.
computeAABBInto
  :: BodyId
  -> Ptr AABB
  -- ^ Result buffer.
  -> IO ()
computeAABBInto a0 out =
  c_b2Body_ComputeAABB a0 out
