{ pkgs, config, lib, ... }:
let
  app2unit = "${pkgs.app2unit-kor}/bin/app2unit";
  uwsmRun = cmd: "${app2unit} ${cmd}";
  toggle_waybar = pkgs.writeShellScript "toggle_waybar" ''
    ${pkgs.killall}/bin/killall .waybar-wrapped || ${pkgs.waybar}/bin/waybar > /dev/null 2>&1 &
  '';

  autostartWaybar = config.kor.desktop.apps.waybar.enable && config.kor.desktop.apps.waybar.hyprlandAutostart;

  cfg = config.kor.desktop.hyprland;

  inherit (lib.generators) mkLuaInline;
in
{
  imports = [
    ./input.nix
    ./keybinds.nix
    ./theme.nix
    # ./hy3.nix
  ];

  wayland.windowManager.hyprland = {
    configType = "lua";
    sourceFirst = true;
    settings = {
      # Autostart: `exec-once` has no working lua equivalent in the HM module
      # (it emits an invalid hl.exec-once). Use the hyprland.start event:
      # on = lib.optionals autostartWaybar [
      #   {
      #     _args = [
      #       "hyprland.start"
      #       (mkLuaInline ''function() hl.exec_cmd("${uwsmRun "${toggle_waybar}"}") end'')
      #     ];
      #   }
      # ];

      # env -> hl.env(name, value):
      # env = [
      #   { _args = [ "XCURSOR_SIZE" "24" ]; }
      #   # HYPRCURSOR stuff set by catppuccin if pointerCursor.enable is true
      #   { _args = [ "HYPRCURSOR_SIZE" "24" ]; }
      #   { _args = [ "HYPRCURSOR_THEME" config.programs.pointerCursor.name ]; }
      #   { _args = [ "QT_QPA_PLATFORMTHEME" "qt6ct" ]; }
      # ];

      # Monitors are now table calls (hl.monitor({ ... })); the old `monitor`
      # string list and `monitorv2` attr list collapse into one `monitor` list.
      # Note `scale` is a string ("auto"/"1"), and `disable` becomes disabled = true.
      monitor = [
        { output = "Unknown-1"; disabled = true; }
        {
          output = "desc:LG Electronics 34GK950G ##ASNP9XrjL0zd";
          mode = "3440x1440@120.00Hz";
          position = "auto";
          scale = "1";
          # transform = 2;
          supports_wide_color = 1;
          # supports_hdr = 1;
          # sdr_min_luminance = 0.005;
          # sdr_max_luminance = 225;
          # min_luminance = 0;
          # max_luminance = 0;
          # max_avg_luminance = 0;
        }
        {
          output = "DP-3";
          mode = "3440x1440@120.00Hz";
          position = "auto";
          scale = "1";
          # transform = 2;
          supports_wide_color = 1;
          # supports_hdr = 1;
          # sdr_min_luminance = 0.005;
          # sdr_max_luminance = 225;
          # min_luminance = 0;
          # max_luminance = 0;
          # max_avg_luminance = 0;
        }
        { output = ""; mode = "preferred"; position = "auto"; scale = "auto"; }
      ];

      config = {
        # debug = {
        #   disable_logs = true;
        #   enable_stdout_logs = false;
        # };

        xwayland = {
          force_zero_scaling = true;
          create_abstract_socket = true; # compat maybe
        };

        general = {
          allow_tearing = true;
          layout = lib.mkDefault "dwindle";

          resize_on_border = true;
          hover_icon_on_border = true;
          extend_border_grab_area = 16;
        };

        cursor = {
          no_hardware_cursors = true;
          inactive_timeout = 3;
          hide_on_touch = true;
          no_warps = true;
        };

        dwindle = {
          preserve_split = true;
          # smart_split = true;
        };

        misc = {
          enable_anr_dialog = false; # problematic with some apps/games
          # disable_autoreload = true;
          disable_splash_rendering = true;
          disable_hyprland_logo = true;
          force_default_wallpaper = 0; # Set to 0 or 1 to disable the anime mascot wallpapers

          vrr = 0; # 0-off 1-on 2-fullscreen only, 3 fullscreen with video or game content type

          key_press_enables_dpms = true;
          mouse_move_enables_dpms = false;

          close_special_on_empty = true;

          focus_on_activate = true;

          initial_workspace_tracking = 1; # 0 - off; 1 - single-shot;  2 - persistent (all children too);
        };

        ecosystem = {
          no_update_news = true;
          no_donation_nag = true;
          enforce_permissions = false; # https://wiki.hypr.land/Configuring/Permissions
        };

        # group = {
        #   groupbar = {};
        # };
      };

      # windowrule -> hl.window_rule({ match = { ... }, <effects> }). The match
      # selectors (class/title) move into `match`; everything else is an effect.
      window_rule =
        let
          floatClass = regex: { match = { class = "^(${regex})$"; }; float = true; };
        in
        [
          # `hyprctl clients` to get class/title...
          # { name = "suppress-maximize"; match = { class = ".*"; }; suppress_event = "maximize"; }
          (floatClass "Picture-in-Picture")
          (floatClass "imv")
          (floatClass "mpv")
          # (floatClass "nemo")
          (floatClass "termfloat")

          { match = { class = "termfloat"; }; rounding = 5; size = "980 640"; }
          { match = { title = "^(Picture-in-Picture)$"; }; move = "100%-25% 100%-25%"; }

          {
            name = "clipse-modal";
            match = { class = "clipse"; };
            float = true;
            center = true;
            pin = true;
            border_size = 8;

            # make it a nice size
            # Width = 50% of monitor, Height = Width / Golden Ratio (1.618)
            size = "(monitor_w*0.5) (monitor_w*0.5/1.618)";
            # Alternative: fixed height (e.g. 60% of screen) and golden width
            # size = "(monitor_h*0.6*1.618) (monitor_h*0.6)";
          }
        ];
    };
  };
}

# 
# { pkgs, config, lib, ... }:
# let
#   app2unit = "${pkgs.app2unit-kor}/bin/app2unit";
#   uwsmRun = cmd: "${app2unit} ${cmd}";
#   toggle_waybar = pkgs.writeShellScript "toggle_waybar" ''
#     ${pkgs.killall}/bin/killall .waybar-wrapped || ${pkgs.waybar}/bin/waybar > /dev/null 2>&1 &
#   '';

#   autostartWaybar = config.kor.desktop.apps.waybar.enable && config.kor.desktop.apps.waybar.hyprlandAutostart;

#   cfg = config.kor.desktop.hyprland;
# in
# {
#   imports = [
#     # ./input.nix
#     ./keybinds.nix
#     # ./theme.nix
#     # ./hy3.nix
#   ];

#   wayland.windowManager.hyprland = {
#     # configType = "hyprlang";
#     configType = "lua";
#     sourceFirst = true;
#     settings = {
#       # exec-once = [ ]
#       #   ++ lib.lists.optional autostartWaybar "${uwsmRun "${toggle_waybar}"}";

#       # env = [
#       #   "XCURSOR_SIZE,24"
#       #   # HYPRCURSOR stuff set by catppuccin if pointerCursor.enable is true
#       #   "HYPRCURSOR_SIZE,24"
#       #   "HYPRCURSOR_THEME,${config.programs.pointerCursor.name}"
#       #   "QT_QPA_PLATFORMTHEME,qt6ct"
#       # ];

#       # debug.disable_logs = true;
#       # debug.enable_stdout_logs = false;

#       monitor = [
#         "Unknown-1, disable"
#         # "desc:LG Electronics 34GK950G ##ASNP9XrjL0zd,3440x1440@120.00Hz,auto,1"
#         ",preferred,auto,auto"
#       ];

#       monitorv2 = [{
#         output = "desc:LG Electronics 34GK950G ##ASNP9XrjL0zd";
#         mode = "3440x1440@120.00Hz";
#         position = "auto";
#         scale = 1;
#         # transform = 2;
#         supports_wide_color = 1;
#         # supports_hdr = 1;
#         # sdr_min_luminance = 0.005;
#         # sdr_max_luminance = 225;
#         # min_luminance = 0;
#         # max_luminance = 0;
#         # max_avg_luminance = 0;
#       }];

#       xwayland = {
#         force_zero_scaling = true;
#         create_abstract_socket = true; # compat maybe
#       };

#       general = {
#         allow_tearing = true;
#         layout = lib.mkDefault "dwindle";

#         resize_on_border = true;
#         hover_icon_on_border = true;
#         extend_border_grab_area = 16;
#       };

#       cursor = {
#         no_hardware_cursors = true;
#         inactive_timeout = 3;
#         hide_on_touch = true;
#         no_warps = true;
#       };

#       dwindle = {
#         pseudotile = true;
#         preserve_split = true;
#         # smart_split = true;
#       };

#       misc = {
#         enable_anr_dialog = false; # problematic with some apps/games
#         # disable_autoreload = true;
#         disable_splash_rendering = true;
#         disable_hyprland_logo = true;
#         force_default_wallpaper = 0; # Set to 0 or 1 to disable the anime mascot wallpapers

#         vrr = 0; # 0-off 1-on 2-fullscreen only, 3 fullscreen with video or game content type

#         key_press_enables_dpms = true;
#         mouse_move_enables_dpms = false;

#         close_special_on_empty = true;

#         focus_on_activate = true;

#         initial_workspace_tracking = 1; # 0 - off; 1 - single-shot;  2 - persistent (all children too);
#       };

#       ecosystem = {
#         no_update_news = true;
#         no_donation_nag = true;
#         enforce_permissions = false; # https://wiki.hyprland.org/Configuring/Permissions
#       };

#       # group = {
#       #   groupbar = {};
#       # };

#       windowrule =
#         let
#           f = regex: "match:class ^(${regex})$, float true";
#         in
#         [
#           # #`hyprctl clients` get class、title...
#           # "suppressevent maximize, class:.*"
#           (f "Picture-inPicture")
#           (f "imv")
#           (f "mpv")
#           # (f "nemo")
#           (f "termfloat")

#           "match:class termfloat, rounding 5"
#           "match:class termfloat, size 980 640"
#           "match:title ^(Picture-in-Picture)$, move -25%"

#           "match:class ^(rimworld)$, immediate true"
#         ] ++
#         [{
#           name = "clipse-modal";
#           "match:class" = "clipse";
#           float = true;
#           center = true;
#           pin = true;
#           border_size = 8;

#           # make it a nice size
#           # size = "512 828";
#           # Width = 50% of monitor, Height = Width / Golden Ratio (1.618)
#           # "size (monitor_w*0.5) (monitor_w*0.5/1.618), class:(clipse)"
#           size = "(monitor_w*0.5) (monitor_w*0.5/1.618)";
#           # Alternative: fixed height (e.g. 60% of screen) and golden width
#           # "size (monitor_h*0.6*1.618) (monitor_h*0.6), class:(clipse)"

#         }];
#     };
#   };
# }
