-- Produced by boxnd-gen; edit the generator, not this file.

module Box2D.Contact
  ( isValid
  , getData
  )
where

import Box2D.Id (ContactId)
import Box2D.World (ContactData)
import Foreign
import Foreign.C.Types (CBool (..))

foreign import ccall unsafe "hsg_b2Contact_IsValid"
  c_b2Contact_IsValid :: Ptr ContactId -> IO CBool

foreign import ccall unsafe "hsg_b2Contact_GetData"
  c_b2Contact_GetData :: Ptr ContactId -> Ptr ContactData -> IO ()

{- | Contact identifier validation. Provides validation for up to 2^32 allocations.

Binds @b2Contact_IsValid@.
-}
isValid
  :: ContactId
  -> IO Bool
isValid a0 =
  with a0 $ \p0 ->
    toBool <$> (c_b2Contact_IsValid p0)

{- | Get the data for a contact. The manifold may have no points if the contact is not touching.

Binds @b2Contact_GetData@.
-}
getData
  :: ContactId
  -> IO ContactData
getData a0 =
  with a0 $ \p0 ->
    alloca $ \pOut -> c_b2Contact_GetData p0 pOut >> peek pOut
