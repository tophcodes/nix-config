{
  lib,
  pkgs,
  ...
}:
# Diversion's CLI is distributed as a single statically linked Go binary, so it
# needs no patching, only fetching and installing.
#
# The upstream URL carries no version: it always serves the current build, and
# `version` below is what that build reported. The hash is therefore the only
# pin, and a release upstream breaks the build with a hash mismatch rather than
# silently swapping the binary. Bump both together when that happens.
#
# The vendor's installer additionally appends to shell profiles and registers a
# launchd agent; neither applies here: PATH comes from the profile and the
# Linux installer registers no service at all.
pkgs.stdenvNoCC.mkDerivation {
  pname = "diversion";
  version = "1.0.1017";

  src = pkgs.fetchurl {
    url = "https://dv-binaries.s3.us-east-2.amazonaws.com/linux_x86_64/dv";
    hash = "sha256-GRyj4Mc3hvXXqKVOwGnZxnyqU6LZ688tiLES/nXc7R8=";
  };

  dontUnpack = true;

  installPhase = ''
    runHook preInstall
    install -Dm755 "$src" "$out/bin/dv"
    runHook postInstall
  '';

  meta = {
    description = "CLI for Diversion, a cloud-native version control system for game and content projects";
    homepage = "https://www.diversion.dev";
    license = lib.licenses.unfree;
    sourceProvenance = [lib.sourceTypes.binaryNativeCode];
    platforms = ["x86_64-linux"];
    mainProgram = "dv";
  };
}
