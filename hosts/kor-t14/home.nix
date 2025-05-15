{ pkgs
, inputs
, ...
}:
{
  imports = [ ./batcheck.nix ];

  kor.preset.desktop.enable = true;
  kor.preset.desktop.enableHyprland = true;
  kor.desktop.apps.firefox.enable = true;
  kor.desktop.suites.gaming.enable = true;

  kor.desktop.hyprland.autostartWaybar = true;
  kor.desktop.apps.waybar.modules-left = [ "idle_inhibitor" "backlight" "wireplumber" "hyprland/workspaces" ];

  kor.desktop.uwsm.env = [
    "HYPRLAND_TRACE=1"
    "AQ_TRACE=1"
    "LIBVA_DRIVER_NAME=iHD"
  ];

  # home.packages = with pkgs; [
  #   npins
  #   inputs.nilla-cli.result.packages.nilla-cli.result.x86_64-linux
  #   inputs.nilla-utils.result.packages.nilla-utils-plugins.result.x86_64-linux
  # ];
}
