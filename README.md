# mparkour2d

A 2D Box2D playground in Haskell, compiled to WebAssembly and drawn on a
Canvas2D in the browser.

## Building

Install the GHC wasm toolchain from
[ghc-wasm-meta](https://gitlab.haskell.org/haskell-wasm/ghc-wasm-meta)
(`FLAVOUR=9.12 ./setup.sh` from a checkout, or its nix flake), then:

```sh
source ~/.ghc-wasm/env
web/build.sh                          # writes web/mparkour2d.wasm + web/ghc_wasm_jsffi.js
python3 -m http.server -d web 8000    # open http://localhost:8000
```

Controls: `A` / `D` push left and right, `Space` pushes up, `P` logs the
mouse position to the browser console.

## How it fits together

Everything runs in Haskell through GHC's JavaScript FFI
(`foreign import javascript`):

- `src/Web/Canvas.hs`: raylib-style drawing calls on a Canvas2D context.
- `src/Web/Input.hs`: keyboard/mouse state fed by DOM event listeners.
- `src/Web/Physics.hs`: the Box2D calls the game uses, against
  [box2d3-wasm](https://www.npmjs.com/package/box2d3-wasm) loaded from a CDN.
- `src/Main.hs`: the game; its `main` loops on `requestAnimationFrame`.

The only hand-written JS is the standard loader in `web/index.html`. It uses
[`@bjorn3/browser_wasi_shim`](https://www.npmjs.com/package/@bjorn3/browser_wasi_shim)
and the `ghc_wasm_jsffi.js` glue that GHC's post-linker generates.
