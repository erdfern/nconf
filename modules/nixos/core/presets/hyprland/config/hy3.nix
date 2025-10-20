{ lib
, config
, inputs
, ...
}:
let
  cfg = config.kor.desktop.hyprland.hy3;
  mod = "ALT";
in
{
  options.kor.desktop.hyprland.hy3 = with lib; {
    enable = mkEnableOption "hyprland hy3 layout";
  };

  config = lib.mkIf cfg.enable {
    programs.hyprland = {
      plugins = [
        inputs.hy3.result.packages.x86_64-linux.hy3
      ];

      settings.general.layout = lib.mkForce "hy3";
      settings.bind =
        let
          binding = mod: cmd: key: arg: extra: "${mod}, ${key}, ${cmd}, ${arg}";
          mvfocus = binding mod "hy3:movefocus";
          mvwindow = binding "${mod} SHIFT" "hy3:movewindow";
          ws = binding mod "workspace";
          # resizeactive = binding "${mod} CTRL" "resizeactive";
          mvtows = binding "${mod} SHIFT" "hy3:movetoworkspace";
          arr = [ 1 2 3 4 5 6 7 8 9 0 ];
        in
        [
          "${mod}, q, hy3:warpcursor"
          "${mod}, tab, hy3:togglefocuslayer"

          "${mod}, d, hy3:makegroup, h"
          "${mod}, s, hy3:makegroup, v"
          "${mod}, z, hy3:makegroup, tab"
          "${mod}, a, hy3:changefocus, raise"
          "${mod}+SHIFT, a, hy3:changefocus, lower"
          "${mod}, e, hy3:expand, expand"
          "${mod}+SHIFT, e, hy3:expand, base"
          "${mod}, r, hy3:changegroup, opposite"

          (mvfocus "k" "u")
          (mvfocus "j" "d")
          (mvfocus "l" "r")
          (mvfocus "h" "l")
          (mvwindow "k" "u")
          (mvwindow "j" "d")
          (mvwindow "l" "r")
          (mvwindow "h" "l")
          # (mvactive "k" "0 -20")
          # (mvactive "j" "0 20")
          # (mvactive "l" "20 0")
          # (mvactive "h" "-20 0")
          (ws "left" "e-1")
          (ws "right" "e+1")
          (mvtows "left" "e-1")
          (mvtows "right" "e+1")
        ] ++ (map (i: ws (toString i) (toString i)) arr) ++ (map (i: mvtows (toString i) (toString i)) arr);

      settings.plugin.hy3 = {
        # disable gaps when only one window is onscreen
        # 0 - always show gaps
        # 1 - hide gaps with a single window onscreen
        # 2 - 1 but also show the window border
        no_gaps_when_only = 1; # default: 0

        # policy controlling what happens when a node is removed from a group,
        # leaving only a group
        # 0 = remove the nested group
        # 1 = keep the nested group
        # 2 = keep the nested group only if its parent is a tab group
        node_collapse_policy = 2; # default: 2

        # offset from group split direction when only one window is in a group
        group_inset = 10; # default: 10

        # if a tab group will automatically be created for the first window spawned in a workspace
        # tab_first_window = <bool>

        # tab group settings
        tabs = {
          # height of the tab bar
          # height = 22; # default: 22

          # padding between the tab bar and its focused node
          # padding = 6; # default: 6

          # the tab bar should animate in/out from the top instead of below the window
          # from_top = false; # default: false

          # radius of tab bar corners
          # radius = 6; # default: 6

          # tab bar border width
          # border_width = 2; # default: 2

          # render the window title on the bar
          # render_text = true; # default: true

          # center the window title
          # text_center = true; # default: true

          # font to render the window title with
          # text_font = "Sans"; # default: Sans

          # height of the window title
          # text_height = <int> # default: 8

          # left padding of the window title
          # text_padding = <int> # default: 3

          # active tab bar segment colors
          "col.active" = "rgba($accentAlpha40)"; # default: rgba(33ccff40)
          "col.active.border " = "rgba($skyAlphaee)"; # default: rgba(33ccffee)
          "col.active.text" = "$text"; # default: rgba(ffffffff)

          # focused tab bar segment colors (focused node in unfocused container)
          "col.focused" = "rgba($crustAlpha40)"; # default: rgba(60606040)
          "col.focused.border" = "rgba($lavenderAlphaee)"; # default: rgba(808080ee)
          "col.focused.text" = "$text"; # default: rgba(ffffffff)

          # inactive tab bar segment colors
          "col.inactive" = "rgba($surface0Alpha20)"; # default: rgba(30303020)
          "col.inactive.border" = "rgba($overlay0Alphaaa)"; # default: rgba(606060aa)
          "col.inactive.text" = "$text"; # default: rgba(ffffffff)

          # urgent tab bar segment colors
          "col.urgent" = "rgba($redAlpha40)"; # default: rgba(ff223340)
          "col.urgent.border" = "rgba($redAlphaee)"; # default: rgba(ff2233ee)
          "col.urgent.text" = "$text"; # default: rgba(ffffffff)

          # locked tab bar segment colors
          "col.locked" = "rgba($tealAlpha40)"; # default: rgba(90903340)
          "col.locked.border" = "rgba($tealAlphaee)"; # default: rgba(909033ee)
          "col.locked.text" = "$text"; # default: rgba(ffffffff)

          # if tab backgrounds should be blurred
          # Blur is only visible when the above colors are not opaque.
          blur = true; # default: true

          # opacity multiplier for tabs
          # Applies to blur as well as the given colors.
          opacity = 1.0; # default: 1.0
        };

        # autotiling settings
        autotile = {
          # enable autotile
          # enable = <bool> # default: false

          # make autotile-created groups ephemeral
          # ephemeral_groups = <bool> # default: true

          # if a window would be squished smaller than this width, a vertical split will be created
          # -1 = never automatically split vertically
          # 0 = always automatically split vertically
          # <number> = pixel width to split at
          # trigger_width = <int> # default: 0

          # if a window would be squished smaller than this height, a horizontal split will be created
          # -1 = never automatically split horizontally
          # 0 = always automatically split horizontally
          # <number> = pixel height to split at
          # trigger_height = <int> # default: 0

          # a space or comma separated list of workspace ids where autotile should be enabled
          # it's possible to create an exception rule by prefixing the definition with "not:"
          # workspaces = 1,2 # autotiling will only be enabled on workspaces 1 and 2
          # workspaces = not:1,2 # autotiling will be enabled on all workspaces except 1 and 2
          # workspaces = <string> # default: all
        };
      };

    };
  };
}
