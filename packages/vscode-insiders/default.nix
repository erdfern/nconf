{ pkgs
, lib
}:
let
  meta = builtins.fromJSON (builtins.readFile ./meta.json);
in
(pkgs.vscode.override { isInsiders = true; }).overrideAttrs
  (oldAttrs: {
    src = (fetchTarball {
      url = meta.url;
      # sha256 = lib.fakeSha256;
      sha256 = meta.sha256;
    });
    # src = inputs.vscode-insider.src;
    version = meta.version;

    buildInputs = oldAttrs.buildInputs ++ [
      pkgs.krb5
      pkgs.libsoup_3
      pkgs.webkitgtk_4_1
      # Added for Copilot / computer.node dependencies
      pkgs.xorg.libXtst
      pkgs.libjpeg
      pkgs.pipewire
      pkgs.libei
    ];
  })
