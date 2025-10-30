{ lib
, config
, ...
}:
let
  cfg = config.kor.system.bluetooth;

  inherit (lib)
    mkOption
    mkEnableOption
    mkIf
    types
    ;
in
{
  options.kor.system.bluetooth = {
    enable = lib.mkEnableOption "bluetooth support";
  };

  config = mkIf cfg.enable {
    hardware.bluetooth.enable = true;
    hardware.bluetooth.powerOnBoot = true;
    hardware.bluetooth.settings = { General = { Experimental = true; }; }; # enable battery reporting to upower
    services.blueman.enable = true;
    # services.upower.enable = true;
  };
}
