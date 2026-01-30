{ pkgs, config, ... }:
let
  app2unit = "${pkgs.app2unit-kor}/bin/app2unit";
  uwsmRun = cmd: "${app2unit} ${cmd}";
  toggle_waybar = pkgs.writeShellScript "toggle_waybar" ''
    ${pkgs.killall}/bin/killall .waybar-wrapped || ${pkgs.waybar}/bin/waybar > /dev/null 2>&1 &
  '';
  toggle_hyprpanel = pkgs.writeShellScript "toggle_hyprpanel" ''
    hyprpanel toggleWindow bar-0
  '';
  toggle_bar = if config.kor.desktop.apps.waybar.enable then toggle_waybar else toggle_hyprpanel;
  toggle_dpms = pkgs.writeShellScriptBin "toggle_dpms" ''
    if [ "$(hyprctl monitors all -j | ${pkgs.jq}/bin/jq 'map(.dpmsStatus) | any')" = "true" ]; then
      hyprctl dispatch dpms off
    else
      hyprctl dispatch dpms on
    fi
  '';
  grimblast = "${pkgs.grimblast}/bin/grimblast";
  hyprlock = "${pkgs.hyprlock}/bin/hyprlock";
  playerctl = "${pkgs.playerctl}/bin/playerctl";
  wpctl = "${pkgs.wireplumber}/bin/wpctl";
  # light = "${pkgs.light}/bin/light";
  bright = "${pkgs.brightnessctl}/bin/brightnessctl";
  fuzzel = "${pkgs.fuzzel}/bin/fuzzel";
  powermenu = "${pkgs.fuzzel-powermenu}/bin/fuzzel-powermenu";

  terminal = cfg.terminal;
  quick-terminal = cfg.terminalQ;

  mod = "ALT";

  cfg = config.kor.desktop.hyprland;
in
{
  wayland.windowManager.hyprland = {
    sourceFirst = true;
    # toggle keybinds
    extraConfig =
      ''
        bind = ${mod}, F11, submap, clean
        submap = clean
        bind = ${mod}, F11, submap, reset
        submap = reset
      '';
    settings = {
      binds = {
        workspace_back_and_forth = true;
        allow_workspace_cycles = true;
        movefocus_cycles_fullscreen = true; # my beloved :}
        # movefocus_cycles_groupfirst = true;
      };

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
          # "${mod} CTRL, Delete, exit" # bye bye
          "${mod} CTRL, Delete, exec, loginctl terminate-user \"\"" # bye bye uwsm
          "${mod} CTRL, X, exec, pidof ${hyprlock} || ${hyprlock}"

          "${mod} SHIFT, Q, killactive"

          "${mod} SHIFT, tab, togglefloating"
          "${mod}, F, fullscreen"
          "${mod} SHIFT, F, fullscreenstate, 0 3" # client internal state to fullscreen, hyprland state to.. not
          # "${mod}, G, fullscreenstate, 3 3" # fullscreen, same as 2 2 i think??
          # "${mod}, G, fullscreenstate, 1 0"
          "${mod}, P, togglesplit"
          # "${mod}, T, togglegroup"

          ",Super_L, exec, pkill fuzzel || ${fuzzel}"
          "${mod}, Super_L,exec, pkill fuzzel || ${uwsmRun powermenu}"
          # ",code:277, exec, pkill fuzzel || ${uwsmRun powermenu}"
          ",mouse:277, exec, pkill fuzzel || ${uwsmRun powermenu}"
          "${mod}, Return, exec, ${uwsmRun terminal}"
          # "${mod} SHIFT, Return, exec, ${uwsmRun terminal} --class='termfloat'"
          "${mod} SHIFT, Return, exec, ${uwsmRun quick-terminal}"
          # "${mod} SHIFT, code:49, exec, ${uwsmRun quick-terminal}"
          "${mod}, grave, exec, ${uwsmRun quick-terminal}"
          # "${mod} SHIFT, Return, exec, [termfloat;noanim] $TERMINAL"
          "${mod} SHIFT, O, exec, ${uwsmRun toggle_bar}"
          "${mod}, bracketleft, exec, ${uwsmRun grimblast} --notify copysave area ~/Pictures/$(date \"+%Y-%m-%d\"T\"%H:%M:%S\").png"
          "${mod}, bracketright, exec, ${uwsmRun grimblast} --notify copy area"
          "${mod}, Print, exec, ${uwsmRun grimblast} --notify copy screen"

          # clipse
          "${mod} SHIFT, grave, exec, ${uwsmRun terminal} --class clipse -e 'clipse'"

          # minimize using special workspace
          "${mod} SHIFT, S, togglespecialworkspace, magic"
          "${mod} SHIFT, S, movetoworkspace, +0"
          "${mod} SHIFT, S, togglespecialworkspace, magic"
          "${mod} SHIFT, S, movetoworkspace, special:magic"
          "${mod} SHIFT, S, togglespecialworkspace, magic"

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
        ",XF86Display,      exec, ${toggle_dpms}/bin/toggle_dpms"
        ",XF86AudioPlay,    exec, ${playerctl} play-pause"
        ",XF86AudioStop,    exec, ${playerctl} pause"
        ",XF86AudioPause,   exec, ${playerctl} pause"
        ",XF86AudioPrev,    exec, ${playerctl} previous"
        ",XF86AudioNext,    exec, ${playerctl} next"
        ",XF86AudioMute,    exec, wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"
        ",XF86AudioMicMute, exec, wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"
      ];

      bindle = [
        ",XF86MonBrightnessUp,   exec, ${bright} set +5%" # TODO conditional on host having brightness control
        ",XF86MonBrightnessDown, exec, ${bright} set 5%-" # "
        ",XF86AudioRaiseVolume,  exec, ${wpctl} set-volume @DEFAULT_AUDIO_SINK@ 5%+"
        ",XF86AudioLowerVolume,  exec, ${wpctl} set-volume @DEFAULT_AUDIO_SINK@ 5%-"
      ];

      # bindm = [
      #   "${mod}, mouse:273, resizewindow"
      #   "${mod}, mouse:272, movewindow"
      # ];
    };
  };
}
