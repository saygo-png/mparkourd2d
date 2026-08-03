-- Produced by boxnd-gen; edit the generator, not this file.

module Box2D.Recording
  ( create
  , destroy
  , getData
  , getSize
  )
where

import Box2D.Tags (Recording)
import Foreign
import Foreign.C.Types (CInt (..))

foreign import ccall unsafe "b2CreateRecording"
  c_b2CreateRecording :: CInt -> IO (Ptr Recording)

foreign import ccall unsafe "b2DestroyRecording"
  c_b2DestroyRecording :: Ptr Recording -> IO ()

foreign import ccall unsafe "b2Recording_GetData"
  c_b2Recording_GetData :: Ptr Recording -> IO (Ptr Word8)

foreign import ccall unsafe "b2Recording_GetSize"
  c_b2Recording_GetSize :: Ptr Recording -> IO CInt

{- | Create a recording buffer. The buffer grows on demand. \@p byteCapacity pre-sizes it to avoid
reallocations during a known-length session. Pass 0 for a small default.

Returns: A recording handle, freed with b2DestroyRecording

Binds @b2CreateRecording@.
-}
create
  :: Int
  -- ^ @byteCapacity@
  -> IO (Ptr Recording)
create a0 =
  c_b2CreateRecording (fromIntegral a0)

{- | Destroy a recording buffer and free its memory.

Binds @b2DestroyRecording@.
-}
destroy
  :: Ptr Recording
  -> IO ()
destroy a0 =
  c_b2DestroyRecording a0

{- | Get a pointer to the recorded bytes, for saving to a file or transmitting. Valid until the
next recording call or b2DestroyRecording.

Binds @b2Recording_GetData@.
-}
getData
  :: Ptr Recording
  -> IO (Ptr Word8)
getData a0 =
  c_b2Recording_GetData a0

{- | Get the number of recorded bytes.

Binds @b2Recording_GetSize@.
-}
getSize
  :: Ptr Recording
  -> IO Int
getSize a0 =
  fromIntegral <$> (c_b2Recording_GetSize a0)
