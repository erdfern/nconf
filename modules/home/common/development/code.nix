{ pkgs, lib, config, inputs, ... }:

let
  cfg = config.kor.development.vscode;
in
{
  options.kor.development.vscode.enable = lib.mkEnableOption "Visual Studio Code";

  config = lib.mkIf cfg.enable {
    home.packages = [
      # pkgs.vscode-insiders
      inputs.code-insiders-flake.result.packages.x86_64-linux.vscode-insiders
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
