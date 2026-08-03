{-# LANGUAGE ForeignFunctionInterface #-}
{-# LANGUAGE PatternSynonyms #-}
{-# LANGUAGE GeneralizedNewtypeDeriving #-}

-- Produced by boxnd-gen; edit the generator, not this file.

module Box2D.Shape
  ( ChainDef (..)
  , ShapeDef (..)
  , SurfaceMaterial (..)
  , ShapeType (..)
  , pattern CircleShape
  , pattern CapsuleShape
  , pattern SegmentShape
  , pattern PolygonShape
  , pattern ChainSegmentShape
  , QueryFilter (..)
  , Filter (..)
  , defaultFilter
  , defaultQueryFilter
  , defaultSurfaceMaterial
  , defaultShapeDef
  , defaultChainDef
  , createCircle
  , createSegment
  , createChainSegment
  , createCapsule
  , createPolygon
  , destroy
  , isValid
  , getType
  , getBody
  , getWorld
  , isSensor
  , setUserData
  , getUserData
  , setDensity
  , getDensity
  , setFriction
  , getFriction
  , setRestitution
  , getRestitution
  , setUserMaterial
  , getUserMaterial
  , setSurfaceMaterial
  , getSurfaceMaterial
  , getSurfaceMaterialInto
  , getFilter
  , getFilterInto
  , setFilter
  , enableSensorEvents
  , areSensorEventsEnabled
  , enableContactEvents
  , areContactEventsEnabled
  , enablePreSolveEvents
  , arePreSolveEventsEnabled
  , enableHitEvents
  , areHitEventsEnabled
  , testPoint
  , rayCast
  , getCircle
  , getCircleInto
  , getSegment
  , getSegmentInto
  , getChainSegment
  , getCapsule
  , getCapsuleInto
  , getPolygon
  , getPolygonInto
  , setCircle
  , setCapsule
  , setSegment
  , setPolygon
  , setChainSegment
  , getParentChain
  , getContactCapacity
  , getContactData
  , getSensorCapacity
  , getSensorData
  , getAABB
  , getAABBInto
  , computeMassData
  , computeMassDataInto
  , getClosestPoint
  , applyWind
  )
  where

import Foreign
import Foreign.C.Types (CBool (..), CInt (..))
import Data.Coerce (coerce)
import Box2D.Internal (allocaOut)
import Box2D.Geometry (Capsule, ChainSegment, Circle, MassData, Polygon, Segment, WorldCastOutput)
import Box2D.Id (BodyId (..), ChainId (..), ShapeId (..), WorldId (..))
import Box2D.MathTypes (AABB, Pos, Vec2)
import {-# SOURCE #-} Box2D.World (ContactData)

#include "box2d/box2d.h"


-- | Used to create a chain of line segments. This is designed to eliminate ghost collisions with some limitations.
data ChainDef = ChainDef
  { userData :: Ptr ()
  , points :: Ptr Vec2
  , count :: CInt
  , materials :: Ptr SurfaceMaterial
  , materialCount :: CInt
  , filter :: Filter
  , isLoop :: CBool
  , enableSensorEvents :: CBool
  , internalValue :: CInt
  }
  deriving (Eq, Show)

instance Storable ChainDef where
  sizeOf _ = #{size b2ChainDef}
  alignment _ = #{alignment b2ChainDef}
  peek p =
    ChainDef
      <$> #{peek b2ChainDef, userData} p
      <*> #{peek b2ChainDef, points} p
      <*> #{peek b2ChainDef, count} p
      <*> #{peek b2ChainDef, materials} p
      <*> #{peek b2ChainDef, materialCount} p
      <*> #{peek b2ChainDef, filter} p
      <*> #{peek b2ChainDef, isLoop} p
      <*> #{peek b2ChainDef, enableSensorEvents} p
      <*> #{peek b2ChainDef, internalValue} p
  poke p (ChainDef f1 f2 f3 f4 f5 f6 f7 f8 f9) = do
    #{poke b2ChainDef, userData} p f1
    #{poke b2ChainDef, points} p f2
    #{poke b2ChainDef, count} p f3
    #{poke b2ChainDef, materials} p f4
    #{poke b2ChainDef, materialCount} p f5
    #{poke b2ChainDef, filter} p f6
    #{poke b2ChainDef, isLoop} p f7
    #{poke b2ChainDef, enableSensorEvents} p f8
    #{poke b2ChainDef, internalValue} p f9

-- | Used to create a shape.
data ShapeDef = ShapeDef
  { userData :: Ptr ()
  , material :: SurfaceMaterial
  , density :: Float
  , filter :: Filter
  , enableCustomFiltering :: CBool
  , isSensor :: CBool
  , enableSensorEvents :: CBool
  , enableContactEvents :: CBool
  , enableHitEvents :: CBool
  , enablePreSolveEvents :: CBool
  , invokeContactCreation :: CBool
  , updateBodyMass :: CBool
  , internalValue :: CInt
  }
  deriving (Eq, Show)

instance Storable ShapeDef where
  sizeOf _ = #{size b2ShapeDef}
  alignment _ = #{alignment b2ShapeDef}
  peek p =
    ShapeDef
      <$> #{peek b2ShapeDef, userData} p
      <*> #{peek b2ShapeDef, material} p
      <*> #{peek b2ShapeDef, density} p
      <*> #{peek b2ShapeDef, filter} p
      <*> #{peek b2ShapeDef, enableCustomFiltering} p
      <*> #{peek b2ShapeDef, isSensor} p
      <*> #{peek b2ShapeDef, enableSensorEvents} p
      <*> #{peek b2ShapeDef, enableContactEvents} p
      <*> #{peek b2ShapeDef, enableHitEvents} p
      <*> #{peek b2ShapeDef, enablePreSolveEvents} p
      <*> #{peek b2ShapeDef, invokeContactCreation} p
      <*> #{peek b2ShapeDef, updateBodyMass} p
      <*> #{peek b2ShapeDef, internalValue} p
  poke p (ShapeDef f1 f2 f3 f4 f5 f6 f7 f8 f9 f10 f11 f12 f13) = do
    #{poke b2ShapeDef, userData} p f1
    #{poke b2ShapeDef, material} p f2
    #{poke b2ShapeDef, density} p f3
    #{poke b2ShapeDef, filter} p f4
    #{poke b2ShapeDef, enableCustomFiltering} p f5
    #{poke b2ShapeDef, isSensor} p f6
    #{poke b2ShapeDef, enableSensorEvents} p f7
    #{poke b2ShapeDef, enableContactEvents} p f8
    #{poke b2ShapeDef, enableHitEvents} p f9
    #{poke b2ShapeDef, enablePreSolveEvents} p f10
    #{poke b2ShapeDef, invokeContactCreation} p f11
    #{poke b2ShapeDef, updateBodyMass} p f12
    #{poke b2ShapeDef, internalValue} p f13

-- | Surface materials allow chain shapes to have per segment surface properties.
data SurfaceMaterial = SurfaceMaterial
  { friction :: Float
  , restitution :: Float
  , rollingResistance :: Float
  , tangentSpeed :: Float
  , userMaterialId :: Word64
  , customColor :: Word32
  }
  deriving (Eq, Show)

instance Storable SurfaceMaterial where
  sizeOf _ = #{size b2SurfaceMaterial}
  alignment _ = #{alignment b2SurfaceMaterial}
  peek p =
    SurfaceMaterial
      <$> #{peek b2SurfaceMaterial, friction} p
      <*> #{peek b2SurfaceMaterial, restitution} p
      <*> #{peek b2SurfaceMaterial, rollingResistance} p
      <*> #{peek b2SurfaceMaterial, tangentSpeed} p
      <*> #{peek b2SurfaceMaterial, userMaterialId} p
      <*> #{peek b2SurfaceMaterial, customColor} p
  poke p (SurfaceMaterial f1 f2 f3 f4 f5 f6) = do
    #{poke b2SurfaceMaterial, friction} p f1
    #{poke b2SurfaceMaterial, restitution} p f2
    #{poke b2SurfaceMaterial, rollingResistance} p f3
    #{poke b2SurfaceMaterial, tangentSpeed} p f4
    #{poke b2SurfaceMaterial, userMaterialId} p f5
    #{poke b2SurfaceMaterial, customColor} p f6

-- | Shape type
newtype ShapeType = ShapeType CInt
  deriving (Eq, Show, Storable)

pattern CircleShape :: ShapeType
pattern CapsuleShape :: ShapeType
pattern SegmentShape :: ShapeType
pattern PolygonShape :: ShapeType
pattern ChainSegmentShape :: ShapeType
pattern CircleShape = ShapeType #{const b2_circleShape}
pattern CapsuleShape = ShapeType #{const b2_capsuleShape}
pattern SegmentShape = ShapeType #{const b2_segmentShape}
pattern PolygonShape = ShapeType #{const b2_polygonShape}
pattern ChainSegmentShape = ShapeType #{const b2_chainSegmentShape}

{-# COMPLETE CircleShape, CapsuleShape, SegmentShape, PolygonShape, ChainSegmentShape #-}

-- | The query filter is used to filter collisions between queries and shapes. For example,
data QueryFilter = QueryFilter
  { categoryBits :: Word64
  , maskBits :: Word64
  }
  deriving (Eq, Show)

instance Storable QueryFilter where
  sizeOf _ = #{size b2QueryFilter}
  alignment _ = #{alignment b2QueryFilter}
  peek p =
    QueryFilter
      <$> #{peek b2QueryFilter, categoryBits} p
      <*> #{peek b2QueryFilter, maskBits} p
  poke p (QueryFilter f1 f2) = do
    #{poke b2QueryFilter, categoryBits} p f1
    #{poke b2QueryFilter, maskBits} p f2

-- | This is used to filter collision on shapes. It affects shape-vs-shape collision
data Filter = Filter
  { categoryBits :: Word64
  , maskBits :: Word64
  , groupIndex :: CInt
  }
  deriving (Eq, Show)

instance Storable Filter where
  sizeOf _ = #{size b2Filter}
  alignment _ = #{alignment b2Filter}
  peek p =
    Filter
      <$> #{peek b2Filter, categoryBits} p
      <*> #{peek b2Filter, maskBits} p
      <*> #{peek b2Filter, groupIndex} p
  poke p (Filter f1 f2 f3) = do
    #{poke b2Filter, categoryBits} p f1
    #{poke b2Filter, maskBits} p f2
    #{poke b2Filter, groupIndex} p f3

foreign import ccall unsafe "hs_b2DefaultFilter"
  c_b2DefaultFilter :: Ptr Filter -> IO ()

defaultFilter :: IO Filter
defaultFilter = allocaOut c_b2DefaultFilter

foreign import ccall unsafe "hs_b2DefaultQueryFilter"
  c_b2DefaultQueryFilter :: Ptr QueryFilter -> IO ()

defaultQueryFilter :: IO QueryFilter
defaultQueryFilter = allocaOut c_b2DefaultQueryFilter

foreign import ccall unsafe "hs_b2DefaultSurfaceMaterial"
  c_b2DefaultSurfaceMaterial :: Ptr SurfaceMaterial -> IO ()

defaultSurfaceMaterial :: IO SurfaceMaterial
defaultSurfaceMaterial = allocaOut c_b2DefaultSurfaceMaterial

foreign import ccall unsafe "hs_b2DefaultShapeDef"
  c_b2DefaultShapeDef :: Ptr ShapeDef -> IO ()

defaultShapeDef :: IO ShapeDef
defaultShapeDef = allocaOut c_b2DefaultShapeDef

foreign import ccall unsafe "hs_b2DefaultChainDef"
  c_b2DefaultChainDef :: Ptr ChainDef -> IO ()

defaultChainDef :: IO ChainDef
defaultChainDef = allocaOut c_b2DefaultChainDef


foreign import ccall unsafe "b2CreateCircleShape"
  c_b2CreateCircleShape :: BodyId -> Ptr ShapeDef -> Ptr Circle -> IO ShapeId

foreign import ccall unsafe "b2CreateSegmentShape"
  c_b2CreateSegmentShape :: BodyId -> Ptr ShapeDef -> Ptr Segment -> IO ShapeId

foreign import ccall unsafe "b2CreateChainSegmentShape"
  c_b2CreateChainSegmentShape :: BodyId -> Ptr ShapeDef -> Ptr ChainSegment -> IO ShapeId

foreign import ccall unsafe "b2CreateCapsuleShape"
  c_b2CreateCapsuleShape :: BodyId -> Ptr ShapeDef -> Ptr Capsule -> IO ShapeId

foreign import ccall unsafe "b2CreatePolygonShape"
  c_b2CreatePolygonShape :: BodyId -> Ptr ShapeDef -> Ptr Polygon -> IO ShapeId

foreign import ccall unsafe "b2DestroyShape"
  c_b2DestroyShape :: ShapeId -> CBool -> IO ()

foreign import ccall unsafe "b2Shape_IsValid"
  c_b2Shape_IsValid :: ShapeId -> IO CBool

foreign import ccall unsafe "b2Shape_GetType"
  c_b2Shape_GetType :: ShapeId -> IO CInt

foreign import ccall unsafe "b2Shape_GetBody"
  c_b2Shape_GetBody :: ShapeId -> IO BodyId

foreign import ccall unsafe "b2Shape_GetWorld"
  c_b2Shape_GetWorld :: ShapeId -> IO WorldId

foreign import ccall unsafe "b2Shape_IsSensor"
  c_b2Shape_IsSensor :: ShapeId -> IO CBool

foreign import ccall unsafe "b2Shape_SetUserData"
  c_b2Shape_SetUserData :: ShapeId -> Ptr () -> IO ()

foreign import ccall unsafe "b2Shape_GetUserData"
  c_b2Shape_GetUserData :: ShapeId -> IO (Ptr ())

foreign import ccall unsafe "b2Shape_SetDensity"
  c_b2Shape_SetDensity :: ShapeId -> Float -> CBool -> IO ()

foreign import ccall unsafe "b2Shape_GetDensity"
  c_b2Shape_GetDensity :: ShapeId -> IO Float

foreign import ccall unsafe "b2Shape_SetFriction"
  c_b2Shape_SetFriction :: ShapeId -> Float -> IO ()

foreign import ccall unsafe "b2Shape_GetFriction"
  c_b2Shape_GetFriction :: ShapeId -> IO Float

foreign import ccall unsafe "b2Shape_SetRestitution"
  c_b2Shape_SetRestitution :: ShapeId -> Float -> IO ()

foreign import ccall unsafe "b2Shape_GetRestitution"
  c_b2Shape_GetRestitution :: ShapeId -> IO Float

foreign import ccall unsafe "b2Shape_SetUserMaterial"
  c_b2Shape_SetUserMaterial :: ShapeId -> Word64 -> IO ()

foreign import ccall unsafe "b2Shape_GetUserMaterial"
  c_b2Shape_GetUserMaterial :: ShapeId -> IO Word64

foreign import ccall unsafe "b2Shape_SetSurfaceMaterial"
  c_b2Shape_SetSurfaceMaterial :: ShapeId -> Ptr SurfaceMaterial -> IO ()

foreign import ccall unsafe "hsg_b2Shape_GetSurfaceMaterial"
  c_b2Shape_GetSurfaceMaterial :: ShapeId -> Ptr SurfaceMaterial -> IO ()

foreign import ccall unsafe "hsg_b2Shape_GetFilter"
  c_b2Shape_GetFilter :: ShapeId -> Ptr Filter -> IO ()

foreign import ccall unsafe "hsg_b2Shape_SetFilter"
  c_b2Shape_SetFilter :: ShapeId -> Ptr Filter -> IO ()

foreign import ccall unsafe "b2Shape_EnableSensorEvents"
  c_b2Shape_EnableSensorEvents :: ShapeId -> CBool -> IO ()

foreign import ccall unsafe "b2Shape_AreSensorEventsEnabled"
  c_b2Shape_AreSensorEventsEnabled :: ShapeId -> IO CBool

foreign import ccall unsafe "b2Shape_EnableContactEvents"
  c_b2Shape_EnableContactEvents :: ShapeId -> CBool -> IO ()

foreign import ccall unsafe "b2Shape_AreContactEventsEnabled"
  c_b2Shape_AreContactEventsEnabled :: ShapeId -> IO CBool

foreign import ccall unsafe "b2Shape_EnablePreSolveEvents"
  c_b2Shape_EnablePreSolveEvents :: ShapeId -> CBool -> IO ()

foreign import ccall unsafe "b2Shape_ArePreSolveEventsEnabled"
  c_b2Shape_ArePreSolveEventsEnabled :: ShapeId -> IO CBool

foreign import ccall unsafe "b2Shape_EnableHitEvents"
  c_b2Shape_EnableHitEvents :: ShapeId -> CBool -> IO ()

foreign import ccall unsafe "b2Shape_AreHitEventsEnabled"
  c_b2Shape_AreHitEventsEnabled :: ShapeId -> IO CBool

foreign import ccall unsafe "hsg_b2Shape_TestPoint"
  c_b2Shape_TestPoint :: ShapeId -> Ptr Pos -> IO CBool

foreign import ccall unsafe "hsg_b2Shape_RayCast"
  c_b2Shape_RayCast :: ShapeId -> Ptr Pos -> Ptr Vec2 -> Ptr WorldCastOutput -> IO ()

foreign import ccall unsafe "hsg_b2Shape_GetCircle"
  c_b2Shape_GetCircle :: ShapeId -> Ptr Circle -> IO ()

foreign import ccall unsafe "hsg_b2Shape_GetSegment"
  c_b2Shape_GetSegment :: ShapeId -> Ptr Segment -> IO ()

foreign import ccall unsafe "hsg_b2Shape_GetChainSegment"
  c_b2Shape_GetChainSegment :: ShapeId -> Ptr ChainSegment -> IO ()

foreign import ccall unsafe "hsg_b2Shape_GetCapsule"
  c_b2Shape_GetCapsule :: ShapeId -> Ptr Capsule -> IO ()

foreign import ccall unsafe "hsg_b2Shape_GetPolygon"
  c_b2Shape_GetPolygon :: ShapeId -> Ptr Polygon -> IO ()

foreign import ccall unsafe "b2Shape_SetCircle"
  c_b2Shape_SetCircle :: ShapeId -> Ptr Circle -> IO ()

foreign import ccall unsafe "b2Shape_SetCapsule"
  c_b2Shape_SetCapsule :: ShapeId -> Ptr Capsule -> IO ()

foreign import ccall unsafe "b2Shape_SetSegment"
  c_b2Shape_SetSegment :: ShapeId -> Ptr Segment -> IO ()

foreign import ccall unsafe "b2Shape_SetPolygon"
  c_b2Shape_SetPolygon :: ShapeId -> Ptr Polygon -> IO ()

foreign import ccall unsafe "b2Shape_SetChainSegment"
  c_b2Shape_SetChainSegment :: ShapeId -> Ptr ChainSegment -> IO ()

foreign import ccall unsafe "b2Shape_GetParentChain"
  c_b2Shape_GetParentChain :: ShapeId -> IO ChainId

foreign import ccall unsafe "b2Shape_GetContactCapacity"
  c_b2Shape_GetContactCapacity :: ShapeId -> IO CInt

foreign import ccall unsafe "b2Shape_GetContactData"
  c_b2Shape_GetContactData :: ShapeId -> Ptr ContactData -> CInt -> IO CInt

foreign import ccall unsafe "b2Shape_GetSensorCapacity"
  c_b2Shape_GetSensorCapacity :: ShapeId -> IO CInt

foreign import ccall unsafe "b2Shape_GetSensorData"
  c_b2Shape_GetSensorData :: ShapeId -> Ptr ShapeId -> CInt -> IO CInt

foreign import ccall unsafe "hsg_b2Shape_GetAABB"
  c_b2Shape_GetAABB :: ShapeId -> Ptr AABB -> IO ()

foreign import ccall unsafe "hsg_b2Shape_ComputeMassData"
  c_b2Shape_ComputeMassData :: ShapeId -> Ptr MassData -> IO ()

foreign import ccall unsafe "hsg_b2Shape_GetClosestPoint"
  c_b2Shape_GetClosestPoint :: ShapeId -> Ptr Pos -> Ptr Pos -> IO ()

foreign import ccall unsafe "hsg_b2Shape_ApplyWind"
  c_b2Shape_ApplyWind :: ShapeId -> Ptr Vec2 -> Float -> Float -> CBool -> IO ()

{- | Create a circle shape and attach it to a body. The shape definition and geometry are fully cloned.
Contacts are not created until the next time step.

Returns: the shape id for accessing the shape

Binds @b2CreateCircleShape@.
-}
createCircle
  :: BodyId
  -> ShapeDef
  -> Circle
  -> IO ShapeId
createCircle a0 a1 a2 =
  with a1 $ \p1 ->
  with a2 $ \p2 ->
  c_b2CreateCircleShape a0 p1 p2

{- | Create a line segment shape and attach it to a body. The shape definition and geometry are fully cloned.
Contacts are not created until the next time step.

Returns: the shape id or b2_nullShapeId if the segment is too short.

Binds @b2CreateSegmentShape@.
-}
createSegment
  :: BodyId
  -> ShapeDef
  -> Segment
  -> IO ShapeId
createSegment a0 a1 a2 =
  with a1 $ \p1 ->
  with a2 $ \p2 ->
  c_b2CreateSegmentShape a0 p1 p2

{- | Create an orphaned chain segment shape and attach it to a body. The shape definition and
geometry are fully cloned. The caller is responsible for the segment\'s ghost vertices and
lifetime. The segment is not owned by any b2ChainShape (b2Shape_GetParentChain returns
b2_nullChainId). Contacts are not created until the next time step.

Returns: the shape id, or b2_nullShapeId if the segment is too short.

Binds @b2CreateChainSegmentShape@.
-}
createChainSegment
  :: BodyId
  -> ShapeDef
  -> Ptr ChainSegment
  -> IO ShapeId
createChainSegment a0 a1 a2 =
  with a1 $ \p1 ->
  c_b2CreateChainSegmentShape a0 p1 a2

{- | Create a capsule shape and attach it to a body. The shape definition and geometry are fully cloned.
Contacts are not created until the next time step.

Returns: the shape id for accessing the shape, this will be b2_nullShapeId if the length is too small.

Binds @b2CreateCapsuleShape@.
-}
createCapsule
  :: BodyId
  -> ShapeDef
  -> Capsule
  -> IO ShapeId
createCapsule a0 a1 a2 =
  with a1 $ \p1 ->
  with a2 $ \p2 ->
  c_b2CreateCapsuleShape a0 p1 p2

{- | Create a polygon shape and attach it to a body. The shape definition and geometry are fully cloned.
Contacts are not created until the next time step.

Returns: the shape id for accessing the shape

Binds @b2CreatePolygonShape@.
-}
createPolygon
  :: BodyId
  -> ShapeDef
  -> Polygon
  -> IO ShapeId
createPolygon a0 a1 a2 =
  with a1 $ \p1 ->
  with a2 $ \p2 ->
  c_b2CreatePolygonShape a0 p1 p2

{- | Destroy a shape. You may defer the body mass update which can improve performance if several shapes on a
body are destroyed at once.
See also b2Body_ApplyMassFromShapes.

Binds @b2DestroyShape@.
-}
destroy
  :: ShapeId
  -> Bool
  -- ^ @updateBodyMass@
  -> IO ()
destroy a0 a1 =
  c_b2DestroyShape a0 (fromBool a1)

{- | Shape identifier validation. Provides validation for up to 64K allocations.

Binds @b2Shape_IsValid@.
-}
isValid
  :: ShapeId
  -> IO Bool
isValid a0 =
  toBool <$> (c_b2Shape_IsValid a0)

{- | Get the type of a shape

Binds @b2Shape_GetType@.
-}
getType
  :: ShapeId
  -> IO ShapeType
getType a0 =
  coerce <$> (c_b2Shape_GetType a0)

{- | Get the id of the body that a shape is attached to

Binds @b2Shape_GetBody@.
-}
getBody
  :: ShapeId
  -> IO BodyId
getBody a0 =
  c_b2Shape_GetBody a0

{- | Get the world that owns this shape

Binds @b2Shape_GetWorld@.
-}
getWorld
  :: ShapeId
  -> IO WorldId
getWorld a0 =
  c_b2Shape_GetWorld a0

{- | Returns true if the shape is a sensor. It is not possible to change a shape
from sensor to solid dynamically because this breaks the contract for
sensor events.

Binds @b2Shape_IsSensor@.
-}
isSensor
  :: ShapeId
  -> IO Bool
isSensor a0 =
  toBool <$> (c_b2Shape_IsSensor a0)

{- | Set the user data for a shape

Binds @b2Shape_SetUserData@.
-}
setUserData
  :: ShapeId
  -> Ptr ()
  -- ^ @userData@
  -> IO ()
setUserData a0 a1 =
  c_b2Shape_SetUserData a0 a1

{- | Get the user data for a shape. This is useful when you get a shape id
from an event or query.

Binds @b2Shape_GetUserData@.
-}
getUserData
  :: ShapeId
  -> IO (Ptr ())
getUserData a0 =
  c_b2Shape_GetUserData a0

{- | Set the mass density of a shape, usually in kg\/m^2.
This will optionally update the mass properties on the parent body.
See also b2ShapeDef::density, b2Body_ApplyMassFromShapes.

Binds @b2Shape_SetDensity@.
-}
setDensity
  :: ShapeId
  -> Float
  -- ^ @density@
  -> Bool
  -- ^ @updateBodyMass@
  -> IO ()
setDensity a0 a1 a2 =
  c_b2Shape_SetDensity a0 a1 (fromBool a2)

{- | Get the density of a shape, usually in kg\/m^2

Binds @b2Shape_GetDensity@.
-}
getDensity
  :: ShapeId
  -> IO Float
getDensity a0 =
  c_b2Shape_GetDensity a0

{- | Set the friction on a shape

Binds @b2Shape_SetFriction@.
-}
setFriction
  :: ShapeId
  -> Float
  -- ^ @friction@
  -> IO ()
setFriction a0 a1 =
  c_b2Shape_SetFriction a0 a1

{- | Get the friction of a shape

Binds @b2Shape_GetFriction@.
-}
getFriction
  :: ShapeId
  -> IO Float
getFriction a0 =
  c_b2Shape_GetFriction a0

{- | Set the shape restitution (bounciness)

Binds @b2Shape_SetRestitution@.
-}
setRestitution
  :: ShapeId
  -> Float
  -- ^ @restitution@
  -> IO ()
setRestitution a0 a1 =
  c_b2Shape_SetRestitution a0 a1

{- | Get the shape restitution

Binds @b2Shape_GetRestitution@.
-}
getRestitution
  :: ShapeId
  -> IO Float
getRestitution a0 =
  c_b2Shape_GetRestitution a0

{- | Set the user material identifier

Binds @b2Shape_SetUserMaterial@.
-}
setUserMaterial
  :: ShapeId
  -> Word64
  -- ^ @material@
  -> IO ()
setUserMaterial a0 a1 =
  c_b2Shape_SetUserMaterial a0 a1

{- | Get the user material identifier

Binds @b2Shape_GetUserMaterial@.
-}
getUserMaterial
  :: ShapeId
  -> IO Word64
getUserMaterial a0 =
  c_b2Shape_GetUserMaterial a0

{- | Set the shape surface material

Binds @b2Shape_SetSurfaceMaterial@.
-}
setSurfaceMaterial
  :: ShapeId
  -> SurfaceMaterial
  -> IO ()
setSurfaceMaterial a0 a1 =
  with a1 $ \p1 ->
  c_b2Shape_SetSurfaceMaterial a0 p1

{- | Get the shape surface material

Binds @b2Shape_GetSurfaceMaterial@.
-}
getSurfaceMaterial
  :: ShapeId
  -> IO SurfaceMaterial
getSurfaceMaterial a0 =
  alloca $ \pOut -> c_b2Shape_GetSurfaceMaterial a0 pOut >> peek pOut

-- | Like 'getSurfaceMaterial', but the result is written into a caller-supplied buffer.
getSurfaceMaterialInto
  :: ShapeId
  -> Ptr SurfaceMaterial
  -- ^ Result buffer.
  -> IO ()
getSurfaceMaterialInto a0 out =
  c_b2Shape_GetSurfaceMaterial a0 out

{- | Get the shape filter

Binds @b2Shape_GetFilter@.
-}
getFilter
  :: ShapeId
  -> IO Filter
getFilter a0 =
  alloca $ \pOut -> c_b2Shape_GetFilter a0 pOut >> peek pOut

-- | Like 'getFilter', but the result is written into a caller-supplied buffer.
getFilterInto
  :: ShapeId
  -> Ptr Filter
  -- ^ Result buffer.
  -> IO ()
getFilterInto a0 out =
  c_b2Shape_GetFilter a0 out

{- | Set the current filter. This is almost as expensive as recreating the shape. This may cause
contacts to be immediately destroyed. However contacts are not created until the next world step.
Sensor overlap state is also not updated until the next world step.
See also b2ShapeDef::filter.

Binds @b2Shape_SetFilter@.
-}
setFilter
  :: ShapeId
  -> Filter
  -> IO ()
setFilter a0 a1 =
  with a1 $ \p1 ->
  c_b2Shape_SetFilter a0 p1

{- | Enable sensor events for this shape.
See also b2ShapeDef::enableSensorEvents.

Binds @b2Shape_EnableSensorEvents@.
-}
enableSensorEvents
  :: ShapeId
  -> Bool
  -- ^ @flag@
  -> IO ()
enableSensorEvents a0 a1 =
  c_b2Shape_EnableSensorEvents a0 (fromBool a1)

{- | Returns true if sensor events are enabled.

Binds @b2Shape_AreSensorEventsEnabled@.
-}
areSensorEventsEnabled
  :: ShapeId
  -> IO Bool
areSensorEventsEnabled a0 =
  toBool <$> (c_b2Shape_AreSensorEventsEnabled a0)

{- | Enable contact events for this shape. Only applies to kinematic and dynamic bodies. Ignored for sensors.
See also b2ShapeDef::enableContactEvents.
Warning: changing this at run-time may lead to lost begin\/end events

Binds @b2Shape_EnableContactEvents@.
-}
enableContactEvents
  :: ShapeId
  -> Bool
  -- ^ @flag@
  -> IO ()
enableContactEvents a0 a1 =
  c_b2Shape_EnableContactEvents a0 (fromBool a1)

{- | Returns true if contact events are enabled

Binds @b2Shape_AreContactEventsEnabled@.
-}
areContactEventsEnabled
  :: ShapeId
  -> IO Bool
areContactEventsEnabled a0 =
  toBool <$> (c_b2Shape_AreContactEventsEnabled a0)

{- | Enable pre-solve contact events for this shape. Only applies to dynamic bodies. These are expensive
and must be carefully handled due to multithreading. Ignored for sensors.
See also b2PreSolveFcn.

Binds @b2Shape_EnablePreSolveEvents@.
-}
enablePreSolveEvents
  :: ShapeId
  -> Bool
  -- ^ @flag@
  -> IO ()
enablePreSolveEvents a0 a1 =
  c_b2Shape_EnablePreSolveEvents a0 (fromBool a1)

{- | Returns true if pre-solve events are enabled

Binds @b2Shape_ArePreSolveEventsEnabled@.
-}
arePreSolveEventsEnabled
  :: ShapeId
  -> IO Bool
arePreSolveEventsEnabled a0 =
  toBool <$> (c_b2Shape_ArePreSolveEventsEnabled a0)

{- | Enable contact hit events for this shape. Ignored for sensors.
See also b2WorldDef.hitEventThreshold.

Binds @b2Shape_EnableHitEvents@.
-}
enableHitEvents
  :: ShapeId
  -> Bool
  -- ^ @flag@
  -> IO ()
enableHitEvents a0 a1 =
  c_b2Shape_EnableHitEvents a0 (fromBool a1)

{- | Returns true if hit events are enabled

Binds @b2Shape_AreHitEventsEnabled@.
-}
areHitEventsEnabled
  :: ShapeId
  -> IO Bool
areHitEventsEnabled a0 =
  toBool <$> (c_b2Shape_AreHitEventsEnabled a0)

{- | Test a world point for overlap with a shape

Binds @b2Shape_TestPoint@.
-}
testPoint
  :: ShapeId
  -> Pos
  -- ^ @point@
  -> IO Bool
testPoint a0 a1 =
  with a1 $ \p1 ->
  toBool <$> (c_b2Shape_TestPoint a0 p1)

{- | Ray cast a single shape. The ray starts at the origin and extends by the translation. The output
point is a world position.

Binds @b2Shape_RayCast@.
-}
rayCast
  :: ShapeId
  -> Pos
  -- ^ @origin@
  -> Vec2
  -- ^ @translation@
  -> IO WorldCastOutput
rayCast a0 a1 a2 =
  with a1 $ \p1 ->
  with a2 $ \p2 ->
  alloca $ \pOut -> c_b2Shape_RayCast a0 p1 p2 pOut >> peek pOut

{- | Get a copy of the shape\'s circle. Asserts the type is correct.

Binds @b2Shape_GetCircle@.
-}
getCircle
  :: ShapeId
  -> IO Circle
getCircle a0 =
  alloca $ \pOut -> c_b2Shape_GetCircle a0 pOut >> peek pOut

-- | Like 'getCircle', but the result is written into a caller-supplied buffer.
getCircleInto
  :: ShapeId
  -> Ptr Circle
  -- ^ Result buffer.
  -> IO ()
getCircleInto a0 out =
  c_b2Shape_GetCircle a0 out

{- | Get a copy of the shape\'s line segment. Asserts the type is correct.

Binds @b2Shape_GetSegment@.
-}
getSegment
  :: ShapeId
  -> IO Segment
getSegment a0 =
  alloca $ \pOut -> c_b2Shape_GetSegment a0 pOut >> peek pOut

-- | Like 'getSegment', but the result is written into a caller-supplied buffer.
getSegmentInto
  :: ShapeId
  -> Ptr Segment
  -- ^ Result buffer.
  -> IO ()
getSegmentInto a0 out =
  c_b2Shape_GetSegment a0 out

{- | Get a copy of the shape\'s chain segment. These come from chain shapes.
Asserts the type is correct.

Binds @b2Shape_GetChainSegment@.
-}
getChainSegment
  :: ShapeId
  -> Ptr ChainSegment
  -- ^ Result buffer.
  -> IO ()
getChainSegment a0 out =
  c_b2Shape_GetChainSegment a0 out

{- | Get a copy of the shape\'s capsule. Asserts the type is correct.

Binds @b2Shape_GetCapsule@.
-}
getCapsule
  :: ShapeId
  -> IO Capsule
getCapsule a0 =
  alloca $ \pOut -> c_b2Shape_GetCapsule a0 pOut >> peek pOut

-- | Like 'getCapsule', but the result is written into a caller-supplied buffer.
getCapsuleInto
  :: ShapeId
  -> Ptr Capsule
  -- ^ Result buffer.
  -> IO ()
getCapsuleInto a0 out =
  c_b2Shape_GetCapsule a0 out

{- | Get a copy of the shape\'s convex polygon. Asserts the type is correct.

Binds @b2Shape_GetPolygon@.
-}
getPolygon
  :: ShapeId
  -> IO Polygon
getPolygon a0 =
  alloca $ \pOut -> c_b2Shape_GetPolygon a0 pOut >> peek pOut

-- | Like 'getPolygon', but the result is written into a caller-supplied buffer.
getPolygonInto
  :: ShapeId
  -> Ptr Polygon
  -- ^ Result buffer.
  -> IO ()
getPolygonInto a0 out =
  c_b2Shape_GetPolygon a0 out

{- | Allows you to change a shape to be a circle or update the current circle.
This does not modify the mass properties.
See also b2Body_ApplyMassFromShapes.

Binds @b2Shape_SetCircle@.
-}
setCircle
  :: ShapeId
  -> Circle
  -> IO ()
setCircle a0 a1 =
  with a1 $ \p1 ->
  c_b2Shape_SetCircle a0 p1

{- | Allows you to change a shape to be a capsule or update the current capsule.
This does not modify the mass properties.
See also b2Body_ApplyMassFromShapes.

Binds @b2Shape_SetCapsule@.
-}
setCapsule
  :: ShapeId
  -> Capsule
  -> IO ()
setCapsule a0 a1 =
  with a1 $ \p1 ->
  c_b2Shape_SetCapsule a0 p1

{- | Allows you to change a shape to be a segment or update the current segment.

Binds @b2Shape_SetSegment@.
-}
setSegment
  :: ShapeId
  -> Segment
  -> IO ()
setSegment a0 a1 =
  with a1 $ \p1 ->
  c_b2Shape_SetSegment a0 p1

{- | Allows you to change a shape to be a polygon or update the current polygon.
This does not modify the mass properties.
See also b2Body_ApplyMassFromShapes.

Binds @b2Shape_SetPolygon@.
-}
setPolygon
  :: ShapeId
  -> Polygon
  -> IO ()
setPolygon a0 a1 =
  with a1 $ \p1 ->
  c_b2Shape_SetPolygon a0 p1

{- | Allows you to change a shape to be an orphaned chain segment or update the current chain
segment, including its ghost vertices. The chainId on the input is ignored. The resulting
shape is always orphaned. Asserts if the shape is already a chain segment
owned by a b2ChainShape (chainId != B2_NULL_INDEX).

Binds @b2Shape_SetChainSegment@.
-}
setChainSegment
  :: ShapeId
  -> Ptr ChainSegment
  -> IO ()
setChainSegment a0 a1 =
  c_b2Shape_SetChainSegment a0 a1

{- | Get the parent chain id if the shape type is a chain segment, otherwise
returns b2_nullChainId.

Binds @b2Shape_GetParentChain@.
-}
getParentChain
  :: ShapeId
  -> IO ChainId
getParentChain a0 =
  c_b2Shape_GetParentChain a0

{- | Get the maximum capacity required for retrieving all the touching contacts on a shape

Binds @b2Shape_GetContactCapacity@.
-}
getContactCapacity
  :: ShapeId
  -> IO Int
getContactCapacity a0 =
  fromIntegral <$> (c_b2Shape_GetContactCapacity a0)

{- | Get the touching contact data for a shape. The provided shapeId will be either shapeIdA or shapeIdB on the contact data.
Note: Box2D uses speculative collision so some contact points may be separated.
Warning: do not ignore the return value, it specifies the valid number of elements

Returns: the number of elements filled in the provided array

Binds @b2Shape_GetContactData@.
-}
getContactData
  :: ShapeId
  -> Ptr ContactData
  -> Int
  -- ^ @capacity@
  -> IO Int
getContactData a0 a1 a2 =
  fromIntegral <$> (c_b2Shape_GetContactData a0 a1 (fromIntegral a2))

{- | Get the maximum capacity required for retrieving all the overlapped shapes on a sensor shape.
This returns 0 if the provided shape is not a sensor.

Returns: the required capacity to get all the overlaps in b2Shape_GetSensorData

Binds @b2Shape_GetSensorCapacity@.
-}
getSensorCapacity
  :: ShapeId
  -- ^ @shapeId@: the id of a sensor shape
  -> IO Int
getSensorCapacity a0 =
  fromIntegral <$> (c_b2Shape_GetSensorCapacity a0)

{- | Get the overlap data for a sensor shape computed the previous world step.
Warning: do not ignore the return value, it specifies the valid number of elements
Warning: overlaps may contain destroyed shapes so use b2Shape_IsValid to confirm each overlap

Returns: the number of elements filled in the provided array

Binds @b2Shape_GetSensorData@.
-}
getSensorData
  :: ShapeId
  -- ^ @shapeId@: the id of a sensor shape
  -> Ptr ShapeId
  -- ^ @visitorIds@: a user allocated array that is filled with the overlapping shapes (visitors)
  -> Int
  -- ^ @capacity@: the capacity of overlappedShapes
  -> IO Int
getSensorData a0 a1 a2 =
  fromIntegral <$> (c_b2Shape_GetSensorData a0 a1 (fromIntegral a2))

{- | Get the current world AABB

Binds @b2Shape_GetAABB@.
-}
getAABB
  :: ShapeId
  -> IO AABB
getAABB a0 =
  alloca $ \pOut -> c_b2Shape_GetAABB a0 pOut >> peek pOut

-- | Like 'getAABB', but the result is written into a caller-supplied buffer.
getAABBInto
  :: ShapeId
  -> Ptr AABB
  -- ^ Result buffer.
  -> IO ()
getAABBInto a0 out =
  c_b2Shape_GetAABB a0 out

{- | Compute the mass data for a shape

Binds @b2Shape_ComputeMassData@.
-}
computeMassData
  :: ShapeId
  -> IO MassData
computeMassData a0 =
  alloca $ \pOut -> c_b2Shape_ComputeMassData a0 pOut >> peek pOut

-- | Like 'computeMassData', but the result is written into a caller-supplied buffer.
computeMassDataInto
  :: ShapeId
  -> Ptr MassData
  -- ^ Result buffer.
  -> IO ()
computeMassDataInto a0 out =
  c_b2Shape_ComputeMassData a0 out

{- | Get the closest point on a shape to a target point. Target and result are world positions.
todo need sample

Binds @b2Shape_GetClosestPoint@.
-}
getClosestPoint
  :: ShapeId
  -> Pos
  -- ^ @target@
  -> IO Pos
getClosestPoint a0 a1 =
  with a1 $ \p1 ->
  alloca $ \pOut -> c_b2Shape_GetClosestPoint a0 p1 pOut >> peek pOut

{- | Apply a wind force to the body for this shape using the density of air. This considers
the projected area of the shape in the wind direction. This also considers
the relative velocity of the shape.

Binds @b2Shape_ApplyWind@.
-}
applyWind
  :: ShapeId
  -- ^ @shapeId@: the shape id
  -> Vec2
  -- ^ @wind@: the wind velocity in world space
  -> Float
  -- ^ @drag@: the drag coefficient, the force that opposes the relative velocity
  -> Float
  -- ^ @lift@: the lift coefficient, the force that is perpendicular to the relative velocity
  -> Bool
  -- ^ @wake@: should this wake the body
  -> IO ()
applyWind a0 a1 a2 a3 a4 =
  with a1 $ \p1 ->
  c_b2Shape_ApplyWind a0 p1 a2 a3 (fromBool a4)
