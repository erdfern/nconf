{ lib
, config
, ...
}:
let
  cfg = config.kor.desktop.apps.imv;
in
{

  options.kor.desktop.apps.imv = with lib; {
    enable = mkEnableOption "imv";
  };

  config = {
    programs.imv = {
      enable = cfg.enable;
      settings = { };
    };
  };
}
