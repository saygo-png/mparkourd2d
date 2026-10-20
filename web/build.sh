#!/usr/bin/env bash
# Builds web/mparkour2d.wasm and its JSFFI glue with the GHC wasm toolchain
# (https://gitlab.haskell.org/haskell-wasm/ghc-wasm-meta). Then serve web/.
set -euo pipefail
cd "$(dirname "$0")/.."

wasm32-wasi-cabal build exe:mparkour2d
bin=$(wasm32-wasi-cabal list-bin exe:mparkour2d)
"$(wasm32-wasi-ghc --print-libdir)/post-link.mjs" -i "$bin" -o web/ghc_wasm_jsffi.js
cp "$bin" web/mparkour2d.wasm
