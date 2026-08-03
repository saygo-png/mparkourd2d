{-# LANGUAGE ForeignFunctionInterface #-}

-- | Low-level bindings to @box2d/base.h@: version info, global allocator /
-- assert / log hooks, and timing helpers.
module Box2D.Base
  ( -- * Version
    Version (..)
  , getVersion
  , isDoublePrecision

    -- * Allocator
  , AllocFcn
  , FreeFcn
  , setAllocator
  , getByteCount

    -- * Assert / log hooks
  , AssertFcn
  , LogFcn
  , setAssertFcn
  , setLogFcn

    -- * Timing
  , getTicks
  , getMilliseconds
  , getMillisecondsAndReset
  , yield
  , hash
  ) where

import Foreign
import Foreign.C.Types
import Foreign.C.String (CString)

import Box2D.Internal (allocaOut)

#include "box2d/box2d.h"

-- | Version numbering scheme, see <https://semver.org/>.
data Version = Version
  { major :: CInt
  , minor :: CInt
  , revision :: CInt
  }
  deriving (Eq, Show)

instance Storable Version where
  sizeOf _ = #{size b2Version}
  alignment _ = #{alignment b2Version}
  peek p =
    Version
      <$> #{peek b2Version, major} p
      <*> #{peek b2Version, minor} p
      <*> #{peek b2Version, revision} p
  poke p (Version ma mi re) = do
    #{poke b2Version, major} p ma
    #{poke b2Version, minor} p mi
    #{poke b2Version, revision} p re

foreign import ccall unsafe "hs_b2GetVersion"
  c_b2GetVersion :: Ptr Version -> IO ()

-- | Get the current version of Box2D.
getVersion :: IO Version
getVersion = allocaOut c_b2GetVersion

-- | 'True' if the library was built with @BOX2D_DOUBLE_PRECISION@.
foreign import ccall unsafe "b2IsDoublePrecision"
  c_b2IsDoublePrecision :: IO CBool

isDoublePrecision :: IO Bool
isDoublePrecision = (/= 0) <$> c_b2IsDoublePrecision

-- Allocator ---------------------------------------------------------------

-- | User allocation function: @void* (size_t size, int alignment)@.
type AllocFcn = CSize -> CInt -> IO (Ptr ())

-- | User free function: @void (void* mem, size_t size)@.
type FreeFcn = Ptr () -> CSize -> IO ()

-- | Override the default allocation functions. Set during application startup.
--
-- The 'FunPtr's must point to C functions: the engine calls the hooks from
-- inside @unsafe@ FFI calls, where re-entering Haskell is undefined
-- behaviour, so wrapping Haskell functions is not supported yet.
foreign import ccall unsafe "b2SetAllocator"
  setAllocator :: FunPtr AllocFcn -> FunPtr FreeFcn -> IO ()

-- | Total bytes allocated by Box2D.
foreign import ccall unsafe "b2GetByteCount"
  getByteCount :: IO Int64

-- Assert / log ------------------------------------------------------------

-- | Assert callback: @int (const char* condition, const char* file, int line)@.
-- Return 0 to skip the debugger break.
type AssertFcn = CString -> CString -> CInt -> IO CInt

-- | Log callback: @void (const char* message)@.
type LogFcn = CString -> IO ()

-- | Override the default assert callback. Must point to a C function, see
-- 'setAllocator'.
foreign import ccall unsafe "b2SetAssertFcn"
  setAssertFcn :: FunPtr AssertFcn -> IO ()

-- | Override the default logging callback. Must point to a C function, see
-- 'setAllocator'.
foreign import ccall unsafe "b2SetLogFcn"
  setLogFcn :: FunPtr LogFcn -> IO ()

-- Timing ------------------------------------------------------------------

-- | Absolute number of system ticks. The value is platform specific.
foreign import ccall unsafe "b2GetTicks"
  getTicks :: IO Word64

-- | Milliseconds passed from an initial tick value.
foreign import ccall unsafe "b2GetMilliseconds"
  getMilliseconds :: Word64 -> IO CFloat

-- | Milliseconds passed from an initial tick value, resetting it to now.
foreign import ccall unsafe "b2GetMillisecondsAndReset"
  getMillisecondsAndReset :: Ptr Word64 -> IO CFloat

-- | Yield to be used in a busy loop.
foreign import ccall unsafe "b2Yield"
  yield :: IO ()

-- | Simple djb2 hash function for determinism testing.
foreign import ccall unsafe "b2Hash"
  hash :: Word32 -> Ptr Word8 -> CInt -> IO Word32
