{
  inputs = {
    treefmt-nix.url = "github:numtide/treefmt-nix";
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    niceHaskell = {
      url = "github:saygo-png/nice-nixpkgs-haskell";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        systems.follows = "systems";
        treefmt-nix.follows = "treefmt-nix";
      };
    };
    systems = {
      url = "path:./nix/systems.nix";
      flake = false;
    };
  };

  outputs = {
    nixpkgs,
    systems,
    niceHaskell,
    treefmt-nix,
    ...
  }: let
    pkgsFor = nixpkgs.lib.genAttrs (import systems) (system: import nixpkgs {inherit system;});
    eachSystem = f: nixpkgs.lib.genAttrs (import systems) (system: f system pkgsFor.${system});
  in {
    packages = eachSystem (system: pkgs: let
      program = pkgs.callPackage ./nix/package.nix {niceHaskell = niceHaskell.outputs.niceHaskell.${system};};
    in {
      "mparkour2d" = program;
      default = program;
    });

    formatter = eachSystem (_system: pkgs: (treefmt-nix.lib.evalModule pkgs ./nix/treefmt.nix).config.build.wrapper);

    devShells = eachSystem (_system: pkgs: {
      default = pkgs.mkShell {
        packages = let
          ghcPackages = pkgs.haskell.packages.ghc912;
        in [
          ghcPackages.ghc
          ghcPackages.cabal-install
          ghcPackages.haskell-language-server

          pkgs.pkg-config
          pkgs.zlib

          pkgs.libGL
          pkgs.libx11
          pkgs.libxinerama
          pkgs.libxcursor
          pkgs.libxrandr
          pkgs.libxi
          pkgs.libxext
        ];

      };
    });
  };
}
