{ fetchurl
, writeShellScriptBin
}:
let
  src = fetchurl {
    url = "https://raw.githubusercontent.com/Vladimir-csp/app2unit/42613bd4c69cd5720114679a52b73b8b5d947678/app2unit";
    sha256 = "sha256-kYF3wzIcBOhxvNLE8AzI1VPQgJOfjh2qJQfmZqLG0Ss=";
  };
in
writeShellScriptBin "app2unit" src
