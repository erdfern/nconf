{ lib
, config
, ...
}:
let
  cfg = config.kor.desktop.apps.feh;
in
{
  options.kor.desktop.apps.feh = with lib; {
    enable = mkEnableOption "feh image viewer";
  };

  config = {
    programs.feh = {
      enable = cfg.enable;
      # buttons = {};
      # themes = {};
    };
  };
}
