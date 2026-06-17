{
  pkgs ? import <nixpkgs> {
    config.allowUnfree = true;
  },
  androidSdkPath ? "${builtins.getEnv "HOME"}/Android/Sdk",
}:

pkgs.mkShell {
  ANDROID_HOME = androidSdkPath;

  packages = with pkgs; [
    # Flutter
    flutter

    # Android
    android-studio
    android-tools
    jdk17

    # Python
    python312
    python312Packages.venvShellHook

    (python312.withPackages (
      pkgs: with pkgs; [
        ruff
        black
      ]
    ))

    # Native deps
    pkg-config
    openssl
    libffi

    # Tools
    curl
    jq
    httpie
    bruno
  ];

  venvDir = "server/.venv";

  postShellHook = ''
    export JAVA_HOME=${pkgs.jdk17}

    export PATH=$ANDROID_HOME/emulator:$PATH
    export PATH=$ANDROID_HOME/platform-tools:$PATH
    export PATH=$ANDROID_HOME/cmdline-tools/latest/bin:$PATH

    export LD_LIBRARY_PATH=${
      pkgs.lib.makeLibraryPath [
        pkgs.openssl
        pkgs.libffi
      ]
    }
  '';

  postVenvCreation = ''
    python -m ensurepip --default-pip
    pip install -r server/requirements.txt ruff mypy black pytest
  '';
}
