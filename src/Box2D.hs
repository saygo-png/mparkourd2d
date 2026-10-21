{-# LANGUAGE QuasiQuotes #-}

{- | The Box2D calls the game uses, from box2d3-wasm (Box2D v3 compiled to
wasm), which web/index.html loads into the JS global @b2@.

Box2D takes its vectors, defs and shapes as Emscripten objects that have to be
freed with @.delete()@, so each call deletes the ones it creates.
-}
module Box2D (
  World,
  Body,
  Shape,
  BodyType (..),
  createWorld,
  step,
  createBody,
  applyForceToCenter,
  getPosition,
  createSegment,
  createCircle,
  setRestitution,
) where

import Linear (V2 (..))
import Miso.DSL (JSVal, ToJSVal)
import Miso.FFI.QQ (js)
import Relude

newtype World = World JSVal
  deriving newtype (Eq, ToJSVal)

newtype Body = Body JSVal
  deriving newtype (Eq, ToJSVal)

newtype Shape = Shape JSVal
  deriving newtype (Eq, ToJSVal)

data BodyType = StaticBody | KinematicBody | DynamicBody
  deriving stock (Enum)

createWorld :: V2 Double -> IO World
createWorld (V2 gravityX gravityY) =
  World
    <$> [js|
      const d = b2.b2DefaultWorldDef(), g = new b2.b2Vec2(${gravityX}, ${gravityY});
      d.gravity = g;
      d.enableSleep = false;
      const w = b2.b2CreateWorld(d);
      g.delete();
      d.delete();
      return w;
    |]

step :: World -> Double -> Int -> IO ()
step world timeStep subSteps = [js| b2.b2World_Step(${world}, ${timeStep}, ${subSteps}); |]

createBody :: World -> BodyType -> V2 Double -> IO Body
createBody world bodyType (V2 x y) =
  let typeIndex = fromEnum bodyType
   in Body
        <$> [js|
          const d = b2.b2DefaultBodyDef(), p = new b2.b2Vec2(${x}, ${y}), t = b2.b2BodyType;
          d.type = [t.b2_staticBody, t.b2_kinematicBody, t.b2_dynamicBody][${typeIndex}];
          d.position = p;
          const b = b2.b2CreateBody(${world}, d);
          p.delete();
          d.delete();
          return b;
        |]

applyForceToCenter :: Body -> V2 Double -> IO ()
applyForceToCenter body (V2 x y) =
  [js|
    const f = new b2.b2Vec2(${x}, ${y});
    b2.b2Body_ApplyForceToCenter(${body}, f, true);
    f.delete();
  |]

getPosition :: Body -> IO (V2 Double)
getPosition body = do
  xy <-
    [js|
      const p = b2.b2Body_GetPosition(${body}), xy = [p.x, p.y];
      p.delete();
      return xy;
    |]
  case xy of
    [x, y] -> pure (V2 x y)
    _ -> error "b2Body_GetPosition didn't return a vector"

createSegment :: Body -> V2 Double -> V2 Double -> IO Shape
createSegment body (V2 x1 y1) (V2 x2 y2) =
  Shape
    <$> [js|
      const d = b2.b2DefaultShapeDef(), s = new b2.b2Segment();
      const p1 = new b2.b2Vec2(${x1}, ${y1}), p2 = new b2.b2Vec2(${x2}, ${y2});
      s.point1 = p1;
      s.point2 = p2;
      const id = b2.b2CreateSegmentShape(${body}, d, s);
      [d, s, p1, p2].forEach(o => o.delete());
      return id;
    |]

-- | @createCircle body center radius@, with the center relative to the body.
createCircle :: Body -> V2 Double -> Double -> IO Shape
createCircle body (V2 x y) radius =
  Shape
    <$> [js|
      const d = b2.b2DefaultShapeDef(), c = new b2.b2Circle(), p = new b2.b2Vec2(${x}, ${y});
      c.center = p;
      c.radius = ${radius};
      const id = b2.b2CreateCircleShape(${body}, d, c);
      [d, c, p].forEach(o => o.delete());
      return id;
    |]

setRestitution :: Shape -> Double -> IO ()
setRestitution shape restitution = [js| b2.b2Shape_SetRestitution(${shape}, ${restitution}); |]
