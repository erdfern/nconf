{ lib
, config
, pkgs
, inputs
, ...
}:
let
  cfg = config.kor.desktop.hyprland;
in
{
  imports = [
    # ./config
    # ./hyprpaper
    # ./hyprlock
    # ./hypridle.nix
  ];
  # ++ [ inputs.hyprpanel.result.homeManagerModules.hyprpanel ];

  options.kor.desktop.hyprland.enable = lib.mkEnableOption "hyprland compositor :I";

  config = lib.mkIf cfg.enable {
    programs.hyprland = {
      enable = true;
      xwayland.enable = true;
      package = inputs.hyprland.result.packages.${pkgs.stdenv.hostPlatform.system}.hyprland;
      portalPackage = inputs.hyprland.result.packages.${pkgs.stdenv.hostPlatform.system}.xdg-desktop-portal-hyprland;

      withUWSM = true; # means that home.wayland.windowManager.hyprland.systemd.enable should be false
    };

    services.dbus.implementation = lib.mkForce "broker"; # uwsm suggestion/soft requirement

    # needed for home-manager programs.hyprlock.enable to work
    security.pam.services.hyprlock = { };
  };
}
