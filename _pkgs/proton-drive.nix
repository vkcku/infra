{
  lib,
  stdenv,
  fetchurl,
  makeWrapper,
}:
let
  version = "0.8.0";

  # The source is available for this and it can be built from source, but
  # there were some random issues in the build setup that I was too lazy to
  # debug and fix.
  #
  # TODO: Build from source.

  proton-drive = stdenv.mkDerivation {
    inherit version;
    pname = "proton-drive";

    src = fetchurl {
      url = "https://proton.me/download/drive/cli/${version}/linux-x64/proton-drive";
      hash = "sha256-lEPXcXGciSeQ2xfm8C7Nma18U1kzKfOmfHdnfc5XdzU=";
    };

    nativeBuildInputs = [
      makeWrapper
    ];

    dontUnpack = true;

    installPhase = ''
      runHook preInstall

      checksum="cf61c2688c45e1055d8add6221d9471a5a5b64bf3bcdb86460f5cb18414596cc4df3cdb6627c9097c94bec32a3c9915ada3211ef2ae5be33c46ebbc996ccaa28"
      echo "$checksum  $src" | sha512sum -c -

      # Invoke via the dynamic loader instead of patching the binary, keeping
      # the appended Bun payload byte-for-byte intact. If the binary is
      # patched, then bun is no longer able to find the embedded application
      # due to the offsets changing.
      makeWrapper \
        "${stdenv.cc.bintools.dynamicLinker}" \
        "$out/bin/proton-drive" \
        --add-flags "$src"

      runHook postInstall
    '';

    meta = {
      description = "Proton Drive command-line interface";
      homepage = "https://proton.me/drive";
      license = lib.licenses.mit;
      sourceProvenance = [ lib.sourceTypes.binaryNativeCode ];
      platforms = [ "x86_64-linux" ];
      mainProgram = "proton-drive";
    };
  };
in
proton-drive
