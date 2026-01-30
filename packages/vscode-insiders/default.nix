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
      sha256 = "sha256-YbWlrSABmVwBd9aVrna7yynCuz7v8luhVGgMnvpQDPo=";
    });
    # src = inputs.vscode-insider.src;
    version = "01.30.26";

    buildInputs = oldAttrs.buildInputs ++ [ pkgs.krb5 pkgs.libsoup_3 pkgs.webkitgtk_4_1 ];
  })
