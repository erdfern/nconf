{ pkgs
, config
, inputs
, ...
}: {
  boot.kernelModules = [ "e1000e" ]; # NIC
  networking.useDHCP = false;
  networking.interfaces."enp0s31f6".ipv4.addresses = [
    {
      address = "135.181.136.190";
      prefixLength = 24;
    }
  ];
  networking.interfaces."enp0s31f6".ipv6.addresses = [
    {
      address = "2a01:4f9:3a:1084::1";
      prefixLength = 64;
    }
  ];
  networking.defaultGateway = "135.181.136.129";
  networking.defaultGateway6 = { address = "fe80::1"; interface = "enp0s31f6"; };
  networking.nameservers = [ "8.8.8.8" ];
}
