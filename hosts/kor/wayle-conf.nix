# HM
{ ... }:
{
  services.wayle.settings = {
    bar = {
      button-variant = "basic";
      layout = [
        {
          center = [ "clock" ];
          left = [
            {
              modules = [
                "dashboard"
                "hyprsunset"
                "idle-inhibit"
              ];
              name = "group";
            }
            {
              modules = [
                "microphone"
                "volume"
              ];
              name = "group";
            }
            {
              modules = [
                "cava"
                "media"
              ];
              name = "group";
            }
          ];
          monitor = "*";
          right = [
            {
              modules = [
                "hyprland-workspaces"
                "keybind-mode"
                "keyboard-input"
              ];
              name = "Desktop";
            }
            {
              modules = [
                "cpu"
                "ram"
                "storage"
                "netstat"
                "network"
              ];
              name = "Monitoring";
            }
            {
              modules = [
                "systray"
                "notifications"
              ];
              name = "System";
            }
          ];
          show = true;
        }
      ];
    };
    modules = {
      clock = {
        format = "%a %b %d %H:%M";
      };
      dashboard = {
        dropdown-lock-command = "pidof hyprlock || hyprlock";
        dropdown-logout-command = "uwsm stop";
      };
      hyprland-workspaces = {
        app-icons-show = true;
      };
      notifications = {
        middle-click = "wayle notify dismiss-all";
      };
      volume = {
        scroll-down = "wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-";
        scroll-up = "wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%+";
      };
      weather = {
        location = "Göttingen";
        time-format = "24h";
      };
    };
    styling = {
      palette = {
        bg = "#11111b";
        blue = "#74c7ec";
        elevated = "#1e1e2e";
        fg = "#cdd6f4";
        fg-muted = "#bac2de";
        green = "#a6e3a1";
        primary = "#fab387";
        red = "#f38ba8";
        surface = "#181825";
        yellow = "#f9e2af";
      };
    };
    wallpaper = {
      engine-enabled = false;
    };
  };
}
