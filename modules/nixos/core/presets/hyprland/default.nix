{ lib
, config
, pkgs
, inputs
, ...
}:
let
  cfg = config.kor.desktop.hyprland;
in
{
  imports = [
    ./config
    # ./hyprpaper
    # ./hyprlock
    # ./hypridle.nix
  ];
  # ++ [ inputs.hyprpanel.result.homeManagerModules.hyprpanel ];
}
