{ ... }:
{
  networking = {
    # hostName = "pi-dns";
    interfaces.end0.ipv4.addresses = [{
      address = "192.168.178.42";
      prefixLength = 24;
    }];
  };


  # networking = {
  #   hostName = "pi-dns";
  #   defaultGateway = {
  #     address = "192.168.178.1";
  #     interface = "end0";
  #   };
  #   nameservers = [ "192.168.178.1" ];
  #   inferfaces.end0 = {
  #     ipv4.addresses = [{
  #       address = "192.168.178.42";
  #       prefixLength = 24;
  #     }];
  #   };
  # };
}
