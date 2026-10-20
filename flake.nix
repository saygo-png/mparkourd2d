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
    # JS libraries the page loads; bump versions by editing the URLs.
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
    eachSystem = f: nixpkgs.lib.genAttrs (import systems) (system: f nixpkgs.legacyPackages.${system});
    wasmHaskellPackages = pkgs: pkgs.callPackage ./nix/wasm-haskell.nix {inherit (inputs) ghc-wasm-meta;};
  in {
    # `nix run` serves the game on http://localhost:8000 (`nix run . -- PORT` for another port).
    packages = eachSystem (pkgs: {
      default = pkgs.callPackage ./nix/package.nix {
        wasmHaskellPackages = wasmHaskellPackages pkgs;
        inherit (inputs) box2d3-wasm browser-wasi-shim;
      };
    });

    # wasm32-wasi-ghc and wasm32-wasi-cabal, for compiling with cabal directly.
    devShells = eachSystem (pkgs: {
      default = pkgs.mkShell {
        packages = [
          (wasmHaskellPackages pkgs).ghc
          (pkgs.callPackage "${inputs.ghc-wasm-meta}/pkgs/wasm32-wasi-cabal.nix" {flavour = "9.12";})
        ];
      };
    });

    formatter = eachSystem (pkgs: (treefmt-nix.lib.evalModule pkgs ./nix/treefmt.nix).config.build.wrapper);
  };
}
