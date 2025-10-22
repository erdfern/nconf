{ me
, pkgs
, ...
}:
{
  imports = [
    ./hardware-configuration.nix
    ./disk-config.nix
    # ./f2fs.nix
    ./graphics.nix
    # "${inputs.facter.result}/modules/nixos/facter.nix"
  ];

  # facter.reportPath = ./facter.json;

  # so I can cross-build for the rpi...
  boot.binfmt.emulatedSystems = [ "aarch64-linux" ];

  kor.profiles.desktop.enable = true;
  kor.profiles.development.enable = true;

  kor.gaming.enable = true;
  kor.flatpak.enable = true;

  kor.hardware.sk.yubikey.enable = true;
  kor.hardware.sk.nitrokey.enable = true;
  kor.hardware.sk.piv.enable = true;

  # kor.virtualisation.qemu.enable = true;
  kor.virtualisation.containers.enable = true;
  kor.virtualisation.waydroid.enable = true;

  services.deluge = {
    enable = true;
    web.enable = false;
  };

  # TODO move
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

  # environment.systemPackages = [ pkgs.zoom-us pkgs.droidcam ];
  # programs.obs-studio = {
  #   enable = true;
  #   enableVirtualCamera = true;
  #   plugins = with pkgs.obs-studio-plugins; [
  #     droidcam-obs
  #   ];
  # };
  # programs.adb.enable = true;
  # # users.users.j.extraGroups = [ "adbusers" ];
  # services.udev.packages = [ pkgs.android-udev-rules ];

  # networking.firewall.enable = false;

  # networking.hostId = "7c238412";
  # networking.interfaces = {
  #   enp9s0 = {
  #     useDHCP = true;
  #     wakeOnLan.enable = true;
  #     wakeOnLan.policy = [ "magic" ];
  #   };
  # };

  services.openssh = {
    enable = true;
  };

  hardware.logitech.wireless.enable = true;
  hardware.logitech.wireless.enableGraphical = true;

  users.mutableUsers = false;
  users.users.root.initialHashedPassword = "$6$F2VMMSRv8pG5wHRw$HVtjknqzelzHPaIM6a4gmeQpYT4CHlhClVkfjU5hjItM41LOIwzy7M9iOMgWdeTOCB8ccIWiRY/v0.1MexDQu.";
  users.users.${me.user} = {
    initialHashedPassword = "$6$F2VMMSRv8pG5wHRw$HVtjknqzelzHPaIM6a4gmeQpYT4CHlhClVkfjU5hjItM41LOIwzy7M9iOMgWdeTOCB8ccIWiRY/v0.1MexDQu.";
    # TEMP
    extraGroups = [
      "adbusers"
    ];
  };

  system.stateVersion = "25.11";
}
