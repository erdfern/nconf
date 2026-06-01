{ config, lib, ... }:
let
  cfg = config.kor.desktop.hyprland;
  inherit (lib.generators) mkLuaInline;

  # Catppuccin's hyprland module declares `local colors = require('themes.catppuccin')`
  # (via colors._var), so colors are referenced from that Lua table rather than
  # hyprlang `$` variables. The old `$<name>` -> `colors.<name>`, and the old
  # `rgba($accentAlphae6)` concatenation -> `"rgba(" .. colors.accentAlpha .. "e6)"`.
  rgbaA = name: alpha: mkLuaInline ''"rgba(" .. colors.${name} .. "${alpha})"'';
in
{
  wayland.windowManager.hyprland = {
    sourceFirst = true;
    settings = {
      config = {
        general = {
          border_size = 2;
          gaps_in = 2;
          gaps_out = 4;
          # gaps_in = 2;
          # gaps_out = 8;

          # Gradients are now a table { colors = [...]; angle = <deg>; };
          # a single color stays a plain string.
          col = {
            active_border = {
              colors = [ (rgbaA "accentAlpha" "e6") (rgbaA "skyAlpha" "e6") ];
              angle = 45;
            };
            inactive_border = rgbaA "overlay0Alpha" "e6";
          };
        };

        misc = {
          background_color = mkLuaInline "colors.base";
        };

        decoration = {
          shadow = {
            enabled = true;
            range = 8;
            render_power = 2;
            color = rgbaA "crustAlpha" "cc";
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

        # The global animations toggle stays a config value; the individual
        # curves/animations below are their own calls.
        animations.enabled = true;
      };

      # `bezier = "name, x1, y1, x2, y2"`  ->  hl.curve(name, { type = "bezier", points = { {x1,y1}, {x2,y2} } })
      curve = [
        { _args = [ "windowIn" { type = "bezier"; points = [ [ 0.06 0.71 ] [ 0.25 1 ] ]; } ]; }
        { _args = [ "windowResize" { type = "bezier"; points = [ [ 0.04 0.67 ] [ 0.38 1 ] ]; } ]; }
        { _args = [ "workspacesMove" { type = "bezier"; points = [ [ 0.1 0.75 ] [ 0.15 1 ] ]; } ]; }
      ];

      # `animation = "leaf, onoff, speed, curve[, style]"`  ->  hl.animation({ leaf, enabled, speed, bezier, style })
      # NOTE: the original styles read "slide #popin 20%" / "slide #popin 70%".
      # In hyprlang everything after `#` is a comment, so the effective style
      # was just "slide". If you actually wanted popin, set e.g. style = "popin 20%".
      animation = [
        { leaf = "windowsIn"; enabled = true; speed = 3; bezier = "windowIn"; style = "slide"; }
        { leaf = "windowsOut"; enabled = true; speed = 3; bezier = "windowIn"; style = "slide"; }
        { leaf = "windowsMove"; enabled = true; speed = 2.5; bezier = "windowResize"; }
        { leaf = "border"; enabled = true; speed = 10; bezier = "default"; }
        { leaf = "borderangle"; enabled = true; speed = 8; bezier = "default"; }
        { leaf = "fade"; enabled = true; speed = 3; bezier = "default"; }
        { leaf = "workspaces"; enabled = true; speed = 5; bezier = "workspacesMove"; style = "slidevert"; }
        { leaf = "layers"; enabled = true; speed = 5; bezier = "windowIn"; style = "slide"; }
      ];

      # env -> hl.env(name, value):
      # env = [
      #   { _args = [ "XCURSOR_SIZE" "24" ]; }
      #   { _args = [ "HYPRCURSOR_SIZE" "24" ]; }
      #   { _args = [ "HYPRCURSOR_THEME" config.programs.pointerCursor.name ]; }
      #   { _args = [ "QT_QPA_PLATFORMTHEME" "qt6ct" ]; }
      # ];

      # smart gaps / 'no gaps when only' -> hl.workspace_rule({ ... }):
      # workspace_rule = lib.optionals (!cfg.hy3.enable) [
      #   { workspace = "w[tv1]"; gaps_out = 0; gaps_in = 0; }
      #   { workspace = "f[1]"; gaps_out = 0; gaps_in = 0; }
      # ];
    };
  };
}


# { config, lib, ... }:
# let
#   cfg = config.kor.desktop.hyprland;
# in
# {
#   wayland.windowManager.hyprland = {
#     sourceFirst = true;
#     settings = {
#       # env = [
#       # "XCURSOR_SIZE,24"
#       # HYPRCURSOR stuff set by catppuccin if pointerCursor.enable is true
#       # "HYPRCURSOR_SIZE,24"
#       # "HYPRCURSOR_THEME,${config.programs.pointerCursor.name}"
#       # "QT_QPA_PLATFORMTHEME,qt6ct"
#       # ];

#       general = {
#         border_size = 2;
#         gaps_in = 2;
#         gaps_out = 4;
#         # gaps_in = 2;
#         # gaps_out = 8;
#         "col.active_border" = "rgba($accentAlphae6) rgba($skyAlphae6) 45deg";
#         "col.inactive_border" = "rgba($overlay0Alphae6)";
#       };

#       misc = {
#         background_color = "$base";
#       };

#       # workspace = [
#       # ] ++ lib.optionals (!cfg.hy3.enable) [
#       #   # smart gaps/'no gaps when only'
#       #   "w[tv1], gapsout:0, gapsin:0"
#       #   "f[1], gapsout:0, gapsin:0"
#       # ];

#       decoration = {
#         shadow = {
#           enabled = true;
#           range = 8;
#           render_power = 2;
#           color = "rgba($crustAlphacc)";
#         };

#         # dim_inactive = false;
#         # dim_strength = 0.5;
#         dim_special = 0.2;

#         blur = {
#           enabled = true;
#           ignore_opacity = true;
#           popups = true;
#           new_optimizations = true;
#           xray = false;

#           size = 16;
#           passes = 4;
#           noise = 0.01;
#           contrast = 0.9;
#           brightness = 0.8;
#         };
#       };

#       animations = {
#         enabled = true;
#         bezier = [
#           "windowIn, 0.06, 0.71, 0.25, 1"
#           "windowResize, 0.04, 0.67, 0.38, 1"
#           "workspacesMove, 0.1, 0.75, 0.15, 1"
#         ];
#         animation = [
#           "windowsIn, 1, 3, windowIn, slide #popin 20%"
#           "windowsOut, 1, 3, windowIn, slide #popin 70%"
#           "windowsMove, 1, 2.5, windowResize"
#           "border, 1, 10, default"
#           "borderangle, 1, 8, default"
#           "fade, 1, 3, default"
#           "workspaces, 1, 5, workspacesMove, slidevert"
#           "layers, 1, 5, windowIn, slide"
#         ];
#       };
#     };
#   };
# }
