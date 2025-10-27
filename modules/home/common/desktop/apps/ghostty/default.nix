{ lib, config, ... }:
let
  cfg = config.kor.desktop.apps.ghostty;
in
{
  options.kor.desktop.apps.ghostty = with lib; {
    enable = mkEnableOption "ghostty terminal";
  };

  config = {
    # enable systemd service, provided by ghostty package (~/.nix-profile/share/systemd/user/app-com.mitchellh.ghostty.service)
    systemd.user.services."ghosttyineeedyou" = {
      Unit = {
        Description = "Express a deep longing for the ghostty service.. will it heed my call?";
        # Documentation = [ "" ];
        After = [ "graphical-session.target" ];
        Requires = "app-com.mitchellh.ghostty.service";
      };
      Service = {
        SuccessAction = "none"; # noop. we love noops
      };
      Install.WantedBy = [ "graphical-session.target" ];
    };
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
