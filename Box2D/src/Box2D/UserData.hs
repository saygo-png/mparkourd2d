{-| Integer-friendly user data: stash an entity\/index id in the engine's
@void* userData@ slots without manual pointer casts. The id travels as the
pointer's bit pattern (it is never dereferenced), so any 'Int' that fits a
word round-trips — which makes contact events and queries resolvable back
to your entities.
-}
module Box2D.UserData
  ( HasUserData (..)
  , setUserIndex
  , getUserIndex
  , userIndexToPtr
  , ptrToUserIndex
  ) where

import Foreign.Ptr (IntPtr (..), Ptr, intPtrToPtr, ptrToIntPtr)

import Box2D.Body qualified as Body
import Box2D.Id (BodyId, JointId, ShapeId)
import Box2D.Joint qualified as Joint
import Box2D.Shape qualified as Shape

-- | Handles carrying a @userData@ pointer slot.
class HasUserData id where
  setUserData :: id -> Ptr () -> IO ()
  getUserData :: id -> IO (Ptr ())

instance HasUserData BodyId where
  setUserData = Body.setUserData
  getUserData = Body.getUserData

instance HasUserData ShapeId where
  setUserData = Shape.setUserData
  getUserData = Shape.getUserData

instance HasUserData JointId where
  setUserData = Joint.setUserData
  getUserData = Joint.getUserData

{- | Encode an id as a user-data pointer (also for the @*Def@ records'
@userData@ fields).
-}
userIndexToPtr :: Int -> Ptr ()
userIndexToPtr = intPtrToPtr . IntPtr

-- | Decode a user-data pointer written by 'userIndexToPtr'.
ptrToUserIndex :: Ptr () -> Int
ptrToUserIndex p = case ptrToIntPtr p of IntPtr i -> i

-- | Stash an entity\/index id on a body, shape or joint.
setUserIndex :: (HasUserData id) => id -> Int -> IO ()
setUserIndex x = setUserData x . userIndexToPtr

-- | Read back an id stored with 'setUserIndex'.
getUserIndex :: (HasUserData id) => id -> IO Int
getUserIndex x = ptrToUserIndex <$> getUserData x
