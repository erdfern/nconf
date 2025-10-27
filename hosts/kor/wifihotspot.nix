{ pkgs
, ...
}:
{
  # networking.hostName = "kor";
  # networking.useDHCP = true;
  # networking.nameservers = [ "192.168.178.42" ];
  # check wifi capabilities with `iw dev`/`iw list`
  environment.systemPackages = [ pkgs.haveged ]; # for entropy
  # https://github.com/NixOS/nixpkgs/blob/d916df777523d75f7c5acca79946652f032f633e/nixos/modules/services/networking/create_ap.nix
  services.create_ap = {
    enable = true;
    # https://raw.githubusercontent.com/lakinduakash/linux-wifi-hotspot/master/src/scripts/create_ap.conf
    settings = {
      WIFI_IFACE = "wlp8s0";
      INTERNET_IFACE = "enp9s0";
      SSID = "kor-ap";
      PASSPHRASE = "kor-hothothot";
      FREQ_BAND = 5;
      CHANNEL = "default";
      # IEEE80211N=0;
      # IEEE80211AC=0;
      IEEE80211AX = 1; # wifi 6
      # GATEWAY="192.168.12.1";
      # WPA_VERSION=2;
      # ETC_HOSTS=0;
      # DHCP_DNS="gateway";
      # NO_DNS=0;
      # NO_DNSMASQ=0;
      # HIDDEN=0;
      # MAC_FILTER=0;
      # MAC_FILTER_ACCEPT=/etc/hostapd/hostapd.accept;
      # ISOLATE_CLIENTS=0;
      # SHARE_METHOD="nat";
      # HT_CAPAB="[HT40+]";
      # VHT_CAPAB=;
      # DRIVER="nl80211";
      # NO_VIRT=0;
      # COUNTRY=;
      # NEW_MACADDR=;
      # DAEMONIZE=0;
      # NO_HAVEGED=0;
      # USE_PSK=0;
      # DHCP_HOSTS=;
    };
  };
}
