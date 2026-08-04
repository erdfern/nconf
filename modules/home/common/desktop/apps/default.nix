# TODO automatically create enable options for apps in cfg...
{ pkgs
, ...
}:
{
  imports = [
    ./firefox
    ./freecad
    ./fuzzel
    ./ghostty
    ./kitty
    ./nemo
    ./waybar
    ./hyprpanel
    ./swayosd
    ./imv.nix
    ./feh
    ./mpv.nix
    ./wayle
  ];
}
