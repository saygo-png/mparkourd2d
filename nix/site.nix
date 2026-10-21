# The site: web/index.html, the game compiled to wasm, and the JS it loads, put
# together by web/build-site.sh. `nix run` serves it (package.nix); CI builds
# the same with cabal for GitHub Pages. wasmHaskellPackages must contain
# mparkour2d (see flake.nix).
{
  runCommand,
  nodejs,
  wasmHaskellPackages,
  box2d3-wasm,
  browser-wasi-shim,
}:
runCommand "mparkour2d-site" {
  nativeBuildInputs = [wasmHaskellPackages.ghc nodejs];
  BOX2D3_WASM = box2d3-wasm;
  BROWSER_WASI_SHIM = browser-wasi-shim;
} ''
  bash ${../web}/build-site.sh ${wasmHaskellPackages.mparkour2d}/bin/mparkour2d.wasm $out
''
