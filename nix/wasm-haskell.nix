# nixpkgs' Haskell package set for GHC `ghcVersion` (e.g. "9.12"), compiled to
# wasm by ghc-wasm-meta's GHC instead of the native one (Setup.hs scripts still
# build natively, with buildHaskellPackages). Use it like any package set:
# callCabal2nix, overrides, etc.
{
  lib,
  haskell,
  callPackage,
  ghc-wasm-meta,
  ghcVersion,
}: let
  native = haskell.packages."ghc${lib.replaceStrings ["."] [""] ghcVersion}";
  wasi-sdk = callPackage "${ghc-wasm-meta}/pkgs/wasi-sdk.nix" {};
  ghc =
    callPackage "${ghc-wasm-meta}/pkgs/wasm32-wasi-ghc.nix" {flavour = ghcVersion;}
    // {
      # What nixpkgs' Haskell builder needs to know about its compiler.
      targetPrefix = "wasm32-wasi-";
      haskellCompilerName = "ghc-${ghcVersion}";
      version = ghcVersion;
      enableShared = true; # Template Haskell loads dependencies as shared libraries.
      hasHaddock = false;
    };
in
  native.override {
    inherit ghc;
    buildHaskellPackages = native;
    overrides = self: super: {
      mkDerivation = args:
        super.mkDerivation (args
          // {
            doCheck = false; # Test suites would be wasm, which the build can't run.
            # Template Haskell in a library fails in the profiling build on wasm.
            enableLibraryProfiling = false;
            dontStrip = true; # The native strip doesn't understand wasm.
            configureFlags =
              (args.configureFlags or [])
              ++ [
                "--with-ghc=wasm32-wasi-ghc"
                "--with-ghc-pkg=wasm32-wasi-ghc-pkg"
                "--with-hsc2hs=wasm32-wasi-hsc2hs"
                "--with-gcc=${wasi-sdk}/bin/wasm32-wasi-clang"
              ];
          });
      # On 32-bit targets tasty needs unbounded-delays, which nixpkgs only
      # resolves dependencies for 64-bit.
      tasty = haskell.lib.compose.addBuildDepend self.unbounded-delays super.tasty;
    };
  }
