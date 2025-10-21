{ lib
, config
, ...
}:
let
  cfg = config.kor.system.graphics;
in
{
  options.kor.system.graphics = {
    enable = lib.mkEnableOption "graphics support";
  };

  config = lib.mkIf cfg.enable {
    hardware.graphics.enable = true;
    hardware.graphics.enable32Bit = true;
  };
}
