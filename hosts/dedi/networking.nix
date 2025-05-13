{ pkgs
, config
, inputs
, lib
, ...
}:
let
  interface = "enp0s31f6";
  gatewayv4 = "135.181.136.129";
  gatewayv6 = "fe80::1";
  ipv4 = "135.181.136.190";
  ipv6 = "2a01:4f9:3a:1084::1";
  netmask = "255.255.255.192";
in
{
  # IP:<ignore>:GATEWAY:NETMASK:HOSTNAME:NIC:AUTCONF?
  # See: https://www.kernel.org/doc/Documentation/filesystems/nfs/nfsroot.txt
  boot.kernelParams = [ "ip=${ipv4}::${gatewayv4}:${netmask}:${config.networking.hostName}:${interface}:off" ];
  boot.kernelModules = [ "e1000e" ]; # NIC

  networking.useDHCP = lib.mkForce false;
  networking.interfaces.${interface} = {
    ipv4.addresses = [
      {
        address = ipv4;
        prefixLength = 24;
      }
    ];
    ipv6.addresses = [
      {
        address = ipv6;
        prefixLength = 64;
      }
    ];
  };
  networking.defaultGateway = { address = gatewayv4; interface = interface; };
  networking.defaultGateway6 = { address = gatewayv6; interface = interface; };
  networking.nameservers = [ "8.8.8.8" ];
}
