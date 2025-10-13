{ fetchFromGitHub
, lib
, stdenv
, makeBinaryWrapper
, installShellFiles
, rustPlatform
, cachix
, gitMinimal
, openssl
, dbus
, protobuf
, pkg-config
, glibcLocalesUtf8
, nixVersions
}:
let
  version = "1.10";
  devenvNixVersion = "2.30.4";

  devenv-nix =
    (nixVersions.git.overrideSource (fetchFromGitHub {
      owner = "cachix";
      repo = "nix";
      rev = "devenv-${devenvNixVersion}";
      hash = "sha256-3+GHIYGg4U9XKUN4rg473frIVNn8YD06bjwxKS1IPrU=";
    })).overrideAttrs
      (old: {
        pname = "devenv-nix";
        version = devenvNixVersion;
        doCheck = false;
        doInstallCheck = false;
        # do override src, but the Nix way so the warning is unaware of it
        __intentionallyOverridingVersion = true;
      });
  cargoHash = "sha256-Wt47YdBEtFXQACk1ByDwQyXzHU4/nGVQKY7gaZeQrQ4=";
  src = fetchFromGitHub {
    owner = "cachix";
    repo = "devenv";
    tag = "v${version}";
    # hash = "sha256-v86pQGIWHJPkRryglJSXOp0aEoU6ZtURuURsXLqfqSE=";
    hash = "sha256-rsb+6Wca43guzLL4Czoc89L394ZW9JZF2MShxaz2Sx4=";
  };
in
rustPlatform.buildRustPackage {
  pname = "devenv";
  inherit src version cargoHash;

  cargoBuildFlags = [ "-p devenv -p devenv-run-tests" ];

  nativeBuildInputs = [
    installShellFiles
    makeBinaryWrapper
    pkg-config
    protobuf
  ];

  buildInputs = [
    openssl
  ]
  # secretspec
  ++ lib.optional (stdenv.isLinux) dbus;

  postConfigure = ''
    # Create proto directory structure that snix expects
    pushd "$NIX_BUILD_TOP/cargo-vendor-dir"
    mkdir -p snix/{castore,store,build}/protos

    # Link proto files to the expected locations
    [ -d snix-castore-*/protos ] && cp snix-castore-*/protos/*.proto snix/castore/protos/ 2>/dev/null || true
    [ -d snix-store-*/protos ] && cp snix-store-*/protos/*.proto snix/store/protos/ 2>/dev/null || true
    [ -d snix-build-*/protos ] && cp snix-build-*/protos/*.proto snix/build/protos/ 2>/dev/null || true

    popd
  '';

  preBuild = ''
    # Fix proto files for snix dependencies
    export PROTO_ROOT="$NIX_BUILD_TOP/cargo-vendor-dir"
  '';

  nativeCheckInputs = [ gitMinimal ];
  preCheck = ''
    # Initialize git repo for tests that use git-root-relative imports
    pushd $NIX_BUILD_TOP/source
    git init -b main
    git add -A
    popd
  '';

  postInstall =
    let
      setDefaultLocaleArchive = lib.optionalString (glibcLocalesUtf8 != null) ''
        --set-default LOCALE_ARCHIVE ${glibcLocalesUtf8}/lib/locale/locale-archive
      '';
    in
    ''
      wrapProgram $out/bin/devenv \
        --prefix PATH ":" "$out/bin:${lib.getBin cachix}/bin" \
        --set DEVENV_NIX ${devenv-nix} \
        ${setDefaultLocaleArchive} \

      # TODO: problematic for our library...
      wrapProgram $out/bin/devenv-run-tests \
        --prefix PATH ":" "$out/bin:${lib.getBin cachix}/bin" \
        --set DEVENV_NIX ${devenv-nix} \
        ${setDefaultLocaleArchive} \

      # Generate manpages
      cargo xtask generate-manpages --out-dir man
      installManPage man/*

      # Generate shell completions
      compdir=./completions
      for shell in bash fish zsh; do
        cargo xtask generate-shell-completion $shell --out-dir $compdir
      done

      installShellCompletion --cmd devenv \
        --bash $compdir/devenv.bash \
        --fish $compdir/devenv.fish \
        --zsh $compdir/_devenv
    '';
}

# 
# { lib
# , fetchFromGitHub
# , makeBinaryWrapper
# , installShellFiles
# , rustPlatform
# , testers
# , cachix
# , nixVersions
# , openssl
# , dbus
# , pkg-config
# , glibcLocalesUtf8
# , devenv
# , # required to run version test
# }:

# let
#   version = "1.10";
#   devenvNixVersion = "2.30.4";

#   devenv_nix =
#     (nixVersions.git.overrideSource (fetchFromGitHub {
#       owner = "cachix";
#       repo = "nix";
#       rev = "devenv-${devenvNixVersion}";
#       hash = "sha256-3+GHIYGg4U9XKUN4rg473frIVNn8YD06bjwxKS1IPrU=";
#     })).overrideAttrs
#       (old: {
#         pname = "devenv-nix";
#         version = devenvNixVersion;
#         doCheck = false;
#         doInstallCheck = false;
#         # do override src, but the Nix way so the warning is unaware of it
#         __intentionallyOverridingVersion = true;
#       });
# in
# rustPlatform.buildRustPackage {
#   pname = "devenv";
#   inherit version;

#   src = fetchFromGitHub {
#     owner = "cachix";
#     repo = "devenv";
#     tag = "v${version}";
#     # hash = "sha256-v86pQGIWHJPkRryglJSXOp0aEoU6ZtURuURsXLqfqSE=";
#     hash = "sha256-rsb+6Wca43guzLL4Czoc89L394ZW9JZF2MShxaz2Sx4=";
#   };

#   # cargoHash = "sha256-41VmzZvoRd2pL5/o6apHztpS2XrL4HGPIJPBkUbPL1I=";
#   cargoHash = "sha256-Wt47YdBEtFXQACk1ByDwQyXzHU4/nGVQKY7gaZeQrQ4=";

#   buildAndTestSubdir = "devenv";

#   nativeBuildInputs = [
#     installShellFiles
#     makeBinaryWrapper
#     pkg-config
#   ];

#   buildInputs = [
#     openssl
#     dbus
#   ];

#   postInstall =
#     let
#       setDefaultLocaleArchive = lib.optionalString (glibcLocalesUtf8 != null) ''
#         --set-default LOCALE_ARCHIVE ${glibcLocalesUtf8}/lib/locale/locale-archive
#       '';
#     in
#     ''
#       wrapProgram $out/bin/devenv \
#         --prefix PATH ":" "$out/bin:${cachix}/bin" \
#         --set DEVENV_NIX ${devenv_nix} \
#         ${setDefaultLocaleArchive}

#       # Generate manpages
#       cargo xtask generate-manpages --out-dir man
#       installManPage man/*

#       # Generate shell completions
#       compdir=./completions
#       for shell in bash fish zsh; do
#         cargo xtask generate-shell-completion $shell --out-dir $compdir
#       done

#       installShellCompletion --cmd devenv \
#         --bash $compdir/devenv.bash \
#         --fish $compdir/devenv.fish \
#         --zsh $compdir/_devenv
#     '';

# passthru.tests = {
#   version = testers.testVersion {
#     package = devenv;
#     command = "export XDG_DATA_HOME=$PWD; devenv version";
#   };
# };

#   meta = {
#     changelog = "https://github.com/cachix/devenv/releases/tag/v${version}";
#     description = "Fast, Declarative, Reproducible, and Composable Developer Environments";
#     homepage = "https://github.com/cachix/devenv";
#     license = lib.licenses.asl20;
#     mainProgram = "devenv";
#     teams = [ lib.teams.cachix ];
#   };
# }
