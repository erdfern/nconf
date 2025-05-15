# TODO automatically create enable options for apps in cfg...
{ lib
, config
, pkgs
, ...
}:
# let
#   cfg = config.kor.desktop.apps;
# in
{
  imports = [
    ./firefox
    ./fuzzel
    ./kitty
    ./nemo
    ./waybar
  ];

  home.packages = with pkgs; [ discord ];
}
