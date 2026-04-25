{ pkgs
, lib
}:
# let
# in
(pkgs.vscode.override { isInsiders = true; }).overrideAttrs
  (oldAttrs: {
    src = (fetchTarball {
      url = "https://code.visualstudio.com/sha/download?build=insider&os=linux-x64";
      # sha256 = lib.fakeSha256;
      sha256 = "sha256:0ym11zspj2l2pmjfg6fnjk39kassnzk20mghrchndf7hblyzmx2l";
    });
    # src = inputs.vscode-insider.src;
    version = "25.04.26";

    buildInputs = oldAttrs.buildInputs ++ [ pkgs.krb5 pkgs.libsoup_3 pkgs.webkitgtk_4_1 ];
  })
