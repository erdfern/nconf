{ pkgs, config, lib, ... }:
let
  app2unit = "${pkgs.app2unit-kor}/bin/app2unit";
  uwsmRun = cmd: "${app2unit} ${cmd}";

  grimblast = "${pkgs.grimblast}/bin/grimblast";
  hyprlock = "${pkgs.hyprlock}/bin/hyprlock";
  playerctl = "${pkgs.playerctl}/bin/playerctl";
  wpctl = "${pkgs.wireplumber}/bin/wpctl";
  # light = "${pkgs.light}/bin/light";
  bright = "${pkgs.brightnessctl}/bin/brightnessctl";
  fuzzel = "${pkgs.fuzzel}/bin/fuzzel";
  powermenu = "${pkgs.fuzzel-powermenu}/bin/fuzzel-powermenu";
  swayosdClient = "${pkgs.swayosd}/bin/swayosd-client";

  useOSD = config.kor.desktop.apps.swayosd.enable;

  # NOTE: these now hold the bare command (no "exec," prefix), since under the
  # Lua config the prefix is replaced by wrapping in hl.dsp.exec_cmd(...).
  volUp = if useOSD then "${swayosdClient} --output-volume raise" else "${wpctl} set-volume @DEFAULT_AUDIO_SINK@ 5%+";
  volDown = if useOSD then "${swayosdClient} --output-volume lower" else "${wpctl} set-volume @DEFAULT_AUDIO_SINK@ 5%-";
  volMute = if useOSD then "${swayosdClient} --output-volume mute-toggle" else "${wpctl} set-mute @DEFAULT_AUDIO_SINK@ toggle";
  micMute = if useOSD then "${swayosdClient} --input-volume mute-toggle" else "${wpctl} set-mute @DEFAULT_AUDIO_SOURCE@ toggle";
  briUp = if useOSD then "${swayosdClient} --brightness raise" else "${bright} set +5%";
  briDown = if useOSD then "${swayosdClient} --brightness lower" else "${bright} set 5%-";

  toggle_waybar = pkgs.writeShellScript "toggle_waybar" ''
    ${pkgs.killall}/bin/killall .waybar-wrapped || ${pkgs.waybar}/bin/waybar > /dev/null 2>&1 &
  '';
  toggle_hyprpanel = pkgs.writeShellScript "toggle_hyprpanel" ''
    hyprpanel toggleWindow bar-0
  '';
  toggle_bar = if config.kor.desktop.apps.waybar.enable then toggle_waybar else toggle_hyprpanel;
  toggle_dpms = pkgs.writeShellScript "toggle_dpms" ''
    if [ "$(hyprctl monitors all -j | ${pkgs.jq}/bin/jq 'map(.dpmsStatus) | any')" = "true" ]; then
      hyprctl dispatch dpms off
    else
      hyprctl dispatch dpms on
    fi
  '';
  toggle_clipse = pkgs.writeShellScript "toggle_clipse" ''
    if ${pkgs.hyprland}/bin/hyprctl clients -j | ${pkgs.jq}/bin/jq -e '.[] | select(.class == "clipse")' > /dev/null; then
      ${pkgs.hyprland}/bin/hyprctl dispatch closewindow class:clipse
    else
      ${uwsmRun terminal} --class clipse -e 'clipse'
    fi
  '';

  terminal = cfg.terminal;
  quick-terminal = cfg.terminalQ;

  mod = "ALT";

  cfg = config.kor.desktop.hyprland;

  # --- Lua helpers -----------------------------------------------------------
  inherit (lib.generators) mkLuaInline;

  # Wrap a string as an escaped Lua double-quoted literal.
  luaStr = s: "\"" + lib.escape [ "\\" "\"" ] s + "\"";

  # hl.bind("<key>", <dispatcher>)
  mkBind = key: dsp: { _args = [ key (mkLuaInline dsp) ]; };
  # hl.bind("<key>", <dispatcher>, <flags>)
  mkBindFlags = flags: key: dsp: { _args = [ key (mkLuaInline dsp) flags ]; };

  # hl.bind("<key>", hl.dsp.exec_cmd("<cmd>"))
  mkExec = key: cmd: mkBind key "hl.dsp.exec_cmd(${luaStr cmd})";
  mkExecFlags = flags: key: cmd: mkBindFlags flags key "hl.dsp.exec_cmd(${luaStr cmd})";

  arr = [ "1" "2" "3" "4" "5" "6" "7" "8" "9" "0" ];

  # --- bind (no flags) -------------------------------------------------------
  mainBinds = [
    # "${mod} + CTRL + Delete" -> hl.dsp.exit() # bye bye
    (mkExec "${mod} + CTRL + Delete" ''loginctl terminate-user ""'') # bye bye uwsm
    (mkExec "${mod} + CTRL + X" "pidof ${hyprlock} || ${hyprlock}")

    (mkBind "${mod} + SHIFT + Q" "hl.dsp.window.close()")

    (mkBind "${mod} + SHIFT + tab" ''hl.dsp.window.float({ action = "toggle" })'')
    (mkBind "${mod} + F" "hl.dsp.window.fullscreen()")
    # client internal state to fullscreen, hyprland state to.. not
    (mkBind "${mod} + SHIFT + F" ''hl.dsp.window.fullscreen_state({ internal = 0, client = 3, action = "toggle" })'')
    (mkBind "${mod} + P" ''hl.dsp.layout("togglesplit")'')
    (mkBind "${mod} + SHIFT + P" ''hl.dsp.layout("swapsplit")'')

    (mkExec "Super_L" "pkill fuzzel || ${fuzzel}")
    (mkExec "${mod} + Super_L" "pkill fuzzel || ${uwsmRun powermenu}")
    (mkExec "mouse:277" "pkill fuzzel || ${uwsmRun powermenu}")
    (mkExec "${mod} + Return" (uwsmRun terminal))
    (mkExec "${mod} + SHIFT + Return" (uwsmRun quick-terminal))
    (mkExec "${mod} + grave" (uwsmRun quick-terminal))
    (mkExec "${mod} + SHIFT + O" (uwsmRun toggle_bar))
    (mkExec "${mod} + bracketleft" ''${uwsmRun grimblast} --notify copysave area ~/Pictures/$(date "+%Y-%m-%d"T"%H:%M:%S").png'')
    (mkExec "${mod} + bracketright" "${uwsmRun grimblast} --notify copy area")
    (mkExec "${mod} + Print" "${uwsmRun grimblast} --notify copy screen")

    # clipse
    (mkExec "${mod} + SHIFT + grave" "${toggle_clipse}")

    # minimize using special workspace (a single bind that runs several
    # dispatchers in sequence -> a Lua function)
    {
      _args = [
        "${mod} + SHIFT + S"
        (mkLuaInline ''
          function()
            hl.dispatch(hl.dsp.workspace.toggle_special("magic"))
            hl.dispatch(hl.dsp.window.move({ workspace = "+0" }))
            hl.dispatch(hl.dsp.workspace.toggle_special("magic"))
            hl.dispatch(hl.dsp.window.move({ workspace = "special:magic" }))
            hl.dispatch(hl.dsp.workspace.toggle_special("magic"))
          end'')
      ];
    }
  ];

  # movefocus -> hl.dsp.focus({ direction })
  focusBinds = lib.mapAttrsToList
    (key: d: mkBind "${mod} + ${key}" ''hl.dsp.focus({ direction = "${d}" })'')
    { k = "up"; j = "down"; l = "right"; h = "left"; };

  # movewindow (directional) -> hl.dsp.window.move({ direction })
  windowMoveBinds = lib.mapAttrsToList
    (key: d: mkBind "${mod} + SHIFT + ${key}" ''hl.dsp.window.move({ direction = "${d}" })'')
    { k = "up"; j = "down"; l = "right"; h = "left"; };

  # moveactive -> hl.dsp.window.move({ x, y, relative = true })
  moveActiveBinds = map
    ({ key, x, y }: mkBind "${mod} + CTRL + SHIFT + ${key}"
      "hl.dsp.window.move({ x = ${toString x}, y = ${toString y}, relative = true })")
    [
      { key = "k"; x = 0; y = -20; }
      { key = "j"; x = 0; y = 20; }
      { key = "l"; x = 20; y = 0; }
      { key = "h"; x = -20; y = 0; }
    ];

  # workspace / movetoworkspace (relative) -> hl.dsp.focus / hl.dsp.window.move
  wsNavBinds = [
    (mkBind "${mod} + left" ''hl.dsp.focus({ workspace = "e-1" })'')
    (mkBind "${mod} + right" ''hl.dsp.focus({ workspace = "e+1" })'')
    (mkBind "${mod} + SHIFT + left" ''hl.dsp.window.move({ workspace = "e-1" })'')
    (mkBind "${mod} + SHIFT + right" ''hl.dsp.window.move({ workspace = "e+1" })'')
  ];

  # workspace <n> -> hl.dsp.focus({ workspace = "<n>" })
  wsNumBinds = map (n: mkBind "${mod} + ${n}" ''hl.dsp.focus({ workspace = "${n}" })'') arr;
  # movetoworkspace <n> -> hl.dsp.window.move({ workspace = "<n>" })
  wsMoveNumBinds = map (n: mkBind "${mod} + SHIFT + ${n}" ''hl.dsp.window.move({ workspace = "${n}" })'') arr;

  # --- binde (repeating) -----------------------------------------------------
  # resizeactive -> hl.dsp.window.resize({ x, y, relative = true })
  resizeBinds = map
    ({ key, x, y }: mkBindFlags { repeating = true; } "${mod} + CTRL + ${key}"
      "hl.dsp.window.resize({ x = ${toString x}, y = ${toString y}, relative = true })")
    [
      { key = "k"; x = 0; y = -20; }
      { key = "j"; x = 0; y = 20; }
      { key = "l"; x = 20; y = 0; }
      { key = "h"; x = -20; y = 0; }
    ];

  # --- bindl (locked) --------------------------------------------------------
  lockedBinds = [
    (mkExecFlags { locked = true; } "XF86Display" "${toggle_dpms}")
    (mkExecFlags { locked = true; } "XF86AudioPlay" "${playerctl} play-pause")
    (mkExecFlags { locked = true; } "XF86AudioStop" "${playerctl} pause")
    (mkExecFlags { locked = true; } "XF86AudioPause" "${playerctl} pause")
    (mkExecFlags { locked = true; } "XF86AudioPrev" "${playerctl} previous")
    (mkExecFlags { locked = true; } "XF86AudioNext" "${playerctl} next")
    (mkExecFlags { locked = true; } "XF86AudioMute" volMute)
    (mkExecFlags { locked = true; } "XF86AudioMicMute" micMute)
  ]
  ++ lib.optionals useOSD [
    (mkExecFlags { locked = true; } "Caps_Lock" "${swayosdClient} --caps-lock")
  ];

  # --- bindle (locked + repeating) -------------------------------------------
  lockedRepeatBinds = [
    (mkExecFlags { locked = true; repeating = true; } "XF86MonBrightnessUp" briUp)
    (mkExecFlags { locked = true; repeating = true; } "XF86MonBrightnessDown" briDown)
    (mkExecFlags { locked = true; repeating = true; } "XF86AudioRaiseVolume" volUp)
    (mkExecFlags { locked = true; repeating = true; } "XF86AudioLowerVolume" volDown)
  ];

  # toggle keybinds via "clean" submap (was the hyprlang extraConfig block)
  submapBinds = [
    (mkBind "${mod} + F11" ''hl.dsp.submap("clean")'')
  ];
in
{
  wayland.windowManager.hyprland = {
    # Interpret `settings` as Lua (hl.* calls) rather than hyprlang.
    configType = "lua";
    sourceFirst = true;

    settings = {
      config = {
        binds = {
          workspace_back_and_forth = true;
          allow_workspace_cycles = true;
          movefocus_cycles_fullscreen = true; # my beloved :}
          # movefocus_cycles_groupfirst = true;
        };
      };

      bind =
        mainBinds
        ++ focusBinds
        ++ windowMoveBinds
        ++ moveActiveBinds
        ++ wsNavBinds
        ++ wsNumBinds
        ++ wsMoveNumBinds
        ++ resizeBinds
        ++ lockedBinds
        ++ lockedRepeatBinds
        ++ submapBinds;

      # The "clean" submap only contains the bind to leave it again.
      define_submap = {
        _args = [
          "clean"
          (mkLuaInline ''
            function()
              hl.bind("${mod} + F11", hl.dsp.submap("reset"))
            end'')
        ];
      };

      # bindm equivalents would use mouse dispatchers, e.g.:
      #   { _args = [ "${mod} + mouse:272" (mkLuaInline "hl.dsp.window.drag()") ]; }
      #   { _args = [ "${mod} + mouse:273" (mkLuaInline "hl.dsp.window.resize()") ]; }
    };
  };
}

# { pkgs, config, lib, ... }:
# let
#   app2unit = "${pkgs.app2unit-kor}/bin/app2unit";
#   uwsmRun = cmd: "${app2unit} ${cmd}";

#   grimblast = "${pkgs.grimblast}/bin/grimblast";
#   hyprlock = "${pkgs.hyprlock}/bin/hyprlock";
#   playerctl = "${pkgs.playerctl}/bin/playerctl";
#   wpctl = "${pkgs.wireplumber}/bin/wpctl";
#   # light = "${pkgs.light}/bin/light";
#   bright = "${pkgs.brightnessctl}/bin/brightnessctl";
#   fuzzel = "${pkgs.fuzzel}/bin/fuzzel";
#   powermenu = "${pkgs.fuzzel-powermenu}/bin/fuzzel-powermenu";
#   swayosdClient = "${pkgs.swayosd}/bin/swayosd-client";

#   useOSD = config.kor.desktop.apps.swayosd.enable;

#   volUp = if useOSD then "exec, ${swayosdClient} --output-volume raise" else "exec, ${wpctl} set-volume @DEFAULT_AUDIO_SINK@ 5%+";
#   volDown = if useOSD then "exec, ${swayosdClient} --output-volume lower" else "exec, ${wpctl} set-volume @DEFAULT_AUDIO_SINK@ 5%-";
#   volMute = if useOSD then "exec, ${swayosdClient} --output-volume mute-toggle" else "exec, ${wpctl} set-mute @DEFAULT_AUDIO_SINK@ toggle";
#   micMute = if useOSD then "exec, ${swayosdClient} --input-volume mute-toggle" else "exec, ${wpctl} set-mute @DEFAULT_AUDIO_SOURCE@ toggle";
#   briUp = if useOSD then "exec, ${swayosdClient} --brightness raise" else "exec, ${bright} set +5%";
#   briDown = if useOSD then "exec, ${swayosdClient} --brightness lower" else "exec, ${bright} set 5%-";

#   toggle_waybar = pkgs.writeShellScript "toggle_waybar" ''
#     ${pkgs.killall}/bin/killall .waybar-wrapped || ${pkgs.waybar}/bin/waybar > /dev/null 2>&1 &
#   '';
#   toggle_hyprpanel = pkgs.writeShellScript "toggle_hyprpanel" ''
#     hyprpanel toggleWindow bar-0
#   '';
#   toggle_bar = if config.kor.desktop.apps.waybar.enable then toggle_waybar else toggle_hyprpanel;
#   # toggle_dpms = pkgs.writeShellScriptBin "toggle_dpms" ''
#   #   if [ "$(hyprctl monitors all -j | ${pkgs.jq}/bin/jq 'map(.dpmsStatus) | any')" = "true" ]; then
#   #     hyprctl dispatch dpms off
#   #   else
#   #     hyprctl dispatch dpms on
#   #   fi
#   # '';
#   toggle_dpms = pkgs.writeShellScript "toggle_dpms" ''
#     if [ "$(hyprctl monitors all -j | ${pkgs.jq}/bin/jq 'map(.dpmsStatus) | any')" = "true" ]; then
#       hyprctl dispatch dpms off
#     else
#       hyprctl dispatch dpms on
#     fi
#   '';
#   toggle_clipse = pkgs.writeShellScript "toggle_clipse" ''
#     if ${pkgs.hyprland}/bin/hyprctl clients -j | ${pkgs.jq}/bin/jq -e '.[] | select(.class == "clipse")' > /dev/null; then
#       ${pkgs.hyprland}/bin/hyprctl dispatch closewindow class:clipse
#     else
#       ${uwsmRun terminal} --class clipse -e 'clipse'
#     fi
#   '';

#   terminal = cfg.terminal;
#   quick-terminal = cfg.terminalQ;

#   mod = "ALT";

#   cfg = config.kor.desktop.hyprland;
# in
# {
#   wayland.windowManager.hyprland = {
#     sourceFirst = true;

#     # toggle keybinds via "clean" submap
#     extraConfig =
#       ''
#         bind = ${mod}, F11, submap, clean
#         submap = clean
#         bind = ${mod}, F11, submap, reset
#         submap = reset
#       '';

#     settings = {
#       binds = {
#         workspace_back_and_forth = true;
#         allow_workspace_cycles = true;
#         movefocus_cycles_fullscreen = true; # my beloved :}
#         # movefocus_cycles_groupfirst = true;
#       };

#       bind =
#         let
#           binding = mod: cmd: key: arg: "${mod} + ${key}, ${cmd}, ${arg}";
#           # mvfocus = binding mod "movefocus";
#           mvfocus = binding mod "focus";
#           mvwindow = binding "${mod} SHIFT" "movewindow";
#           ws = binding mod "workspace";
#           # resizeactive = binding "${mod} CTRL" "resizeactive";
#           mvactive = binding "${mod} + CTRL SHIFT" "moveactive";
#           mvtows = binding "${mod} SHIFT" "movetoworkspace";
#           arr = [ 1 2 3 4 5 6 7 8 9 0 ];
#         in
#         [
#           # "${mod} CTRL, Delete, exit" # bye bye
#           "${mod} CTRL, Delete, exec, loginctl terminate-user \"\"" # bye bye uwsm
#           "${mod} CTRL, X, exec, pidof ${hyprlock} || ${hyprlock}"

#           "${mod} SHIFT, Q, killactive"

#           "${mod} SHIFT, tab, togglefloating"
#           "${mod}, F, fullscreen"
#           "${mod} SHIFT, F, fullscreenstate, 0 3" # client internal state to fullscreen, hyprland state to.. not
#           # "${mod}, G, fullscreenstate, 3 3" # fullscreen, same as 2 2 i think??
#           # "${mod}, G, fullscreenstate, 1 0"
#           "${mod}, P, layoutmsg, togglesplit"
#           "${mod} SHIFT, P, layoutmsg, swapsplit"
#           # "${mod}, T, togglegroup"

#           ",Super_L, exec, pkill fuzzel || ${fuzzel}"
#           "${mod}, Super_L,exec, pkill fuzzel || ${uwsmRun powermenu}"
#           # ",code:277, exec, pkill fuzzel || ${uwsmRun powermenu}"
#           ",mouse:277, exec, pkill fuzzel || ${uwsmRun powermenu}"
#           "${mod}, Return, exec, ${uwsmRun terminal}"
#           # "${mod} SHIFT, Return, exec, ${uwsmRun terminal} --class='termfloat'"
#           "${mod} SHIFT, Return, exec, ${uwsmRun quick-terminal}"
#           # "${mod} SHIFT, code:49, exec, ${uwsmRun quick-terminal}"
#           "${mod}, grave, exec, ${uwsmRun quick-terminal}"
#           # "${mod} SHIFT, Return, exec, [termfloat;noanim] $TERMINAL"
#           "${mod} SHIFT, O, exec, ${uwsmRun toggle_bar}"
#           "${mod}, bracketleft, exec, ${uwsmRun grimblast} --notify copysave area ~/Pictures/$(date \"+%Y-%m-%d\"T\"%H:%M:%S\").png"
#           "${mod}, bracketright, exec, ${uwsmRun grimblast} --notify copy area"
#           "${mod}, Print, exec, ${uwsmRun grimblast} --notify copy screen"

#           # clipse
#           # "${mod} SHIFT, grave, exec, ${uwsmRun terminal} --class clipse -e 'clipse'"
#           "${mod} SHIFT, grave, exec, ${toggle_clipse}"

#           # minimize using special workspace
#           "${mod} SHIFT, S, togglespecialworkspace, magic"
#           "${mod} SHIFT, S, movetoworkspace, +0"
#           "${mod} SHIFT, S, togglespecialworkspace, magic"
#           "${mod} SHIFT, S, movetoworkspace, special:magic"
#           "${mod} SHIFT, S, togglespecialworkspace, magic"

#           (mvfocus "k" "u")
#           (mvfocus "j" "d")
#           (mvfocus "l" "r")
#           (mvfocus "h" "l")
#           (mvwindow "k" "u")
#           (mvwindow "j" "d")
#           (mvwindow "l" "r")
#           (mvwindow "h" "l")
#           (mvactive "k" "0 -20")
#           (mvactive "j" "0 20")
#           (mvactive "l" "20 0")
#           (mvactive "h" "-20 0")
#           (ws "left" "e-1")
#           (ws "right" "e+1")
#           (mvtows "left" "e-1")
#           (mvtows "right" "e+1")
#         ] ++ (map (i: ws (toString i) (toString i)) arr) ++ (map (i: mvtows (toString i) (toString i)) arr);

#       binde =
#         let
#           binding = mod: cmd: key: arg: "${mod}, ${key}, ${cmd}, ${arg}";
#           resizeactive = binding "${mod} CTRL" "resizeactive";
#         in
#         [
#           (resizeactive "k" "0 -20")
#           (resizeactive "j" "0 20")
#           (resizeactive "l" "20 0")
#           (resizeactive "h" "-20 0")
#         ];

#       bindl = [
#         # ",XF86Display,      exec, ${toggle_dpms}/bin/toggle_dpms"
#         ",XF86Display,      exec, ${toggle_dpms}"
#         ",XF86AudioPlay,    exec, ${playerctl} play-pause"
#         ",XF86AudioStop,    exec, ${playerctl} pause"
#         ",XF86AudioPause,   exec, ${playerctl} pause"
#         ",XF86AudioPrev,    exec, ${playerctl} previous"
#         ",XF86AudioNext,    exec, ${playerctl} next"

#         ",XF86AudioMute,    ${volMute}"
#         ",XF86AudioMicMute, ${micMute}"
#       ]
#       ++ (lib.optionals useOSD [
#         ",Caps_Lock, exec, ${swayosdClient} --caps-lock"
#       ]);

#       bindle = [
#         ",XF86MonBrightnessUp,   ${briUp}"
#         ",XF86MonBrightnessDown, ${briDown}"

#         ",XF86AudioRaiseVolume,  ${volUp}"
#         ",XF86AudioLowerVolume,  ${volDown}"
#       ];

#       # bindm = [
#       #   "${mod}, mouse:273, resizewindow"
#       #   "${mod}, mouse:272, movewindow"
#       # ];
#     };
#   };
# }
