{- | Low-level bindings to @box2d/id.h@: opaque handles to Box2D objects.

The C API passes these as integer-only structs of at most 8 bytes by value.
On the 64-bit ABIs this package supports (x86-64 SysV and Win64, AArch64)
such a struct travels in a general-purpose register exactly like a
@uint32_t@/@uint64_t@, so the handles are newtypes over words and cross the
FFI directly, with no shim. The payload is the raw struct bytes and carries
no stable meaning; the constructors are exported only so foreign imports can
see through the newtypes. A zero word is the null id, which is also what
zero-initialisation produces on the C side. Struct sizes are pinned by
@_Static_assert@s in @cbits/box2d_shim.c@.

'ContactId' is 12 bytes and does not fit a word, so it keeps a struct-shaped
representation; nothing passes it by value yet.
-}
module Box2D.Id
  ( WorldId (..)
  , BodyId (..)
  , ShapeId (..)
  , ChainId (..)
  , JointId (..)
  , ContactId (..)
  , nullWorldId
  , nullBodyId
  , nullShapeId
  , nullChainId
  , nullJointId
  , nullContactId
  ) where

import Foreign

#include "box2d/id.h"

-- | Handle to a world instance.
newtype WorldId = WorldId Word32
  deriving (Eq, Show)

-- | Handle to a body instance.
newtype BodyId = BodyId Word64
  deriving (Eq, Show)

-- | Handle to a shape instance.
newtype ShapeId = ShapeId Word64
  deriving (Eq, Show)

-- | Handle to a chain instance.
newtype ChainId = ChainId Word64
  deriving (Eq, Show)

-- | Handle to a joint instance.
newtype JointId = JointId Word64
  deriving (Eq, Show)

-- | Handle to a contact instance.
data ContactId = ContactId Int32 Word16 Word32
  deriving (Eq, Show)

-- The word's alignment is at least the struct's, so alloca'd space is always
-- aligned enough for the aliased peek/poke.

instance Storable WorldId where
  sizeOf _ = #{size b2WorldId}
  alignment _ = alignment (0 :: Word32)
  peek p = WorldId <$> peek (castPtr p)
  poke p (WorldId w) = poke (castPtr p) w

instance Storable BodyId where
  sizeOf _ = #{size b2BodyId}
  alignment _ = alignment (0 :: Word64)
  peek p = BodyId <$> peek (castPtr p)
  poke p (BodyId w) = poke (castPtr p) w

instance Storable ShapeId where
  sizeOf _ = #{size b2ShapeId}
  alignment _ = alignment (0 :: Word64)
  peek p = ShapeId <$> peek (castPtr p)
  poke p (ShapeId w) = poke (castPtr p) w

instance Storable ChainId where
  sizeOf _ = #{size b2ChainId}
  alignment _ = alignment (0 :: Word64)
  peek p = ChainId <$> peek (castPtr p)
  poke p (ChainId w) = poke (castPtr p) w

instance Storable JointId where
  sizeOf _ = #{size b2JointId}
  alignment _ = alignment (0 :: Word64)
  peek p = JointId <$> peek (castPtr p)
  poke p (JointId w) = poke (castPtr p) w

instance Storable ContactId where
  sizeOf _ = #{size b2ContactId}
  alignment _ = #{alignment b2ContactId}
  peek p =
    ContactId
      <$> #{peek b2ContactId, index1} p
      <*> #{peek b2ContactId, world0} p
      <*> #{peek b2ContactId, generation} p
  poke p (ContactId i w g) = do
    #{poke b2ContactId, index1} p i
    #{poke b2ContactId, world0} p w
    #{poke b2ContactId, padding} p (0 :: Int16)
    #{poke b2ContactId, generation} p g

nullWorldId :: WorldId
nullWorldId = WorldId 0

nullBodyId :: BodyId
nullBodyId = BodyId 0

nullShapeId :: ShapeId
nullShapeId = ShapeId 0

nullChainId :: ChainId
nullChainId = ChainId 0

nullJointId :: JointId
nullJointId = JointId 0

nullContactId :: ContactId
nullContactId = ContactId 0 0 0
