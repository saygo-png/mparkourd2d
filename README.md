# mparkour2d

A 2D Box2D game in Haskell that runs in the browser. It is compiled to
WebAssembly, draws on a canvas, and works offline.

```sh
nix run              # build and serve on http://localhost:8000
nix run . -- 8080    # another port
```

Controls: `A`/`D` push left and right, `Space` pushes up, `P` prints the mouse
position to the browser console.

## How it works

```
web/index.html ── starts ──▶ mparkour2d.wasm   (GHC runtime + your Haskell)
                               │ foreign import javascript
                               ├──▶ canvas, DOM events, requestAnimationFrame
                               └──▶ vendor/box2d3-wasm   (Box2D compiled to wasm)
```

GHC's WebAssembly backend compiles the game to one `.wasm` module. The game
talks to the browser through
[`foreign import javascript`](https://ghc.gitlab.haskell.org/ghc/doc/users_guide/wasm.html#javascript-ffi-in-the-wasm-backend):
a JS snippet in a Haskell declaration, with `$1`, `$2`, … as its arguments.

```haskell
foreign import javascript unsafe "$1.fillStyle = $2; $1.fillRect($3, $4, $5, $6)"
  js_fillRect :: Context -> JSString -> Float -> Float -> Float -> Float -> IO ()
```

`unsafe` imports run synchronously. Imports without it may `await` a promise,
which pauses only the calling Haskell thread. `nextFrame` in `Main.hs` uses
that to wait for `requestAnimationFrame`.

| File | What it does |
| --- | --- |
| `src/Main.hs` | The game: world setup, input handling, physics step, drawing, and the frame loop. `main` is exported to JS as `start`. |
| `src/Physics.hs` | The Box2D functions the game uses, as calls into box2d3-wasm. |
| `src/Canvas.hs` | Drawing on the canvas: `fillRect`, `fillCircle`, `strokeLine`, `fillText`. |
| `src/Input.hs` | Keyboard and mouse state, updated by DOM event listeners. |
| `web/index.html` | The page: a 1920×1080 canvas scaled to the window, and the few lines of JS that load the wasm module and call `start`. |

Physics uses Box2D's y-up coordinates, and the screen is y-down. `flipY` and
`v2` in `Main.hs` convert between them.

### The build

- `nix/wasm-haskell.nix` is nixpkgs' GHC 9.12 Haskell package set, with its
  compiler swapped for the wasm GHC from
  [ghc-wasm-meta](https://gitlab.haskell.org/haskell-wasm/ghc-wasm-meta).
  Dependency versions come from nixpkgs, and each dependency is its own cached
  derivation.
- `nix/package.nix` builds the game with `callCabal2nix`. GHC's post-linker
  then generates `ghc_wasm_jsffi.js`, the JS half of the foreign imports. The
  result is put next to `index.html` and the JS libraries.
- Every external piece is a flake input: nixpkgs (and with it the Haskell
  dependencies), ghc-wasm-meta, box2d3-wasm and browser_wasi_shim (which
  gives the wasm module stdout/stderr in the console). `nix flake update`
  updates them. The two JS libraries are npm tarballs pinned by version in
  `flake.nix`.

Add Haskell dependencies to `mparkour2d.cabal` as usual. `nix develop` gives you
`wasm32-wasi-cabal` and `wasm32-wasi-ghc` for quick compiles with cabal
(dependencies from Hackage).

## Using more of Box2D

The game can only use the Box2D functions bound in `src/Physics.hs`. Each
binding is a JS snippet that calls box2d3-wasm, plus a small Haskell function
that unpacks `V2`s. box2d3-wasm mirrors Box2D v3's C API: `b2CreateBody`,
`b2Body_GetLinearVelocity`, and so on, with the same arguments. Its full list
is in `build/dist/es/compat/Box2D.compat.d.ts` in the
[npm package](https://www.npmjs.com/package/box2d3-wasm). The
[Box2D docs](https://box2d.org/documentation/) explain what each one does.

For example, to give a body a box shape, add to `Physics.hs`:

```haskell
foreign import javascript unsafe
  "const d = b2.b2DefaultShapeDef(), box = b2.b2MakeBox($2, $3); \
  \const id = b2.b2CreatePolygonShape($1, d, box); d.delete(); box.delete(); return id"
  js_createBox :: BodyId -> Float -> Float -> IO ShapeId

-- | @createBox body halfSize@: a box centered on the body.
createBox :: BodyId -> V2 Float -> IO ShapeId
createBox body (V2 halfWidth halfHeight) = js_createBox body halfWidth halfHeight
```

Export it from the module, then use it in `startup`:

```haskell
crate <- Physics.createBody physicsWorldID DynamicBody (v2 700 500)
_ <- Physics.createBox crate (V2 20 20)
```

Things to keep in mind:

- Box2D's vectors, defs and shapes (`b2Vec2`, `b2DefaultShapeDef()`,
  `b2MakeBox(...)`) are Emscripten objects. Call `.delete()` on each one you
  create, or it leaks. Ids (`WorldId`, `BodyId`, `ShapeId`) are kept and passed
  back in.
- Pass numbers, not vectors, across the FFI, and build the `b2Vec2` in the
  snippet. To return a vector, return a JS array as `getPosition` does.
- Settings such as friction or density go on the def before the create call,
  e.g. `d.density = $4;`. Changing them afterwards is a separate call such as
  `b2.b2Shape_SetFriction(id, f)`.
- `b2` is the global that `loadBox2D` sets; it holds the whole library.
