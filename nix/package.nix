# The game compiled to wasm with ghc-wasm-meta's GHC, bundled with the JS
# libraries the page loads. `bin/mparkour2d` serves it on localhost.
{
  lib,
  callPackage,
  stdenvNoCC,
  runCommand,
  srcOnly,
  haskell,
  makeWrapper,
  nodejs,
  python3,
  ghc-wasm-meta,
  box2d3-wasm,
  browser-wasi-shim,
}: let
  # node runs GHC's post-linker (post-link.mjs).
  toolchain =
    [nodejs]
    ++ map (p: callPackage "${ghc-wasm-meta}/pkgs/${p}.nix" {flavour = "9.12";}) [
      "wasm32-wasi-ghc"
      "wasm32-wasi-cabal"
    ];

  # The JS libraries web/index.html and Web.Physics import from ./vendor.
  vendor = runCommand "mparkour2d-js-vendor" {} ''
    mkdir -p $out/box2d3-wasm $out/browser_wasi_shim
    cp ${box2d3-wasm}/build/dist/es/compat/*.{mjs,wasm} $out/box2d3-wasm
    cp ${browser-wasi-shim}/dist/*.js $out/browser_wasi_shim
  '';

  # Sources of the Hackage dependencies at the versions nixpkgs pins (with its
  # revisions and patches), as a local repository for cabal. The roots are the
  # non-boot build-depends of mparkour2d.cabal, plus what only wasm32 needs:
  # nixpkgs resolves the closure for 64-bit, where tasty (pulled in by
  # vector's benchmark library) doesn't need unbounded-delays.
  hackage = let
    hp = haskell.packages.ghc912;
    roots = [hp.lens hp.linear hp.relude hp.unbounded-delays];
    closure = lib.filter (d: d != null && d ? pname) (lib.closePropagation roots);
    # Unpacking and patching needs no Haskell library inputs; dropping them
    # avoids building native dependencies just to get at the sources.
    source = d:
      srcOnly (d.overrideAttrs {
        buildInputs = [];
        propagatedBuildInputs = [];
      });
  in
    runCommand "mparkour2d-hackage" {} ''
      mkdir $out
      ${lib.concatMapStrings (d: ''
          tar czf $out/${d.name}.tar.gz --transform 's,^\.,${d.name},' -C ${source d} .
        '')
        closure}
    '';
in
  stdenvNoCC.mkDerivation {
    name = "mparkour2d-web";
    src = lib.fileset.toSource {
      root = ../.;
      fileset = lib.fileset.unions [../cabal.project ../mparkour2d.cabal ../src ../web];
    };
    nativeBuildInputs = toolchain ++ [makeWrapper];
    WEB_VENDOR = vendor;
    buildPhase = ''
      export HOME=$TMPDIR CABAL_DIR=$TMPDIR/cabal
      cp -r --no-preserve=mode ${hackage} $TMPDIR/hackage
      # ghc-wasm-meta's cabal config, with the local repository instead of Hackage.
      mkdir $CABAL_DIR
      sed '/^repository/,/^$/d' ${ghc-wasm-meta}/cabal.th.config > $CABAL_DIR/config
      cat >> $CABAL_DIR/config <<EOF
      repository nixpkgs
        url: file+noindex://$TMPDIR/hackage
      EOF
      printf 'optimization: True\ndocumentation: False\n' > cabal.project.local
      patchShebangs web/build.sh
      web/build.sh
    '';
    installPhase = ''
      mkdir -p $out/bin $out/share
      rm web/build.sh
      cp -r web $out/share/mparkour2d
      makeWrapper ${lib.getExe python3} $out/bin/mparkour2d \
        --add-flags "-m http.server --bind 127.0.0.1 --directory $out/share/mparkour2d"
    '';
    passthru = {inherit toolchain vendor;};
    meta.mainProgram = "mparkour2d";
  }
