-- | Hand-written type helpers that complement the generated modules.
module Box2D.Extra
  ( withShapeProxy
  ) where

import Data.Vector.Storable qualified as VS
import Foreign

import Box2D.Geometry (ShapeProxy (..))
import Box2D.MathTypes (Vec2)

-- | Marshal a point cloud + radius as a 'ShapeProxy' for the duration of an action.
withShapeProxy :: VS.Vector Vec2 -> Float -> (Ptr ShapeProxy -> IO a) -> IO a
withShapeProxy points radius = with (ShapeProxy points radius)
