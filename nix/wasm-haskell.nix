# nixpkgs' GHC 9.12 Haskell package set, compiled to wasm by ghc-wasm-meta's
# GHC instead of the native one (Setup.hs scripts still build natively).
# Use it like any package set: callCabal2nix, overrides, etc.
{
  haskell,
  callPackage,
  ghc-wasm-meta,
}: let
  wasi-sdk = callPackage "${ghc-wasm-meta}/pkgs/wasi-sdk.nix" {};
  ghc =
    callPackage "${ghc-wasm-meta}/pkgs/wasm32-wasi-ghc.nix" {flavour = "9.12";}
    // {
      # What nixpkgs' Haskell builder needs to know about its compiler.
      targetPrefix = "wasm32-wasi-";
      haskellCompilerName = "ghc-9.12";
      version = "9.12";
      enableShared = true; # Template Haskell loads dependencies as shared libraries.
      hasHaddock = false;
    };
in
  haskell.packages.ghc912.override {
    inherit ghc;
    buildHaskellPackages = haskell.packages.ghc912;
    overrides = self: super: {
      mkDerivation = args:
        super.mkDerivation (args
          // {
            doCheck = false; # Test suites would be wasm, which the build can't run.
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
