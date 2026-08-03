{-| Friendly surface over the engine's mover plane solver.

The raw bindings ("Box2D.Collision".@solvePlanes@ / @clipVector@) work on a
mutable @b2CollisionPlane@ array: @b2SolvePlanes@ accumulates each plane's
@push@ in place and @b2ClipVector@ reads those accumulators back. The
wrappers here own that mutation, so a kinematic character controller can
stay in vector land:

@
(delta, planes', _iters) <- solvePlanes targetDelta planes
velocity' <- clipVector velocity planes'
@

Planes are normally assembled from the 'Box2D.Collision.PlaneResult's gathered
by 'Box2D.World.collideMover'.
-}
module Box2D.Mover
  ( solvePlanes
  , clipVector
  ) where

import Data.Vector.Storable qualified as VS
import Data.Vector.Storable.Mutable qualified as VSM

import Box2D.Collision (CollisionPlane, PlaneSolverResult (..))
import Box2D.Collision qualified as Collision
import Box2D.MathTypes (Vec2)

{- | Solve the position of a mover that satisfies the given collision
planes. Returns the resolved translation, the planes with their final
@push@ accumulators (feed these to 'clipVector'), and the solver
iteration count (for diagnostics).
-}
solvePlanes :: Vec2 -> VS.Vector CollisionPlane -> IO (Vec2, VS.Vector CollisionPlane, Int)
solvePlanes targetDelta planes = do
  mplanes <- VS.thaw planes
  result <- VSM.unsafeWith mplanes $ \p ->
    Collision.solvePlanes targetDelta p (VSM.length mplanes)
  planes' <- VS.unsafeFreeze mplanes
  pure
    ( result.translation
    , planes'
    , fromIntegral result.iterationCount
    )

{- | Clip a velocity against the given collision planes; planes with zero
@push@ or with @clipVelocity@ unset are skipped. Call it on the planes
returned by 'solvePlanes'.
-}
clipVector :: Vec2 -> VS.Vector CollisionPlane -> IO Vec2
clipVector vector planes =
  VS.unsafeWith planes $ \p ->
    Collision.clipVector vector p (VS.length planes)
