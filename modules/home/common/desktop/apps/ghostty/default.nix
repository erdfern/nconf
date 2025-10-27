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
      # enable systemd service, provided by ghostty package (~/.nix-profile/share/systemd/user/app-com.mitchellh.ghostty.service)
      systemd.user.services."ghosttyineeedyou" = {
        Unit = {
          Description = "Express a deep longing for the ghostty service.. will it heed my call?";
          # Documentation = [ "" ];
          After = [ "graphical-session.target" ];
          Requires = "app-com.mitchellh.ghostty.service";
        };
        Install.WantedBy = [ "graphical-session.target" ];
      };
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
