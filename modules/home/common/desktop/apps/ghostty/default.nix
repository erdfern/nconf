{ lib, config, ... }:
let
  cfg = config.kor.desktop.apps.ghostty;
in
{
  options.kor.desktop.apps.ghostty = with lib; {
    enable = mkEnableOption "ghostty terminal";
  };

  config = {
    programs = lib.mkIf cfg.enable {
      ghostty = {
        enable = cfg.enable;
        # installVimSyntax = true;
        installBatSyntax = true;
        settings = {
          keybind = [
            "global:ctrl+grave_accent=toggle_quick_terminal"
          ];
        };
      };
    };
  };
}
