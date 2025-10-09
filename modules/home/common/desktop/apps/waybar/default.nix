{ pkgs, lib, config, ... }:

let
  # sharedScripts = import ../../../shared_scripts.nix { inherit pkgs; };
  style = builtins.readFile ./style.css;
  cfg = config.kor.desktop.apps.waybar;
in
{
  options.kor.desktop.apps.waybar = with lib; {
    enable = mkEnableOption "waybar panel";
    hyprlandAutostart = mkOption { type = types.bool; default = false; description = "Whether to exec-once waybar on hyprland"; };
    modules-left = mkOption {
      type = types.listOf types.str;
      default = [ "idle_inhibitor" "backlight" "wireplumber" "hyprland/workspaces" ];
      description = "left side panel modules";
    };
    modules-center = mkOption {
      type = types.listOf types.str;
      default = [ "clock" ];
      description = "center panel modules";
    };
    modules-right = mkOption {
      type = types.listOf types.str;
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
          format = " {percentage}%";
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
          # format-ethernet = "󰈀 {ifname}";
          format-ethernet = "󰈀 ETH";
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
