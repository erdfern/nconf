{ ... }:
{
  networking = {
    # hostName = "pi-dns";
    defaultGateway = {
      address = "192.168.178.1";
      interface = "end0";
    };
    interfaces.end0.ipv4.addresses = [{
      address = "192.168.178.42";
      prefixLength = 24;
    }];
    nameservers = [ "192.168.178.1" ];
  };
}
