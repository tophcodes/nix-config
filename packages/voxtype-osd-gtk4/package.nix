{
  lib,
  pkgs,
  ...
}:
# The GTK4 on-screen display voxtype's `voxtype-osd` launcher execs into.
# llm-agents.nix ships the launcher and the daemon but not this frontend, so
# without it the OSD crash-loops and gives up: "preferred frontend
# 'voxtype-osd-gtk4' not installed".
#
# Version and src hash track the voxtype package in llm-agents.nix: the
# frontend speaks the daemon's protocol and the two are released together.
# Built with the unstable toolchain because the GTK4 dependency graph declares
# rust-version 1.92 and 25.11 ships 1.91.
pkgs.rustPlatformUnstable.buildRustPackage rec {
  pname = "voxtype-osd-gtk4";
  version = "0.7.5";

  src = pkgs.fetchFromGitHub {
    owner = "peteonrails";
    repo = "voxtype";
    tag = "v${version}";
    hash = "sha256-zsOG1mBTXN4gdsTb1pUPKXATfhV5ZjgEsIUk07asaGo=";
  };

  # Upstream's lock, vendored rather than `cargoHash`: the vendor fetcher that
  # backs cargoHash sends no User-Agent, and crates.io answers those with 403.
  # Refresh alongside `version` from the matching upstream tag.
  cargoLock.lockFile = ./Cargo.lock;

  nativeBuildInputs = with pkgs; [
    cmake
    pkg-config
    clang
    git # whisper.cpp cmake invokes git
    wrapGAppsHook4
  ];

  buildInputs = with pkgs; [
    alsa-lib
    openssl
    gtk4-layer-shell
  ];

  # whisper-rs runs bindgen against whisper.cpp headers.
  env.LIBCLANG_PATH = "${pkgs.llvmPackages.libclang.lib}/lib";

  buildFeatures = ["osd-gtk4"];
  cargoBuildFlags = ["--bin" "voxtype-osd-gtk4"];

  # The workspace test suite needs audio hardware and downloaded models; this
  # package builds one binary out of it.
  doCheck = false;

  meta = {
    description = "GTK4 on-screen display frontend for voxtype";
    homepage = "https://voxtype.io";
    license = lib.licenses.mit;
    platforms = ["x86_64-linux" "aarch64-linux"];
    mainProgram = "voxtype-osd-gtk4";
  };
}
