{ pkgs, lib, config, ... }:

let
  cfg = config.kor.development.vscode;
in
{
  options.kor.development.vscode.enable = lib.mkEnableOption "Visual Studio Code";

  config = lib.mkIf cfg.enable {
    home.packages = [
      ((pkgs.vscode.override { isInsiders = true; }).overrideAttrs
        (oldAttrs: {
          src = (builtins.fetchTarball {
            url = "https://code.visualstudio.com/sha/download?build=insider&os=linux-x64";
            sha256 = lib.fakeSha256;
          });
          version = "latest";

          buildInputs = oldAttrs.buildInputs ++ [ pkgs.krb5 ];
        }))
    ];
    # programs.vscode = {
    #   enable = true;
    #   # package = pkgs.vscode.fhs; # vscode.fhsWithPackages (ps: with ps; [ rustup zlib openssl.dev pkg-config ]);

    #   profiles.default.enableUpdateCheck = false;
    #   profiles.default.enableExtensionUpdateCheck = false;
    #   profiles.default.userSettings = {
    #     # General
    #     "extensions.autoUpdate" = false;
    #     "explorer.confirmDelete" = false;
    #     "terminal.integrated.minimumContrastRatio" = 1;
    #     "security.promptForLocalFileProtocolHandling" = false;
    #     # TS
    #     "[typescript]" = {
    #       "editor.defaultFormatter" = "esbenp.prettier-vscode";
    #     };
    #     # Svelte
    #     "svelte.enable-ts-plugin" = true;
    #     # Neovim
    #     "extensions.experimental.affinity" = {
    #       "asvetliakov.vscode-neovim" = 1;
    #     };
    #     "vscode-neovim.neovimExecutablePaths.linux" = "${config.nixCats.out.packages.nixCats}/bin/nixCats";
    #     # "vscode-neovim.neovimExecutablePaths.linux" = "${config.nixCats.out.packages.regularCats}/bin/testCat";
    #   };
    #   profiles.default.extensions = with pkgs.vscode-extensions; [
    #     # vscodevim.vim
    #     asvetliakov.vscode-neovim
    #     yzhang.markdown-all-in-one

    #     christian-kohler.path-intellisense
    #     aaron-bond.better-comments

    #     esbenp.prettier-vscode
    #     svelte.svelte-vscode
    #     bradlc.vscode-tailwindcss
    #     # quentiumyt.vscode-tailwindcss-directives
    #     # ritwickdey.liveserver
    #     #


    #     mikestead.dotenv
    #   ];
    # };
  };
}
