{ lib, config, ... }:

let
  cfg = config.kor.development.neovim;
in
{
  options.kor.development.neovim.enable = lib.mkEnableOption "Neovim";

  config = lib.mkIf cfg.enable {
    # nixCats.enable = true;
    # nixCats.packageNames = [ "nixCats" "regularCats" ];
    programs.neovim = {
      # for compat and stuff
      enable = true;
      viAlias = true;
      vimAlias = true;
      withRuby = false;
      withPython3 = false;
      withNodeJs = false;
    };
    # programs.nvf = {
    #   enable = true;
    #   settings = {
    #     vim.package = pkgs.neovim-unwrapped;
    #     vim.viAlias = true;
    #     vim.vimAlias = true;
    #     vim.lsp = {
    #       enable = true;
    #     };
    #   };
    # };
  };
}
