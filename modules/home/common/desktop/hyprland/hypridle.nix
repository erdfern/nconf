{ ... }:
{
  services.hypridle = {
    enable = true;
    settings = {
      general = {
        ignore_dbus_inhibit = false;
        lock_cmd = "pidof hyprlock || hyprlock";
        # before_sleep_cmd = "loginctl lock-session";
        # after_sleep_cmd = "hyprctl dispatch dpms on";
      };
      listener = [
        # {
        #   timeout = 150; # 2.5min.
        #   on-timeout = "${light} -O && ${light} -S 10"; # set monitor backlight to minimum, avoid 0 on OLED monitor.
        #   on-resume = "${light} -I"; # monitor backlight restore.
        # }
        # turn off keyboard backlight, comment out this section if you dont have a keyboard backlight.
        # {
        #     timeout = 150                                          # 2.5min.
        #     on-timeout = brightnessctl -sd rgb:kbd_backlight set 0 # turn off keyboard backlight.
        #     on-resume = brightnessctl -rd rgb:kbd_backlight        # turn on keyboard backlight.
        # }
        {
          # lock screen
          timeout = 600; # 10min.
          on-timeout = "loginctl lock-session";
        }
        {
          # turn screen off
          timeout = 900; # 15min.
          on-timeout = "hyprctl dispatch dpms off";
          on-resume = "hyprctl dispatch dpms on";
        }
        # {
        #   # suspend
        #   timeout = 1800; # 30min.
        #   on-timeout = "systemctl suspend";
        # }
      ];
    };
  };
}
