{-# LANGUAGE ForeignFunctionInterface #-}

{-| Producing 'FunPtr' callbacks from Haskell closures, and a ready-made
multithreaded task system.

The generated bindings take callbacks as raw @'FunPtr' Tag@ (see
"Box2D.Tags"); this module is the hand-written counterpart that turns an
ordinary Haskell function into such a 'FunPtr' via @foreign import "wrapper"@,
and frees it again. Every @mk*@ returns a 'FunPtr' the caller must
'freeHaskellFunPtr' (use the @with*@ brackets to get that for free).

== Threads

Box2D invokes these callbacks from its solver, which runs on background
worker threads when @WorldDef.workerCount@ > 1 — either its own scheduler, or
the 'TaskSystem' installed here. A Haskell closure wrapped as a 'FunPtr' is
therefore entered concurrently from several non-Haskell OS threads, so the
program must be built with the threaded runtime (@-threaded@) and the
closure must be thread-safe. Because the solver's task work re-enters Haskell
through these callbacks, the task dispatch is a @safe@ call.
-}
module Box2D.Callbacks
  ( -- * Leaf callbacks
    CustomFilter
  , mkCustomFilterFcn
  , withCustomFilterFcn
  , Friction
  , mkFrictionCallback
  , withFrictionCallback
  , Restitution
  , mkRestitutionCallback
  , withRestitutionCallback

    -- * Query and cast visitors
  , OverlapResult
  , withOverlapResultFcn
  , CastResult
  , withCastResultFcn
  , PreSolve
  , withPreSolveFcn
  , PlaneResultVisitor
  , withPlaneResultFcn

    -- * Dynamic-tree visitors
  , TreeQuery
  , withTreeQueryFcn
  , TreeRayCast
  , withTreeRayCastFcn
  , TreeBoxCast
  , withTreeBoxCastFcn

    -- * A multithreaded task system
  , TaskSystem (..)
  , withThreadPoolTaskSystem
  ) where

import Control.Concurrent (forkIO)
import Control.Concurrent.MVar (MVar, newEmptyMVar, putMVar, takeMVar)
import Control.Exception (bracket, finally)
import Foreign
import Foreign.C.Types (CBool (..), CInt (..))

import Box2D.Collision (PlaneResult)
import Box2D.DynamicTree (BoxCastInput)
import Box2D.Geometry (RayCastInput)
import Box2D.Id (ShapeId (..))
import Box2D.MathTypes (Pos, Vec2)
import Box2D.Tags
  ( CastResultFcn
  , CustomFilterFcn
  , EnqueueTaskCallback
  , FinishTaskCallback
  , FrictionCallback
  , OverlapResultFcn
  , PlaneResultFcn
  , PreSolveFcn
  , RestitutionCallback
  , TreeBoxCastCallbackFcn
  , TreeQueryCallbackFcn
  , TreeRayCastCallbackFcn
  )

-- Leaf callbacks ----------------------------------------------------------

{- | Decide whether two shapes should collide (see
'Box2D.World.setCustomFilterCallback'). The 'Ptr' is the user context.
-}
type CustomFilter = ShapeId -> ShapeId -> Ptr () -> IO Bool

type CustomFilterC = ShapeId -> ShapeId -> Ptr () -> IO CBool

foreign import ccall "wrapper"
  wrapCustomFilter :: CustomFilterC -> IO (FunPtr CustomFilterC)

{- | Wrap a Haskell predicate as a custom-filter callback. Free it with
'freeHaskellFunPtr' when the world no longer references it.
-}
mkCustomFilterFcn :: CustomFilter -> IO (FunPtr CustomFilterFcn)
mkCustomFilterFcn f =
  castFunPtr <$> wrapCustomFilter (\a b ctx -> fromBool <$> f a b ctx)

-- | Run an action with a custom-filter callback that is freed on exit.
withCustomFilterFcn :: CustomFilter -> (FunPtr CustomFilterFcn -> IO a) -> IO a
withCustomFilterFcn f = bracket (mkCustomFilterFcn f) freeHaskellFunPtr

{- | Combine the friction of two materials (see
'Box2D.World.setFrictionCallback'): @frictionA userMatA frictionB userMatB@.
-}
type Friction = Float -> Word64 -> Float -> Word64 -> IO Float

foreign import ccall "wrapper"
  wrapFriction :: Friction -> IO (FunPtr Friction)

-- | Wrap a Haskell function as a friction-mixing callback.
mkFrictionCallback :: Friction -> IO (FunPtr FrictionCallback)
mkFrictionCallback f = castFunPtr <$> wrapFriction f

-- | Run an action with a friction callback that is freed on exit.
withFrictionCallback :: Friction -> (FunPtr FrictionCallback -> IO a) -> IO a
withFrictionCallback f = bracket (mkFrictionCallback f) freeHaskellFunPtr

{- | Combine the restitution of two materials (see
'Box2D.World.setRestitutionCallback'); same shape as 'Friction'.
-}
type Restitution = Float -> Word64 -> Float -> Word64 -> IO Float

foreign import ccall "wrapper"
  wrapRestitution :: Restitution -> IO (FunPtr Restitution)

-- | Wrap a Haskell function as a restitution-mixing callback.
mkRestitutionCallback :: Restitution -> IO (FunPtr RestitutionCallback)
mkRestitutionCallback f = castFunPtr <$> wrapRestitution f

-- | Run an action with a restitution callback that is freed on exit.
withRestitutionCallback :: Restitution -> (FunPtr RestitutionCallback -> IO a) -> IO a
withRestitutionCallback f = bracket (mkRestitutionCallback f) freeHaskellFunPtr

-- Query and cast visitors --------------------------------------------------
--
-- The cast and pre-solve callbacks receive b2Pos/b2Vec2 arguments *by value*,
-- which a GHC "wrapper" cannot accept. Each of those routes through a fixed C
-- trampoline (see box2d_shim.h) that takes the structs by value and forwards
-- pointers to the Haskell closure, carried in an hs_b2Closure context.

{- | Overlap query visitor: called for each shape found; return 'True' to
continue the query.
-}
type OverlapResult = ShapeId -> IO Bool

type OverlapResultC = ShapeId -> Ptr () -> IO CBool

foreign import ccall "wrapper"
  wrapOverlapResult :: OverlapResultC -> IO (FunPtr OverlapResultC)

{- | Run an action with an overlap visitor and the context to pass alongside
it (e.g. to 'Box2D.World.overlapAABB'); both are released on exit.
-}
withOverlapResultFcn :: OverlapResult -> (FunPtr OverlapResultFcn -> Ptr () -> IO a) -> IO a
withOverlapResultFcn f act =
  bracket (wrapOverlapResult (\s _ -> fromBool <$> f s)) freeHaskellFunPtr $ \p ->
    act (castFunPtr p) nullPtr

{- | Cast visitor: called for each shape a world ray\/shape cast finds, with
the hit point, normal and fraction. The returned fraction controls the
query: 0 terminates, the given fraction clips the ray, 1 continues.
-}
type CastResult = ShapeId -> Pos -> Vec2 -> Float -> IO Float

type CastResultC = ShapeId -> Ptr Pos -> Ptr Vec2 -> Float -> Ptr () -> IO Float

foreign import ccall "wrapper"
  wrapCastResult :: CastResultC -> IO (FunPtr CastResultC)

foreign import ccall unsafe "&hs_b2CastResultTrampoline"
  p_castResultTrampoline :: FunPtr CastResultFcn

{- | Run an action with a cast visitor and the context to pass alongside it
(e.g. to 'Box2D.World.castRay'); both are released on exit.
-}
withCastResultFcn :: CastResult -> (FunPtr CastResultFcn -> Ptr () -> IO a) -> IO a
withCastResultFcn f act =
  bracket (wrapCastResult go) freeHaskellFunPtr $ \hsFn ->
    withClosure (castFunPtr hsFn) $ act p_castResultTrampoline
  where
    go sid pPoint pNormal frac _ctx = do
      point <- peek pPoint
      normal <- peek pNormal
      f sid point normal frac

{- | Contact gate, called after narrow phase but before the solver: return
'False' to disable the contact. Fired from solver worker threads when the
world is multithreaded, so it must be thread-safe. Requires
@shapeDefEnablePreSolveEvents@ on the shapes.
-}
type PreSolve = ShapeId -> ShapeId -> Pos -> Vec2 -> IO Bool

type PreSolveC = ShapeId -> ShapeId -> Ptr Pos -> Ptr Vec2 -> Ptr () -> IO CBool

foreign import ccall "wrapper"
  wrapPreSolve :: PreSolveC -> IO (FunPtr PreSolveC)

foreign import ccall unsafe "&hs_b2PreSolveTrampoline"
  p_preSolveTrampoline :: FunPtr PreSolveFcn

{- | Run an action with a pre-solve gate and the context to pass alongside it
(to 'Box2D.World.setPreSolveCallback'). Unhook the callback from the world
before the action returns: both are released on exit.
-}
withPreSolveFcn :: PreSolve -> (FunPtr PreSolveFcn -> Ptr () -> IO a) -> IO a
withPreSolveFcn f act =
  bracket (wrapPreSolve go) freeHaskellFunPtr $ \hsFn ->
    withClosure (castFunPtr hsFn) $ act p_preSolveTrampoline
  where
    go a b pPoint pNormal _ctx = do
      point <- peek pPoint
      normal <- peek pNormal
      fromBool <$> f a b point normal

{- | Mover collision visitor: one collision plane per convex shape the mover
capsule touches (see 'Box2D.World.collideMover'); return 'True' to keep
gathering planes.
-}
type PlaneResultVisitor = ShapeId -> PlaneResult -> IO Bool

type PlaneResultC = ShapeId -> Ptr PlaneResult -> Ptr () -> IO CBool

foreign import ccall "wrapper"
  wrapPlaneResult :: PlaneResultC -> IO (FunPtr PlaneResultC)

{- | Run an action with a mover-plane visitor and the context to pass
alongside it (to 'Box2D.World.collideMover'); both are released on exit.
-}
withPlaneResultFcn :: PlaneResultVisitor -> (FunPtr PlaneResultFcn -> Ptr () -> IO a) -> IO a
withPlaneResultFcn f act =
  bracket (wrapPlaneResult go) freeHaskellFunPtr $ \p ->
    act (castFunPtr p) nullPtr
  where
    go sid pPlane _ctx = do
      plane <- peek pPlane
      fromBool <$> f sid plane

-- Dynamic-tree visitors -----------------------------------------------------

{- | Tree query visitor: @proxyId userData@; return 'True' to continue the
query.
-}
type TreeQuery = CInt -> Word64 -> IO Bool

type TreeQueryC = CInt -> Word64 -> Ptr () -> IO CBool

foreign import ccall "wrapper"
  wrapTreeQuery :: TreeQueryC -> IO (FunPtr TreeQueryC)

{- | Run an action with a tree-query visitor and the context to pass alongside
it (to 'Box2D.DynamicTree.query'); both are released on exit.
-}
withTreeQueryFcn :: TreeQuery -> (FunPtr TreeQueryCallbackFcn -> Ptr () -> IO a) -> IO a
withTreeQueryFcn f act =
  bracket (wrapTreeQuery (\i u _ -> fromBool <$> f i u)) freeHaskellFunPtr $ \p ->
    act (castFunPtr p) nullPtr

{- | Tree ray-cast visitor: the (possibly clipped) input, @proxyId@ and
@userData@. The returned fraction controls the query: 0 terminates, the
given fraction clips the ray, 1 continues.
-}
type TreeRayCast = RayCastInput -> CInt -> Word64 -> IO Float

type TreeRayCastC = Ptr RayCastInput -> CInt -> Word64 -> Ptr () -> IO Float

foreign import ccall "wrapper"
  wrapTreeRayCast :: TreeRayCastC -> IO (FunPtr TreeRayCastC)

{- | Run an action with a tree ray-cast visitor and the context to pass
alongside it (to 'Box2D.DynamicTree.rayCast'); both are released on exit.
-}
withTreeRayCastFcn :: TreeRayCast -> (FunPtr TreeRayCastCallbackFcn -> Ptr () -> IO a) -> IO a
withTreeRayCastFcn f act =
  bracket (wrapTreeRayCast go) freeHaskellFunPtr $ \p ->
    act (castFunPtr p) nullPtr
  where
    go pInput i u _ctx = do
      input <- peek pInput
      f input i u

{- | Tree box-cast visitor. The input stays a raw 'Ptr' ('BoxCastInput' is
still an opaque tag with no 'Storable').
-}
type TreeBoxCast = Ptr BoxCastInput -> CInt -> Word64 -> IO Float

type TreeBoxCastC = Ptr BoxCastInput -> CInt -> Word64 -> Ptr () -> IO Float

foreign import ccall "wrapper"
  wrapTreeBoxCast :: TreeBoxCastC -> IO (FunPtr TreeBoxCastC)

{- | Run an action with a tree box-cast visitor and the context to pass
alongside it (to 'Box2D.DynamicTree.boxCast'); both are released on exit.
-}
withTreeBoxCastFcn :: TreeBoxCast -> (FunPtr TreeBoxCastCallbackFcn -> Ptr () -> IO a) -> IO a
withTreeBoxCastFcn f act =
  bracket (wrapTreeBoxCast (\p i u _ -> f p i u)) freeHaskellFunPtr $ \p ->
    act (castFunPtr p) nullPtr

{- | Allocate the two-pointer @hs_b2Closure@ a trampoline dereferences: the
Haskell-wrapped function and the user context it should receive.
-}
withClosure :: FunPtr a -> (Ptr () -> IO b) -> IO b
withClosure fn act =
  allocaBytes (2 * sz) $ \p -> do
    pokeByteOff p 0 (castFunPtrToPtr fn)
    pokeByteOff p sz nullPtr
    act (castPtr p)
  where
    sz = sizeOf nullPtr

-- A multithreaded task system --------------------------------------------

{- | The two callbacks (ready to poke into @WorldDef.enqueueTask@ /
@WorldDef.finishTask@) plus the worker count to set on @WorldDef.workerCount@.
-}
data TaskSystem = TaskSystem
  { enqueue :: FunPtr EnqueueTaskCallback
  , finish :: FunPtr FinishTaskCallback
  , workerCount :: Int
  }

-- The engine's per-task work function: @void b2TaskCallback(void* taskContext)@.
type TaskC = Ptr () -> IO ()

-- Calling it re-enters Haskell (the solver work invokes our other callbacks),
-- so it must be a `safe` call.
foreign import ccall safe "dynamic"
  callTask :: FunPtr TaskC -> TaskC

type EnqueueC = FunPtr TaskC -> Ptr () -> Ptr () -> IO (Ptr ())
type FinishC = Ptr () -> Ptr () -> IO ()

foreign import ccall "wrapper" wrapEnqueue :: EnqueueC -> IO (FunPtr EnqueueC)
foreign import ccall "wrapper" wrapFinish :: FinishC -> IO (FunPtr FinishC)

{- | Install a Haskell thread-pool task system for the duration of an action,
so the Box2D solver runs across the threaded runtime's capabilities. Set
@WorldDef.workerCount@, @WorldDef.enqueueTask@ and @WorldDef.finishTask@ from the
'TaskSystem' before creating the world.

Each enqueued task is run on a fresh 'forkIO' thread; @finishTask@ joins it.
The task's handle travels through the engine as a 'StablePtr' to its join
'MVar'. Requires @-threaded@.
-}
withThreadPoolTaskSystem :: Int -> (TaskSystem -> IO a) -> IO a
withThreadPoolTaskSystem workers act =
  bracket (wrapEnqueue enqueue) freeHaskellFunPtr $ \enq ->
    bracket (wrapFinish finish) freeHaskellFunPtr $ \fin ->
      act
        TaskSystem
          { enqueue = castFunPtr enq
          , finish = castFunPtr fin
          , workerCount = workers
          }
  where
    enqueue :: EnqueueC
    enqueue task taskCtx _userCtx = do
      done <- newEmptyMVar
      _ <- forkIO (callTask task taskCtx `finally` putMVar done ())
      castStablePtrToPtr <$> newStablePtr done

    finish :: FinishC
    finish userTask _userCtx = do
      let sp = castPtrToStablePtr userTask :: StablePtr (MVar ())
      done <- deRefStablePtr sp
      takeMVar done
      freeStablePtr sp
