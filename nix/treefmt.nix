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
