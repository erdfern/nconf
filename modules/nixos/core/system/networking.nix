# Taken from https://github.com/NotAShelf/nyx/blob/2a8273ed3f11a4b4ca027a68405d9eb35eba567b/modules/core/common/system/impermanence/default.nix
{ lib
, config
, me
, pkgs
, ...
}:
let
  inherit (me) user;
  cfg = config.kor.system.networking;
in
{
  options.kor.system.networking = {
    networkmanager = lib.mkEnableOption "Networkmanager";

  };

  config = {
    networking.usePredictableInterfaceNames = lib.mkDefault true;

    networking.networkmanager = lib.mkIf cfg.networkmanager {
      enable = true;
      plugins = [ pkgs.networkmanager-openvpn ];
    };

    users.users.${user}.extraGroups = [
      "dialout"
      "networkmanager"
    ];

    # example (https://github.com/infinisil/system/blob/f41c1437aa146fcfd038694d92a077a02f01f142/config/modules/iphone-usb-tethering.nix#L9-L17)
    # Predictably names the iphone's tethering interface "iphone"
    #systemd.network.links."81-iphone" = {
    #  matchConfig.Driver = "ipheth";
    #  linkConfig.Name = "iphone";
    #  networkConfig.DHCP = true;
    #};
    # Enable DHCP to set up correct routes
    #networking.interfaces.iphone.useDHCP = true;
  };
}
