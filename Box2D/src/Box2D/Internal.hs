{-| Marshalling helpers shared by the binding modules.

By-value calls involving float structs or defs go through the shim as
pointers (ids pass directly as words), so the same two idioms recur: read
a struct back from an out parameter, and decode a C boolean returned for
a marshalled argument.
-}
module Box2D.Internal
  ( allocaOut
  , withValid
  , copyVector
  , pokeCountedVector
  , unsafeViewVector
  ) where

import Data.Vector.Storable qualified as VS
import Foreign
import Foreign.C.Types (CBool, CInt)

-- | Run a shim call that writes its result to an out parameter and read it.
{-# INLINE allocaOut #-}
allocaOut :: (Storable a) => (Ptr a -> IO ()) -> IO a
allocaOut f = alloca $ \p -> f p >> peek p

-- | Marshal a value in and decode the returned C boolean.
{-# INLINE withValid #-}
withValid :: (Storable a) => (Ptr a -> IO CBool) -> a -> IO Bool
withValid f a = with a (fmap (/= 0) . f)

{- | Copy a C-owned array into a Haskell-owned storable vector: one @memcpy@,
no per-element marshalling. Safe to keep after the source is invalidated.
-}
{-# INLINE copyVector #-}
copyVector :: (Storable a) => Int -> Ptr a -> IO (VS.Vector a)
copyVector n src = do
  fp <- mallocForeignPtrArray n
  withForeignPtr fp $ \dst -> copyArray dst src n
  pure (VS.unsafeFromForeignPtr0 fp n)

{- | The poke-side counterpart of 'copyVector': copy a vector into a struct's
fixed-capacity array (dropping anything past the capacity) and write the
resulting length through the count writer, which is a continuation because
@#{poke}@ is bound to a specific struct field.
-}
{-# INLINE pokeCountedVector #-}
pokeCountedVector :: (Storable a) => Int -> Ptr a -> (CInt -> IO ()) -> VS.Vector a -> IO ()
pokeCountedVector cap dst pokeCount v = do
  let ps = VS.take cap v
  VS.unsafeWith ps $ \src -> copyArray dst src (VS.length ps)
  pokeCount (fromIntegral (VS.length ps))

{- | View a C-owned array as a storable vector without copying. The vector
aliases engine memory and carries no finalizer: it is only valid while the
source buffer is (for event buffers, until the next world step). Prefer
'copyVector' unless the copy shows up in a profile.
-}
{-# INLINE unsafeViewVector #-}
unsafeViewVector :: Int -> Ptr a -> IO (VS.Vector a)
unsafeViewVector n p = do
  fp <- newForeignPtr_ p
  pure (VS.unsafeFromForeignPtr0 fp n)
