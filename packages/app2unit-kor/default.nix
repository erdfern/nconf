{ lib
, stdenvNoCC
, dash
, scdoc
, fetchFromGitHub
, nix-update-script
, installShellFiles
,
}:
stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "app2unit";
  # version = "1.1.2";
  version = "git";

  src = fetchFromGitHub {
    owner = "Vladimir-csp";
    repo = "app2unit";
    rev = "83e2656fb8d39ad71e2f8a5ba113a9cedc90841f";
    sha256 = "sha256-DZ0W7SygOUmjIO0+K8hS9K1U+gSp1gA6Q15eXr6rOmo=";
    # tag = "v${finalAttrs.version}";
    # sha256 = "sha256-M2sitlrQNSLthSaDH+R8gUcZ8i+o1ktf2SB/vvjyJEI=";
  };

  passthru.updateScript = nix-update-script { };

  nativeBuildInputs = [
    scdoc
    installShellFiles
  ];

  buildPhase = ''
    scdoc < app2unit.1.scd > app2unit.1
  '';

  installPhase = ''
    install -Dt $out/bin app2unit
    installManPage app2unit.1

    for link in \
      app2unit-open \
      app2unit-open-scope \
      app2unit-open-service \
      app2unit-term \
      app2unit-term-scope \
      app2unit-term-service
    do
      ln -s $out/bin/app2unit $out/bin/$link
    done
  '';

  dontPatchShebangs = true;
  postFixup = ''
    substituteInPlace $out/bin/app2unit \
      --replace-fail '#!/bin/sh' '#!${lib.getExe dash}'
  '';

  meta = {
    description = "Launches Desktop Entries as Systemd user units";
    homepage = "https://github.com/Vladimir-csp/app2unit";
    license = lib.licenses.gpl3;
    mainProgram = "app2unit";
    maintainers = with lib.maintainers; [ fazzi ];
    platforms = lib.platforms.linux;
  };
})
