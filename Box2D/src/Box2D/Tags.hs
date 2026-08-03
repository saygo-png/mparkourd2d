{-| Phantom tag types for the by-reference structs and callbacks of the Box2D API.

These carry no fields and no 'Storable'; a raw FFI signature reads
@Ptr Foo@ / @FunPtr Foo@ while the caller supplies the value.
-}
module Box2D.Tags
  ( AssertFcn
  , CastResultFcn
  , CustomFilterFcn
  , DebugDraw
  , EnqueueTaskCallback
  , FinishTaskCallback
  , FreeFcn
  , FrictionCallback
  , LocalManifold
  , LogFcn
  , OverlapResultFcn
  , PlaneResultFcn
  , PreSolveFcn
  , RecPlayer
  , Recording
  , RestitutionCallback
  , TaskCallback
  , TreeBoxCastCallbackFcn
  , TreeNode
  , TreeQueryCallbackFcn
  , TreeRayCastCallbackFcn
  )
where

-- | This function receives proxies found in the AABB query.
data TreeQueryCallbackFcn

-- | This function receives clipped ray cast input for a proxy. The function
data TreeRayCastCallbackFcn

-- | This function receives clipped AABB cast input for a proxy. The function
data TreeBoxCastCallbackFcn

-- | Task interface
data TaskCallback

-- | These functions can be provided to Box2D to invoke a task system.
data EnqueueTaskCallback

-- | Finishes a user task object that wraps a Box2D task.
data FinishTaskCallback

-- | Optional friction mixing callback. This intentionally provides no context objects because this is called
data FrictionCallback

-- | Optional restitution mixing callback. This intentionally provides no context objects because this is called
data RestitutionCallback

-- | Prototype for a contact filter callback.
data CustomFilterFcn

-- | Prototype for a pre-solve callback.
data PreSolveFcn

-- | Prototype callback for overlap queries.
data OverlapResultFcn

-- | Prototype callback for ray and shape casts.
data CastResultFcn

data PlaneResultFcn

-- | Prototype for user free function
data FreeFcn

-- | Prototype for the user assert callback. Return 0 to skip the debugger break.
data AssertFcn

-- | Prototype for user log callback. Used to log warnings.
data LogFcn

data DebugDraw
data LocalManifold
data RecPlayer
data Recording
data TreeNode
