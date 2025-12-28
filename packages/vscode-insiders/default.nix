{ pkgs
, inputs
}:
(pkgs.vscode.override { isInsiders = true; }).overrideAttrs
  (oldAttrs: {
    # src = (builtins.fetchTarball {
    #   url = "https://code.visualstudio.com/sha/download?build=insider&os=linux-x64";
    #   # sha256 = "sha256-L0UEE7pEA05cMj7SCmWqtvfRcW+BZshmVx2shLw9Gvg=";
    #   sha256 = "sha256-aVtO1HyUD332wfPrshmsmCKKaGME2W0XMcXQMYzeuBg=";
    # });
    src = inputs.vscode-insider.src;
    version = "latest";

    buildInputs = oldAttrs.buildInputs ++ [ pkgs.krb5 pkgs.libsoup_3 pkgs.webkitgtk_4_1 ];
  })
