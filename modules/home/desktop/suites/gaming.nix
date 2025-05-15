{ lib
, config
, pkgs
, ...
}:
let
  cfg = config.kor.desktop.suites.gaming;
in
{
  options.kor.desktop.suites.gaming = with lib; {
    enable = mkEnableOption "gaming stuff";
  };

  config = lib.mkIf cfg.enable {
    programs.lutris.enable = true;
  };
}
