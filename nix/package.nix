# `bin/mparkour2d` serves the site (see site.nix) on localhost.
{
  runCommand,
  makeWrapper,
  writers,
  wasmHaskellPackages,
  site,
}: let
  serve =
    writers.writeHaskellBin "serve" {
      # The native GHC the game's package set builds with; the default is
      # haskellPackages', which would mean downloading another GHC.
      inherit (wasmHaskellPackages.buildHaskellPackages) ghc;
      libraries = p: [p.wai-app-static p.warp];
    }
    ./serve.hs;
in
  runCommand "mparkour2d" {
    nativeBuildInputs = [makeWrapper];
    meta.mainProgram = "mparkour2d";
  } ''
    makeWrapper ${serve}/bin/serve $out/bin/mparkour2d --add-flags ${site}
  ''
