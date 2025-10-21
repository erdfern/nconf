{ lib
, config
, ...
}:
let
  cfg = config.kor.system.wifi;

  inherit (lib)
    mkOption
    mkEnableOption
    mkIf
    types
    ;
in
{
  options.kor.system.wifi = {
    enable = mkEnableOption "wifi support";

    implementation = mkOption {
      type = types.enum [
        "networkmanager"
        # https://nixos.wiki/wiki/Wpa_supplicant
        "wpa_supplicant"
        # https://wiki.nixos.org/wiki/Iwd
        "iwd"
      ];
      default = "networkmanager";
      description = '''';
    };

    networks = mkOption {
      type = types.attrs;
      default = { };
      description = ''
        Set of wireless networks; only works with wpa_supplicant.
      '';
    };
  };

  config = mkIf cfg.enable {
    networking.networkmanager = mkIf (cfg.implementation == "networkmanager") { enable = true; };
  };
}
