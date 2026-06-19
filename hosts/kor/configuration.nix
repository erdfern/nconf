{ me
, pkgs
, inputs
, ...
}:
{
  imports = [
    ./hardware-configuration.nix
    ./disk-config.nix
    # ./f2fs.nix
    ./graphics.nix
    ./wifihotspot.nix
    "${inputs.facter.result}/modules/nixos/facter.nix"
    inputs.probe-rs-rules.result.nixosModules.x86_64-linux.default
  ];
  hardware.probe-rs.enable = true;

  facter.reportPath = ./facter.json;

  # so I can cross-build for the rpi...
  # boot.binfmt.emulatedSystems = [ "aarch64-linux" ];

  kor.profiles.desktop.enable = true;
  kor.profiles.development.enable = true;

  kor.gaming.enable = true;
  kor.flatpak.enable = true;
  # OrcaSlicer's nixpkgs build has a blank 3D viewport on this host: a GL
  # regression in the mesa-26.1.2 driver vs its wxWidgets-3.1.7 GLX context
  # (libgbm/mesa version skew is intentional in nixpkgs and unrelated). The
  # Flatpak runs against the Freedesktop runtime's mesa and renders correctly.
  # kor.flatpak.packages = [ "com.orcaslicer.OrcaSlicer" ];

  kor.hardware.sk.yubikey.enable = true;
  # kor.hardware.sk.nitrokey.enable = true;
  kor.hardware.sk.piv.enable = true;

  kor.virtualisation.qemu.enable = true;
  kor.virtualisation.containers.enable = true;
  kor.virtualisation.waydroid.enable = true;


  services.deluge = {
    enable = true;
    web.enable = false;
  };

  environment.systemPackages = [
    # pkgs.arduino-ide
    pkgs.arduino-cli
    # orca-slicer is installed via Flatpak (see kor.flatpak.packages above);
    # the nixpkgs build's 3D viewport is broken by a mesa-26.1 GL regression.
  ];
  # environment.systemPackages = [
  # pkgs.inkscape
  # (pkgs.inkscape-with-extensions.override {
  #   inkscapeExtensions = with pkgs.inkscape-extensions; [];
  # })
  # ];
  # environment.systemPackages = [ pkgs.zoom-us ];
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

  # boot.kernelPackages = pkgs.linuxPackages_xanmod_latest;
  # boot.kernelPackages = pkgs.linuxKernel.kernels.linux_zen;
  # boot.kernelPackages = pkgs.linuxPackages_zen;

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
      "dialout" # arduino-ide
      "plugdev" # embassy/probe-rs
    ];
  };

  system.stateVersion = "26.11";
}
