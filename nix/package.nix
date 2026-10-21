# The site: web/index.html, the game compiled to wasm, and the JS it loads.
# wasmHaskellPackages must contain mparkour2d (see flake.nix).
# `bin/mparkour2d` serves it on localhost.
{
  runCommand,
  makeWrapper,
  writers,
  haskellPackages,
  nodejs,
  wasmHaskellPackages,
  box2d3-wasm,
  browser-wasi-shim,
}: let
  serve = writers.writeHaskellBin "serve" {libraries = [haskellPackages.wai-app-static haskellPackages.warp];} ./serve.hs;
in
  runCommand "mparkour2d" {
    nativeBuildInputs = [wasmHaskellPackages.ghc nodejs makeWrapper];
    meta.mainProgram = "mparkour2d";
  } ''
    site=$out/share/mparkour2d
    mkdir -p $site/vendor/box2d3-wasm $site/vendor/browser_wasi_shim
    cp ${../web/index.html} $site/index.html
    cp ${wasmHaskellPackages.mparkour2d}/bin/mparkour2d.wasm $site
    # Generates the JS half of the `foreign import javascript`s (miso's and the game's).
    "$(wasm32-wasi-ghc --print-libdir)/post-link.mjs" -i $site/mparkour2d.wasm -o $site/ghc_wasm_jsffi.js
    cp ${box2d3-wasm}/build/dist/es/compat/*.{mjs,wasm} $site/vendor/box2d3-wasm
    cp ${browser-wasi-shim}/dist/*.js $site/vendor/browser_wasi_shim
    makeWrapper ${serve}/bin/serve $out/bin/mparkour2d --add-flags $site
  ''
