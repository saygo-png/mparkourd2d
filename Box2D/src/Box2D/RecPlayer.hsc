{-# LANGUAGE ForeignFunctionInterface #-}
{-# LANGUAGE PatternSynonyms #-}
{-# LANGUAGE GeneralizedNewtypeDeriving #-}

-- Produced by boxnd-gen; edit the generator, not this file.

module Box2D.RecPlayer
  ( RecQueryHit (..)
  , RecQueryInfo (..)
  , RecQueryType (..)
  , pattern RecQueryOverlapAABB
  , pattern RecQueryOverlapShape
  , pattern RecQueryCastRay
  , pattern RecQueryCastShape
  , pattern RecQueryCollideMover
  , pattern RecQueryCastRayClosest
  , pattern RecQueryCastMover
  , pattern RecQueryShapeTestPoint
  , pattern RecQueryShapeRayCast
  , RecPlayerInfo (..)
  , create
  , stepFrame
  , getWorldId
  , restart
  , seekFrame
  , getFrame
  , getInfo
  , isAtEnd
  , hasDiverged
  , getDivergeFrame
  , setKeyframePolicy
  , getKeyframeBudget
  , getKeyframeMinInterval
  , getKeyframeInterval
  , getKeyframeBytes
  , destroy
  , drawFrameQueries
  , getFrameQueryCount
  , getFrameQuery
  , getFrameQueryHit
  , getBodyCount
  , getBodyId
  )
  where

import Foreign
import Foreign.C.Types (CBool (..), CInt (..), CSize (..))
import Box2D.Id (BodyId (..), ShapeId, WorldId (..))
import Box2D.MathTypes (AABB, Pos, Vec2)
import Box2D.Shape (QueryFilter)
import Box2D.Tags (DebugDraw, RecPlayer)

#include "box2d/box2d.h"


-- | One result of a recorded spatial query.
data RecQueryHit = RecQueryHit
  { shape :: ShapeId
  , point :: Pos
  , normal :: Vec2
  , fraction :: Float
  }
  deriving (Eq, Show)

instance Storable RecQueryHit where
  sizeOf _ = #{size b2RecQueryHit}
  alignment _ = #{alignment b2RecQueryHit}
  peek p =
    RecQueryHit
      <$> #{peek b2RecQueryHit, shape} p
      <*> #{peek b2RecQueryHit, point} p
      <*> #{peek b2RecQueryHit, normal} p
      <*> #{peek b2RecQueryHit, fraction} p
  poke p (RecQueryHit f1 f2 f3 f4) = do
    #{poke b2RecQueryHit, shape} p f1
    #{poke b2RecQueryHit, point} p f2
    #{poke b2RecQueryHit, normal} p f3
    #{poke b2RecQueryHit, fraction} p f4

-- | A spatial query recorded during a replayed frame, exposed for inspection.
data RecQueryInfo = RecQueryInfo
  { type_ :: CInt
  , filter :: QueryFilter
  , aabb :: AABB
  , origin :: Pos
  , translation :: Vec2
  , shape :: ShapeId
  , hitCount :: CInt
  }
  deriving (Eq, Show)

instance Storable RecQueryInfo where
  sizeOf _ = #{size b2RecQueryInfo}
  alignment _ = #{alignment b2RecQueryInfo}
  peek p =
    RecQueryInfo
      <$> #{peek b2RecQueryInfo, type} p
      <*> #{peek b2RecQueryInfo, filter} p
      <*> #{peek b2RecQueryInfo, aabb} p
      <*> #{peek b2RecQueryInfo, origin} p
      <*> #{peek b2RecQueryInfo, translation} p
      <*> #{peek b2RecQueryInfo, shape} p
      <*> #{peek b2RecQueryInfo, hitCount} p
  poke p (RecQueryInfo f1 f2 f3 f4 f5 f6 f7) = do
    #{poke b2RecQueryInfo, type} p f1
    #{poke b2RecQueryInfo, filter} p f2
    #{poke b2RecQueryInfo, aabb} p f3
    #{poke b2RecQueryInfo, origin} p f4
    #{poke b2RecQueryInfo, translation} p f5
    #{poke b2RecQueryInfo, shape} p f6
    #{poke b2RecQueryInfo, hitCount} p f7

-- | The kind of a recorded spatial query, matching the public query and cast functions.
newtype RecQueryType = RecQueryType CInt
  deriving (Eq, Show, Storable)

pattern RecQueryOverlapAABB :: RecQueryType
pattern RecQueryOverlapShape :: RecQueryType
pattern RecQueryCastRay :: RecQueryType
pattern RecQueryCastShape :: RecQueryType
pattern RecQueryCollideMover :: RecQueryType
pattern RecQueryCastRayClosest :: RecQueryType
pattern RecQueryCastMover :: RecQueryType
pattern RecQueryShapeTestPoint :: RecQueryType
pattern RecQueryShapeRayCast :: RecQueryType
pattern RecQueryOverlapAABB = RecQueryType #{const b2_recQueryOverlapAABB}
pattern RecQueryOverlapShape = RecQueryType #{const b2_recQueryOverlapShape}
pattern RecQueryCastRay = RecQueryType #{const b2_recQueryCastRay}
pattern RecQueryCastShape = RecQueryType #{const b2_recQueryCastShape}
pattern RecQueryCollideMover = RecQueryType #{const b2_recQueryCollideMover}
pattern RecQueryCastRayClosest = RecQueryType #{const b2_recQueryCastRayClosest}
pattern RecQueryCastMover = RecQueryType #{const b2_recQueryCastMover}
pattern RecQueryShapeTestPoint = RecQueryType #{const b2_recQueryShapeTestPoint}
pattern RecQueryShapeRayCast = RecQueryType #{const b2_recQueryShapeRayCast}

{-# COMPLETE RecQueryOverlapAABB, RecQueryOverlapShape, RecQueryCastRay, RecQueryCastShape, RecQueryCollideMover, RecQueryCastRayClosest, RecQueryCastMover, RecQueryShapeTestPoint, RecQueryShapeRayCast #-}

-- | Static metadata describing a recording, resolved once when the player opens the file.
data RecPlayerInfo = RecPlayerInfo
  { frameCount :: CInt
  , workerCount :: CInt
  , timeStep :: Float
  , subStepCount :: CInt
  , lengthScale :: Float
  , bounds :: AABB
  }
  deriving (Eq, Show)

instance Storable RecPlayerInfo where
  sizeOf _ = #{size b2RecPlayerInfo}
  alignment _ = #{alignment b2RecPlayerInfo}
  peek p =
    RecPlayerInfo
      <$> #{peek b2RecPlayerInfo, frameCount} p
      <*> #{peek b2RecPlayerInfo, workerCount} p
      <*> #{peek b2RecPlayerInfo, timeStep} p
      <*> #{peek b2RecPlayerInfo, subStepCount} p
      <*> #{peek b2RecPlayerInfo, lengthScale} p
      <*> #{peek b2RecPlayerInfo, bounds} p
  poke p (RecPlayerInfo f1 f2 f3 f4 f5 f6) = do
    #{poke b2RecPlayerInfo, frameCount} p f1
    #{poke b2RecPlayerInfo, workerCount} p f2
    #{poke b2RecPlayerInfo, timeStep} p f3
    #{poke b2RecPlayerInfo, subStepCount} p f4
    #{poke b2RecPlayerInfo, lengthScale} p f5
    #{poke b2RecPlayerInfo, bounds} p f6


foreign import ccall unsafe "b2RecPlayer_Create"
  c_b2RecPlayer_Create :: Ptr () -> CInt -> CInt -> IO (Ptr RecPlayer)

foreign import ccall safe "b2RecPlayer_StepFrame"
  c_b2RecPlayer_StepFrame :: Ptr RecPlayer -> IO CBool

foreign import ccall unsafe "b2RecPlayer_GetWorldId"
  c_b2RecPlayer_GetWorldId :: Ptr RecPlayer -> IO WorldId

foreign import ccall unsafe "b2RecPlayer_Restart"
  c_b2RecPlayer_Restart :: Ptr RecPlayer -> IO ()

foreign import ccall unsafe "b2RecPlayer_SeekFrame"
  c_b2RecPlayer_SeekFrame :: Ptr RecPlayer -> CInt -> IO ()

foreign import ccall unsafe "b2RecPlayer_GetFrame"
  c_b2RecPlayer_GetFrame :: Ptr RecPlayer -> IO CInt

foreign import ccall unsafe "hsg_b2RecPlayer_GetInfo"
  c_b2RecPlayer_GetInfo :: Ptr RecPlayer -> Ptr RecPlayerInfo -> IO ()

foreign import ccall unsafe "b2RecPlayer_IsAtEnd"
  c_b2RecPlayer_IsAtEnd :: Ptr RecPlayer -> IO CBool

foreign import ccall unsafe "b2RecPlayer_HasDiverged"
  c_b2RecPlayer_HasDiverged :: Ptr RecPlayer -> IO CBool

foreign import ccall unsafe "b2RecPlayer_GetDivergeFrame"
  c_b2RecPlayer_GetDivergeFrame :: Ptr RecPlayer -> IO CInt

foreign import ccall unsafe "b2RecPlayer_SetKeyframePolicy"
  c_b2RecPlayer_SetKeyframePolicy :: Ptr RecPlayer -> CSize -> CInt -> IO ()

foreign import ccall unsafe "b2RecPlayer_GetKeyframeBudget"
  c_b2RecPlayer_GetKeyframeBudget :: Ptr RecPlayer -> IO CSize

foreign import ccall unsafe "b2RecPlayer_GetKeyframeMinInterval"
  c_b2RecPlayer_GetKeyframeMinInterval :: Ptr RecPlayer -> IO CInt

foreign import ccall unsafe "b2RecPlayer_GetKeyframeInterval"
  c_b2RecPlayer_GetKeyframeInterval :: Ptr RecPlayer -> IO CInt

foreign import ccall unsafe "b2RecPlayer_GetKeyframeBytes"
  c_b2RecPlayer_GetKeyframeBytes :: Ptr RecPlayer -> IO CSize

foreign import ccall unsafe "b2RecPlayer_Destroy"
  c_b2RecPlayer_Destroy :: Ptr RecPlayer -> IO ()

foreign import ccall unsafe "b2RecPlayer_DrawFrameQueries"
  c_b2RecPlayer_DrawFrameQueries :: Ptr RecPlayer -> Ptr DebugDraw -> CInt -> IO ()

foreign import ccall unsafe "b2RecPlayer_GetFrameQueryCount"
  c_b2RecPlayer_GetFrameQueryCount :: Ptr RecPlayer -> IO CInt

foreign import ccall unsafe "hsg_b2RecPlayer_GetFrameQuery"
  c_b2RecPlayer_GetFrameQuery :: Ptr RecPlayer -> CInt -> Ptr RecQueryInfo -> IO ()

foreign import ccall unsafe "hsg_b2RecPlayer_GetFrameQueryHit"
  c_b2RecPlayer_GetFrameQueryHit :: Ptr RecPlayer -> CInt -> CInt -> Ptr RecQueryHit -> IO ()

foreign import ccall unsafe "b2RecPlayer_GetBodyCount"
  c_b2RecPlayer_GetBodyCount :: Ptr RecPlayer -> IO CInt

foreign import ccall unsafe "b2RecPlayer_GetBodyId"
  c_b2RecPlayer_GetBodyId :: Ptr RecPlayer -> CInt -> IO BodyId

{- | Open a recording for incremental playback and replay up to the first step. The player copies
the bytes, so you may free or destroy the source buffer immediately after this call.

Returns: A player handle, or NULL if the recording is malformed

Binds @b2RecPlayer_Create@.
-}
create
  :: Ptr ()
  -- ^ @data@: Recorded bytes, e.g. from b2Recording_GetData or a loaded file
  -> Int
  -- ^ @size@: Number of recorded bytes
  -> Int
  -- ^ @workerCount@: Worker count for the replay world. 0 uses the serial single-worker fallback.
  -> IO (Ptr RecPlayer)
create a0 a1 a2 =
  c_b2RecPlayer_Create a0 (fromIntegral a1) (fromIntegral a2)

{- | Advance the replay by one recorded step.

Returns: true if a step executed, false once the end of the recording is reached

Binds @b2RecPlayer_StepFrame@.
-}
stepFrame
  :: Ptr RecPlayer
  -> IO Bool
stepFrame a0 =
  toBool <$> (c_b2RecPlayer_StepFrame a0)

{- | Get the id of the replayed world.

Binds @b2RecPlayer_GetWorldId@.
-}
getWorldId
  :: Ptr RecPlayer
  -> IO WorldId
getWorldId a0 =
  c_b2RecPlayer_GetWorldId a0

{- | Rewind the player to the first step, recreating the replay world from the file.

Binds @b2RecPlayer_Restart@.
-}
restart
  :: Ptr RecPlayer
  -> IO ()
restart a0 =
  c_b2RecPlayer_Restart a0

{- | Seek to a recorded step. Seeking backward rewinds and re-runs from the start, so the
cost grows with the target frame. Clamps to the recording bounds.

Binds @b2RecPlayer_SeekFrame@.
-}
seekFrame
  :: Ptr RecPlayer
  -> Int
  -- ^ @targetFrame@
  -> IO ()
seekFrame a0 a1 =
  c_b2RecPlayer_SeekFrame a0 (fromIntegral a1)

{- | Get the number of steps replayed so far.

Binds @b2RecPlayer_GetFrame@.
-}
getFrame
  :: Ptr RecPlayer
  -> IO Int
getFrame a0 =
  fromIntegral <$> (c_b2RecPlayer_GetFrame a0)

{- | Get static metadata for the recording (frame count, recorded tuning, time).

Binds @b2RecPlayer_GetInfo@.
-}
getInfo
  :: Ptr RecPlayer
  -> Ptr RecPlayerInfo
  -- ^ Result buffer.
  -> IO ()
getInfo a0 out =
  c_b2RecPlayer_GetInfo a0 out

{- | Returns true once the end of the recording has been reached.

Binds @b2RecPlayer_IsAtEnd@.
-}
isAtEnd
  :: Ptr RecPlayer
  -> IO Bool
isAtEnd a0 =
  toBool <$> (c_b2RecPlayer_IsAtEnd a0)

{- | Returns true if a recorded state hash failed to reproduce, meaning replay diverged.

Binds @b2RecPlayer_HasDiverged@.
-}
hasDiverged
  :: Ptr RecPlayer
  -> IO Bool
hasDiverged a0 =
  toBool <$> (c_b2RecPlayer_HasDiverged a0)

{- | Get the first step at which replay diverged, or -1 if it has not diverged.

Binds @b2RecPlayer_GetDivergeFrame@.
-}
getDivergeFrame
  :: Ptr RecPlayer
  -> IO Int
getDivergeFrame a0 =
  fromIntegral <$> (c_b2RecPlayer_GetDivergeFrame a0)

{- | Tune the keyframe ring used to speed up backward seeking. A keyframe is a periodic snapshot the
player restores from instead of replaying from the start, trading memory for seek speed.

Binds @b2RecPlayer_SetKeyframePolicy@.
-}
setKeyframePolicy
  :: Ptr RecPlayer
  -- ^ @player@: the recording player
  -> CSize
  -- ^ @budgetBytes@: Memory cap for the kept snapshots. The spacing widens to stay under it.
  -> Int
  -- ^ @minIntervalFrames@: Finest spacing between keyframes, in frames. A zero budget or a non-positive interval keeps that value. Clears the existing ring, so call b2RecPlayer_Restart afterward to repopulate it under the new policy.
  -> IO ()
setKeyframePolicy a0 a1 a2 =
  c_b2RecPlayer_SetKeyframePolicy a0 a1 (fromIntegral a2)

{- | Get the keyframe memory budget in bytes.

Binds @b2RecPlayer_GetKeyframeBudget@.
-}
getKeyframeBudget
  :: Ptr RecPlayer
  -> IO CSize
getKeyframeBudget a0 =
  c_b2RecPlayer_GetKeyframeBudget a0

{- | Get the finest keyframe spacing in frames.

Binds @b2RecPlayer_GetKeyframeMinInterval@.
-}
getKeyframeMinInterval
  :: Ptr RecPlayer
  -> IO Int
getKeyframeMinInterval a0 =
  fromIntegral <$> (c_b2RecPlayer_GetKeyframeMinInterval a0)

{- | Get the current keyframe spacing in frames. Starts at the min interval and doubles as the ring
evicts to stay under budget, so it reflects the effective backward-seek granularity right now.

Binds @b2RecPlayer_GetKeyframeInterval@.
-}
getKeyframeInterval
  :: Ptr RecPlayer
  -> IO Int
getKeyframeInterval a0 =
  fromIntegral <$> (c_b2RecPlayer_GetKeyframeInterval a0)

{- | Get the memory currently held by keyframe snapshots, in bytes.

Binds @b2RecPlayer_GetKeyframeBytes@.
-}
getKeyframeBytes
  :: Ptr RecPlayer
  -> IO CSize
getKeyframeBytes a0 =
  c_b2RecPlayer_GetKeyframeBytes a0

{- | Close a player and free its replay world and file buffer.

Binds @b2RecPlayer_Destroy@.
-}
destroy
  :: Ptr RecPlayer
  -> IO ()
destroy a0 =
  c_b2RecPlayer_Destroy a0

{- | Draw spatial queries recorded during the most recently replayed frame.
Call after b2World_Draw so queries are layered on top of the world.

Binds @b2RecPlayer_DrawFrameQueries@.
-}
drawFrameQueries
  :: Ptr RecPlayer
  -- ^ @player@: A valid player handle
  -> Ptr DebugDraw
  -- ^ @draw@: Debug draw callbacks. NULL draw function pointers are skipped.
  -> Int
  -- ^ @queryIndex@: Index into the frame\'s queries to draw, or -1 to draw all of them.
  -> IO ()
drawFrameQueries a0 a1 a2 =
  c_b2RecPlayer_DrawFrameQueries a0 a1 (fromIntegral a2)

{- | Get the number of spatial queries recorded for the most recently replayed frame.

Binds @b2RecPlayer_GetFrameQueryCount@.
-}
getFrameQueryCount
  :: Ptr RecPlayer
  -> IO Int
getFrameQueryCount a0 =
  fromIntegral <$> (c_b2RecPlayer_GetFrameQueryCount a0)

{- | Get a recorded query from the most recently replayed frame by index.

Binds @b2RecPlayer_GetFrameQuery@.
-}
getFrameQuery
  :: Ptr RecPlayer
  -> Int
  -- ^ @index@
  -> Ptr RecQueryInfo
  -- ^ Result buffer.
  -> IO ()
getFrameQuery a0 a1 out =
  c_b2RecPlayer_GetFrameQuery a0 (fromIntegral a1) out

{- | Get one result of a recorded query from the most recently replayed frame.

Binds @b2RecPlayer_GetFrameQueryHit@.
-}
getFrameQueryHit
  :: Ptr RecPlayer
  -> Int
  -- ^ @queryIndex@
  -> Int
  -- ^ @hitIndex@
  -> Ptr RecQueryHit
  -- ^ Result buffer.
  -> IO ()
getFrameQueryHit a0 a1 a2 out =
  c_b2RecPlayer_GetFrameQueryHit a0 (fromIntegral a1) (fromIntegral a2) out

{- | Get the number of body slots tracked for the outliner. This is the creation-order span and
includes holes for destroyed bodies, so it only grows as the replay advances.

Binds @b2RecPlayer_GetBodyCount@.
-}
getBodyCount
  :: Ptr RecPlayer
  -> IO Int
getBodyCount a0 =
  fromIntegral <$> (c_b2RecPlayer_GetBodyCount a0)

{- | Get a tracked body by creation ordinal. Returns b2_nullBodyId for a destroyed slot, an ordinal not
yet reached at the current frame, or an out-of-range index. Validate with b2Body_IsValid.

Binds @b2RecPlayer_GetBodyId@.
-}
getBodyId
  :: Ptr RecPlayer
  -> Int
  -- ^ @index@
  -> IO BodyId
getBodyId a0 a1 =
  c_b2RecPlayer_GetBodyId a0 (fromIntegral a1)
