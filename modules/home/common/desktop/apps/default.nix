# TODO automatically create enable options for apps in cfg...
{ pkgs
, ...
}:
{
  imports = [
    ./firefox
    ./fuzzel
    ./ghostty
    ./kitty
    ./nemo
    ./waybar
    ./hyprpanel
    ./swayosd
    ./imv.nix
    ./mpv.nix
  ];

  home.packages = with pkgs; [ discord signal-desktop ];
}
