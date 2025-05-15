{ lib
, fetchurl
, runCommand
, makeWrapper
  # deps
, bash
}:
let
  src = fetchurl {
    url = "https://raw.githubusercontent.com/Vladimir-csp/app2unit/7b9672a2dc16bdfbe7b7b7c27043529ca3bcb6ae/app2unit";
    sha256 = "sha256-kYF3wzIcBOhxvNLE8AzI1VPQgJOfjh2qJQfmZqLG0Ss=";
    # executable = true;
    # sha256 = "sha256-2PNk/G+5AfeFZm+7B8GkM9EhgyPw5A9U0hUblvsxdM8=";
  };
  binName = "app2unit";
  deps = [ bash ];
in
# writeShellScriptBin "app2unit" builtins.trace src src
runCommand binName
{
  nativeBuildInputs = [ makeWrapper ];
  meta.mainProgram = binName;
}
  ''
    mkdir -p $out/bin
    install -m +x ${src} $out/bin/${binName}

    wrapProgram $out/bin/${binName} \
      --prefix PATH : ${lib.makeBinPath deps}
  ''
