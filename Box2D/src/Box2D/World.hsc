{-# LANGUAGE ForeignFunctionInterface #-}
{-# LANGUAGE PatternSynonyms #-}
{-# LANGUAGE GeneralizedNewtypeDeriving #-}

-- Produced by boxnd-gen; edit the generator, not this file.

module Box2D.World
  ( ContactData (..)
  , JointEvents (..)
  , JointEvent (..)
  , BodyEvents (..)
  , BodyMoveEvent (..)
  , ContactEvents (..)
  , ContactHitEvent (..)
  , ContactEndTouchEvent (..)
  , ContactBeginTouchEvent (..)
  , SensorEvents (..)
  , SensorEndTouchEvent (..)
  , SensorBeginTouchEvent (..)
  , ExplosionDef (..)
  , Counters (..)
  , Profile (..)
  , WorldDef (..)
  , Capacity (..)
  , RayResult (..)
  , defaultWorldDef
  , defaultExplosionDef
  , create
  , destroy
  , isValid
  , step
  , draw
  , getBounds
  , getBoundsInto
  , getBodyEvents
  , getBodyEventsInto
  , getSensorEvents
  , getSensorEventsInto
  , getContactEvents
  , getContactEventsInto
  , getJointEvents
  , getJointEventsInto
  , overlapAABB
  , overlapShape
  , castRay
  , castRayClosest
  , castShape
  , castMover
  , collideMover
  , enableSleeping
  , isSleepingEnabled
  , enableContinuous
  , isContinuousEnabled
  , setRestitutionThreshold
  , getRestitutionThreshold
  , setHitEventThreshold
  , getHitEventThreshold
  , setCustomFilterCallback
  , setPreSolveCallback
  , setGravity
  , getGravity
  , getGravityInto
  , explode
  , setContactTuning
  , setContactRecycleDistance
  , getContactRecycleDistance
  , setMaximumLinearSpeed
  , getMaximumLinearSpeed
  , enableWarmStarting
  , isWarmStartingEnabled
  , getAwakeBodyCount
  , getProfile
  , getCounters
  , getMaxCapacity
  , getMaxCapacityInto
  , setUserData
  , getUserData
  , setFrictionCallback
  , setRestitutionCallback
  , setWorkerCount
  , getWorkerCount
  , dumpMemoryStats
  , rebuildStaticTree
  , enableSpeculative
  , startRecording
  , stopRecording
  , snapshot
  , restore
  , createFromSnapshot
  )
  where

import Foreign
import Foreign.C.Types (CBool (..), CInt (..))
import Data.Vector.Storable qualified as VS
import Box2D.Internal (allocaOut, copyVector, pokeCountedVector)
import Box2D.Collision (Manifold)
import Box2D.DynamicTree (TreeStats)
import Box2D.Geometry (Capsule, ShapeProxy)
import Box2D.Id (BodyId, ContactId, JointId, ShapeId, WorldId (..))
import Box2D.MathTypes (AABB, Pos, Vec2, WorldTransform)
import Box2D.Shape (QueryFilter)
import Box2D.Tags (CastResultFcn, CustomFilterFcn, DebugDraw, EnqueueTaskCallback, FinishTaskCallback, FrictionCallback, OverlapResultFcn, PlaneResultFcn, PreSolveFcn, Recording, RestitutionCallback)

#include "box2d/box2d.h"


-- | The contact data for two shapes. By convention the manifold normal points
data ContactData = ContactData
  { contactId :: ContactId
  , shapeIdA :: ShapeId
  , shapeIdB :: ShapeId
  , manifold :: Manifold
  }
  deriving (Eq, Show)

instance Storable ContactData where
  sizeOf _ = #{size b2ContactData}
  alignment _ = #{alignment b2ContactData}
  peek p =
    ContactData
      <$> #{peek b2ContactData, contactId} p
      <*> #{peek b2ContactData, shapeIdA} p
      <*> #{peek b2ContactData, shapeIdB} p
      <*> #{peek b2ContactData, manifold} p
  poke p (ContactData f1 f2 f3 f4) = do
    #{poke b2ContactData, contactId} p f1
    #{poke b2ContactData, shapeIdA} p f2
    #{poke b2ContactData, shapeIdB} p f3
    #{poke b2ContactData, manifold} p f4

-- | Joint events are buffered in the world and are available
data JointEvents = JointEvents
  { jointEvents :: Ptr JointEvent
  , count :: CInt
  }
  deriving (Eq, Show)

instance Storable JointEvents where
  sizeOf _ = #{size b2JointEvents}
  alignment _ = #{alignment b2JointEvents}
  peek p =
    JointEvents
      <$> #{peek b2JointEvents, jointEvents} p
      <*> #{peek b2JointEvents, count} p
  poke p (JointEvents f1 f2) = do
    #{poke b2JointEvents, jointEvents} p f1
    #{poke b2JointEvents, count} p f2

-- | Joint events report joints that are awake and have a force and/or torque exceeding the threshold
data JointEvent = JointEvent
  { jointId :: JointId
  , userData :: Ptr ()
  }
  deriving (Eq, Show)

instance Storable JointEvent where
  sizeOf _ = #{size b2JointEvent}
  alignment _ = #{alignment b2JointEvent}
  peek p =
    JointEvent
      <$> #{peek b2JointEvent, jointId} p
      <*> #{peek b2JointEvent, userData} p
  poke p (JointEvent f1 f2) = do
    #{poke b2JointEvent, jointId} p f1
    #{poke b2JointEvent, userData} p f2

-- | Body events are buffered in the Box2D world and are available
data BodyEvents = BodyEvents
  { moveEvents :: Ptr BodyMoveEvent
  , moveCount :: CInt
  }
  deriving (Eq, Show)

instance Storable BodyEvents where
  sizeOf _ = #{size b2BodyEvents}
  alignment _ = #{alignment b2BodyEvents}
  peek p =
    BodyEvents
      <$> #{peek b2BodyEvents, moveEvents} p
      <*> #{peek b2BodyEvents, moveCount} p
  poke p (BodyEvents f1 f2) = do
    #{poke b2BodyEvents, moveEvents} p f1
    #{poke b2BodyEvents, moveCount} p f2

-- | Body move events triggered when a body moves.
data BodyMoveEvent = BodyMoveEvent
  { userData :: Ptr ()
  , transform :: WorldTransform
  , bodyId :: BodyId
  , fellAsleep :: CBool
  }
  deriving (Eq, Show)

instance Storable BodyMoveEvent where
  sizeOf _ = #{size b2BodyMoveEvent}
  alignment _ = #{alignment b2BodyMoveEvent}
  peek p =
    BodyMoveEvent
      <$> #{peek b2BodyMoveEvent, userData} p
      <*> #{peek b2BodyMoveEvent, transform} p
      <*> #{peek b2BodyMoveEvent, bodyId} p
      <*> #{peek b2BodyMoveEvent, fellAsleep} p
  poke p (BodyMoveEvent f1 f2 f3 f4) = do
    #{poke b2BodyMoveEvent, userData} p f1
    #{poke b2BodyMoveEvent, transform} p f2
    #{poke b2BodyMoveEvent, bodyId} p f3
    #{poke b2BodyMoveEvent, fellAsleep} p f4

-- | Contact events are buffered in the Box2D world and are available
data ContactEvents = ContactEvents
  { beginEvents :: Ptr ContactBeginTouchEvent
  , endEvents :: Ptr ContactEndTouchEvent
  , hitEvents :: Ptr ContactHitEvent
  , beginCount :: CInt
  , endCount :: CInt
  , hitCount :: CInt
  }
  deriving (Eq, Show)

instance Storable ContactEvents where
  sizeOf _ = #{size b2ContactEvents}
  alignment _ = #{alignment b2ContactEvents}
  peek p =
    ContactEvents
      <$> #{peek b2ContactEvents, beginEvents} p
      <*> #{peek b2ContactEvents, endEvents} p
      <*> #{peek b2ContactEvents, hitEvents} p
      <*> #{peek b2ContactEvents, beginCount} p
      <*> #{peek b2ContactEvents, endCount} p
      <*> #{peek b2ContactEvents, hitCount} p
  poke p (ContactEvents f1 f2 f3 f4 f5 f6) = do
    #{poke b2ContactEvents, beginEvents} p f1
    #{poke b2ContactEvents, endEvents} p f2
    #{poke b2ContactEvents, hitEvents} p f3
    #{poke b2ContactEvents, beginCount} p f4
    #{poke b2ContactEvents, endCount} p f5
    #{poke b2ContactEvents, hitCount} p f6

-- | A hit touch event is generated when two shapes collide with a speed faster than the hit speed threshold.
data ContactHitEvent = ContactHitEvent
  { shapeIdA :: ShapeId
  , shapeIdB :: ShapeId
  , contactId :: ContactId
  , point :: Pos
  , normal :: Vec2
  , approachSpeed :: Float
  }
  deriving (Eq, Show)

instance Storable ContactHitEvent where
  sizeOf _ = #{size b2ContactHitEvent}
  alignment _ = #{alignment b2ContactHitEvent}
  peek p =
    ContactHitEvent
      <$> #{peek b2ContactHitEvent, shapeIdA} p
      <*> #{peek b2ContactHitEvent, shapeIdB} p
      <*> #{peek b2ContactHitEvent, contactId} p
      <*> #{peek b2ContactHitEvent, point} p
      <*> #{peek b2ContactHitEvent, normal} p
      <*> #{peek b2ContactHitEvent, approachSpeed} p
  poke p (ContactHitEvent f1 f2 f3 f4 f5 f6) = do
    #{poke b2ContactHitEvent, shapeIdA} p f1
    #{poke b2ContactHitEvent, shapeIdB} p f2
    #{poke b2ContactHitEvent, contactId} p f3
    #{poke b2ContactHitEvent, point} p f4
    #{poke b2ContactHitEvent, normal} p f5
    #{poke b2ContactHitEvent, approachSpeed} p f6

-- | An end touch event is generated when two shapes stop touching.
data ContactEndTouchEvent = ContactEndTouchEvent
  { shapeIdA :: ShapeId
  , shapeIdB :: ShapeId
  , contactId :: ContactId
  }
  deriving (Eq, Show)

instance Storable ContactEndTouchEvent where
  sizeOf _ = #{size b2ContactEndTouchEvent}
  alignment _ = #{alignment b2ContactEndTouchEvent}
  peek p =
    ContactEndTouchEvent
      <$> #{peek b2ContactEndTouchEvent, shapeIdA} p
      <*> #{peek b2ContactEndTouchEvent, shapeIdB} p
      <*> #{peek b2ContactEndTouchEvent, contactId} p
  poke p (ContactEndTouchEvent f1 f2 f3) = do
    #{poke b2ContactEndTouchEvent, shapeIdA} p f1
    #{poke b2ContactEndTouchEvent, shapeIdB} p f2
    #{poke b2ContactEndTouchEvent, contactId} p f3

-- | A begin touch event is generated when two shapes begin touching.
data ContactBeginTouchEvent = ContactBeginTouchEvent
  { shapeIdA :: ShapeId
  , shapeIdB :: ShapeId
  , contactId :: ContactId
  }
  deriving (Eq, Show)

instance Storable ContactBeginTouchEvent where
  sizeOf _ = #{size b2ContactBeginTouchEvent}
  alignment _ = #{alignment b2ContactBeginTouchEvent}
  peek p =
    ContactBeginTouchEvent
      <$> #{peek b2ContactBeginTouchEvent, shapeIdA} p
      <*> #{peek b2ContactBeginTouchEvent, shapeIdB} p
      <*> #{peek b2ContactBeginTouchEvent, contactId} p
  poke p (ContactBeginTouchEvent f1 f2 f3) = do
    #{poke b2ContactBeginTouchEvent, shapeIdA} p f1
    #{poke b2ContactBeginTouchEvent, shapeIdB} p f2
    #{poke b2ContactBeginTouchEvent, contactId} p f3

-- | Sensor events are buffered in the world and are available
data SensorEvents = SensorEvents
  { beginEvents :: Ptr SensorBeginTouchEvent
  , endEvents :: Ptr SensorEndTouchEvent
  , beginCount :: CInt
  , endCount :: CInt
  }
  deriving (Eq, Show)

instance Storable SensorEvents where
  sizeOf _ = #{size b2SensorEvents}
  alignment _ = #{alignment b2SensorEvents}
  peek p =
    SensorEvents
      <$> #{peek b2SensorEvents, beginEvents} p
      <*> #{peek b2SensorEvents, endEvents} p
      <*> #{peek b2SensorEvents, beginCount} p
      <*> #{peek b2SensorEvents, endCount} p
  poke p (SensorEvents f1 f2 f3 f4) = do
    #{poke b2SensorEvents, beginEvents} p f1
    #{poke b2SensorEvents, endEvents} p f2
    #{poke b2SensorEvents, beginCount} p f3
    #{poke b2SensorEvents, endCount} p f4

-- | An end touch event is generated when a shape stops overlapping a sensor shape.
data SensorEndTouchEvent = SensorEndTouchEvent
  { sensorShapeId :: ShapeId
  , visitorShapeId :: ShapeId
  }
  deriving (Eq, Show)

instance Storable SensorEndTouchEvent where
  sizeOf _ = #{size b2SensorEndTouchEvent}
  alignment _ = #{alignment b2SensorEndTouchEvent}
  peek p =
    SensorEndTouchEvent
      <$> #{peek b2SensorEndTouchEvent, sensorShapeId} p
      <*> #{peek b2SensorEndTouchEvent, visitorShapeId} p
  poke p (SensorEndTouchEvent f1 f2) = do
    #{poke b2SensorEndTouchEvent, sensorShapeId} p f1
    #{poke b2SensorEndTouchEvent, visitorShapeId} p f2

-- | A begin touch event is generated when a shape starts to overlap a sensor shape.
data SensorBeginTouchEvent = SensorBeginTouchEvent
  { sensorShapeId :: ShapeId
  , visitorShapeId :: ShapeId
  }
  deriving (Eq, Show)

instance Storable SensorBeginTouchEvent where
  sizeOf _ = #{size b2SensorBeginTouchEvent}
  alignment _ = #{alignment b2SensorBeginTouchEvent}
  peek p =
    SensorBeginTouchEvent
      <$> #{peek b2SensorBeginTouchEvent, sensorShapeId} p
      <*> #{peek b2SensorBeginTouchEvent, visitorShapeId} p
  poke p (SensorBeginTouchEvent f1 f2) = do
    #{poke b2SensorBeginTouchEvent, sensorShapeId} p f1
    #{poke b2SensorBeginTouchEvent, visitorShapeId} p f2

-- | The explosion definition is used to configure options for explosions. Explosions
data ExplosionDef = ExplosionDef
  { maskBits :: Word64
  , position :: Pos
  , radius :: Float
  , falloff :: Float
  , impulsePerLength :: Float
  }
  deriving (Eq, Show)

instance Storable ExplosionDef where
  sizeOf _ = #{size b2ExplosionDef}
  alignment _ = #{alignment b2ExplosionDef}
  peek p =
    ExplosionDef
      <$> #{peek b2ExplosionDef, maskBits} p
      <*> #{peek b2ExplosionDef, position} p
      <*> #{peek b2ExplosionDef, radius} p
      <*> #{peek b2ExplosionDef, falloff} p
      <*> #{peek b2ExplosionDef, impulsePerLength} p
  poke p (ExplosionDef f1 f2 f3 f4 f5) = do
    #{poke b2ExplosionDef, maskBits} p f1
    #{poke b2ExplosionDef, position} p f2
    #{poke b2ExplosionDef, radius} p f3
    #{poke b2ExplosionDef, falloff} p f4
    #{poke b2ExplosionDef, impulsePerLength} p f5

-- | Counters that give details of the simulation size.
data Counters = Counters
  { bodyCount :: CInt
  , shapeCount :: CInt
  , contactCount :: CInt
  , jointCount :: CInt
  , islandCount :: CInt
  , stackUsed :: CInt
  , staticTreeHeight :: CInt
  , treeHeight :: CInt
  , taskCount :: CInt
  , colorCounts :: VS.Vector CInt
  , awakeContactCount :: CInt
  , recycledContactCount :: CInt
  }
  deriving (Eq, Show)

instance Storable Counters where
  sizeOf _ = #{size b2Counters}
  alignment _ = #{alignment b2Counters}
  peek p = do
    n <- #{peek b2Counters, byteCount} p :: IO CInt
    Counters
      <$> #{peek b2Counters, bodyCount} p
      <*> #{peek b2Counters, shapeCount} p
      <*> #{peek b2Counters, contactCount} p
      <*> #{peek b2Counters, jointCount} p
      <*> #{peek b2Counters, islandCount} p
      <*> #{peek b2Counters, stackUsed} p
      <*> #{peek b2Counters, staticTreeHeight} p
      <*> #{peek b2Counters, treeHeight} p
      <*> #{peek b2Counters, taskCount} p
      <*> copyVector (fromIntegral n) (#{ptr b2Counters, colorCounts} p)
      <*> #{peek b2Counters, awakeContactCount} p
      <*> #{peek b2Counters, recycledContactCount} p
  poke p x = do
    #{poke b2Counters, bodyCount} p x.bodyCount
    #{poke b2Counters, shapeCount} p x.shapeCount
    #{poke b2Counters, contactCount} p x.contactCount
    #{poke b2Counters, jointCount} p x.jointCount
    #{poke b2Counters, islandCount} p x.islandCount
    #{poke b2Counters, stackUsed} p x.stackUsed
    #{poke b2Counters, staticTreeHeight} p x.staticTreeHeight
    #{poke b2Counters, treeHeight} p x.treeHeight
    #{poke b2Counters, taskCount} p x.taskCount
    pokeCountedVector (#{const 24}) (#{ptr b2Counters, colorCounts} p) (#{poke b2Counters, byteCount} p) x.colorCounts
    #{poke b2Counters, awakeContactCount} p x.awakeContactCount
    #{poke b2Counters, recycledContactCount} p x.recycledContactCount

-- | Profiling data. Times are in milliseconds.
data Profile = Profile
  { step :: Float
  , pairs :: Float
  , collide :: Float
  , solve :: Float
  , solverSetup :: Float
  , constraints :: Float
  , prepareConstraints :: Float
  , integrateVelocities :: Float
  , warmStart :: Float
  , solveImpulses :: Float
  , integratePositions :: Float
  , relaxImpulses :: Float
  , applyRestitution :: Float
  , storeImpulses :: Float
  , splitIslands :: Float
  , transforms :: Float
  , sensorHits :: Float
  , jointEvents :: Float
  , hitEvents :: Float
  , refit :: Float
  , bullets :: Float
  , sleepIslands :: Float
  , sensors :: Float
  }
  deriving (Eq, Show)

instance Storable Profile where
  sizeOf _ = #{size b2Profile}
  alignment _ = #{alignment b2Profile}
  peek p =
    Profile
      <$> #{peek b2Profile, step} p
      <*> #{peek b2Profile, pairs} p
      <*> #{peek b2Profile, collide} p
      <*> #{peek b2Profile, solve} p
      <*> #{peek b2Profile, solverSetup} p
      <*> #{peek b2Profile, constraints} p
      <*> #{peek b2Profile, prepareConstraints} p
      <*> #{peek b2Profile, integrateVelocities} p
      <*> #{peek b2Profile, warmStart} p
      <*> #{peek b2Profile, solveImpulses} p
      <*> #{peek b2Profile, integratePositions} p
      <*> #{peek b2Profile, relaxImpulses} p
      <*> #{peek b2Profile, applyRestitution} p
      <*> #{peek b2Profile, storeImpulses} p
      <*> #{peek b2Profile, splitIslands} p
      <*> #{peek b2Profile, transforms} p
      <*> #{peek b2Profile, sensorHits} p
      <*> #{peek b2Profile, jointEvents} p
      <*> #{peek b2Profile, hitEvents} p
      <*> #{peek b2Profile, refit} p
      <*> #{peek b2Profile, bullets} p
      <*> #{peek b2Profile, sleepIslands} p
      <*> #{peek b2Profile, sensors} p
  poke p (Profile f1 f2 f3 f4 f5 f6 f7 f8 f9 f10 f11 f12 f13 f14 f15 f16 f17 f18 f19 f20 f21 f22 f23) = do
    #{poke b2Profile, step} p f1
    #{poke b2Profile, pairs} p f2
    #{poke b2Profile, collide} p f3
    #{poke b2Profile, solve} p f4
    #{poke b2Profile, solverSetup} p f5
    #{poke b2Profile, constraints} p f6
    #{poke b2Profile, prepareConstraints} p f7
    #{poke b2Profile, integrateVelocities} p f8
    #{poke b2Profile, warmStart} p f9
    #{poke b2Profile, solveImpulses} p f10
    #{poke b2Profile, integratePositions} p f11
    #{poke b2Profile, relaxImpulses} p f12
    #{poke b2Profile, applyRestitution} p f13
    #{poke b2Profile, storeImpulses} p f14
    #{poke b2Profile, splitIslands} p f15
    #{poke b2Profile, transforms} p f16
    #{poke b2Profile, sensorHits} p f17
    #{poke b2Profile, jointEvents} p f18
    #{poke b2Profile, hitEvents} p f19
    #{poke b2Profile, refit} p f20
    #{poke b2Profile, bullets} p f21
    #{poke b2Profile, sleepIslands} p f22
    #{poke b2Profile, sensors} p f23

-- | World definition used to create a simulation world.
data WorldDef = WorldDef
  { gravity :: Vec2
  , restitutionThreshold :: Float
  , hitEventThreshold :: Float
  , contactHertz :: Float
  , contactDampingRatio :: Float
  , contactSpeed :: Float
  , maximumLinearSpeed :: Float
  , frictionCallback :: FunPtr FrictionCallback
  , restitutionCallback :: FunPtr RestitutionCallback
  , enableSleep :: CBool
  , enableContinuous :: CBool
  , enableContactSoftening :: CBool
  , workerCount :: CInt
  , enqueueTask :: FunPtr EnqueueTaskCallback
  , finishTask :: FunPtr FinishTaskCallback
  , userTaskContext :: Ptr ()
  , userData :: Ptr ()
  , capacity :: Capacity
  , internalValue :: CInt
  }
  deriving (Eq, Show)

instance Storable WorldDef where
  sizeOf _ = #{size b2WorldDef}
  alignment _ = #{alignment b2WorldDef}
  peek p =
    WorldDef
      <$> #{peek b2WorldDef, gravity} p
      <*> #{peek b2WorldDef, restitutionThreshold} p
      <*> #{peek b2WorldDef, hitEventThreshold} p
      <*> #{peek b2WorldDef, contactHertz} p
      <*> #{peek b2WorldDef, contactDampingRatio} p
      <*> #{peek b2WorldDef, contactSpeed} p
      <*> #{peek b2WorldDef, maximumLinearSpeed} p
      <*> #{peek b2WorldDef, frictionCallback} p
      <*> #{peek b2WorldDef, restitutionCallback} p
      <*> #{peek b2WorldDef, enableSleep} p
      <*> #{peek b2WorldDef, enableContinuous} p
      <*> #{peek b2WorldDef, enableContactSoftening} p
      <*> #{peek b2WorldDef, workerCount} p
      <*> #{peek b2WorldDef, enqueueTask} p
      <*> #{peek b2WorldDef, finishTask} p
      <*> #{peek b2WorldDef, userTaskContext} p
      <*> #{peek b2WorldDef, userData} p
      <*> #{peek b2WorldDef, capacity} p
      <*> #{peek b2WorldDef, internalValue} p
  poke p (WorldDef f1 f2 f3 f4 f5 f6 f7 f8 f9 f10 f11 f12 f13 f14 f15 f16 f17 f18 f19) = do
    #{poke b2WorldDef, gravity} p f1
    #{poke b2WorldDef, restitutionThreshold} p f2
    #{poke b2WorldDef, hitEventThreshold} p f3
    #{poke b2WorldDef, contactHertz} p f4
    #{poke b2WorldDef, contactDampingRatio} p f5
    #{poke b2WorldDef, contactSpeed} p f6
    #{poke b2WorldDef, maximumLinearSpeed} p f7
    #{poke b2WorldDef, frictionCallback} p f8
    #{poke b2WorldDef, restitutionCallback} p f9
    #{poke b2WorldDef, enableSleep} p f10
    #{poke b2WorldDef, enableContinuous} p f11
    #{poke b2WorldDef, enableContactSoftening} p f12
    #{poke b2WorldDef, workerCount} p f13
    #{poke b2WorldDef, enqueueTask} p f14
    #{poke b2WorldDef, finishTask} p f15
    #{poke b2WorldDef, userTaskContext} p f16
    #{poke b2WorldDef, userData} p f17
    #{poke b2WorldDef, capacity} p f18
    #{poke b2WorldDef, internalValue} p f19

-- | Optional world capacities that can be used to avoid run-time allocations.
data Capacity = Capacity
  { staticShapeCount :: CInt
  , dynamicShapeCount :: CInt
  , staticBodyCount :: CInt
  , dynamicBodyCount :: CInt
  , contactCount :: CInt
  }
  deriving (Eq, Show)

instance Storable Capacity where
  sizeOf _ = #{size b2Capacity}
  alignment _ = #{alignment b2Capacity}
  peek p =
    Capacity
      <$> #{peek b2Capacity, staticShapeCount} p
      <*> #{peek b2Capacity, dynamicShapeCount} p
      <*> #{peek b2Capacity, staticBodyCount} p
      <*> #{peek b2Capacity, dynamicBodyCount} p
      <*> #{peek b2Capacity, contactCount} p
  poke p (Capacity f1 f2 f3 f4 f5) = do
    #{poke b2Capacity, staticShapeCount} p f1
    #{poke b2Capacity, dynamicShapeCount} p f2
    #{poke b2Capacity, staticBodyCount} p f3
    #{poke b2Capacity, dynamicBodyCount} p f4
    #{poke b2Capacity, contactCount} p f5

-- | Result from b2World_RayCastClosest
data RayResult = RayResult
  { shapeId :: ShapeId
  , point :: Pos
  , normal :: Vec2
  , fraction :: Float
  , nodeVisits :: CInt
  , leafVisits :: CInt
  , hit :: CBool
  }
  deriving (Eq, Show)

instance Storable RayResult where
  sizeOf _ = #{size b2RayResult}
  alignment _ = #{alignment b2RayResult}
  peek p =
    RayResult
      <$> #{peek b2RayResult, shapeId} p
      <*> #{peek b2RayResult, point} p
      <*> #{peek b2RayResult, normal} p
      <*> #{peek b2RayResult, fraction} p
      <*> #{peek b2RayResult, nodeVisits} p
      <*> #{peek b2RayResult, leafVisits} p
      <*> #{peek b2RayResult, hit} p
  poke p (RayResult f1 f2 f3 f4 f5 f6 f7) = do
    #{poke b2RayResult, shapeId} p f1
    #{poke b2RayResult, point} p f2
    #{poke b2RayResult, normal} p f3
    #{poke b2RayResult, fraction} p f4
    #{poke b2RayResult, nodeVisits} p f5
    #{poke b2RayResult, leafVisits} p f6
    #{poke b2RayResult, hit} p f7

foreign import ccall unsafe "hs_b2DefaultWorldDef"
  c_b2DefaultWorldDef :: Ptr WorldDef -> IO ()

defaultWorldDef :: IO WorldDef
defaultWorldDef = allocaOut c_b2DefaultWorldDef

foreign import ccall unsafe "hs_b2DefaultExplosionDef"
  c_b2DefaultExplosionDef :: Ptr ExplosionDef -> IO ()

defaultExplosionDef :: IO ExplosionDef
defaultExplosionDef = allocaOut c_b2DefaultExplosionDef


foreign import ccall unsafe "b2CreateWorld"
  c_b2CreateWorld :: Ptr WorldDef -> IO WorldId

foreign import ccall unsafe "b2DestroyWorld"
  c_b2DestroyWorld :: WorldId -> IO ()

foreign import ccall unsafe "b2World_IsValid"
  c_b2World_IsValid :: WorldId -> IO CBool

foreign import ccall safe "b2World_Step"
  c_b2World_Step :: WorldId -> Float -> CInt -> IO ()

foreign import ccall unsafe "b2World_Draw"
  c_b2World_Draw :: WorldId -> Ptr DebugDraw -> IO ()

foreign import ccall unsafe "hsg_b2World_GetBounds"
  c_b2World_GetBounds :: WorldId -> Ptr AABB -> IO ()

foreign import ccall unsafe "hsg_b2World_GetBodyEvents"
  c_b2World_GetBodyEvents :: WorldId -> Ptr BodyEvents -> IO ()

foreign import ccall unsafe "hsg_b2World_GetSensorEvents"
  c_b2World_GetSensorEvents :: WorldId -> Ptr SensorEvents -> IO ()

foreign import ccall unsafe "hsg_b2World_GetContactEvents"
  c_b2World_GetContactEvents :: WorldId -> Ptr ContactEvents -> IO ()

foreign import ccall unsafe "hsg_b2World_GetJointEvents"
  c_b2World_GetJointEvents :: WorldId -> Ptr JointEvents -> IO ()

foreign import ccall safe "hsg_b2World_OverlapAABB"
  c_b2World_OverlapAABB :: WorldId -> Ptr Pos -> Ptr AABB -> Ptr QueryFilter -> FunPtr OverlapResultFcn -> Ptr () -> Ptr TreeStats -> IO ()

foreign import ccall safe "hsg_b2World_OverlapShape"
  c_b2World_OverlapShape :: WorldId -> Ptr Pos -> Ptr ShapeProxy -> Ptr QueryFilter -> FunPtr OverlapResultFcn -> Ptr () -> Ptr TreeStats -> IO ()

foreign import ccall safe "hsg_b2World_CastRay"
  c_b2World_CastRay :: WorldId -> Ptr Pos -> Ptr Vec2 -> Ptr QueryFilter -> FunPtr CastResultFcn -> Ptr () -> Ptr TreeStats -> IO ()

foreign import ccall unsafe "hsg_b2World_CastRayClosest"
  c_b2World_CastRayClosest :: WorldId -> Ptr Pos -> Ptr Vec2 -> Ptr QueryFilter -> Ptr RayResult -> IO ()

foreign import ccall safe "hsg_b2World_CastShape"
  c_b2World_CastShape :: WorldId -> Ptr Pos -> Ptr ShapeProxy -> Ptr Vec2 -> Ptr QueryFilter -> FunPtr CastResultFcn -> Ptr () -> Ptr TreeStats -> IO ()

foreign import ccall unsafe "hsg_b2World_CastMover"
  c_b2World_CastMover :: WorldId -> Ptr Pos -> Ptr Capsule -> Ptr Vec2 -> Ptr QueryFilter -> IO Float

foreign import ccall safe "hsg_b2World_CollideMover"
  c_b2World_CollideMover :: WorldId -> Ptr Pos -> Ptr Capsule -> Ptr QueryFilter -> FunPtr PlaneResultFcn -> Ptr () -> IO ()

foreign import ccall unsafe "b2World_EnableSleeping"
  c_b2World_EnableSleeping :: WorldId -> CBool -> IO ()

foreign import ccall unsafe "b2World_IsSleepingEnabled"
  c_b2World_IsSleepingEnabled :: WorldId -> IO CBool

foreign import ccall unsafe "b2World_EnableContinuous"
  c_b2World_EnableContinuous :: WorldId -> CBool -> IO ()

foreign import ccall unsafe "b2World_IsContinuousEnabled"
  c_b2World_IsContinuousEnabled :: WorldId -> IO CBool

foreign import ccall unsafe "b2World_SetRestitutionThreshold"
  c_b2World_SetRestitutionThreshold :: WorldId -> Float -> IO ()

foreign import ccall unsafe "b2World_GetRestitutionThreshold"
  c_b2World_GetRestitutionThreshold :: WorldId -> IO Float

foreign import ccall unsafe "b2World_SetHitEventThreshold"
  c_b2World_SetHitEventThreshold :: WorldId -> Float -> IO ()

foreign import ccall unsafe "b2World_GetHitEventThreshold"
  c_b2World_GetHitEventThreshold :: WorldId -> IO Float

foreign import ccall safe "b2World_SetCustomFilterCallback"
  c_b2World_SetCustomFilterCallback :: WorldId -> FunPtr CustomFilterFcn -> Ptr () -> IO ()

foreign import ccall safe "b2World_SetPreSolveCallback"
  c_b2World_SetPreSolveCallback :: WorldId -> FunPtr PreSolveFcn -> Ptr () -> IO ()

foreign import ccall unsafe "hsg_b2World_SetGravity"
  c_b2World_SetGravity :: WorldId -> Ptr Vec2 -> IO ()

foreign import ccall unsafe "hsg_b2World_GetGravity"
  c_b2World_GetGravity :: WorldId -> Ptr Vec2 -> IO ()

foreign import ccall unsafe "b2World_Explode"
  c_b2World_Explode :: WorldId -> Ptr ExplosionDef -> IO ()

foreign import ccall unsafe "b2World_SetContactTuning"
  c_b2World_SetContactTuning :: WorldId -> Float -> Float -> Float -> IO ()

foreign import ccall unsafe "b2World_SetContactRecycleDistance"
  c_b2World_SetContactRecycleDistance :: WorldId -> Float -> IO ()

foreign import ccall unsafe "b2World_GetContactRecycleDistance"
  c_b2World_GetContactRecycleDistance :: WorldId -> IO Float

foreign import ccall unsafe "b2World_SetMaximumLinearSpeed"
  c_b2World_SetMaximumLinearSpeed :: WorldId -> Float -> IO ()

foreign import ccall unsafe "b2World_GetMaximumLinearSpeed"
  c_b2World_GetMaximumLinearSpeed :: WorldId -> IO Float

foreign import ccall unsafe "b2World_EnableWarmStarting"
  c_b2World_EnableWarmStarting :: WorldId -> CBool -> IO ()

foreign import ccall unsafe "b2World_IsWarmStartingEnabled"
  c_b2World_IsWarmStartingEnabled :: WorldId -> IO CBool

foreign import ccall unsafe "b2World_GetAwakeBodyCount"
  c_b2World_GetAwakeBodyCount :: WorldId -> IO CInt

foreign import ccall unsafe "hsg_b2World_GetProfile"
  c_b2World_GetProfile :: WorldId -> Ptr Profile -> IO ()

foreign import ccall unsafe "hsg_b2World_GetCounters"
  c_b2World_GetCounters :: WorldId -> Ptr Counters -> IO ()

foreign import ccall unsafe "hsg_b2World_GetMaxCapacity"
  c_b2World_GetMaxCapacity :: WorldId -> Ptr Capacity -> IO ()

foreign import ccall unsafe "b2World_SetUserData"
  c_b2World_SetUserData :: WorldId -> Ptr () -> IO ()

foreign import ccall unsafe "b2World_GetUserData"
  c_b2World_GetUserData :: WorldId -> IO (Ptr ())

foreign import ccall safe "b2World_SetFrictionCallback"
  c_b2World_SetFrictionCallback :: WorldId -> FunPtr FrictionCallback -> IO ()

foreign import ccall safe "b2World_SetRestitutionCallback"
  c_b2World_SetRestitutionCallback :: WorldId -> FunPtr RestitutionCallback -> IO ()

foreign import ccall unsafe "b2World_SetWorkerCount"
  c_b2World_SetWorkerCount :: WorldId -> CInt -> IO ()

foreign import ccall unsafe "b2World_GetWorkerCount"
  c_b2World_GetWorkerCount :: WorldId -> IO CInt

foreign import ccall unsafe "b2World_DumpMemoryStats"
  c_b2World_DumpMemoryStats :: WorldId -> IO ()

foreign import ccall unsafe "b2World_RebuildStaticTree"
  c_b2World_RebuildStaticTree :: WorldId -> IO ()

foreign import ccall unsafe "b2World_EnableSpeculative"
  c_b2World_EnableSpeculative :: WorldId -> CBool -> IO ()

foreign import ccall unsafe "b2World_StartRecording"
  c_b2World_StartRecording :: WorldId -> Ptr Recording -> IO ()

foreign import ccall unsafe "b2World_StopRecording"
  c_b2World_StopRecording :: WorldId -> IO ()

foreign import ccall unsafe "b2World_Snapshot"
  c_b2World_Snapshot :: WorldId -> Ptr Word8 -> CInt -> IO CInt

foreign import ccall unsafe "b2World_Restore"
  c_b2World_Restore :: WorldId -> Ptr Word8 -> CInt -> IO CBool

foreign import ccall unsafe "b2CreateWorldFromSnapshot"
  c_b2CreateWorldFromSnapshot :: Ptr Word8 -> CInt -> CInt -> IO WorldId

{- | Create a world for rigid body simulation. A world contains bodies, shapes, and constraints. You make create
up to 128 worlds. Each world is completely independent and may be simulated in parallel.

Returns: the world id.

Binds @b2CreateWorld@.
-}
create
  :: WorldDef
  -> IO WorldId
create a0 =
  with a0 $ \p0 ->
  c_b2CreateWorld p0

{- | Destroy a world

Binds @b2DestroyWorld@.
-}
destroy
  :: WorldId
  -> IO ()
destroy a0 =
  c_b2DestroyWorld a0

{- | World id validation. Provides validation for up to 64K allocations.

Binds @b2World_IsValid@.
-}
isValid
  :: WorldId
  -> IO Bool
isValid a0 =
  toBool <$> (c_b2World_IsValid a0)

{- | Simulate a world for one time step. This performs collision detection, integration, and constraint solution.

Binds @b2World_Step@.
-}
step
  :: WorldId
  -- ^ @worldId@: The world to simulate
  -> Float
  -- ^ @timeStep@: The amount of time to simulate, this should be a fixed number. Usually 1\/60.
  -> Int
  -- ^ @subStepCount@: The number of sub-steps, increasing the sub-step count can increase accuracy. Usually 4.
  -> IO ()
step a0 a1 a2 =
  c_b2World_Step a0 a1 (fromIntegral a2)

{- | Call this to draw shapes and other debug draw data

Binds @b2World_Draw@.
-}
draw
  :: WorldId
  -> Ptr DebugDraw
  -> IO ()
draw a0 a1 =
  c_b2World_Draw a0 a1

{- | Call this to get the world bounds based on the union of all shape bounds.

Binds @b2World_GetBounds@.
-}
getBounds
  :: WorldId
  -> IO AABB
getBounds a0 =
  alloca $ \pOut -> c_b2World_GetBounds a0 pOut >> peek pOut

-- | Like 'getBounds', but the result is written into a caller-supplied buffer.
getBoundsInto
  :: WorldId
  -> Ptr AABB
  -- ^ Result buffer.
  -> IO ()
getBoundsInto a0 out =
  c_b2World_GetBounds a0 out

{- | Get the body events for the current time step. The event data is transient. Do not store a reference to this data.

Binds @b2World_GetBodyEvents@.
-}
getBodyEvents
  :: WorldId
  -> IO BodyEvents
getBodyEvents a0 =
  alloca $ \pOut -> c_b2World_GetBodyEvents a0 pOut >> peek pOut

-- | Like 'getBodyEvents', but the result is written into a caller-supplied buffer.
getBodyEventsInto
  :: WorldId
  -> Ptr BodyEvents
  -- ^ Result buffer.
  -> IO ()
getBodyEventsInto a0 out =
  c_b2World_GetBodyEvents a0 out

{- | Get sensor events for the current time step. The event data is transient. Do not store a reference to this data.

Binds @b2World_GetSensorEvents@.
-}
getSensorEvents
  :: WorldId
  -> IO SensorEvents
getSensorEvents a0 =
  alloca $ \pOut -> c_b2World_GetSensorEvents a0 pOut >> peek pOut

-- | Like 'getSensorEvents', but the result is written into a caller-supplied buffer.
getSensorEventsInto
  :: WorldId
  -> Ptr SensorEvents
  -- ^ Result buffer.
  -> IO ()
getSensorEventsInto a0 out =
  c_b2World_GetSensorEvents a0 out

{- | Get contact events for this current time step. The event data is transient. Do not store a reference to this data.

Binds @b2World_GetContactEvents@.
-}
getContactEvents
  :: WorldId
  -> IO ContactEvents
getContactEvents a0 =
  alloca $ \pOut -> c_b2World_GetContactEvents a0 pOut >> peek pOut

-- | Like 'getContactEvents', but the result is written into a caller-supplied buffer.
getContactEventsInto
  :: WorldId
  -> Ptr ContactEvents
  -- ^ Result buffer.
  -> IO ()
getContactEventsInto a0 out =
  c_b2World_GetContactEvents a0 out

{- | Get the joint events for the current time step. The event data is transient. Do not store a reference to this data.

Binds @b2World_GetJointEvents@.
-}
getJointEvents
  :: WorldId
  -> IO JointEvents
getJointEvents a0 =
  alloca $ \pOut -> c_b2World_GetJointEvents a0 pOut >> peek pOut

-- | Like 'getJointEvents', but the result is written into a caller-supplied buffer.
getJointEventsInto
  :: WorldId
  -> Ptr JointEvents
  -- ^ Result buffer.
  -> IO ()
getJointEventsInto a0 out =
  c_b2World_GetJointEvents a0 out

{- | Overlap test for all shapes that *potentially* overlap the provided AABB.
The AABB is relative to the origin, which keeps the test precise far from the world origin
in large world mode. Near the origin pass b2Pos_zero and a world AABB.

Binds @b2World_OverlapAABB@.
-}
overlapAABB
  :: WorldId
  -> Pos
  -- ^ @origin@
  -> AABB
  -> QueryFilter
  -> FunPtr OverlapResultFcn
  -> Ptr ()
  -- ^ @context@
  -> IO TreeStats
overlapAABB a0 a1 a2 a3 a4 a5 =
  with a1 $ \p1 ->
  with a2 $ \p2 ->
  with a3 $ \p3 ->
  alloca $ \pOut -> c_b2World_OverlapAABB a0 p1 p2 p3 a4 a5 pOut >> peek pOut

{- | Overlap test for all shapes that overlap the provided shape proxy.
The proxy points are relative to the origin. Near the origin pass b2Pos_zero and world points.

Binds @b2World_OverlapShape@.
-}
overlapShape
  :: WorldId
  -> Pos
  -- ^ @origin@
  -> Ptr ShapeProxy
  -> QueryFilter
  -> FunPtr OverlapResultFcn
  -> Ptr ()
  -- ^ @context@
  -> IO TreeStats
overlapShape a0 a1 a2 a3 a4 a5 =
  with a1 $ \p1 ->
  with a3 $ \p3 ->
  alloca $ \pOut -> c_b2World_OverlapShape a0 p1 a2 p3 a4 a5 pOut >> peek pOut

{- | Cast a ray into the world to collect shapes in the path of the ray.
Your callback function controls whether you get the closest point, any point, or n-points.
Note: The callback function may receive shapes in any order

Returns: traversal performance counters

Binds @b2World_CastRay@.
-}
castRay
  :: WorldId
  -- ^ @worldId@: The world to cast the ray against
  -> Pos
  -- ^ @origin@: The start point of the ray
  -> Vec2
  -- ^ @translation@: The translation of the ray from the start point to the end point
  -> QueryFilter
  -- ^ @filter@: Contains bit flags to filter unwanted shapes from the results
  -> FunPtr CastResultFcn
  -- ^ @fcn@: A user implemented callback function
  -> Ptr ()
  -- ^ @context@: A user context that is passed along to the callback function
  -> IO TreeStats
castRay a0 a1 a2 a3 a4 a5 =
  with a1 $ \p1 ->
  with a2 $ \p2 ->
  with a3 $ \p3 ->
  alloca $ \pOut -> c_b2World_CastRay a0 p1 p2 p3 a4 a5 pOut >> peek pOut

{- | Cast a ray into the world to collect the closest hit. This is a convenience function. Ignores initial overlap.
This is less general than b2World_CastRay() and does not allow for custom filtering.

Binds @b2World_CastRayClosest@.
-}
castRayClosest
  :: WorldId
  -> Pos
  -- ^ @origin@
  -> Vec2
  -- ^ @translation@
  -> QueryFilter
  -> IO RayResult
castRayClosest a0 a1 a2 a3 =
  with a1 $ \p1 ->
  with a2 $ \p2 ->
  with a3 $ \p3 ->
  alloca $ \pOut -> c_b2World_CastRayClosest a0 p1 p2 p3 pOut >> peek pOut

{- | Cast a shape through the world. Similar to a cast ray except that a shape is cast instead of a point.
The proxy points are relative to the origin. Callback points are world positions.
See also b2World_CastRay.

Binds @b2World_CastShape@.
-}
castShape
  :: WorldId
  -> Pos
  -- ^ @origin@
  -> Ptr ShapeProxy
  -> Vec2
  -- ^ @translation@
  -> QueryFilter
  -> FunPtr CastResultFcn
  -> Ptr ()
  -- ^ @context@
  -> IO TreeStats
castShape a0 a1 a2 a3 a4 a5 a6 =
  with a1 $ \p1 ->
  with a3 $ \p3 ->
  with a4 $ \p4 ->
  alloca $ \pOut -> c_b2World_CastShape a0 p1 a2 p3 p4 a5 a6 pOut >> peek pOut

{- | Cast a capsule mover through the world. This is a special shape cast that handles sliding along other shapes while reducing
clipping. The mover capsule is relative to the origin. Near the origin pass b2Pos_zero and a world capsule.

Binds @b2World_CastMover@.
-}
castMover
  :: WorldId
  -> Pos
  -- ^ @origin@
  -> Capsule
  -- ^ @mover@
  -> Vec2
  -- ^ @translation@
  -> QueryFilter
  -> IO Float
castMover a0 a1 a2 a3 a4 =
  with a1 $ \p1 ->
  with a2 $ \p2 ->
  with a3 $ \p3 ->
  with a4 $ \p4 ->
  c_b2World_CastMover a0 p1 p2 p3 p4

{- | Collide a capsule mover with the world, gathering collision planes that can be fed to b2SolvePlanes. Useful for
kinematic character movement. The mover capsule and the resulting planes are relative to the origin.

Binds @b2World_CollideMover@.
-}
collideMover
  :: WorldId
  -> Pos
  -- ^ @origin@
  -> Capsule
  -- ^ @mover@
  -> QueryFilter
  -> FunPtr PlaneResultFcn
  -> Ptr ()
  -- ^ @context@
  -> IO ()
collideMover a0 a1 a2 a3 a4 a5 =
  with a1 $ \p1 ->
  with a2 $ \p2 ->
  with a3 $ \p3 ->
  c_b2World_CollideMover a0 p1 p2 p3 a4 a5

{- | Enable\/disable sleep. If your application does not need sleeping, you can gain some performance
by disabling sleep completely at the world level.
See also b2WorldDef.

Binds @b2World_EnableSleeping@.
-}
enableSleeping
  :: WorldId
  -> Bool
  -- ^ @flag@
  -> IO ()
enableSleeping a0 a1 =
  c_b2World_EnableSleeping a0 (fromBool a1)

{- | Is body sleeping enabled?

Binds @b2World_IsSleepingEnabled@.
-}
isSleepingEnabled
  :: WorldId
  -> IO Bool
isSleepingEnabled a0 =
  toBool <$> (c_b2World_IsSleepingEnabled a0)

{- | Enable\/disable continuous collision between dynamic and static bodies. Generally you should keep continuous
collision enabled to prevent fast moving objects from going through static objects. The performance gain from
disabling continuous collision is minor.
See also b2WorldDef.

Binds @b2World_EnableContinuous@.
-}
enableContinuous
  :: WorldId
  -> Bool
  -- ^ @flag@
  -> IO ()
enableContinuous a0 a1 =
  c_b2World_EnableContinuous a0 (fromBool a1)

{- | Is continuous collision enabled?

Binds @b2World_IsContinuousEnabled@.
-}
isContinuousEnabled
  :: WorldId
  -> IO Bool
isContinuousEnabled a0 =
  toBool <$> (c_b2World_IsContinuousEnabled a0)

{- | Adjust the restitution threshold. It is recommended not to make this value very small
because it will prevent bodies from sleeping. Usually in meters per second.
See also b2WorldDef.

Binds @b2World_SetRestitutionThreshold@.
-}
setRestitutionThreshold
  :: WorldId
  -> Float
  -- ^ @value@
  -> IO ()
setRestitutionThreshold a0 a1 =
  c_b2World_SetRestitutionThreshold a0 a1

{- | Get the the restitution speed threshold. Usually in meters per second.

Binds @b2World_GetRestitutionThreshold@.
-}
getRestitutionThreshold
  :: WorldId
  -> IO Float
getRestitutionThreshold a0 =
  c_b2World_GetRestitutionThreshold a0

{- | Adjust the hit event threshold. This controls the collision speed needed to generate a b2ContactHitEvent.
Usually in meters per second.
See also b2WorldDef::hitEventThreshold.

Binds @b2World_SetHitEventThreshold@.
-}
setHitEventThreshold
  :: WorldId
  -> Float
  -- ^ @value@
  -> IO ()
setHitEventThreshold a0 a1 =
  c_b2World_SetHitEventThreshold a0 a1

{- | Get the the hit event speed threshold. Usually in meters per second.

Binds @b2World_GetHitEventThreshold@.
-}
getHitEventThreshold
  :: WorldId
  -> IO Float
getHitEventThreshold a0 =
  c_b2World_GetHitEventThreshold a0

{- | Register the custom filter callback. This is optional.

Binds @b2World_SetCustomFilterCallback@.
-}
setCustomFilterCallback
  :: WorldId
  -> FunPtr CustomFilterFcn
  -> Ptr ()
  -- ^ @context@
  -> IO ()
setCustomFilterCallback a0 a1 a2 =
  c_b2World_SetCustomFilterCallback a0 a1 a2

{- | Register the pre-solve callback. This is optional.

Binds @b2World_SetPreSolveCallback@.
-}
setPreSolveCallback
  :: WorldId
  -> FunPtr PreSolveFcn
  -> Ptr ()
  -- ^ @context@
  -> IO ()
setPreSolveCallback a0 a1 a2 =
  c_b2World_SetPreSolveCallback a0 a1 a2

{- | Set the gravity vector for the entire world. Box2D has no concept of an up direction and this
is left as a decision for the application. Usually in m\/s^2.
See also b2WorldDef.

Binds @b2World_SetGravity@.
-}
setGravity
  :: WorldId
  -> Vec2
  -- ^ @gravity@
  -> IO ()
setGravity a0 a1 =
  with a1 $ \p1 ->
  c_b2World_SetGravity a0 p1

{- | Get the gravity vector

Binds @b2World_GetGravity@.
-}
getGravity
  :: WorldId
  -> IO Vec2
getGravity a0 =
  alloca $ \pOut -> c_b2World_GetGravity a0 pOut >> peek pOut

-- | Like 'getGravity', but the result is written into a caller-supplied buffer.
getGravityInto
  :: WorldId
  -> Ptr Vec2
  -- ^ Result buffer.
  -> IO ()
getGravityInto a0 out =
  c_b2World_GetGravity a0 out

{- | Apply a radial explosion

Binds @b2World_Explode@.
-}
explode
  :: WorldId
  -- ^ @worldId@: The world id
  -> ExplosionDef
  -- ^ @explosionDef@: The explosion definition
  -> IO ()
explode a0 a1 =
  with a1 $ \p1 ->
  c_b2World_Explode a0 p1

{- | Adjust contact tuning parameters
Note: Advanced feature

Binds @b2World_SetContactTuning@.
-}
setContactTuning
  :: WorldId
  -- ^ @worldId@: The world id
  -> Float
  -- ^ @hertz@: The contact stiffness (cycles per second)
  -> Float
  -- ^ @dampingRatio@: The contact bounciness with 1 being critical damping (non-dimensional)
  -> Float
  -- ^ @pushSpeed@: The maximum contact constraint push out speed (meters per second)
  -> IO ()
setContactTuning a0 a1 a2 a3 =
  c_b2World_SetContactTuning a0 a1 a2 a3

{- | Set the contact point recycling distance. Setting this to zero disables contact point recycling.
Usually in meters.

Binds @b2World_SetContactRecycleDistance@.
-}
setContactRecycleDistance
  :: WorldId
  -> Float
  -- ^ @recycleDistance@
  -> IO ()
setContactRecycleDistance a0 a1 =
  c_b2World_SetContactRecycleDistance a0 a1

{- | Get the contact point recycling distance. Usually in meters.

Binds @b2World_GetContactRecycleDistance@.
-}
getContactRecycleDistance
  :: WorldId
  -> IO Float
getContactRecycleDistance a0 =
  c_b2World_GetContactRecycleDistance a0

{- | Set the maximum linear speed. Usually in m\/s.

Binds @b2World_SetMaximumLinearSpeed@.
-}
setMaximumLinearSpeed
  :: WorldId
  -> Float
  -- ^ @maximumLinearSpeed@
  -> IO ()
setMaximumLinearSpeed a0 a1 =
  c_b2World_SetMaximumLinearSpeed a0 a1

{- | Get the maximum linear speed. Usually in m\/s.

Binds @b2World_GetMaximumLinearSpeed@.
-}
getMaximumLinearSpeed
  :: WorldId
  -> IO Float
getMaximumLinearSpeed a0 =
  c_b2World_GetMaximumLinearSpeed a0

{- | Enable\/disable constraint warm starting. Advanced feature for testing. Disabling
warm starting greatly reduces stability and provides no performance gain.

Binds @b2World_EnableWarmStarting@.
-}
enableWarmStarting
  :: WorldId
  -> Bool
  -- ^ @flag@
  -> IO ()
enableWarmStarting a0 a1 =
  c_b2World_EnableWarmStarting a0 (fromBool a1)

{- | Is constraint warm starting enabled?

Binds @b2World_IsWarmStartingEnabled@.
-}
isWarmStartingEnabled
  :: WorldId
  -> IO Bool
isWarmStartingEnabled a0 =
  toBool <$> (c_b2World_IsWarmStartingEnabled a0)

{- | Get the number of awake bodies.

Binds @b2World_GetAwakeBodyCount@.
-}
getAwakeBodyCount
  :: WorldId
  -> IO Int
getAwakeBodyCount a0 =
  fromIntegral <$> (c_b2World_GetAwakeBodyCount a0)

{- | Get the current world performance profile

Binds @b2World_GetProfile@.
-}
getProfile
  :: WorldId
  -> Ptr Profile
  -- ^ Result buffer.
  -> IO ()
getProfile a0 out =
  c_b2World_GetProfile a0 out

{- | Get world counters and sizes

Binds @b2World_GetCounters@.
-}
getCounters
  :: WorldId
  -> Ptr Counters
  -- ^ Result buffer.
  -> IO ()
getCounters a0 out =
  c_b2World_GetCounters a0 out

{- | Get max capacity. This can be used with b2WorldDef to avoid run-time allocations and copies

Binds @b2World_GetMaxCapacity@.
-}
getMaxCapacity
  :: WorldId
  -> IO Capacity
getMaxCapacity a0 =
  alloca $ \pOut -> c_b2World_GetMaxCapacity a0 pOut >> peek pOut

-- | Like 'getMaxCapacity', but the result is written into a caller-supplied buffer.
getMaxCapacityInto
  :: WorldId
  -> Ptr Capacity
  -- ^ Result buffer.
  -> IO ()
getMaxCapacityInto a0 out =
  c_b2World_GetMaxCapacity a0 out

{- | Set the user data pointer.

Binds @b2World_SetUserData@.
-}
setUserData
  :: WorldId
  -> Ptr ()
  -- ^ @userData@
  -> IO ()
setUserData a0 a1 =
  c_b2World_SetUserData a0 a1

{- | Get the user data pointer.

Binds @b2World_GetUserData@.
-}
getUserData
  :: WorldId
  -> IO (Ptr ())
getUserData a0 =
  c_b2World_GetUserData a0

{- | Set the friction callback. Passing NULL resets to default.

Binds @b2World_SetFrictionCallback@.
-}
setFrictionCallback
  :: WorldId
  -> FunPtr FrictionCallback
  -> IO ()
setFrictionCallback a0 a1 =
  c_b2World_SetFrictionCallback a0 a1

{- | Set the restitution callback. Passing NULL resets to default.

Binds @b2World_SetRestitutionCallback@.
-}
setRestitutionCallback
  :: WorldId
  -> FunPtr RestitutionCallback
  -> IO ()
setRestitutionCallback a0 a1 =
  c_b2World_SetRestitutionCallback a0 a1

{- | Set the worker count. Must be between in the range \[1, B2_MAX_WORKERS\]

Binds @b2World_SetWorkerCount@.
-}
setWorkerCount
  :: WorldId
  -> Int
  -- ^ @count@
  -> IO ()
setWorkerCount a0 a1 =
  c_b2World_SetWorkerCount a0 (fromIntegral a1)

{- | Get the worker count.

Binds @b2World_GetWorkerCount@.
-}
getWorkerCount
  :: WorldId
  -> IO Int
getWorkerCount a0 =
  fromIntegral <$> (c_b2World_GetWorkerCount a0)

{- | Dump memory stats to box2d_memory.txt

Binds @b2World_DumpMemoryStats@.
-}
dumpMemoryStats
  :: WorldId
  -> IO ()
dumpMemoryStats a0 =
  c_b2World_DumpMemoryStats a0

{- | This is for internal testing

Binds @b2World_RebuildStaticTree@.
-}
rebuildStaticTree
  :: WorldId
  -> IO ()
rebuildStaticTree a0 =
  c_b2World_RebuildStaticTree a0

{- | This is for internal testing

Binds @b2World_EnableSpeculative@.
-}
enableSpeculative
  :: WorldId
  -> Bool
  -- ^ @flag@
  -> IO ()
enableSpeculative a0 a1 =
  c_b2World_EnableSpeculative a0 (fromBool a1)

{- | Begin recording the world into \@p recording. Serializes a snapshot of the current world as the
seed, then logs every mutating call. Call at a step boundary, before or after creating bodies.
Start before the first step to capture the whole session. No effect if already recording or if
the world is locked.

Binds @b2World_StartRecording@.
-}
startRecording
  :: WorldId
  -- ^ @worldId@: The world to record
  -> Ptr Recording
  -- ^ @recording@: A recording buffer from b2CreateRecording
  -> IO ()
startRecording a0 a1 =
  c_b2World_StartRecording a0 a1

{- | Stop recording. The recording buffer keeps its bytes. Save and destroy it yourself.

Binds @b2World_StopRecording@.
-}
stopRecording
  :: WorldId
  -- ^ @worldId@: The world being recorded
  -> IO ()
stopRecording a0 =
  c_b2World_StopRecording a0

{- | Write a snapshot of the world\'s simulation state into a caller-owned buffer.
Call once with image == NULL to get the required size, then again with a buffer
of at least that size. Must be called at a step boundary.

Returns: The number of bytes the snapshot needs. If it exceeds capacity nothing is written. Returns 0 if the world is mid-step.

Binds @b2World_Snapshot@.
-}
snapshot
  :: WorldId
  -- ^ @worldId@: The world to snapshot
  -> Ptr Word8
  -- ^ @image@: Destination buffer, or NULL to query the size
  -> Int
  -- ^ @capacity@: Size of image in bytes, ignored when querying
  -> IO Int
snapshot a0 a1 a2 =
  fromIntegral <$> (c_b2World_Snapshot a0 a1 (fromIntegral a2))

{- | Restore a world\'s simulation state from a snapshot image, in place. The world keeps
its slot and generation, so this b2WorldId and any ids held from this same world stay
valid for objects that existed at the snapshot instant. Host wiring is preserved.
Restore into the same world the snapshot came from to keep held ids valid. Must be
called at a step boundary.

Returns: true on success. On a rejected image (bad magic, version, or layout) the world is left unchanged. A corrupt payload detected after the rebuild begins returns false and leaves the world unusable, so the caller must destroy it.

Binds @b2World_Restore@.
-}
restore
  :: WorldId
  -- ^ @worldId@: The world to restore into
  -> Ptr Word8
  -- ^ @image@: A snapshot image produced by b2World_Snapshot
  -> Int
  -- ^ @size@: Size of image in bytes
  -> IO Bool
restore a0 a1 a2 =
  toBool <$> (c_b2World_Restore a0 a1 (fromIntegral a2))

{- | Create a new world from a snapshot image. Use this to load a saved world when there is
no existing world to restore into. The new world gets a fresh slot and id, so ids held
from the origin world will not match it. Host wiring is reset to defaults.

Returns: The new world id, or b2_nullWorldId on failure.

Binds @b2CreateWorldFromSnapshot@.
-}
createFromSnapshot
  :: Ptr Word8
  -- ^ @image@: A snapshot image produced by b2World_Snapshot
  -> Int
  -- ^ @size@: Size of image in bytes
  -> Int
  -- ^ @workerCount@: Worker count for the new world. 0 uses the serial single-worker fallback.
  -> IO WorldId
createFromSnapshot a0 a1 a2 =
  c_b2CreateWorldFromSnapshot a0 (fromIntegral a1) (fromIntegral a2)
