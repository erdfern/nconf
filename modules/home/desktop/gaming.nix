{ lib
, config
, pkgs
, ...
}:
let
  cfg = config.kor.preset.desktop.gaming;
in
{
  options.kor.preset.desktop.gaming = with lib; {
    enable = mkEnableOption "firefox browser";
  };

  config = lib.mkIf cfg.enable {
    programs.lutris.enable = true;

  };
}
