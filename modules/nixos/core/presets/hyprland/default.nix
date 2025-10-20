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

  programs.hyprland = {
    enable = true;
    xwayland.enable = true;
    package = inputs.hyprland.result.packages.${pkgs.stdenv.hostPlatform.system}.hyprland;
    portalPackage = inputs.hyprland.result.packages.${pkgs.stdenv.hostPlatform.system}.xdg-desktop-portal-hyprland;

    withUWSM = true; # means that home.wayland.windowManager.hyprland.systemd.enable should be false
  };

  # needed for home-manager programs.hyprlock.enable to work
  security.pam.services.hyprlock = { };
}
