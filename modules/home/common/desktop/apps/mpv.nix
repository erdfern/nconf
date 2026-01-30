{ lib
, config
, ...
}:
let
  cfg = config.kor.desktop.apps.mpv;
in
{

  options.kor.desktop.apps.mpv = with lib; {
    enable = mkEnableOption "mpv";
  };

  config = {
    programs.mpv = {
      enable = cfg.enable;
      config = { };
    };
  };
}
