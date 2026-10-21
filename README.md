# mparkour2d

A 2D Box2D game in Haskell that runs in the browser. It is compiled to
WebAssembly, written in the Elm architecture with
[miso](https://github.com/haskell-miso/miso), and works offline.

```sh
nix run              # build and serve on http://localhost:8000
nix run . -- 8080    # another port
```

Controls: `A`/`D` push left and right, `Space` pushes up, `P` prints the mouse
position to the browser console. `Shift` uses the GA: a dash to the target
(brown dot) nearest the mouse, within the pink circle. It has a 3 second
cooldown, and `Space` during it jumps out towards the mouse.

## How it works

| Path | What it is |
| --- | --- |
| `src/Main.hs` | The game, as a miso app: a `Model`, the `Msg`s that change it, `update`, and a `view` that draws the model on a canvas. |
| `src/Box2D.hs` | The Box2D functions the game uses, each a few lines of JS. |
| `web/index.html` | Loads Box2D and the wasm module, then calls `start` (the game's `main`). |

Each frame miso sends `Frame time` (from `rAFSub`). `update` then pushes the
player according to the held keys (from `keyboardSub`), steps the physics world,
and stores the player's new position. miso redraws the canvas from the new
model with `view`.

The camera keeps the player in the middle of the screen. Positions in the model
are world positions, except the mouse's, which is on the screen;
`screenToWorld` and `worldToScreen` convert between them. `drawWorld` draws in
world positions (the canvas is translated for it), and the text around it is
drawn on the screen.

Each `Miso.Canvas` call costs a few JS values, so drawing hundreds of shapes
every frame is slow: draw only what is on the screen, as `drawWorld` does with
the targets.

Box2D is [box2d3-wasm](https://github.com/Birch-san/box2d3-wasm), Box2D v3
compiled to wasm by Emscripten. It is a separate wasm module, so the game uses
it through JS, as the global `b2`. Box2D's objects (worlds, bodies, shapes) stay
in JS; the game holds them as `JSVal`s and passes them back to Box2D. Physics is
y-up and the screen is y-down; `flipY` and `v2` in `Main.hs` convert between
them.

### Using more of Box2D

Add a function to `src/Box2D.hs`. miso's `[js| ... |]` quasiquote runs the JS
with `${x}` replaced by the Haskell value `x`, and converts what it returns to
the function's result type:

```haskell
applyLinearImpulseToCenter :: Body -> Vector2 -> IO ()
applyLinearImpulseToCenter body (Vector2 x y) =
  [js|
    const i = new b2.b2Vec2(${x}, ${y});
    b2.b2Body_ApplyLinearImpulseToCenter(${body}, i, true);
    i.delete();
  |]
```

Box2D's vectors and definitions are Emscripten objects; `.delete()` the ones you
create. The JS API mirrors Box2D's C API (`b2Body_ApplyLinearImpulseToCenter(bodyId,
impulse, wake)`), see the [Box2D docs](https://box2d.org/documentation/).

Call it from `update` inside `sync_`, which runs `IO` after the update. `sync`
and `io` also turn the result into the next `Msg`; `io` runs it in a new
thread, which is too slow for every frame.

The physics runs `timeScale` (10) times faster than real time, so velocities
in Box2D are a tenth of the speed on screen; `setVelocity` in `Main.hs` converts.

## Developing

`nix develop` gives you native GHC with the game's dependencies, `cabal`
and HLS. miso compiles natively too (its JS calls just aren't usable there), so
HLS and `cabal build` work on all of the code. For the real thing, `nix run`
builds it for wasm; after the first build only the game is rebuilt.

The shell also has `wasm32-wasi-cabal`, for building the wasm by hand
(`wasm32-wasi-cabal build`).

## The build

- `nix/wasm-haskell.nix` is nixpkgs' Haskell package set, with its
  compiler swapped for the wasm GHC from
  [ghc-wasm-meta](https://gitlab.haskell.org/haskell-wasm/ghc-wasm-meta).
  Dependency versions come from nixpkgs, and each dependency is its own cached
  derivation. The GHC version is `ghcVersion` in `flake.nix`, the one place to
  change it; it picks both the wasm GHC and nixpkgs' native package set.
- `flake.nix` adds miso (with its `template-haskell` flag, for `[js| |]`) and
  `mparkour2d` to that set with `callCabal2nix`. It also adds them to the
  native set, for the dev shell.
- `nix/package.nix` takes the built `.wasm` and generates `ghc_wasm_jsffi.js`
  with GHC's post-linker; this is the JS half of the Haskell↔JS calls. It puts
  both next to `index.html` and the JS libraries.
- `nix/serve.hs` is the server `nix run` starts: Warp serving the site with
  caching turned off. Everything in the Nix store is dated 1970, so a browser
  that caches the files never notices a new build.
- Every external piece is a flake input: nixpkgs (and with it the Haskell
  dependencies), ghc-wasm-meta, miso, box2d3-wasm and browser_wasi_shim (which
  gives the wasm module stdout/stderr in the console). `nix flake update`
  updates them; miso and the JS libraries are tarballs pinned by version in
  `flake.nix`.
