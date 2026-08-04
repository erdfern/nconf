{ pkgs
, lib
}:
let
  meta = builtins.fromJSON (builtins.readFile ./meta.json);
in
(pkgs.vscode.override { isInsiders = true; }).overrideAttrs
  (oldAttrs: {
    version = meta.productVersion;

    # Commit-pinned, immutable download; the hex sha256 comes straight from
    # https://update.code.visualstudio.com/api/update/linux-x64/insider/latest
    # (refresh with the `update-vscode-insiders` command).
    src = pkgs.fetchurl {
      # name must end in .tar.gz so unpackCmd recognizes the format (the URL basename is "insider")
      name = "VSCode_${meta.productVersion}_linux-x64.tar.gz";
      url = "https://update.code.visualstudio.com/commit:${meta.commit}/linux-x64/insider";
      sha256 = meta.sha256;
    };

    buildInputs = oldAttrs.buildInputs ++ [
      pkgs.krb5
      pkgs.libsoup_3
      pkgs.webkitgtk_4_1
      # Added for Copilot / computer.node dependencies
      pkgs.libxtst
      pkgs.libjpeg8
      pkgs.pipewire
      pkgs.libei
    ];
  })
