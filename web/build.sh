#!/usr/bin/env bash
# Builds the game into web/. Run inside `nix develop`, which provides the GHC
# wasm toolchain and $WEB_VENDOR (box2d3-wasm and the WASI shim). Then serve web/.
set -euo pipefail
cd "$(dirname "$0")/.."

wasm32-wasi-cabal build exe:mparkour2d
bin=$(wasm32-wasi-cabal list-bin exe:mparkour2d)
"$(wasm32-wasi-ghc --print-libdir)/post-link.mjs" -i "$bin" -o web/ghc_wasm_jsffi.js
cp "$bin" web/mparkour2d.wasm
rm -rf web/vendor
cp -r --no-preserve=mode "$WEB_VENDOR" web/vendor
