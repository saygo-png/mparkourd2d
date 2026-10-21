{
  inputs = {
    treefmt-nix.url = "github:numtide/treefmt-nix";
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    ghc-wasm-meta = {
      url = "gitlab:haskell-wasm/ghc-wasm-meta?host=gitlab.haskell.org";
      flake = false;
    };
    systems = {
      url = "path:./nix/systems.nix";
      flake = false;
    };
    # miso isn't on GitHub past 1.9 and nixpkgs has an old one; bump versions
    # by editing the URLs.
    miso = {
      url = "https://hackage.haskell.org/package/miso-1.14.0.0/miso-1.14.0.0.tar.gz";
      flake = false;
    };
    # JS libraries the page loads.
    box2d3-wasm = {
      url = "https://registry.npmjs.org/box2d3-wasm/-/box2d3-wasm-5.2.0.tgz";
      flake = false;
    };
    browser-wasi-shim = {
      url = "https://registry.npmjs.org/@bjorn3/browser_wasi_shim/-/browser_wasi_shim-0.4.2.tgz";
      flake = false;
    };
  };

  outputs = {
    nixpkgs,
    systems,
    treefmt-nix,
    ...
  } @ inputs: let
    inherit (nixpkgs) lib;
    eachSystem = f: lib.genAttrs (import systems) (system: f nixpkgs.legacyPackages.${system});

    # The GHC everything uses: the wasm one from ghc-wasm-meta, and the native
    # one from nixpkgs for the dev shell and build tools.
    ghcVersion = "9.12";

    # The game and miso, added to a Haskell package set: the wasm one for the
    # build, a native one for HLS.
    localPackages = self: _: {
      # template-haskell for Miso.FFI.QQ, as in cabal.project.
      miso = self.callCabal2nixWithOptions "miso" inputs.miso "-ftemplate-haskell" {};
      mparkour2d = self.callCabal2nix "mparkour2d" (lib.fileset.toSource {
        root = ./.;
        fileset = lib.fileset.unions [./mparkour2d.cabal ./src];
      }) {};
    };
    wasmHaskellPackages = pkgs:
      (pkgs.callPackage ./nix/wasm-haskell.nix {
        inherit (inputs) ghc-wasm-meta;
        inherit ghcVersion;
      }).extend
      localPackages;
  in {
    # `nix run` serves the game on http://localhost:8000 (`nix run . -- PORT` for another port).
    packages = eachSystem (pkgs: {
      default = pkgs.callPackage ./nix/package.nix {
        wasmHaskellPackages = wasmHaskellPackages pkgs;
        inherit (inputs) box2d3-wasm browser-wasi-shim;
      };
    });

    # Native GHC with the game's dependencies, cabal and HLS, for working on
    # the game. Also wasm32-wasi-ghc and wasm32-wasi-cabal for the wasm side.
    devShells = eachSystem (pkgs: let
      native = (wasmHaskellPackages pkgs).buildHaskellPackages.extend localPackages;
    in {
      default = native.shellFor {
        packages = p: [p.mparkour2d];
        nativeBuildInputs = [
          native.haskell-language-server
          pkgs.cabal-install
          (wasmHaskellPackages pkgs).ghc
          (pkgs.callPackage "${inputs.ghc-wasm-meta}/pkgs/wasm32-wasi-cabal.nix" {flavour = ghcVersion;})
        ];
      };
    });

    formatter = eachSystem (pkgs: (treefmt-nix.lib.evalModule pkgs ./nix/treefmt.nix).config.build.wrapper);
  };
}
