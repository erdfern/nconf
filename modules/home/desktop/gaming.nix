{ lib
, config
, pkgs
, ...
}:
let
  cfg = config.kor.desktop.gaming;
in
{
  options.kor.desktop.gaming = with lib; {
    enable = mkEnableOption "firefox browser";
  };

  config = lib.mkIf cfg.enable {
    programs.lutris.enable = true;

  };
}
