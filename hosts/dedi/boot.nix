{ lib, pkgs, ... }:
{
  kor.boot.enable = lib.mkForce false;

  # need to use older kernel, since zfs package is marked broken for newer versions...
  boot.kernelPackages = lib.mkForce pkgs.linuxPackages_6_6;

  # zfs support per nixos wiki
  # boot.loader.systemd-boot.enable = lib.mkForce false;
  boot.loader.grub = {
    enable = true;
    zfsSupport = true;
    efiSupport = true;
    efiInstallAsRemovable = true;
    # mirroredBoots = [ «thunk» «thunk» ];
  };

  # pools to import at boot...? https://nixos.wiki/wiki/ZFS#Importing_pools_at_boot
  # boot.zfs.extraPools = [ "zpool_name" ];

  # or per openzfs
  # boot.supportedFilesystems = [ "zfs" ];
  # boot.zfs.forceImportRoot = false;

  # generated via
  # head -c4 /dev/urandom | od -A none -t x4
  # or
  # head -c 8 /etc/machine-id on host
  networking.hostId = "e1ce6466";

  # services.zfs = {
  #   autoScrub = {
  #     enable = true;
  #     pools = cfg.pools;
  #   };

  #   autoSnapshot = lib.mkIf cfg.auto-snapshot.enable {
  #     enable = true;
  #     flags = "-k -p --utc";
  #     weekly = lib.mkDefault 3;
  #     daily = lib.mkDefault 3;
  #     hourly = lib.mkDefault 0;
  #     frequent = lib.mkDefault 0;
  #     monthly = lib.mkDefault 2;
  #   };
  # };  
}
