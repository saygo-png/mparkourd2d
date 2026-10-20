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
    self,
    nixpkgs,
    systems,
    treefmt-nix,
    ...
  } @ inputs: let
    pkgsFor = nixpkgs.lib.genAttrs (import systems) (system: import nixpkgs {inherit system;});
    eachSystem = f: nixpkgs.lib.genAttrs (import systems) (system: f system pkgsFor.${system});
  in {
    # `nix run` serves the game on http://localhost:8000 (`nix run . -- PORT` for another port).
    packages = eachSystem (_system: pkgs: {
      default = pkgs.callPackage ./nix/package.nix {inherit (inputs) ghc-wasm-meta box2d3-wasm browser-wasi-shim;};
    });

    formatter = eachSystem (_system: pkgs: (treefmt-nix.lib.evalModule pkgs ./nix/treefmt.nix).config.build.wrapper);

    # For incremental builds: `web/build.sh`, then serve web/.
    devShells = eachSystem (system: pkgs: let
      game = self.packages.${system}.default;
    in {
      default = pkgs.mkShell {
        packages = game.toolchain;
        WEB_VENDOR = game.vendor;
      };
    });
  };
}
