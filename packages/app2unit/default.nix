{ fetchurl
, writeShellScriptBin
}:
let
  src = fetchurl {
    url = "https://raw.githubusercontent.com/Vladimir-csp/app2unit/refs/heads/master/app2unit";
    sha256 = "sha256-L2N3saNeJDdji/IzC2Zi0Iixc/pPNSUpz07egywx+4U=";
  };
in
writeShellScriptBin "app2unit" src
