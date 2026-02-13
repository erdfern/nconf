{ pkgs, lib, config, ... }:

let
  cfg = config.kor.desktop.apps.swayosd;
in
{
  options.kor.desktop.apps.swayosd = with lib; {
    enable = mkEnableOption "Wayland OSD";
  };

  config = lib.mkIf cfg.enable {
    services.swayosd = {
      enable = true;
      # OSD Margin from the top edge, 0.5 would be the screen center. May be from 0.0 - 1.0.
      topMargin = 0.9;
      # For a custom stylesheet file.
      # https://github.com/ErikReider/SwayOSD/blob/main/data/style/style.scss
      # https://github.com/ErikReider/SwayOSD/issues/36
      stylePath = ./style.css;
    };

  };
}
