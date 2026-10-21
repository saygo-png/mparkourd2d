# The site: web/index.html, the game compiled to wasm, and the JS it loads.
# `bin/mparkour2d` serves it on localhost.
{
  lib,
  runCommand,
  makeWrapper,
  nodejs,
  python3,
  wasmHaskellPackages,
  box2d3-wasm,
  browser-wasi-shim,
}: let
  src = lib.fileset.toSource {
    root = ../.;
    fileset = lib.fileset.unions [../mparkour2d.cabal ../src];
  };
  haskellPackages = wasmHaskellPackages.extend (self: _: {
    web-game = self.callCabal2nix "web-game" ../web-game {};
  });
  game = haskellPackages.callCabal2nix "mparkour2d" src {};
in
  runCommand "mparkour2d" {
    nativeBuildInputs = [wasmHaskellPackages.ghc nodejs makeWrapper];
    meta.mainProgram = "mparkour2d";
  } ''
    site=$out/share/mparkour2d
    mkdir -p $site/vendor/box2d3-wasm $site/vendor/browser_wasi_shim
    cp ${../web/index.html} $site/index.html
    cp ${game}/bin/mparkour2d.wasm $site
    # Generates the JS half of all `foreign import javascript`s (the game's and web-game's).
    "$(wasm32-wasi-ghc --print-libdir)/post-link.mjs" -i $site/mparkour2d.wasm -o $site/ghc_wasm_jsffi.js
    cp ${box2d3-wasm}/build/dist/es/compat/*.{mjs,wasm} $site/vendor/box2d3-wasm
    cp ${browser-wasi-shim}/dist/*.js $site/vendor/browser_wasi_shim
    makeWrapper ${lib.getExe python3} $out/bin/mparkour2d \
      --add-flags "-m http.server --bind 127.0.0.1 --directory $site"
  ''
