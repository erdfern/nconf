{ config, lib, ... }:
let
  cfg = config.kor.desktop.hyprland;
in
{
  programs.hyprland = {
    settings = {
      # env = [
      # "XCURSOR_SIZE,24"
      # HYPRCURSOR stuff set by catppuccin if pointerCursor.enable is true
      # "HYPRCURSOR_SIZE,24"
      # "HYPRCURSOR_THEME,${config.programs.pointerCursor.name}"
      # "QT_QPA_PLATFORMTHEME,qt6ct"
      # ];

      general = {
        border_size = 2;
        gaps_in = 2;
        gaps_out = 4;
        # gaps_in = 2;
        # gaps_out = 8;
        "col.active_border" = "rgba($accentAlphae6) rgba($skyAlphae6) 45deg";
        "col.inactive_border" = "rgba($overlay0Alphae6)";
      };

      misc = {
        background_color = "$base";
      };

      workspace = [
      ] ++ lib.optionals (!cfg.hy3.enable) [
        # smart gaps/'no gaps when only'
        "w[tv1], gapsout:0, gapsin:0"
        "f[1], gapsout:0, gapsin:0"
      ];

      decoration = {
        shadow = {
          enabled = true;
          range = 8;
          render_power = 2;
          color = "rgba($crustAlphacc)";
        };

        # dim_inactive = false;
        # dim_strength = 0.5;
        dim_special = 0.2;

        blur = {
          enabled = true;
          ignore_opacity = true;
          popups = true;
          new_optimizations = true;
          xray = false;

          size = 16;
          passes = 4;
          noise = 0.01;
          contrast = 0.9;
          brightness = 0.8;
        };
      };

      animations = {
        enabled = true;
        bezier = [
          "windowIn, 0.06, 0.71, 0.25, 1"
          "windowResize, 0.04, 0.67, 0.38, 1"
          "workspacesMove, 0.1, 0.75, 0.15, 1"
        ];
        animation = [
          "windowsIn, 1, 3, windowIn, slide #popin 20%"
          "windowsOut, 1, 3, windowIn, slide #popin 70%"
          "windowsMove, 1, 2.5, windowResize"
          "border, 1, 10, default"
          "borderangle, 1, 8, default"
          "fade, 1, 3, default"
          "workspaces, 1, 5, workspacesMove, slidevert"
          "layers, 1, 5, windowIn, slide"
        ];
      };
    };
  };
}
