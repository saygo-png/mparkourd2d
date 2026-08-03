-- Produced by boxnd-gen; edit the generator, not this file.

module Box2D.Chain
  ( create
  , destroy
  , getWorld
  , getSegmentCount
  , getSegments
  , getSurfaceMaterialCount
  , setSurfaceMaterial
  , getSurfaceMaterial
  , getSurfaceMaterialInto
  , isValid
  , enableContactEvents
  , enableHitEvents
  )
where

import Box2D.Id (BodyId (..), ChainId (..), ShapeId (..), WorldId (..))
import Box2D.Shape (ChainDef, SurfaceMaterial)
import Foreign
import Foreign.C.Types (CBool (..), CInt (..))

foreign import ccall unsafe "b2CreateChain"
  c_b2CreateChain :: BodyId -> Ptr ChainDef -> IO ChainId

foreign import ccall unsafe "b2DestroyChain"
  c_b2DestroyChain :: ChainId -> IO ()

foreign import ccall unsafe "b2Chain_GetWorld"
  c_b2Chain_GetWorld :: ChainId -> IO WorldId

foreign import ccall unsafe "b2Chain_GetSegmentCount"
  c_b2Chain_GetSegmentCount :: ChainId -> IO CInt

foreign import ccall unsafe "b2Chain_GetSegments"
  c_b2Chain_GetSegments :: ChainId -> Ptr ShapeId -> CInt -> IO CInt

foreign import ccall unsafe "b2Chain_GetSurfaceMaterialCount"
  c_b2Chain_GetSurfaceMaterialCount :: ChainId -> IO CInt

foreign import ccall unsafe "b2Chain_SetSurfaceMaterial"
  c_b2Chain_SetSurfaceMaterial :: ChainId -> Ptr SurfaceMaterial -> CInt -> IO ()

foreign import ccall unsafe "hsg_b2Chain_GetSurfaceMaterial"
  c_b2Chain_GetSurfaceMaterial :: ChainId -> CInt -> Ptr SurfaceMaterial -> IO ()

foreign import ccall unsafe "b2Chain_IsValid"
  c_b2Chain_IsValid :: ChainId -> IO CBool

foreign import ccall unsafe "hs_b2Chain_EnableContactEvents"
  c_b2Chain_EnableContactEvents :: ChainId -> CBool -> IO ()

foreign import ccall unsafe "hs_b2Chain_EnableHitEvents"
  c_b2Chain_EnableHitEvents :: ChainId -> CBool -> IO ()

{- | Create a chain shape
See also b2ChainDef for details.

Binds @b2CreateChain@.
-}
create
  :: BodyId
  -> ChainDef
  -> IO ChainId
create a0 a1 =
  with a1 $ \p1 ->
    c_b2CreateChain a0 p1

{- | Destroy a chain shape

Binds @b2DestroyChain@.
-}
destroy
  :: ChainId
  -> IO ()
destroy a0 =
  c_b2DestroyChain a0

{- | Get the world that owns this chain shape

Binds @b2Chain_GetWorld@.
-}
getWorld
  :: ChainId
  -> IO WorldId
getWorld a0 =
  c_b2Chain_GetWorld a0

{- | Get the number of segments on this chain

Binds @b2Chain_GetSegmentCount@.
-}
getSegmentCount
  :: ChainId
  -> IO Int
getSegmentCount a0 =
  fromIntegral <$> (c_b2Chain_GetSegmentCount a0)

{- | Fill a user array with chain segment shape ids up to the specified capacity. Returns
the actual number of segments returned.

Binds @b2Chain_GetSegments@.
-}
getSegments
  :: ChainId
  -> Ptr ShapeId
  -- ^ @segmentArray@
  -> Int
  -- ^ @capacity@
  -> IO Int
getSegments a0 a1 a2 =
  fromIntegral <$> (c_b2Chain_GetSegments a0 a1 (fromIntegral a2))

{- | Get the number of materials used on this chain. Must be 1 or the number of segments.

Binds @b2Chain_GetSurfaceMaterialCount@.
-}
getSurfaceMaterialCount
  :: ChainId
  -> IO Int
getSurfaceMaterialCount a0 =
  fromIntegral <$> (c_b2Chain_GetSurfaceMaterialCount a0)

{- | Set a chain material. If the chain has only one material, this material is applied to all
segments. Otherwise it is applied to a single segment.

Binds @b2Chain_SetSurfaceMaterial@.
-}
setSurfaceMaterial
  :: ChainId
  -> SurfaceMaterial
  -> Int
  -- ^ @materialIndex@
  -> IO ()
setSurfaceMaterial a0 a1 a2 =
  with a1 $ \p1 ->
    c_b2Chain_SetSurfaceMaterial a0 p1 (fromIntegral a2)

{- | Get a chain material by index.

Binds @b2Chain_GetSurfaceMaterial@.
-}
getSurfaceMaterial
  :: ChainId
  -> Int
  -- ^ @materialIndex@
  -> IO SurfaceMaterial
getSurfaceMaterial a0 a1 =
  alloca $ \pOut -> c_b2Chain_GetSurfaceMaterial a0 (fromIntegral a1) pOut >> peek pOut

-- | Like 'getSurfaceMaterial', but the result is written into a caller-supplied buffer.
getSurfaceMaterialInto
  :: ChainId
  -> Int
  -- ^ @materialIndex@
  -> Ptr SurfaceMaterial
  -- ^ Result buffer.
  -> IO ()
getSurfaceMaterialInto a0 a1 out =
  c_b2Chain_GetSurfaceMaterial a0 (fromIntegral a1) out

{- | Chain identifier validation. Provides validation for up to 64K allocations.

Binds @b2Chain_IsValid@.
-}
isValid
  :: ChainId
  -> IO Bool
isValid a0 =
  toBool <$> (c_b2Chain_IsValid a0)

{- | Enable\/disable contact events on every segment shape of a chain.
Chain creation turns segment contact events off, so this visits
each segment in C instead of one FFI round-trip per segment.

Provided by the hand-written shim @hs_b2Chain_EnableContactEvents@; no upstream equivalent.
-}
enableContactEvents
  :: ChainId
  -> Bool
  -- ^ @flag@
  -> IO ()
enableContactEvents a0 a1 =
  c_b2Chain_EnableContactEvents a0 (fromBool a1)

{- | Enable\/disable hit events on every segment shape of a chain.
Chain creation turns segment hit events off, so this visits
each segment in C instead of one FFI round-trip per segment.

Provided by the hand-written shim @hs_b2Chain_EnableHitEvents@; no upstream equivalent.
-}
enableHitEvents
  :: ChainId
  -> Bool
  -- ^ @flag@
  -> IO ()
enableHitEvents a0 a1 =
  c_b2Chain_EnableHitEvents a0 (fromBool a1)
