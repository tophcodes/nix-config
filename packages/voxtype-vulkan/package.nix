{
  lib,
  pkgs,
  ...
}:
# voxtype with whisper.cpp on the GPU via Vulkan. llm-agents.nix packages only
# the CPU build, which is what makes dictation slow and pins the CPU.
#
# Vulkan rather than the ROCm/hipBLAS variant: vendor-neutral, a far smaller
# build, and the RADV driver already carries this machine's GPU. ROCm is the
# next step if this is not fast enough, not a prerequisite.
#
# Whisper stays the engine, so multilingual transcription is kept — the ONNX
# engines are faster still but Parakeet is English-only.
pkgs.rustPlatformUnstable.buildRustPackage rec {
  pname = "voxtype-vulkan";
  version = "0.7.5";

  src = pkgs.fetchFromGitHub {
    owner = "peteonrails";
    repo = "voxtype";
    tag = "v${version}";
    hash = "sha256-zsOG1mBTXN4gdsTb1pUPKXATfhV5ZjgEsIUk07asaGo=";
  };

  # Same source and tag as voxtype-osd-gtk4, so the lock is shared rather than
  # duplicated. Both move together when `version` does.
  cargoLock.lockFile = ../voxtype-osd-gtk4/Cargo.lock;

  nativeBuildInputs = with pkgs; [
    cmake
    pkg-config
    clang
    git # whisper.cpp cmake invokes git
    makeWrapper
    shaderc
    vulkan-headers
    vulkan-loader
  ];

  buildInputs = with pkgs; [
    alsa-lib
    openssl
    vulkan-headers
    vulkan-loader
  ];

  # whisper-rs runs bindgen against whisper.cpp headers.
  env.LIBCLANG_PATH = "${pkgs.llvmPackages.libclang.lib}/lib";

  buildFeatures = ["gpu-vulkan"];

  preBuild = ''
    export CMAKE_BUILD_PARALLEL_LEVEL=$NIX_BUILD_CORES
    export VULKAN_SDK="${pkgs.vulkan-loader}"
    export Vulkan_INCLUDE_DIR="${pkgs.vulkan-headers}/include"
    export Vulkan_LIBRARY="${pkgs.vulkan-loader}/lib/libvulkan.so"
  '';

  # Audio tests need hardware and downloaded models.
  doCheck = false;

  postInstall = ''
    install -Dm644 packaging/completions/voxtype.bash \
      $out/share/bash-completion/completions/voxtype
    install -Dm644 packaging/completions/voxtype.zsh \
      $out/share/zsh/site-functions/_voxtype
    install -Dm644 packaging/completions/voxtype.fish \
      $out/share/fish/vendor_completions.d/voxtype.fish

    install -Dm644 config/default.toml \
      $out/share/voxtype/default-config.toml

    # The typing and clipboard backends are resolved at runtime off PATH, so
    # they are wrapped in rather than left to the caller's environment.
    wrapProgram $out/bin/voxtype \
      --prefix PATH : ${
      lib.makeBinPath (with pkgs; [
        wtype
        dotool
        wl-clipboard
        ydotool
        xdotool
        xclip
        libnotify
        pciutils
      ])
    } \
      --prefix LD_LIBRARY_PATH : ${lib.makeLibraryPath [pkgs.vulkan-loader]}
  '';

  meta = {
    description = "Push-to-talk voice-to-text for Wayland, Vulkan-accelerated";
    homepage = "https://voxtype.io";
    license = lib.licenses.mit;
    platforms = ["x86_64-linux" "aarch64-linux"];
    mainProgram = "voxtype";
  };
}
