{
  pkgs,
  lib,
  ...
}: {
  projectRootFile = "flake.nix";

  programs.alejandra.enable = true;
  programs.deadnix.enable = true;
  programs.statix.enable = true;
  programs.fourmolu = {
    enable = true;
    # The statically linked build; haskellPackages.fourmolu pulls in a whole GHC.
    package = pkgs.fourmolu;
  };
  programs.cabal-fmt.enable = true;

  settings.formatter = {
    fourmolu = {
      options = [
        "--indentation"
        "2"

        "--respectful"
        "false"

        "--indent-wheres"
        "true"
      ];
      # fourmolu's parser (ghc-lib-parser 9.12.3) rejects the multiline JS
      # strings in these modules' foreign imports, though GHC accepts them.
      excludes = ["web-game/src/Web/Box2D.hs" "web-game/src/Web/Canvas.hs" "web-game/src/Web/Input.hs"];
    };

    trim-newlines = {
      command = "${lib.getExe pkgs.gnused}";
      options =
        lib.strings.splitString " "
        '':a; /^\s*$/ { $d; N; ba }'';
      includes = ["*"];
    };
  };
}
