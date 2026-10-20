{- | The Box2D calls the game uses, made through the JS FFI against
box2d3-wasm (Box2D v3 compiled to wasm, bundled into web/vendor by nix), which
'loadBox2D' loads into the JS global @b2@. Its vectors and defs are Emscripten
objects, so every temporary one is deleted before returning.
-}
module Web.Physics (
  WorldId,
  BodyId,
  ShapeId,
  BodyType (..),
  loadBox2D,
  createWorld,
  createBody,
  createSegment,
  createCircle,
  setRestitution,
  applyForceToCenter,
  step,
  getPosition,
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

loadBox2D :: IO ()
loadBox2D = evaluateWHNF =<< js_load

foreign import javascript unsafe "const d = b2.b2DefaultWorldDef(), g = new b2.b2Vec2($1, $2); d.gravity = g; d.enableSleep = false; \
  \const w = b2.b2CreateWorld(d); g.delete(); d.delete(); return w"
  js_createWorld :: Float -> Float -> IO WorldId

foreign import javascript unsafe "const d = b2.b2DefaultBodyDef(), p = new b2.b2Vec2($3, $4), t = b2.b2BodyType; \
  \d.type = [t.b2_staticBody, t.b2_kinematicBody, t.b2_dynamicBody][$2]; d.position = p; \
  \const b = b2.b2CreateBody($1, d); p.delete(); d.delete(); return b"
  js_createBody :: WorldId -> Int -> Float -> Float -> IO BodyId

foreign import javascript unsafe "const d = b2.b2DefaultShapeDef(), s = new b2.b2Segment(), p1 = new b2.b2Vec2($2, $3), p2 = new b2.b2Vec2($4, $5); \
  \s.point1 = p1; s.point2 = p2; const id = b2.b2CreateSegmentShape($1, d, s); \
  \[d, s, p1, p2].forEach(o => o.delete()); return id"
  js_createSegment :: BodyId -> Float -> Float -> Float -> Float -> IO ShapeId

foreign import javascript unsafe "const d = b2.b2DefaultShapeDef(), c = new b2.b2Circle(), p = new b2.b2Vec2($2, $3); \
  \c.center = p; c.radius = $4; const id = b2.b2CreateCircleShape($1, d, c); \
  \[d, c, p].forEach(o => o.delete()); return id"
  js_createCircle :: BodyId -> Float -> Float -> Float -> IO ShapeId

foreign import javascript unsafe "b2.b2Shape_SetRestitution($1, $2)"
  setRestitution :: ShapeId -> Float -> IO ()

foreign import javascript unsafe "const f = new b2.b2Vec2($2, $3); b2.b2Body_ApplyForceToCenter($1, f, $4); f.delete()"
  js_applyForceToCenter :: BodyId -> Float -> Float -> Bool -> IO ()

foreign import javascript unsafe "b2.b2World_Step($1, $2, $3)"
  step :: WorldId -> Float -> Int -> IO ()

foreign import javascript unsafe "const p = b2.b2Body_GetPosition($1), r = [p.x, p.y]; p.delete(); return r"
  js_getPosition :: BodyId -> IO JSVal

foreign import javascript unsafe "$1[$2]"
  js_index :: JSVal -> Int -> IO Float

createWorld :: V2 Float -> IO WorldId
createWorld (V2 x y) = js_createWorld x y

createBody :: WorldId -> BodyType -> V2 Float -> IO BodyId
createBody w t (V2 x y) = js_createBody w (fromEnum t) x y

createSegment :: BodyId -> V2 Float -> V2 Float -> IO ShapeId
createSegment b (V2 x1 y1) (V2 x2 y2) = js_createSegment b x1 y1 x2 y2

createCircle :: BodyId -> V2 Float -> Float -> IO ShapeId
createCircle b (V2 x y) = js_createCircle b x y

applyForceToCenter :: BodyId -> V2 Float -> Bool -> IO ()
applyForceToCenter b (V2 x y) = js_applyForceToCenter b x y

getPosition :: BodyId -> IO (V2 Float)
getPosition b = do
  r <- js_getPosition b
  V2 <$> js_index r 0 <*> js_index r 1 <* freeJSVal r
