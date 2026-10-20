{- | The Box2D calls the game uses, from box2d3-wasm (Box2D v3 compiled to
wasm). 'loadBox2D' puts the library in the JS global @b2@, which the other
functions call into.

Box2D takes its vectors, defs and shapes as Emscripten objects that have to be
freed with @.delete()@, so each binding creates what it needs and deletes it.
-}
module Physics (
  WorldId,
  BodyId,
  ShapeId,
  BodyType (..),
  loadBox2D,
  createWorld,
  step,
  createBody,
  applyForceToCenter,
  getPosition,
  createSegment,
  createCircle,
  setRestitution,
) where

import GHC.Wasm.Prim (JSVal, freeJSVal)
import Linear (V2 (..))
import Relude

newtype WorldId = WorldId JSVal

newtype BodyId = BodyId JSVal

newtype ShapeId = ShapeId JSVal

data BodyType = StaticBody | KinematicBody | DynamicBody
  deriving stock (Enum)

foreign import javascript safe "globalThis.b2 = await (await import('./vendor/box2d3-wasm/Box2D.compat.mjs')).default()"
  js_load :: IO ()

-- | Loads the library; call it before anything else here.
loadBox2D :: IO ()
loadBox2D = evaluateWHNF =<< js_load -- the import finishes when its result is forced

foreign import javascript unsafe "const d = b2.b2DefaultWorldDef(), g = new b2.b2Vec2($1, $2); d.gravity = g; d.enableSleep = false; \
  \const w = b2.b2CreateWorld(d); g.delete(); d.delete(); return w"
  js_createWorld :: Float -> Float -> IO WorldId

-- | @createWorld gravity@
createWorld :: V2 Float -> IO WorldId
createWorld (V2 x y) = js_createWorld x y

-- | @step world timeStep subStepCount@
foreign import javascript unsafe "b2.b2World_Step($1, $2, $3)"
  step :: WorldId -> Float -> Int -> IO ()

foreign import javascript unsafe "const d = b2.b2DefaultBodyDef(), p = new b2.b2Vec2($3, $4), t = b2.b2BodyType; \
  \d.type = [t.b2_staticBody, t.b2_kinematicBody, t.b2_dynamicBody][$2]; d.position = p; \
  \const b = b2.b2CreateBody($1, d); p.delete(); d.delete(); return b"
  js_createBody :: WorldId -> Int -> Float -> Float -> IO BodyId

createBody :: WorldId -> BodyType -> V2 Float -> IO BodyId
createBody world bodyType (V2 x y) = js_createBody world (fromEnum bodyType) x y

foreign import javascript unsafe "const f = new b2.b2Vec2($2, $3); b2.b2Body_ApplyForceToCenter($1, f, $4); f.delete()"
  js_applyForceToCenter :: BodyId -> Float -> Float -> Bool -> IO ()

-- | @applyForceToCenter body force wake@
applyForceToCenter :: BodyId -> V2 Float -> Bool -> IO ()
applyForceToCenter body (V2 x y) = js_applyForceToCenter body x y

foreign import javascript unsafe "const p = b2.b2Body_GetPosition($1), r = [p.x, p.y]; p.delete(); return r"
  js_getPosition :: BodyId -> IO JSVal

foreign import javascript unsafe "$1[$2]"
  js_index :: JSVal -> Int -> IO Float

getPosition :: BodyId -> IO (V2 Float)
getPosition body = do
  p <- js_getPosition body
  V2 <$> js_index p 0 <*> js_index p 1 <* freeJSVal p

foreign import javascript unsafe "const d = b2.b2DefaultShapeDef(), s = new b2.b2Segment(), p1 = new b2.b2Vec2($2, $3), p2 = new b2.b2Vec2($4, $5); \
  \s.point1 = p1; s.point2 = p2; const id = b2.b2CreateSegmentShape($1, d, s); \
  \[d, s, p1, p2].forEach(o => o.delete()); return id"
  js_createSegment :: BodyId -> Float -> Float -> Float -> Float -> IO ShapeId

createSegment :: BodyId -> V2 Float -> V2 Float -> IO ShapeId
createSegment body (V2 x1 y1) (V2 x2 y2) = js_createSegment body x1 y1 x2 y2

foreign import javascript unsafe "const d = b2.b2DefaultShapeDef(), c = new b2.b2Circle(), p = new b2.b2Vec2($2, $3); \
  \c.center = p; c.radius = $4; const id = b2.b2CreateCircleShape($1, d, c); \
  \[d, c, p].forEach(o => o.delete()); return id"
  js_createCircle :: BodyId -> Float -> Float -> Float -> IO ShapeId

-- | @createCircle body center radius@, with the center relative to the body.
createCircle :: BodyId -> V2 Float -> Float -> IO ShapeId
createCircle body (V2 x y) = js_createCircle body x y

foreign import javascript unsafe "b2.b2Shape_SetRestitution($1, $2)"
  setRestitution :: ShapeId -> Float -> IO ()
