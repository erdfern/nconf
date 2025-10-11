{ config, ... }:
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
    # nameservers = [ "192.168.178.1" ];
  };

  networking.firewall.enable = true;
  # networking.firewall.allowedTCPPorts = [ ] ++ config.services.openssh.ports; # NOTE adding openssh ports here is redundant

  services.openssh = {
    enable = true;
    ports = [ 5678 2222 22 ];
    settings.PermitRootLogin = "prohibit-password";
  };

  # services.fail2ban.enable = true;
  # services.endlessh = {
  #   enable = true;
  #   port = 22;
  #   openFirewall = true;
  # };
}
