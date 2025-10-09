{ me
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

  # networking.hostName = "kor";

  # so I can cross-build for the rpi...
  boot.binfmt.emulatedSystems = [ "aarch64-linux" ];

  kor.preset.desktop.enable = true;
  kor.preset.development.enable = true;

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
    web.enable = true;
  };

  # environment.systemPackages = [ pkgs.distrobox pkgs.distrobox-tui ];

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
