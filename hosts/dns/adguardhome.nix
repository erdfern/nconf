{ ... }:
let
  # addr = "127.0.0.1";
  addr = "0.0.0.0";
  uiPort = 3000;
  udpPorts = [
    # plain dns
    53
    # dhcph server
    # 67 68
    # HTTPS/DNS-over-HTTPS
    # 443
    # DNS-over-QUIC
    # 853
    # DNSCrypt
    # 5443
  ];
  tcpPorts = [
    # plain dns
    53
    # dhcph server
    # 68
    # HTTPS/DNS-over-HTTPS
    80
    # 443
    # 3000 # default ui port
    uiPort
    # DNS-over-TLS
    # 853
    # DNSCrypt
    # 5443
    # debugging profiles
    # 6000
  ];
in
{
  networking.firewall.allowedTCPPorts = udpPorts;
  networking.firewall.allowedUDPPorts = tcpPorts;
  services.adguardhome = {
    enable = true;
    host = addr;
    port = uiPort;
    settings = {
      users = [{
        name = "kor";
        # TODO make sops for hash
        password = "$2y$10$u1Qb8QSi32e/nkiLCibZQOjbqedXUDFgWCDrLq/3PaK4sY0iGBC6m";
      }];
      http = {
        # You can select any ip and port, just make sure to open firewalls where needed
        # address = "${addr}:${toString uiPort}"; # setting both this and adguardhome.host/port borks something; i think host/port options just set this?
      };
      dns = {
        # bind_hosts = ["0.0.0.0"];
        # port = 53;
        upstream_dns = [
          # Example config with quad9
          # BUG: the ipv6 comments seem to break adguard
          # "9.9.9.9#dns.quad9.net"
          # "149.112.112.112#dns.quad9.net"
          "9.9.9.9"
          "149.112.112.112"
          "2620:fe::fe"
          "2620:fe::9"
          # Uncomment the following to use a local DNS service (e.g. Unbound)
          # Additionally replace the address & port as needed
          # "127.0.0.1:5335"
        ];
      };
      filtering = {
        protection_enabled = true;
        filtering_enabled = true;

        parental_enabled = false; # Parental control-based DNS requests filtering.
        safe_search = {
          enabled = false; # Enforcing "Safe search" option for search engines, when possible.
        };
      };
      # The following notation uses map
      # to not have to manually create {enabled = true; url = "";} for every filter
      filters = map (url: { enabled = true; url = url; }) [
        # "https://adguardteam.github.io/HostlistsRegistry/assets/filter_9.txt" # The Big List of Hacked Malware Web Sites
        # "https://adguardteam.github.io/HostlistsRegistry/assets/filter_11.txt" # malicious url blocklist
        "https://github.com/ppfeufer/adguard-filter-list/blob/master/blocklist?raw=true" # combines 80+ other lists, including defaults; extensive
      ];
    };
  };
}
