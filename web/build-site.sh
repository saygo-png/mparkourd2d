#!/usr/bin/env bash
# Puts the site together in OUT: index.html, the game's wasm with its JS half,
# and the JS libraries the page loads. Used by nix/site.nix and by CI
# (.github/workflows/deploy.yaml).
#
# Usage: web/build-site.sh GAME.wasm OUT
# Needs wasm32-wasi-ghc and node on PATH, and BOX2D3_WASM and BROWSER_WASI_SHIM
# set to those npm packages (the `wasm` dev shell sets them).
set -euo pipefail
wasm=$1
out=$2

mkdir -p "$out/vendor/box2d3-wasm" "$out/vendor/browser_wasi_shim"
cp "$(dirname "$0")/index.html" "$out/index.html"
cp "$wasm" "$out/mparkour2d.wasm"
# Generates the JS half of the `foreign import javascript`s (miso's and the game's).
"$(wasm32-wasi-ghc --print-libdir)/post-link.mjs" -i "$out/mparkour2d.wasm" -o "$out/ghc_wasm_jsffi.js"
cp "$BOX2D3_WASM"/build/dist/es/compat/*.{mjs,wasm} "$out/vendor/box2d3-wasm"
cp "$BROWSER_WASI_SHIM"/dist/*.js "$out/vendor/browser_wasi_shim"
