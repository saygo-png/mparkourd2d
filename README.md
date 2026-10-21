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
foreign import javascript unsafe
  """
  $1.fillStyle = $2;
  $1.fillRect($3, $4, $5, $6);
  """
  js_fillRect :: Context -> JSString -> Float -> Float -> Float -> Float -> IO ()
```

`unsafe` imports run synchronously. Imports without it may `await` a promise,
which pauses only the calling Haskell thread. `nextFrame` uses that to wait
for `requestAnimationFrame`.

The bindings are a separate library, [`web-game/`](web-game/README.md), so
other games can reuse them:

| File | What it does |
| --- | --- |
| `src/Main.hs` | The game: world setup, input handling, physics step, drawing, and the frame loop. `main` is exported to JS as `start`. |
| `web-game/` | The library: `Web.Canvas` (drawing), `Web.Input` (keyboard and mouse), `Web.Frame` (`nextFrame`), `Web.Box2D` (physics). |
| `web/index.html` | The page: a 1920×1080 canvas scaled to the window, and the few lines of JS that load the wasm module and call `start`. |

Physics uses Box2D's y-up coordinates, and the screen is y-down. `flipY` and
`v2` in `Main.hs` convert between them.

### The build

- `nix/wasm-haskell.nix` is nixpkgs' GHC 9.12 Haskell package set, with its
  compiler swapped for the wasm GHC from
  [ghc-wasm-meta](https://gitlab.haskell.org/haskell-wasm/ghc-wasm-meta).
  Dependency versions come from nixpkgs, and each dependency is its own cached
  derivation.
- `nix/package.nix` adds `web-game` to that set and builds the game with
  `callCabal2nix`. GHC's post-linker
  then generates `ghc_wasm_jsffi.js`, the JS half of the foreign imports. The
  result is put next to `index.html` and the JS libraries.
- Every external piece is a flake input: nixpkgs (and with it the Haskell
  dependencies), ghc-wasm-meta, box2d3-wasm and browser_wasi_shim (which
  gives the wasm module stdout/stderr in the console). `nix flake update`
  updates them. The two JS libraries are npm tarballs pinned by version in
  `flake.nix`.

Add Haskell dependencies to `mparkour2d.cabal` (or `web-game/web-game.cabal`)
as usual. `nix develop` gives you
`wasm32-wasi-cabal` and `wasm32-wasi-ghc` for quick compiles with cabal
(dependencies from Hackage).

## Using more of Box2D

The game can only use the Box2D functions bound in
`web-game/src/Web/Box2D.hs`. The [web-game README](web-game/README.md#binding-more-of-box2d)
shows how to bind more, with an example.
