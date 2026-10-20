# mparkour2d

A 2D Box2D playground in Haskell, compiled to WebAssembly and drawn on a
Canvas2D in the browser. Everything it needs is part of the build, so it runs
offline.

## Running

```sh
nix run              # builds, then serves the game on http://localhost:8000
nix run . -- 8080    # another port
```

For development, `nix develop` gives you the GHC wasm toolchain. Then
`web/build.sh` rebuilds incrementally into `web/`; serve that directory, for
example with `python3 -m http.server -d web`. That build resolves Haskell
dependencies from Hackage as usual. `nix build` uses the versions nixpkgs pins.

Controls: `A` / `D` push left and right, `Space` pushes up, `P` logs the
mouse position to the browser console.

`nix flake update` updates everything: nixpkgs (and with it the Haskell
dependencies), the GHC wasm toolchain and the JS libraries. The JS libraries
are npm tarballs pinned by version in `flake.nix`, so bump them by editing
their URLs.

## Architecture

```
browser ── index.html ── loads ──▶ mparkour2d.wasm (GHC RTS + game)
                                     │  Haskell `main` runs the game loop
            ghc_wasm_jsffi.js  ◀─────┤  foreign import javascript: canvas,
            (generated glue)         │  DOM events, requestAnimationFrame
                                     ▼
                              vendor/box2d3-wasm (Box2D compiled to wasm)
```

- **Compilation.** GHC's wasm backend
  ([ghc-wasm-meta](https://gitlab.haskell.org/haskell-wasm/ghc-wasm-meta),
  GHC 9.12) compiles the game and its Hackage dependencies to one
  `wasm32-wasi` module. It is linked as a *reactor* (a library with exports,
  not a program with `_start`) that exports `start`, which is the Haskell
  `main` (see `mparkour2d.cabal`).
- **JS FFI.** `foreign import javascript` declarations embed small JS
  snippets in Haskell; `$1`, `$2`, … are the arguments. GHC's post-linker
  (`post-link.mjs` in `web/build.sh`) collects them into
  `ghc_wasm_jsffi.js`, which the wasm module imports. Calls marked `unsafe`
  are synchronous. The ones without it may `await`, and suspend only the
  calling Haskell thread.
- **Startup.** `web/index.html` holds the only hand-written JS. It
  instantiates the module with a WASI shim
  ([browser_wasi_shim](https://www.npmjs.com/package/@bjorn3/browser_wasi_shim),
  which routes stdout/stderr to the console) and calls `start`.
- **Game loop** (`src/Main.hs`). `main` loads Box2D, registers input
  listeners, then loops: await the next `requestAnimationFrame`, step physics,
  draw, repeat.
- **Rendering** (`src/Web/Canvas.hs`). Each raylib-style call
  (`drawCircleV`, `drawText`, …) is one synchronous JS FFI call on the
  canvas's 2D context. The canvas is a fixed 1920×1080 that CSS scales to fit
  the window.
- **Input** (`src/Web/Input.hs`). DOM `keydown`/`keyup`/`pointermove`
  listeners are Haskell callbacks, made with `foreign import javascript
  "wrapper"`. They update `IORef`s that `isKeyDown` and friends read. Keys are
  `KeyboardEvent.code` names such as `"KeyA"`.
- **Physics** (`src/Web/Physics.hs`). The Box2D calls the game makes, as JS
  FFI calls into [box2d3-wasm](https://www.npmjs.com/package/box2d3-wasm),
  Box2D v3 compiled to its own wasm module by Emscripten. Its vectors and
  defs are Emscripten objects, so each call deletes its temporaries.
- **Nix** (`nix/package.nix`). The toolchain comes from ghc-wasm-meta's
  package definitions. The Hackage dependencies are the sources nixpkgs pins
  for its GHC 9.12 package set, handed to cabal as a local package
  repository, so the build needs no network. The JS libraries are copied into
  `vendor/`. The output is the static site plus a `bin/mparkour2d` that serves
  it.
