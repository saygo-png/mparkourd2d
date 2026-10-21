# web-game

Browser bindings for Haskell games compiled with GHC's WebAssembly backend:

| Module | What it does |
| --- | --- |
| `Web.Canvas` | Drawing on the page's `<canvas>`: `fillRect`, `fillCircle`, `strokeLine`, `fillText`. |
| `Web.Input` | Keyboard and mouse state from DOM events: `isKeyDown`, `isKeyPressed`, `getMousePosition`, … |
| `Web.Frame` | `nextFrame`, which waits for the browser's next frame (`requestAnimationFrame`). |
| `Web.Box2D` | The Box2D functions bound so far, from [box2d3-wasm](https://www.npmjs.com/package/box2d3-wasm). |

Each binding is a
[`foreign import javascript`](https://ghc.gitlab.haskell.org/ghc/doc/users_guide/wasm.html#javascript-ffi-in-the-wasm-backend):
a JS snippet in a Haskell declaration, with `$1`, `$2`, … as its arguments.
Where a JS API takes vectors, a small Haskell function next to the import
unpacks `V2`s.

## Using it in a game

The game is a cabal executable that depends on `web-game` and is linked as a
wasm module exporting its `main` (see `mparkour2d.cabal` and the end of
`src/Main.hs`):

```haskell
main :: IO ()
main = do
  loadBox2D           -- only if you use Web.Box2D
  ctx <- getContext
  input <- newInput
  let loop = do
        _time <- nextFrame
        -- update, draw with ctx
        endFrame input
        loop
  loop

foreign export javascript "start" main :: IO ()
```

The page it runs in needs:

- a `<canvas>`, which `getContext` and the mouse position use;
- the loader script from `web/index.html`, which instantiates the wasm module
  with `browser_wasi_shim` and calls `start`;
- `ghc_wasm_jsffi.js`, which GHC's `post-link.mjs` generates from the built
  `.wasm`, next to the page;
- for `Web.Box2D`: box2d3-wasm's `Box2D.compat.mjs` and `Box2D.compat.wasm`
  in `vendor/box2d3-wasm/`, next to `ghc_wasm_jsffi.js`.

`nix/package.nix` in this repository puts all of that together.

## Binding more of Box2D

box2d3-wasm mirrors Box2D v3's C API (`b2CreateBody`,
`b2Body_GetLinearVelocity`, …) with the same arguments. Its full list is in
`build/dist/es/compat/Box2D.compat.d.ts` in the npm package, and the
[Box2D docs](https://box2d.org/documentation/) explain each call. To bind one,
add a foreign import to `Web/Box2D.hs` and export it. For example, a box shape:

```haskell
foreign import javascript unsafe
  """
  const d = b2.b2DefaultShapeDef(), box = b2.b2MakeBox($2, $3);
  const id = b2.b2CreatePolygonShape($1, d, box);
  d.delete();
  box.delete();
  return id;
  """
  js_createBox :: BodyId -> Float -> Float -> IO ShapeId

-- | @createBox body halfSize@: a box centered on the body.
createBox :: BodyId -> V2 Float -> IO ShapeId
createBox body (V2 halfWidth halfHeight) = js_createBox body halfWidth halfHeight
```

Then, in a game:

```haskell
crate <- Physics.createBody world DynamicBody (V2 700 (-500))
_ <- Physics.createBox crate (V2 20 20)
```

Things to keep in mind:

- Box2D's vectors, defs and shapes (`new b2.b2Vec2(...)`,
  `b2DefaultShapeDef()`, `b2MakeBox(...)`) are Emscripten objects. Call
  `.delete()` on each one you create, or it leaks. Ids (`WorldId`, `BodyId`,
  `ShapeId`) are kept and passed back in.
- Pass numbers, not vectors, across the FFI, and build the `b2Vec2` in the
  snippet. To return a vector, return a JS array as `getPosition` does.
- Settings such as friction or density go on the def before the create call,
  e.g. `d.density = $4;`. Changing them afterwards is a separate call such as
  `b2.b2Shape_SetFriction(id, f)`.
- `b2` is the global that `loadBox2D` sets; it holds the whole library.
- Box2D is y-up, so a game drawing on a y-down canvas flips y between the two.
