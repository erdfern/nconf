{ pkgs, lib, config, inputs, ... }:

let
  cfg = config.kor.desktop.apps.hyprpanel;

  hyprpanel-git = inputs.hyprpanel.result.packages.${pkgs.stdenv.hostPlatform.system}.default;
  theme_path = "${hyprpanel-git}/share/themes/catppuccin_mocha.json";
  # theme_path = "${hyprpanel-git}/share/themes/catppuccin_mocha.json";
  # theme_path = "${hyprpanel-git}/share/themes/catppuccin_mocha_vivid.json";
  # theme_path = "${hyprpanel-git}/share/themes/catppuccin_mocha_split.json";
  # theme_path = "${hyprpanel-git}/share/themes/catppuccin_macchiato_vivid.json";
  # theme_path = "${hyprpanel-git}/share/themes/catppuccin_macchiato_split.json";
  theme = builtins.fromJSON (builtins.readFile theme_path);
in
{
  options.kor.desktop.apps.hyprpanel = with lib;
    {
      enable = mkEnableOption "hyprpanel";
    };

  config = lib.mkIf cfg.enable {

    # make sure that other notification daemons are disabled; hyprpanel uses AGS inbuild thing
    # TODO how do I keep getting notifications if I kill the barrr? :[
    kor.desktop.notifications.fnott.enable = lib.mkForce false;

    programs.hyprpanel = {
      enable = true;
      package = hyprpanel-git;

      systemd.enable = true; # service for starting panel

      # TODO set this to true to disable hyprpanels notification daemon which is buggy
      # dontAssertNotificationDaemons = true;

      settings = {
        # NOTE https://github.com/Jas-SinghFSU/HyprPanel/issues/1074
        # Configure bar layouts for monitors.
        # See 'https://hyprpanel.com/configuration/panel.html'.
        # Default: null
        bar.layouts = {
          "0" = {
            # left = [ "dashboard" "workspaces" "microphone" "volume" "cava" ];
            left = [ "dashboard" "hypridle" "hyprsunset" "microphone" "volume" "separator" "workspaces" ];
            middle = [ "media" ];
            right = [ "submap" "separator" "cputemp" "cpu" "ram" "separator" "systray" "clock" "notifications" ];
          };
        };

        # bar.launcher.autoDetectIcon = true;
        bar.launcher.icon = "";
        bar.workspaces.show_icons = true;

        # bar.clock.format = "%a %b %d %H:%M:S";
        bar.clock.format = "%a %b %d %T";

        bar.hypridle = {
          label = false;
        };
        bar.hyprsunset = {
          label = false;
        };

        menus.dashboard.directories.enabled = false;
        menus.dashboard.shortcuts.enabled = true;
        menus.dashboard.powermenu.avatar = "~/.face.icon";
        menus.dashboard.shortcuts.left = {
          shortcut1 = { icon = "󰈹"; tooltip = "Firefox"; command = "firefox"; };
          shortcut2 = { icon = ""; tooltip = "Files"; command = "nemo"; };
          # shortcut2 = { icon = ""; tooltip = "Files"; command = "nemo"; };
          shortcut4 = { command = "fuzzel"; };
        };

        menus.dashboard.stats.enable_gpu = false;
        menus.clock = {
          time = {
            military = true;
            # hideSeconds = true;
          };
          weather.unit = "metric";
          weather.key = "ad8906b40d1c43c9b0c234212251810";
          weather.location = "Göttingen";
        };
        theme.font = {
          name = "CaskaydiaCove NF";
          size = "16px";
        };

        theme.bar.opacity = 85;
      } // theme;
    };
  };
}
