{niceHaskell, ...}:
niceHaskell.mkPackage {
  flags = niceHaskell.mkFlags {doCheck = false;};
  packageRoot = ../.;
  cabalName = "mparkour2d";
  compiler = "ghc912";
}
