# TODO automatically create enable options for apps in cfg...
{ pkgs
, ...
}:
{
  imports = [
    ./firefox
    ./fuzzel
    ./kitty
    ./nemo
    ./waybar
    ./hyprpanel
  ];

  home.packages = with pkgs; [ discord signal-desktop ];
}
