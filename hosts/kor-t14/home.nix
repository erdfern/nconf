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

  # kor.desktop.apps.waybar.enable  = true;
  kor.desktop.hyprland.autostartWaybar = true;
  kor.desktop.apps.waybar.modules-left = [ "idle_inhibitor" "backlight" "wireplumber" "hyprland/workspaces" ];

  kor.desktop.hyprland.uwsmEnv = [
    "export HYPRLAND_TRACE=0"
    "export AQ_TRACE=0"
    "export LIBVA_DRIVER_NAME=iHD"
  ];

  # home.packages = with pkgs; [
  #   npins
  #   inputs.nilla-cli.result.packages.nilla-cli.result.x86_64-linux
  #   inputs.nilla-utils.result.packages.nilla-utils-plugins.result.x86_64-linux
  # ];
}
