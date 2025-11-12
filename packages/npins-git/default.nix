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
    rev = "f4e3698681704e74196fa0f905c7dfdd43cf5c86";
    hash = lib.fakeHash;
  };

  cargoHash = lib.fakeHash;

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
