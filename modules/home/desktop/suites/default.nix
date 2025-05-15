# TODO automatically create enable options for apps in cfg...
{ lib
, config
, pkgs
, ...
}:
# let
#   cfg = config.kor.desktop.suites;
# in
{
  imports = [
  ./gaming.nix
  ];
}
