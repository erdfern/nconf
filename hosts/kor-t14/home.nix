{ pkgs
, inputs
, ...
}:
{
  imports = [ ./batcheck.nix ];

  kor.desktop.enable = true;

  kor.desktop.enableHyprland = true;
  # kor.desktop.hyprland.hy3.enable = true;
  kor.desktop.apps.waybar.enable = true;
  kor.desktop.apps.waybar.hyprlandAutostart = true;
  kor.desktop.apps.waybar.modules-left = [ "idle_inhibitor" "backlight" "wireplumber" "hyprland/workspaces" ];
  kor.desktop.apps.swayosd.enable = true;
  # kor.desktop.apps.wayle.enable = true;

  kor.development.neovim.enable = true;
  kor.development.vscode.enable = true;

  kor.desktop.apps.firefox.enable = true;

  # kor.desktop.apps.ghostty.enable = true;
  # kor.desktop.hyprland.terminal = "ghostty";
  # TODO how do I run this without using an in-process ghostty keybind??
  # kor.desktop.hyprland.terminalQ= "";

  kor.desktop.uwsm.env = [
    "LIBVA_DRIVER_NAME=iHD"
  ];

  # kor.desktop.suites.gaming.enable = true;

  services.hypridle.settings.listener = [
    {
      timeout = 150; # 2.5min.
      on-timeout = "light -O && light -S 10"; # set monitor backlight to minimum, avoid 0 on OLED monitor.
      on-resume = "light -I"; # monitor backlight restore.
    }
    # turn off keyboard backlight
    {
      timeout = 150; # 2.5min.
      on-timeout = "brightnessctl -sd rgb:kbd_backlight set 0"; # turn off keyboard backlight.
      on-resume = "brightnessctl -rd rgb:kbd_backlight"; # turn on keyboard backlight.
    }
  ];

  programs.btop.settings.presets = "cpu:0:default,proc:0:default"; # compact view on preset 1
  programs.fish.shellAliases.btop = "btop -p 1";

  home.packages = with pkgs; [
    signal-desktop
    discord
    freecad
    # openscad-unstable
    # openscad-lsp
    orca-slicer
    # orca-slicer-git
    claude-code
  ];

  home.stateVersion = "25.11";
}
