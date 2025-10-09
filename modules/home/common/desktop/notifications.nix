{ config, lib, ... }:
let
  catcolors = builtins.fromJSON (builtins.readFile ./catcolors.json);
  # catcolors = import ../../../catcolors.nix;
  flavor = config.catppuccin.flavor;
  accent = config.catppuccin.accent;
  hexcolor = color: "${lib.strings.removePrefix "#" catcolors.${flavor}.colors.${color}.hex}ff";

  cfg = config.kor.desktop.notifications;
in
{
  options.kor.desktop.notifications.fnott.enable = lib.mkEnableOption "fnott notification daemon";

  config = lib.mkIf cfg.fnott.enable {
    services.fnott = {
      enable = true;
      extraFlags = [ ];
      settings = {
        main = {
          notification-margin = 5;
          default-timeout = 5;
          selection-helper = "fuzzel --dmenu0";
          selection-helper-uses-null-separator = true;
          icon-theme = config.gtk.iconTheme.name;

          dpi-aware = true;
          progress-bar-color = hexcolor "overlay0";
          border-color = hexcolor "lavender";
          border-radius = 3;
          border-size = 3;

          background = hexcolor "base";

          title-color = hexcolor "text";
          title-font = "Hack Nerd Font:slant=italic";
          summary-color = hexcolor "subtext0";
          summary-font = "Hack Nerd Font:weight=bold";
          body-color = hexcolor "text";
          body-font = "DroidSansM Nerd Font";
        };
        critical = {
          # border-color = hexcolor "red";
          border-color = hexcolor accent;
        };
        low = {
          # title-color = "ffffff";
        };
      };
    };

    # TODO use fnott maybe
    # catppuccin.mako.enable = true;
    # services.mako = {
    #   enable = true; # NOTE conflicts with hyprpanel/ags notif service
    #   settings = {
    #     default-timeout = 5000;
    #     width = 256;
    #     height = 500;
    #     margin = "10";
    #     padding = "5";
    #     border-size = 3;
    #     border-radius = 3;
    #     text-alignment = "center";

    #     font = "DroidSansM Nerd Font 12";

    #     # "urgency=critical".border-color = "#B45C65";
    #   };
    # };

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
  };
}
