{ lib
, rustPlatform
, fetchFromGitHub
, makeWrapper
  # runtime dependencies
  # , nix
, # for nix-prefetch-url
  nix-prefetch-git
, git
, # for git ls-remote
}:

let
  runtimePath = lib.makeBinPath [
    # nix
    nix-prefetch-git
    git
  ];
in
rustPlatform.buildRustPackage rec {
  pname = "npins";
  version = "0.3.1+rev=${lib.substring 0 7 src.rev}-git";

  src = fetchFromGitHub {
    owner = "andir";
    repo = "npins";
    rev = "afa9fe50cb0bff9ba7e9f7796892f71722b2180d";
    hash = "sha256-D6dYAMk9eYpBriE07s8Q7M3WBT7uM9pz3RKIoNk+h7I=";
  };

  cargoHash = "sha256-dBMY5L9xzq3czs5fGHFXNqzQQvHO3+c6WRY8tVvIz20=";

  buildNoDefaultFeatures = true;
  buildFeatures = [
    "clap"
    "crossterm"
    "env_logger"
  ];

  nativeBuildInputs = [ makeWrapper ];

  # (Almost) all tests require internet
  doCheck = false;

  postFixup = ''
    wrapProgram $out/bin/npins --prefix PATH : "${runtimePath}"
  '';

  meta = with lib; {
    description = "Simple and convenient dependency pinning for Nix";
    mainProgram = "npins";
    homepage = "https://github.com/andir/npins";
    license = licenses.eupl12;
    maintainers = with maintainers; [ piegames ];
  };
}
