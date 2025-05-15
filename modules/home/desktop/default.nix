{ lib
, config
, pkgs
, inputs
, ...
}:
let
  cfg = config.kor.preset.desktop;
in
{
  imports = [
    ./apps
    ./hyprland
    ./gtk.nix
    ./suites
  ];

  options.kor.preset.desktop = with lib; {
    enable = mkEnableOption "desktop preset";
    enableHyprland = mkEnableOption "Hyprland compositor";
    # TODO check format and automatically prepend "export"
    uwsmEnv = mkOption {
      type = types.listOf types.lines;
      default = [ ];
      description = "List of environment variables to export in ~/.config/uwsm/env. Format is \"export <VAR>=<value>\"";
    };
  };

  config = lib.mkIf (cfg.enable || cfg.enableHyprland) {
    programs.starship.enable = true;

    kor.desktop.hyprland.enable = lib.mkIf cfg.enableHyprland true; # mkIf so it could be set elswhere without conflict

    home.file."${config.xdg.configHome}/uwsm/TESTenv".text = lib.mkIf (cfg.uwsmEnv != [ ]) lib.strings.concatLines cfg.uwsmEnv;

    catppuccin.mako.enable = false; # until they stop using mako.extraConfig
    services.mako = {
      enable = true; # NOTE conflicts with hyprpanel/ags notif service
      # font = "Iosevka Nerd Font 12";
      # backgroundColor = "#3A4353";
      # borderColor = "#c0caf5";
      # progressColor = "over #3B4252";
      # textColor = "#FAF4FC";
      settings = {
        default-timeout = 5000;
        width = 256;
        height = 500;
        margin = "10";
        padding = "5";
        border-size = 3;
        border-radius = 3;
        text-alignment = "center";
        # criteria."urgency=critical".border-color = "#B45C65";
      };
      # ''
      #   {
      #    text-alignment=center
      #    [urgency=critical]
      #    border-color=#B45C65
      #   }
      # '';
    };

    # hm sets up a similar service already
    # systemd.user.services.mako = {
    # Unit = {
    #   Description = "Wayland notification daemon";
    #   Documentation = ["man:mako(1)"];
    #   PartOf = [ "graphical-session.target" ];
    #   After = [ "graphical-session.target" ];
    # };
    # Service = {
    #   Type = "dbus";
    #   BusName = "org.freedesktop.Notifications";
    #   ExecCondition = "/usr/bin/env sh -c '[ -n \"$WAYLAND_DISPLAY\" ]'";
    #   ExecStart = "/usr/bin/env mako";
    #   ExecReload = "/usr/bin/env makoctl reload";
    #  };
    # Install.WantedBy = [ "graphical-session.target" ];
    # };

    home.packages = with pkgs; [
      wl-clipboard
      wev
    ];
  };
}
