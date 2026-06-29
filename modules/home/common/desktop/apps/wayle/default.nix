{ pkgs, lib, config, inputs, ... }:

let
  cfg = config.kor.desktop.apps.wayle;
in
{
  options.kor.desktop.apps.wayle = with lib;
    {
      enable = mkEnableOption "wayle bar";
    };

  config = lib.mkIf cfg.enable {
    xdg.configFile."wayle/config.toml".force = true;
    services.wayle = {
      enable = true;
      # package = wayle-git;
      autoInstallDependencies = true;
      settings = {
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
                "separator"
                {
                  modules = [
                    "microphone"
                    "volume"
                  ];
                  name = "group";
                }
                "separator"
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
                "separator"
                {
                  modules = [
                    "cpu"
                    "ram"
                    "storage"
                  ];
                  name = "Metrics";
                }
                "separator"
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
    };
  };
}
