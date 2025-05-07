{ pkgs, ... }:
let
  # toggle_waybar = pkgs.writeShellScriptBin "toggle_waybar" ''
  #   killall .waybar-wrapped || ${pkgs.waybar}/bin/waybar > /dev/null 2>&1 &
  # '';
  toggle_dpms = pkgs.writeShellScriptBin "toggle_dpms" ''
    if [ "$(hyprctl monitors all -j | ${pkgs.jq}/bin/jq 'map(.dpmsStatus) | any')" = "true" ]; then
      hyprctl dispatch dpms off
    else
      hyprctl dispatch dpms on
    fi
  '';
  hyprlock = "${pkgs.hyprlock}/bin/hyprlock";
  playerctl = "${pkgs.playerctl}/bin/playerctl";
  wpctl = "${pkgs.wireplumber}/bin/wpctl";
  light = "${pkgs.light}/bin/light";
  # brightnessctl = "${pkgs.brightnessctl}/bin/light";
  fuzzel = "${pkgs.fuzzel}/bin/fuzzel";
  terminal = "kitty";
  mod = "ALT";
in
{
  wayland.windowManager.hyprland = {
    sourceFirst = true;
    settings = {
      "$mod" = mod;

      # exec-once = [
      # "${toggle_waybar}/bin/toggle_waybar &"
      # "mako &"
      # "nm-applet &"
      # ];

      # env = [
      # "XCURSOR_SIZE,24"
      # HYPRCURSOR stuff set by catppuccin if pointerCursor.enable is true
      # "HYPRCURSOR_SIZE,24"
      # "HYPRCURSOR_THEME,${config.programs.pointerCursor.name}"
      # "QT_QPA_PLATFORMTHEME,qt6ct"
      # ];

      debug.disable_logs = false;
      debug.enable_stdout_logs = true;

      monitor = [
        "Unknown-1, disable"
        "desc:LG Electronics 34GK950G ##ASNP9XrjL0zd,3440x1440@120.00Hz,auto,1"
        # ",highrr,auto,auto"
        ",preferred,auto,auto"
      ];

      xwayland = { force_zero_scaling = true; };

      general = {
        allow_tearing = true;
        layout = "dwindle";
        resize_on_border = true;
        hover_icon_on_border = true;
        border_size = 1;
        gaps_in = 1;
        gaps_out = 1;
        # gaps_in = 2;
        # gaps_out = 8;
        "col.active_border" = "rgba(33ccffee) rgba(00ff99ee) 45deg";
        "col.inactive_border" = "rgba(595959aa)";
      };

      cursor = {
        no_hardware_cursors = true;
        inactive_timeout = 3;
        hide_on_touch = true;
        # no_warps = true;
      };

      dwindle = {
        pseudotile = true;
        preserve_split = true;
      };

      misc = {
        close_special_on_empty = true;
        vrr = 1; # 0-off 1-on 2-fullscreen only
        focus_on_activate = true;
        disable_splash_rendering = true;
        force_default_wallpaper = 0; # Set to 0 or 1 to disable the anime mascot wallpapers
        disable_hyprland_logo = true;
        disable_autoreload = true;
      };

      ecosystem.no_update_news = true;

      input = {
        kb_layout = "us,de";
        # shift+caps=caps,lshift+rshift=switch layout
        kb_options = "caps:escape_shifted_capslock,grp:shifts_toggle";
        follow_mouse = 2; # click on window to focus
        sensitivity = 0;
        float_switch_override_focus = 1;
        special_fallthrough = false;
        touchpad = {
          natural_scroll = "yes";
          disable_while_typing = true;
          drag_lock = false;
        };
        touchdevice = {
          enabled = true;
          # output = 
          # transform = -1;
        };
      };

      # device = {
      #   "synps/2-synaptics-touchpad" = {};
      # };

      gestures = {
        # workspace_swipe = true;
        # workspace_swipe_forever = true;
        # workspace_swipe_numbered = true;
      };

      # group = {
      #   groupbar = {};
      # };

      binds = {
        allow_workspace_cycles = true;
      };

      # TODO toggle keybinds keybind:
      # bind = MOD, KEY, submap, clean
      # submap = clean
      # bind = MOD, KEY, submap, reset
      # submap = reset

      bind =
        let
          binding = mod: cmd: key: arg: "${mod}, ${key}, ${cmd}, ${arg}";
          mvfocus = binding mod "movefocus";
          mvwindow = binding "${mod} SHIFT" "movewindow";
          ws = binding mod "workspace";
          # resizeactive = binding "${mod} CTRL" "resizeactive";
          mvactive = binding "${mod} CTRL SHIFT" "moveactive";
          mvtows = binding "${mod} SHIFT" "movetoworkspace";
          arr = [ 1 2 3 4 5 6 7 8 9 0 ];
        in
        [
          # "$mod CTRL, Delete, exit" # bye bye
          "$mod CTRL, Delete, exec, loginctl terminate-user \"\"" # bye bye uwsm
          "$mod CTRL, X, exec, pidof ${hyprlock} || ${hyprlock}"

          "$mod SHIFT, Q, killactive"

          "$mod SHIFT, Space, togglefloating"
          "$mod, G, fullscreen"
          # "$mod SHIFT, G, fakefullscreen"
          # "$mod SHIFT, G, fullscreenstate TODO"
          "$mod, P, togglesplit"
          "$mod, T, togglegroup"

          ",Super_L, exec, pkill fuzzel || ${fuzzel}"
          # "$mod, Super_L,exec, pkill fuzzel || ${sharedScripts.fuzzel-powermenu}/bin/fuzzel-powermenu"
          "$mod, Return, exec, ${terminal}"
          "$mod SHIFT, Return, exec, ${terminal} --class='termfloat'"
          # "$mod SHIFT, Return, exec, [termfloat;noanim] $TERMINAL"
          # "$mod SHIFT, O, exec, ${toggle_waybar}/bin/toggle_waybar"
          "$mod, bracketleft, exec, grimblast --notify copysave area ~/Pictures/$(date \"+%Y-%m-%d\"T\"%H:%M:%S\").png"
          "$mod, bracketright, exec, grimblast --notify copy area"
          "$mod, Print, exec, grimblast --notify copy screen"


          # minimize using special workspace
          "$mod SHIFT, S, togglespecialworkspace, magic"
          "$mod SHIFT, S, movetoworkspace, +0"
          "$mod SHIFT, S, togglespecialworkspace, magic"
          "$mod SHIFT, S, movetoworkspace, special:magic"
          "$mod SHIFT, S, togglespecialworkspace, magic"

          (mvfocus "k" "u")
          (mvfocus "j" "d")
          (mvfocus "l" "r")
          (mvfocus "h" "l")
          (mvwindow "k" "u")
          (mvwindow "j" "d")
          (mvwindow "l" "r")
          (mvwindow "h" "l")
          (mvactive "k" "0 -20")
          (mvactive "j" "0 20")
          (mvactive "l" "20 0")
          (mvactive "h" "-20 0")
          (ws "left" "e-1")
          (ws "right" "e+1")
          (mvtows "left" "e-1")
          (mvtows "right" "e+1")
        ] ++ (map (i: ws (toString i) (toString i)) arr) ++ (map (i: mvtows (toString i) (toString i)) arr);

      binde =
        let
          binding = mod: cmd: key: arg: "${mod}, ${key}, ${cmd}, ${arg}";
          resizeactive = binding "${mod} CTRL" "resizeactive";
        in
        [
          (resizeactive "k" "0 -20")
          (resizeactive "j" "0 20")
          (resizeactive "l" "20 0")
          (resizeactive "h" "-20 0")
        ];

      bindl = [
        ",XF86Display, exec, ${toggle_dpms}/bin/toggle_dpms"
        ",XF86AudioPlay,    exec, ${playerctl} play-pause"
        ",XF86AudioStop,    exec, ${playerctl} pause"
        ",XF86AudioPause,   exec, ${playerctl} pause"
        ",XF86AudioPrev,    exec, ${playerctl} previous"
        ",XF86AudioNext,    exec, ${playerctl} next"
        ",XF86AudioMute, exec, wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"
        ",XF86AudioMicMute, exec, wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"
      ];

      bindle = [
        ",XF86MonBrightnessUp,   exec, ${light} -A 5%"
        ",XF86MonBrightnessDown, exec, ${light} -U 5%"
        ",XF86AudioRaiseVolume,  exec, ${wpctl} set-volume @DEFAULT_AUDIO_SINK@ 5%+"
        ",XF86AudioLowerVolume,  exec, ${wpctl} set-volume @DEFAULT_AUDIO_SINK@ 5%-"
      ];

      # bindm = [
      #   "$mod, mouse:273, resizewindow"
      #   "$mod, mouse:272, movewindow"
      # ];

      windowrule =
        let
          f = regex: "float, class:^(${regex})$";
        in
        [
          # #`hyprctl clients` get class、title...
          # "suppressevent maximize, class:.*"
          (f "Picture-inPicture")
          (f "imv")
          (f "mpv")
          (f "nemo")
          (f "termfloat")

          "rounding 5, class:termfloat"
          "size 980 640,class:termfloat"

          "move -25%,title:^(Picture-in-Picture)$"
          "immediate, class:^(rimworld)$"

          # smart gaps/'no gaps when only'
          "bordersize 0, floating:0, onworkspace:w[tv1]"
          "rounding 0, floating:0, onworkspace:w[tv1]"
          "bordersize 0, floating:0, onworkspace:f[1]"
          "rounding 0, floating:0, onworkspace:f[1]"
        ];

      workspace = [
        # smart gaps/'no gaps when only'
        "w[tv1], gapsout:0, gapsin:0"
        "f[1], gapsout:0, gapsin:0"
      ];

      decoration = {
        shadow = {
          enabled = true;
          range = 8;
          render_power = 2;
          color = "rgba(00000044)";
        };

        # dim_inactive = false;
        # dim_strength = 0.5;
        dim_special = 0.2;

        blur = {
          enabled = true;
          ignore_opacity = false;
          popups = true;
          new_optimizations = true;
          xray = true;

          size = 8;
          passes = 3;
          noise = 0.01;
          contrast = 0.9;
          brightness = 0.8;
        };
      };

      animations = {
        enabled = true;
        bezier = "myBezier, 0.05, 0.9, 0.1, 1.05";
        animation = [
          "windows, 1, 5, myBezier"
          "windowsOut, 1, 7, default, popin 80%"
          "border, 1, 10, default"
          "borderangle, 1, 8, default"
          "fade, 1, 7, default"
          "workspaces, 1, 6, default"
        ];
      };
    };
  };
}
