{-| Reading the per-step event buffers as ordinary Haskell values.

Box2D exposes events as C-owned arrays that live only between one
'Box2D.World.step' and the next. The generated @World.get*Events@ primitives
hand back the raw @{ pointer, count }@ buffer struct; this module copies the
elements out (one @memcpy@ each) into Haskell-owned storable vectors so
they outlive the step. For zero-copy step-scoped views, wrap the raw
buffers with 'Box2D.Internal.unsafeViewVector'. Call it after stepping.

This is the hand-written counterpart to the generated bindings: the array
marshalling (roadmap phase 5) is not something the generator emits.
-}
module Box2D.Events
  ( bodyMoveEvents
  , sensorBeginTouchEvents
  , sensorEndTouchEvents
  , contactBeginTouchEvents
  , contactEndTouchEvents
  , contactHitEvents
  , jointEvents
  ) where

import Data.Vector.Storable (Vector)

import Box2D.Id (WorldId)
import Box2D.Internal (copyVector)
import Box2D.World
  ( BodyEvents (..)
  , BodyMoveEvent
  , ContactBeginTouchEvent
  , ContactEndTouchEvent
  , ContactEvents (..)
  , ContactHitEvent
  , JointEvent
  , JointEvents (..)
  , SensorBeginTouchEvent
  , SensorEndTouchEvent
  , SensorEvents (..)
  )
import Box2D.World qualified as World

{- | The bodies that moved during the last 'Box2D.World.step', copied out of the
world-owned buffer. Valid to call any time, but only reflects the most recent
step.
-}
bodyMoveEvents :: WorldId -> IO (Vector BodyMoveEvent)
bodyMoveEvents w = do
  BodyEvents ptr n <- World.getBodyEvents w
  copyVector (fromIntegral n) ptr

-- | The shapes that started overlapping a sensor during the last step.
sensorBeginTouchEvents :: WorldId -> IO (Vector SensorBeginTouchEvent)
sensorBeginTouchEvents w = do
  SensorEvents beginPtr _ beginN _ <- World.getSensorEvents w
  copyVector (fromIntegral beginN) beginPtr

-- | The shapes that stopped overlapping a sensor during the last step.
sensorEndTouchEvents :: WorldId -> IO (Vector SensorEndTouchEvent)
sensorEndTouchEvents w = do
  SensorEvents _ endPtr _ endN <- World.getSensorEvents w
  copyVector (fromIntegral endN) endPtr

{- | The shape pairs that began touching during the last step. Requires
@shapeDefEnableContactEvents@ on both shapes.
-}
contactBeginTouchEvents :: WorldId -> IO (Vector ContactBeginTouchEvent)
contactBeginTouchEvents w = do
  ContactEvents beginPtr _ _ beginN _ _ <- World.getContactEvents w
  copyVector (fromIntegral beginN) beginPtr

-- | The shape pairs that stopped touching during the last step.
contactEndTouchEvents :: WorldId -> IO (Vector ContactEndTouchEvent)
contactEndTouchEvents w = do
  ContactEvents _ endPtr _ _ endN _ <- World.getContactEvents w
  copyVector (fromIntegral endN) endPtr

{- | The impacts faster than @WorldDef.hitEventThreshold@ during the last step.
Requires @shapeDefEnableHitEvents@.
-}
contactHitEvents :: WorldId -> IO (Vector ContactHitEvent)
contactHitEvents w = do
  ContactEvents _ _ hitPtr _ _ hitN <- World.getContactEvents w
  copyVector (fromIntegral hitN) hitPtr

{- | The joints that exceeded their force/torque event threshold during the
last step. Requires @Box2D.Joint.setForceThreshold@ \/ torque threshold and
per-joint event enabling.
-}
jointEvents :: WorldId -> IO (Vector JointEvent)
jointEvents w = do
  JointEvents ptr n <- World.getJointEvents w
  copyVector (fromIntegral n) ptr
