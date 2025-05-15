{ pkgs, lib, config, nixosConfig, ... }:

let
  # sharedScripts = import ../../../shared_scripts.nix { inherit pkgs; };
  style = builtins.readFile ./style.css;
  cfg = config.kor.desktop.apps.waybar;
in
{
  options.kor.desktop.apps.waybar = with lib; {
    enable = mkEnableOption "waybar panel";
    modules-left = mkOption {
      type = types.listOf types.string;
      default = [ "idle_inhibitor" "backlight" "wireplumber" "hyprland/workspaces" ];
      description = "left side panel modules";
    };
    modules-center = mkOption {
      type = types.listOf types.string;
      default = [ "clock" ];
      description = "center panel modules";
    };
    modules-right = mkOption {
      type = types.listOf types.string;
      default = [ "cpu" "memory" "temperature" "battery" "network" "tray" ];
      description = "right side panel modules";
    };
    # TODO settings option with merge
  };

  config = lib.mkIf cfg.enable {
    # services.blueman-applet.enable = true;
    # services.network-manager-applet.enable = true;

    programs.waybar = {
      enable = true;
      systemd = {
        enable = lib.mkForce false; # disable it, autostart it in hyprland conf
        target = "graphical-session.target";
      };
      settings = [{
        layer = "top";
        position = "top";
        # height = 30;

        modules-left = lib.mkIf (cfg.modules-left != { }) cfg.modules-left;
        modules-center = lib.mkIf (cfg.modules-center != { }) cfg.modules-center;
        modules-right = lib.mkIf (cfg.modules-right != { }) cfg.modules-right;

        cpu = {
          interval = 1;
          format = "󰻠 {usage}%";
        };
        backlight = {
          device = "intel_backlight";
          on-scroll-up = "light -A 5";
          on-scroll-down = "light -U 5";
          format = "{icon} {percent}%";
          format-icons = [ "󰃝" "󰃞" "󰃟" "󰃠" ];
        };
        memory = {
          interval = 1;
          format = "󰍛 {percentage}%";
          states = {
            warning = 85;
          };
        };
        battery = {
          interval = 10;
          states = {
            warning = 20;
            critical = 10;
          };
          format = "{icon} {capacity}%";
          format-icons = [ "󰁺" "󰁻" "󰁼" "󰁽" "󰁾" "󰁿" "󰂀" "󰂁" "󰂂" "󰁹" ];
          format-full = "{icon} {capacity}%";
          format-charging = "󰂄 {capacity}%";
          tooltip = false;
        };
        "hyprland/workspaces" = {
          format = "{icon}:{windows}";
          # format-window-separator = "\n";
          window-rewrite-default = "";
          window-rewrite = {
            "title<.*youtube.*>" = "";
            "class<firefox>" = "";
            "class<firefox> title<.*github.*>" = "";
            "kitty" = "";
            "steam" = "";
            # "code" = "󰨞";
          };
        };
        network = {
          max-length = 32;
          format-disconnected = "󰯡 Disconnected";
          format-ethernet = "󰈀 {ifname})";
          format-linked = "󰖪 {essid} (No IP)";
          format-wifi = "󰖩 {essid}";
          interval = 1;
          tooltip = true;
          tooltip-format = "{ifname} via {gwaddr}";
          tooltip-format-wifi = "{essid} ({signalStrength}%) ↓{bandwidthDownBytes} ↑{bandwidthUpBytes}";
          tooltip-format-ethernet = "{ifname} ↓{bandwidthDownBytes} ↑{bandwidthUpBytes}";
          tooltip-format-disconnected = "Disconnected";
        };
        temperature = {
          critical-threshold = 64;
          # thermal-zone = if isT14 then 3 else 1;
          thermal-zone = 3;
          tooltip = false;
          format = " {temperatureC}󰔄";
          format_critical = " {temperatureC}󰔄";
        };
        tray = {
          icon-size = 15;
          spacing = 5;
        };
        idle_inhibitor = {
          format = "{icon}";
          format-icons = {
            activated = "";
            deactivated = "";
          };
        };
        clock = {
          format = "{:%H:%M}";
          format-alt = "{:%A, %B %d, %Y (%R)}";
          tooltip-format = "<tt><small>{calendar}</small></tt>";
          calendar = {
            mode = "year";
            mode-mon-col = 3;
            weeks-pos = "right";
            on-scroll = 1;
            on-click-right = "mode";
            format = {
              months = "<span color='#ffead3'><b>{}</b></span>";
              days = "<span color='#ecc6d9'><b>{}</b></span>";
              weeks = "<span color='#99ffdd'><b>W{}</b></span>";
              weekdays = "<span color='#ffcc66'><b>{}</b></span>";
              today = "<span color='#ff6699'><b><u>{}</u></b></span>";
            };
          };
          actions = {
            on-click-right = "mode";
            on-click-forward = "tz_up";
            on-click-backward = "tz_down";
            on-scroll-up = "shift_up";
            on-scroll-down = "shift_down";
          };
        };
        wireplumber = {
          max-length = 16;
          scroll-step = 1;
          format = "{icon} {volume}% {node_name}";
          format-muted = "󰝟";
          format-icons = [ "󰕿" "󰕾" "󰖀" ];
          on-click = "${pkgs.wireplumber}/bin/wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle";
          tooltip = true;
          tooltip-format = "{node_name}@{volume}%";
        };
      }];
      style = style;
    };
  };
}
# { pkgs, lib, nixosConfig, ... }:
# let
#   sharedScripts = import ../../../shared_scripts.nix { inherit pkgs; };
#   isT14 = nixosConfig.networking.hostName == "kor-t14";
# in
# {
#   # TODO: the applet services don't survive `exit`
#   services.blueman-applet.enable = true;
#   services.network-manager-applet.enable = true;
#   programs.waybar = {
#     enable = true;
#     catppuccin.enable = true;
#     systemd = {
#       enable = false; # disable it, autostart it in hyprland conf
#       # target = "graphical-session.target";
#     };
#     settings = [{
#       "layer" = "top";
#       "position" = "top";
#       modules-left = [
#         "custom/launcher"
#         "hyprland/workspaces"
#         "idle_inhibitor"
#         "wireplumber"
#         (lib.mkIf isT14 "backlight")
#         # "backlight"
#         # "mpd"
#         # "cava"
#       ];
#       modules-center = [
#         "clock"
#       ];
#       modules-right = [
#         "cpu"
#         "memory"
#         "temperature"
#         "battery"
#         "network"
#         "tray"
#         "custom/powermenu"
#       ];
#       idle_inhibitor = {
#         format = "{icon}";
#         format-icons = {
#           activated = "";
#           deactivated = "";
#         };
#       };
#       "custom/launcher" = {
#         "format" = "";
#         "on-click" = "pkill fuzzel || fuzzel";
#         "tooltip" = false;
#       };
#       "cava" = {
#         # "cava_config"= "$XDG_CONFIG_HOME/cava/cava.conf";
#         "autohide" = 1;
#         "framerate" = 30;
#         "autosens" = 1;
#         # "sensitivity" = 100;
#         "bars" = 14;
#         "lower_cutoff_freq" = 50;
#         "higher_cutoff_freq" = 10000;
#         "method" = "pipewire";
#         "source" = "auto";
#         "stereo" = true;
#         "reverse" = false;
#         "bar_delimiter" = 0;
#         "monstercat" = false;
#         "waves" = false;
#         "noise_reduction" = 0.77;
#         "input_delay" = 2;
#         "format-icons" = [ "▁" "▂" "▃" "▄" "▅" "▆" "▇" "█" ];
#         # "actions" = { "on-click-right" = "mode"; };
#       };
#       "hyprland/workspaces" = {
#         "format" = "{icon}";
#         # "on-click" = "activate";
#         # "on-scroll-up" = "hyprctl dispatch workspace e+1";
#         # "on-scroll-down" = "hyprctl dispatch workspace e-1";
#       };
#       "backlight" = {
#         "device" = "intel_backlight";
#         "on-scroll-up" = "light -A 5";
#         "on-scroll-down" = "light -U 5";
#         "format" = "{icon} {percent}%";
#         "format-icons" = [ "󰃝" "󰃞" "󰃟" "󰃠" ];
#       };
#       "wireplumber" = {
#         "scroll-step" = 1;
#         "format" = "{icon} {node_name} {volume}%";
#         "format-muted" = "󰖁";
#         "format-icons" = [ "" "" "󰖀" "" ];
#         "on-click" = "pamixer -t";
#         "tooltip" = false;
#       };
#       "battery" = {
#         "interval" = 10;
#         "states" = {
#           "warning" = 20;
#           "critical" = 10;
#         };
#         "format" = "{icon} {capacity}%";
#         "format-icons" = [ "󰁺" "󰁻" "󰁼" "󰁽" "󰁾" "󰁿" "󰂀" "󰂁" "󰂂" "󰁹" ];
#         "format-full" = "{icon} {capacity}%";
#         "format-charging" = "󰂄 {capacity}%";
#         "tooltip" = false;
#       };
#       "clock" = {
#         "format" = "{:%H:%M}";
#         "format-alt" = "{:%A, %B %d, %Y (%R)}";
#         "tooltip-format" = "<tt><small>{calendar}</small></tt>";
#         "calendar" = {
#           "mode" = "year";
#           "mode-mon-col" = 3;
#           "weeks-pos" = "right";
#           "on-scroll" = 1;
#           "on-click-right" = "mode";
#           "format" = {
#             "months" = "<span color='#ffead3'><b>{}</b></span>";
#             "days" = "<span color='#ecc6d9'><b>{}</b></span>";
#             "weeks" = "<span color='#99ffdd'><b>W{}</b></span>";
#             "weekdays" = "<span color='#ffcc66'><b>{}</b></span>";
#             "today" = "<span color='#ff6699'><b><u>{}</u></b></span>";
#           };
#         };
#         "actions" = {
#           "on-click-right" = "mode";
#           "on-click-forward" = "tz_up";
#           "on-click-backward" = "tz_down";
#           "on-scroll-up" = "shift_up";
#           "on-scroll-down" = "shift_down";
#         };
#       };
#       "memory" = {
#         "interval" = 1;
#         "format" = "󰍛 {percentage}%";
#         "states" = {
#           "warning" = 85;
#         };
#       };
#       "cpu" = {
#         "interval" = 1;
#         "format" = "󰻠 {usage}%";
#       };
#       "mpd" = {
#         "max-length" = 25;
#         "format" = "<span foreground='#bb9af7'></span> {title}";
#         "format-paused" = " {title}";
#         "format-stopped" = "<span foreground='#bb9af7'></span>";
#         "format-disconnected" = "";
#         "on-click" = "mpc --quiet toggle";
#         "on-click-right" = "mpc update; mpc ls | mpc add";
#         "on-click-middle" = "kitty --class='ncmpcpp' ncmpcpp";
#         "on-scroll-up" = "mpc --quiet prev";
#         "on-scroll-down" = "mpc --quiet next";
#         "smooth-scrolling-threshold" = 5;
#         "tooltip-format" = "{title} - {artist} ({elapsedTime:%M:%S}/{totalTime:%H:%M:%S})";
#       };
#       "network" = {
#         "max-length" = 40;
#         "format-disconnected" = "󰯡 Disconnected";
#         "format-ethernet" = "󰀂 {ifname})";
#         "format-linked" = "󰖪 {essid} (No IP)";
#         "format-wifi" = "󰖩 {essid}";
#         "interval" = 1;
#         "tooltip" = true;
#         "tooltip-format" = "{ipaddr} {bandwidthDownBytes}";
#       };
#       "temperature" = {
#         "critical-threshold" = 64;
#         thermal-zone = if isT14 then 3 else 1;
#         tooltip = false;
#         format = " {temperatureC}󰔄";
#         format_critical = " {temperatureC}󰔄";
#       };
#       "custom/powermenu" = {
#         "format" = "";
#         "on-click" = "pkill fuzzel || ${sharedScripts.fuzzel-powermenu}/bin/fuzzel-powermenu";
#         "tooltip" = false;
#       };
#       "tray" = {
#         "icon-size" = 15;
#         "spacing" = 5;
#       };
#     }];
#     style = ''
#       * {
#         font-family: "JetBrainsMono Nerd Font";
#         font-size: 14px;
#         font-weight: bold;
#         border: none;
#         border-radius: 0;
#         min-height: 0;
#         transition-property: background-color;
#         transition-duration: 0.5s;
#       }
#       window#waybar {
#         background: @theme_bg_color;
#         color: @theme_text_color;
#       }
#       tooltip {
#         background: @theme_base_color;
#       }
#       tooltip label {
#         color: @theme_text_color;
#       }
#       #mode, #idle_inhibitor, #clock, #memory, #temperature ,#cpu , #mpd, #temperature, #backlight, #wireplumber, #network, #battery, #custom-powermenu, #cava {
#         padding-left: 10px;
#         padding-right: 10px;
#       }
#       @keyframes blink_error {
#         to {
#           background-color: @theme_bg_color;
#           color: @error_color;
#         }
#       }
#       @keyframes blink_warning {
#         to {
#           background-color: @theme_bg_color;
#           color: @error_color;
#         }
#       }
#       .warning {
#         animation-name: blink_warning;
#         animation-duration: 1s;
#         animation-timing-function: linear;
#         animation-iteration-count: infinite;
#         animation-direction: alternate;
#       }
#       .critical, .urgent {
#         animation-name: blink_error;
#         animation-duration: 1s;
#         animation-timing-function: linear;
#         animation-iteration-count: infinite;
#         animation-direction: alternate;
#       }
#       #workspaces button {
#           padding: 0 5px;
#           background: transparent;
#           color: @theme_text_color;
#           border-bottom: 3px solid transparent;
#       }
#       #workspaces button.focused {
#           background: @theme_selected_bg_color;
#           border-bottom: 3px solid @borders;
#       }
#       #custom-launcher {
#         font-size: 20px;
#         padding-left: 8px;
#         padding-right: 6px;
#         color: @sky;
#       }
#       #memory {
#         color: @sapphire;
#       }
#       #cpu {
#         color: @lavender;
#       }
#       #clock {
#         color: @text;
#       }
#       #temperature {
#         color: @mauve;
#       }
#       #temperature.critical {
#         color: @red;
#       }
#       #backlight {
#         color: @yellow;
#       }
#       #wireplumber {
#         color: #8bd5ca;
#       }
#       #wireplumber.muted {
#         color: #b7bdf8
#       }
#       #network {
#         color: #b7bdf8;
#       }
#       #network.disconnected {
#         color: #cccccc;
#       }
#       #battery.charging, #battery.full, #battery.discharging {
#         color: @green;
#       }
#       #battery.warning:not(.charging) {
#         color: @warning_collor;
#       }
#       #battery.critical:not(.charging) {
#         color: @error_color;
#         animation-name: blink_error;
#         animation-duration: 1s;
#         animation-timing-function: steps(12);
#         animation-iteration-count: infinite;
#         animation-direction: alternate;
#       }
#       #custom-powermenu {
#         color: @text;
#       }
#       #tray menu {
#         background: @theme_bg_color;
#         color: @text;
#       }
#       #tray {
#           background-color: @theme_bg_color;
#       }
#       #tray > .passive {
#           -gtk-icon-effect: dim;
#       }
#       #tray > .needs-attention {
#           -gtk-icon-effect: highlight;
#           /*background-color: @warning_color;*/
#       }
#       #idle_inhibitor { color: @theme_text_color; -gtk-icon-effect: dim; }
#       #idle_inhibitor.activated { color: @yellow; }
#     '';
#   };
# }
