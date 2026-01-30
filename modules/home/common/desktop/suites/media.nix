{ lib
, config
, ...
}:
let
  cfg = config.kor.desktop.suites.media;
in
{
  options.kor.desktop.suites.media = with lib; {
    enable = mkEnableOption "media stuff";
  };

  config = lib.mkIf cfg.enable {
    kor.desktop.apps = {
      imv.enable = true;
      mpv.enable = true;
    };
  };
}
