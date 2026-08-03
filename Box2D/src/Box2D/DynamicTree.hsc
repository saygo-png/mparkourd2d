{-# LANGUAGE ForeignFunctionInterface #-}
{-# LANGUAGE PatternSynonyms #-}
{-# LANGUAGE GeneralizedNewtypeDeriving #-}

-- Produced by boxnd-gen; edit the generator, not this file.

module Box2D.DynamicTree
  ( BoxCastInput (..)
  , TreeStats (..)
  , DynamicTree (..)
  , TreeNodeChildren (..)
  , dynamicTreeByteCount
  , create
  , destroy
  , createProxy
  , destroyProxy
  , moveProxy
  , enlargeProxy
  , setCategoryBits
  , getCategoryBits
  , query
  , queryAll
  , rayCast
  , boxCast
  , boxCastInto
  , getHeight
  , getAreaRatio
  , getRootBounds
  , getRootBoundsInto
  , getProxyCount
  , rebuild
  , getByteCount
  , getUserData
  , getAABB
  , getAABBInto
  , validate
  , validateNoEnlarged
  )
  where

import Foreign
import Foreign.C.Types (CBool (..), CInt (..))
import Box2D.Geometry (RayCastInput)
import Box2D.MathTypes (AABB, Vec2)
import Box2D.Tags (TreeBoxCastCallbackFcn, TreeNode, TreeQueryCallbackFcn, TreeRayCastCallbackFcn)

#include "box2d/box2d.h"


-- | Input for casting an AABB through a dynamic tree
data BoxCastInput = BoxCastInput
  { box :: AABB
  , translation :: Vec2
  , maxFraction :: Float
  }
  deriving (Eq, Show)

instance Storable BoxCastInput where
  sizeOf _ = #{size b2BoxCastInput}
  alignment _ = #{alignment b2BoxCastInput}
  peek p =
    BoxCastInput
      <$> #{peek b2BoxCastInput, box} p
      <*> #{peek b2BoxCastInput, translation} p
      <*> #{peek b2BoxCastInput, maxFraction} p
  poke p (BoxCastInput f1 f2 f3) = do
    #{poke b2BoxCastInput, box} p f1
    #{poke b2BoxCastInput, translation} p f2
    #{poke b2BoxCastInput, maxFraction} p f3

-- | These are performance results returned by dynamic tree queries.
data TreeStats = TreeStats
  { nodeVisits :: CInt
  , leafVisits :: CInt
  }
  deriving (Eq, Show)

instance Storable TreeStats where
  sizeOf _ = #{size b2TreeStats}
  alignment _ = #{alignment b2TreeStats}
  peek p =
    TreeStats
      <$> #{peek b2TreeStats, nodeVisits} p
      <*> #{peek b2TreeStats, leafVisits} p
  poke p (TreeStats f1 f2) = do
    #{poke b2TreeStats, nodeVisits} p f1
    #{poke b2TreeStats, leafVisits} p f2

-- | The dynamic tree structure. This should be considered private data.
data DynamicTree = DynamicTree
  { nodes :: Ptr TreeNode
  , root :: Int32
  , nodeCount :: Int32
  , nodeCapacity :: Int32
  , freeList :: Int32
  , proxyCount :: Int32
  , leafIndices :: Ptr ()
  , leafBoxes :: Ptr AABB
  , leafCenters :: Ptr Vec2
  , binIndices :: Ptr ()
  , rebuildCapacity :: Int32
  }
  deriving (Eq, Show)

instance Storable DynamicTree where
  sizeOf _ = #{size b2DynamicTree}
  alignment _ = #{alignment b2DynamicTree}
  peek p =
    DynamicTree
      <$> #{peek b2DynamicTree, nodes} p
      <*> #{peek b2DynamicTree, root} p
      <*> #{peek b2DynamicTree, nodeCount} p
      <*> #{peek b2DynamicTree, nodeCapacity} p
      <*> #{peek b2DynamicTree, freeList} p
      <*> #{peek b2DynamicTree, proxyCount} p
      <*> #{peek b2DynamicTree, leafIndices} p
      <*> #{peek b2DynamicTree, leafBoxes} p
      <*> #{peek b2DynamicTree, leafCenters} p
      <*> #{peek b2DynamicTree, binIndices} p
      <*> #{peek b2DynamicTree, rebuildCapacity} p
  poke p (DynamicTree f1 f2 f3 f4 f5 f6 f7 f8 f9 f10 f11) = do
    #{poke b2DynamicTree, nodes} p f1
    #{poke b2DynamicTree, root} p f2
    #{poke b2DynamicTree, nodeCount} p f3
    #{poke b2DynamicTree, nodeCapacity} p f4
    #{poke b2DynamicTree, freeList} p f5
    #{poke b2DynamicTree, proxyCount} p f6
    #{poke b2DynamicTree, leafIndices} p f7
    #{poke b2DynamicTree, leafBoxes} p f8
    #{poke b2DynamicTree, leafCenters} p f9
    #{poke b2DynamicTree, binIndices} p f10
    #{poke b2DynamicTree, rebuildCapacity} p f11

-- | Tree node child indices. Internal usage.
data TreeNodeChildren = TreeNodeChildren
  { child1 :: CInt
  , child2 :: CInt
  }
  deriving (Eq, Show)

instance Storable TreeNodeChildren where
  sizeOf _ = #{size b2TreeNodeChildren}
  alignment _ = #{alignment b2TreeNodeChildren}
  peek p =
    TreeNodeChildren
      <$> #{peek b2TreeNodeChildren, child1} p
      <*> #{peek b2TreeNodeChildren, child2} p
  poke p (TreeNodeChildren f1 f2) = do
    #{poke b2TreeNodeChildren, child1} p f1
    #{poke b2TreeNodeChildren, child2} p f2

dynamicTreeByteCount :: Int
dynamicTreeByteCount = #{size b2DynamicTree}


foreign import ccall unsafe "hsg_b2DynamicTree_Create"
  c_b2DynamicTree_Create :: CInt -> Ptr DynamicTree -> IO ()

foreign import ccall unsafe "b2DynamicTree_Destroy"
  c_b2DynamicTree_Destroy :: Ptr DynamicTree -> IO ()

foreign import ccall unsafe "hsg_b2DynamicTree_CreateProxy"
  c_b2DynamicTree_CreateProxy :: Ptr DynamicTree -> Ptr AABB -> Word64 -> Word64 -> IO CInt

foreign import ccall unsafe "b2DynamicTree_DestroyProxy"
  c_b2DynamicTree_DestroyProxy :: Ptr DynamicTree -> CInt -> IO ()

foreign import ccall unsafe "hsg_b2DynamicTree_MoveProxy"
  c_b2DynamicTree_MoveProxy :: Ptr DynamicTree -> CInt -> Ptr AABB -> IO ()

foreign import ccall unsafe "hsg_b2DynamicTree_EnlargeProxy"
  c_b2DynamicTree_EnlargeProxy :: Ptr DynamicTree -> CInt -> Ptr AABB -> IO ()

foreign import ccall unsafe "b2DynamicTree_SetCategoryBits"
  c_b2DynamicTree_SetCategoryBits :: Ptr DynamicTree -> CInt -> Word64 -> IO ()

foreign import ccall unsafe "b2DynamicTree_GetCategoryBits"
  c_b2DynamicTree_GetCategoryBits :: Ptr DynamicTree -> CInt -> IO Word64

foreign import ccall safe "hsg_b2DynamicTree_Query"
  c_b2DynamicTree_Query :: Ptr DynamicTree -> Ptr AABB -> Word64 -> FunPtr TreeQueryCallbackFcn -> Ptr () -> Ptr TreeStats -> IO ()

foreign import ccall safe "hsg_b2DynamicTree_QueryAll"
  c_b2DynamicTree_QueryAll :: Ptr DynamicTree -> Ptr AABB -> FunPtr TreeQueryCallbackFcn -> Ptr () -> Ptr TreeStats -> IO ()

foreign import ccall safe "hsg_b2DynamicTree_RayCast"
  c_b2DynamicTree_RayCast :: Ptr DynamicTree -> Ptr RayCastInput -> Word64 -> FunPtr TreeRayCastCallbackFcn -> Ptr () -> Ptr TreeStats -> IO ()

foreign import ccall safe "hsg_b2DynamicTree_BoxCast"
  c_b2DynamicTree_BoxCast :: Ptr DynamicTree -> Ptr BoxCastInput -> Word64 -> FunPtr TreeBoxCastCallbackFcn -> Ptr () -> Ptr TreeStats -> IO ()

foreign import ccall unsafe "b2DynamicTree_GetHeight"
  c_b2DynamicTree_GetHeight :: Ptr DynamicTree -> IO CInt

foreign import ccall unsafe "b2DynamicTree_GetAreaRatio"
  c_b2DynamicTree_GetAreaRatio :: Ptr DynamicTree -> IO Float

foreign import ccall unsafe "hsg_b2DynamicTree_GetRootBounds"
  c_b2DynamicTree_GetRootBounds :: Ptr DynamicTree -> Ptr AABB -> IO ()

foreign import ccall unsafe "b2DynamicTree_GetProxyCount"
  c_b2DynamicTree_GetProxyCount :: Ptr DynamicTree -> IO CInt

foreign import ccall unsafe "b2DynamicTree_Rebuild"
  c_b2DynamicTree_Rebuild :: Ptr DynamicTree -> CBool -> IO CInt

foreign import ccall unsafe "b2DynamicTree_GetByteCount"
  c_b2DynamicTree_GetByteCount :: Ptr DynamicTree -> IO CInt

foreign import ccall unsafe "b2DynamicTree_GetUserData"
  c_b2DynamicTree_GetUserData :: Ptr DynamicTree -> CInt -> IO Word64

foreign import ccall unsafe "hsg_b2DynamicTree_GetAABB"
  c_b2DynamicTree_GetAABB :: Ptr DynamicTree -> CInt -> Ptr AABB -> IO ()

foreign import ccall unsafe "b2DynamicTree_Validate"
  c_b2DynamicTree_Validate :: Ptr DynamicTree -> IO ()

foreign import ccall unsafe "b2DynamicTree_ValidateNoEnlarged"
  c_b2DynamicTree_ValidateNoEnlarged :: Ptr DynamicTree -> IO ()

{- | Constructing the tree initializes the node pool.

Binds @b2DynamicTree_Create@.
-}
create
  :: Int
  -- ^ @proxyCapacity@
  -> Ptr DynamicTree
  -- ^ Result buffer.
  -> IO ()
create a0 out =
  c_b2DynamicTree_Create (fromIntegral a0) out

{- | Destroy the tree, freeing the node pool.

Binds @b2DynamicTree_Destroy@.
-}
destroy
  :: Ptr DynamicTree
  -> IO ()
destroy a0 =
  c_b2DynamicTree_Destroy a0

{- | Create a proxy. Provide an AABB and a userData value.

Binds @b2DynamicTree_CreateProxy@.
-}
createProxy
  :: Ptr DynamicTree
  -> AABB
  -> Word64
  -- ^ @categoryBits@
  -> Word64
  -- ^ @userData@
  -> IO Int
createProxy a0 a1 a2 a3 =
  with a1 $ \p1 ->
  fromIntegral <$> (c_b2DynamicTree_CreateProxy a0 p1 a2 a3)

{- | Destroy a proxy. This asserts if the id is invalid.

Binds @b2DynamicTree_DestroyProxy@.
-}
destroyProxy
  :: Ptr DynamicTree
  -> Int
  -- ^ @proxyId@
  -> IO ()
destroyProxy a0 a1 =
  c_b2DynamicTree_DestroyProxy a0 (fromIntegral a1)

{- | Move a proxy to a new AABB by removing and reinserting into the tree.

Binds @b2DynamicTree_MoveProxy@.
-}
moveProxy
  :: Ptr DynamicTree
  -> Int
  -- ^ @proxyId@
  -> AABB
  -> IO ()
moveProxy a0 a1 a2 =
  with a2 $ \p2 ->
  c_b2DynamicTree_MoveProxy a0 (fromIntegral a1) p2

{- | Enlarge a proxy and enlarge ancestors as necessary.

Binds @b2DynamicTree_EnlargeProxy@.
-}
enlargeProxy
  :: Ptr DynamicTree
  -> Int
  -- ^ @proxyId@
  -> AABB
  -> IO ()
enlargeProxy a0 a1 a2 =
  with a2 $ \p2 ->
  c_b2DynamicTree_EnlargeProxy a0 (fromIntegral a1) p2

{- | Modify the category bits on a proxy. This is an expensive operation.

Binds @b2DynamicTree_SetCategoryBits@.
-}
setCategoryBits
  :: Ptr DynamicTree
  -> Int
  -- ^ @proxyId@
  -> Word64
  -- ^ @categoryBits@
  -> IO ()
setCategoryBits a0 a1 a2 =
  c_b2DynamicTree_SetCategoryBits a0 (fromIntegral a1) a2

{- | Get the category bits on a proxy.

Binds @b2DynamicTree_GetCategoryBits@.
-}
getCategoryBits
  :: Ptr DynamicTree
  -> Int
  -- ^ @proxyId@
  -> IO Word64
getCategoryBits a0 a1 =
  c_b2DynamicTree_GetCategoryBits a0 (fromIntegral a1)

{- | Query an AABB for overlapping proxies. The callback class is called for each proxy that overlaps the supplied AABB.

Returns: performance data

Binds @b2DynamicTree_Query@.
-}
query
  :: Ptr DynamicTree
  -> AABB
  -> Word64
  -- ^ @maskBits@
  -> FunPtr TreeQueryCallbackFcn
  -> Ptr ()
  -- ^ @context@
  -> IO TreeStats
query a0 a1 a2 a3 a4 =
  with a1 $ \p1 ->
  alloca $ \pOut -> c_b2DynamicTree_Query a0 p1 a2 a3 a4 pOut >> peek pOut

{- | Query an AABB for overlapping proxies. The callback class is called for each proxy that overlaps the supplied AABB.
No filtering is performed.

Returns: performance data

Binds @b2DynamicTree_QueryAll@.
-}
queryAll
  :: Ptr DynamicTree
  -> AABB
  -> FunPtr TreeQueryCallbackFcn
  -> Ptr ()
  -- ^ @context@
  -> IO TreeStats
queryAll a0 a1 a2 a3 =
  with a1 $ \p1 ->
  alloca $ \pOut -> c_b2DynamicTree_QueryAll a0 p1 a2 a3 pOut >> peek pOut

{- | Ray cast against the proxies in the tree. This relies on the callback
to perform a exact ray cast in the case were the proxy contains a shape.
The callback also performs the any collision filtering. This has performance
roughly equal to k * log(n), where k is the number of collisions and n is the
number of proxies in the tree.
Bit-wise filtering using mask bits can greatly improve performance in some scenarios.
However, this filtering may be approximate, so the user should still apply filtering to results.

Returns: performance data

Binds @b2DynamicTree_RayCast@.
-}
rayCast
  :: Ptr DynamicTree
  -- ^ @tree@: the dynamic tree to ray cast
  -> RayCastInput
  -- ^ @input@: the ray cast input data. The ray extends from p1 to p1 + maxFraction * (p2 - p1)
  -> Word64
  -- ^ @maskBits@: mask bit hint: \`bool accept = (maskBits & node-\>categoryBits) != 0;\`
  -> FunPtr TreeRayCastCallbackFcn
  -- ^ @callback@: a callback class that is called for each proxy that is hit by the ray
  -> Ptr ()
  -- ^ @context@: user context that is passed to the callback
  -> IO TreeStats
rayCast a0 a1 a2 a3 a4 =
  with a1 $ \p1 ->
  alloca $ \pOut -> c_b2DynamicTree_RayCast a0 p1 a2 a3 a4 pOut >> peek pOut

{- | Cast a swept AABB through the tree. This has performance roughly equal to k * log(n),
where k is the number of collisions and n is the number of proxies in the tree.

Returns: performance data

Binds @b2DynamicTree_BoxCast@.
-}
boxCast
  :: Ptr DynamicTree
  -- ^ @tree@: the dynamic tree to cast through
  -> Ptr BoxCastInput
  -- ^ @input@: the AABB cast input. The box sweeps from its origin to origin + maxFraction * translation.
  -> Word64
  -- ^ @maskBits@: filter bits: \`bool accept = (maskBits & node-\>categoryBits) != 0;\`
  -> FunPtr TreeBoxCastCallbackFcn
  -- ^ @callback@: a callback that is called for each proxy the swept box may hit
  -> Ptr ()
  -- ^ @context@: user context that is passed to the callback
  -> IO TreeStats
boxCast a0 a1 a2 a3 a4 =
  alloca $ \pOut -> c_b2DynamicTree_BoxCast a0 a1 a2 a3 a4 pOut >> peek pOut

-- | Like 'boxCast', but the result is written into a caller-supplied buffer.
boxCastInto
  :: Ptr DynamicTree
  -- ^ @tree@: the dynamic tree to cast through
  -> Ptr BoxCastInput
  -- ^ @input@: the AABB cast input. The box sweeps from its origin to origin + maxFraction * translation.
  -> Word64
  -- ^ @maskBits@: filter bits: \`bool accept = (maskBits & node-\>categoryBits) != 0;\`
  -> FunPtr TreeBoxCastCallbackFcn
  -- ^ @callback@: a callback that is called for each proxy the swept box may hit
  -> Ptr ()
  -- ^ @context@: user context that is passed to the callback
  -> Ptr TreeStats
  -- ^ Result buffer.
  -> IO ()
boxCastInto a0 a1 a2 a3 a4 out =
  c_b2DynamicTree_BoxCast a0 a1 a2 a3 a4 out

{- | Get the height of the binary tree.

Binds @b2DynamicTree_GetHeight@.
-}
getHeight
  :: Ptr DynamicTree
  -> IO Int
getHeight a0 =
  fromIntegral <$> (c_b2DynamicTree_GetHeight a0)

{- | Get the ratio of the sum of the node areas to the root area.

Binds @b2DynamicTree_GetAreaRatio@.
-}
getAreaRatio
  :: Ptr DynamicTree
  -> IO Float
getAreaRatio a0 =
  c_b2DynamicTree_GetAreaRatio a0

{- | Get the bounding box that contains the entire tree

Binds @b2DynamicTree_GetRootBounds@.
-}
getRootBounds
  :: Ptr DynamicTree
  -> IO AABB
getRootBounds a0 =
  alloca $ \pOut -> c_b2DynamicTree_GetRootBounds a0 pOut >> peek pOut

-- | Like 'getRootBounds', but the result is written into a caller-supplied buffer.
getRootBoundsInto
  :: Ptr DynamicTree
  -> Ptr AABB
  -- ^ Result buffer.
  -> IO ()
getRootBoundsInto a0 out =
  c_b2DynamicTree_GetRootBounds a0 out

{- | Get the number of proxies created

Binds @b2DynamicTree_GetProxyCount@.
-}
getProxyCount
  :: Ptr DynamicTree
  -> IO Int
getProxyCount a0 =
  fromIntegral <$> (c_b2DynamicTree_GetProxyCount a0)

{- | Rebuild the tree while retaining subtrees that haven\'t changed. Returns the number of boxes sorted.

Binds @b2DynamicTree_Rebuild@.
-}
rebuild
  :: Ptr DynamicTree
  -> Bool
  -- ^ @fullBuild@
  -> IO Int
rebuild a0 a1 =
  fromIntegral <$> (c_b2DynamicTree_Rebuild a0 (fromBool a1))

{- | Get the number of bytes used by this tree

Binds @b2DynamicTree_GetByteCount@.
-}
getByteCount
  :: Ptr DynamicTree
  -> IO Int
getByteCount a0 =
  fromIntegral <$> (c_b2DynamicTree_GetByteCount a0)

{- | Get proxy user data

Binds @b2DynamicTree_GetUserData@.
-}
getUserData
  :: Ptr DynamicTree
  -> Int
  -- ^ @proxyId@
  -> IO Word64
getUserData a0 a1 =
  c_b2DynamicTree_GetUserData a0 (fromIntegral a1)

{- | Get the AABB of a proxy

Binds @b2DynamicTree_GetAABB@.
-}
getAABB
  :: Ptr DynamicTree
  -> Int
  -- ^ @proxyId@
  -> IO AABB
getAABB a0 a1 =
  alloca $ \pOut -> c_b2DynamicTree_GetAABB a0 (fromIntegral a1) pOut >> peek pOut

-- | Like 'getAABB', but the result is written into a caller-supplied buffer.
getAABBInto
  :: Ptr DynamicTree
  -> Int
  -- ^ @proxyId@
  -> Ptr AABB
  -- ^ Result buffer.
  -> IO ()
getAABBInto a0 a1 out =
  c_b2DynamicTree_GetAABB a0 (fromIntegral a1) out

{- | Validate this tree. For testing.

Binds @b2DynamicTree_Validate@.
-}
validate
  :: Ptr DynamicTree
  -> IO ()
validate a0 =
  c_b2DynamicTree_Validate a0

{- | Validate this tree has no enlarged AABBs. For testing.

Binds @b2DynamicTree_ValidateNoEnlarged@.
-}
validateNoEnlarged
  :: Ptr DynamicTree
  -> IO ()
validateNoEnlarged a0 =
  c_b2DynamicTree_ValidateNoEnlarged a0
