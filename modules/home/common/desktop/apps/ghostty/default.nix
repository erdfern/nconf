{ lib, config, ... }:
let
  cfg = config.kor.desktop.apps.kitty;
in
{
  options.kor.desktop.apps.kitty = with lib; {
    enable = mkEnableOption "kitty terminal";
    makeFishAliases = mkOption { type = lib.types.bool; default = config.programs.fish.enable; };
  };

  config = {
    programs = lib.mkIf cfg.enable {
      ghostty = {
        enable = cfg.enable;
        # installVimSyntax = true;
        installBatSyntax = true;
      };
      # fish.shellAliases = lib.mkIf cfg.makeFishAliases {
      #   s = "kitten ssh";
      # };
    };

  };
}
