{ lib
, config
, pkgs
, ...
}:
let
  cfg = config.kor.preset.desktop.apps;
in
{
  imports = [ ./nemo ./firefox ];

  home.packages = with pkgs; [ discord ];
}
