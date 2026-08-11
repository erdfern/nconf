# HM
{ ... }:
{
  services.wayle.settings =
    {
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
                name = "Audio";
              }
              {
                modules = [ "hyprland-workspaces" ];
                name = "Workspaces";
              }
            ];
            monitor = "*";
            right = [
              {
                modules = [
                  "cpu"
                  "ram"
                  "battery"
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
        scale = 0.75;
      };
      general = {
        tearing-mode = true;
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
        scale = 0.6;
      };
      wallpaper = {
        engine-enabled = false;
      };
    };
}
