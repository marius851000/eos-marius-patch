{ pkgs ? import <nixpkgs> {}}:

let
  make_simple_patch = name: source: pkgs.stdenv.mkDerivation {
    inherit name;

    dontUnpack = true;

    buildInputs = [ pkgs.zip ];

    buildPhase = ''
      mkdir -p tmp/asm_patches
      ln -s ${source}/*.asm tmp/asm_patches
      ln -s ${source}/*.py ${source}/*.xml tmp
      if [[ ! -f tmp/asm_patches/header_stub_eu.asm ]]
      then
        touch tmp/asm_patches/header_stub_eu.asm
      fi
      if [[ ! -f tmp/asm_patches/header_stub_na.asm ]]
      then
        touch tmp/asm_patches/header_stub_na.asm
      fi
    '';

    installPhase = ''
      pushd tmp
      zip -rv tmp.zip .
      mv tmp.zip $out
      popd
    '';
  };

  make_patches_folder = patches: pkgs.stdenv.mkDerivation {
    name = "cotpatches";

    dontUnpack = true;

    installPhase = ''
      mkdir -p $out
    '' + (
      pkgs.lib.concatStringsSep
      "\n"
      (pkgs.lib.forEach patches (patch: "cp --reflink=auto ${patch} $out/${patch.name}.skypatch"))
    );
  };

  patches = [
    (make_simple_patch "faster_flush_mode_4" ./patches/faster_flush_mode_4)
    (make_simple_patch "snd_stream" (pkgs.stdenv.mkDerivation {
      name = "snd_stream_patch_source";
      dontUnpack = true;

      installPhase = ''
        mkdir -p $out
        cp ${./patches/snd_stream/patch.py} $out/patch.py
        cp ${./patches/snd_stream/config.xml} $out/config.xml
        cp ${./patches/snd_stream/new_snd_stream_official_v2_looppoint_fix_eu.asm} $out/sndstream_eu.asm
        cp ${./patches/snd_stream/new_snd_stream_official_v2_looppoint_fix.asm} $out/sndstream_na.asm
      '';
    }))
  ];
in
  make_patches_folder patches