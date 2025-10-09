{ lib, pkgs, ... }:
{
  # need to use older kernel, since zfs package is marked broken for newer versions...
  boot.kernelPackages = lib.mkForce pkgs.linuxPackages_6_6;

  # zfs support per nixos wiki
  boot.loader.systemd-boot.enable = lib.mkForce false;
  boot.loader.grub = {
    enable = true;
    zfsSupport = true;
    efiSupport = false;
    # efiInstallAsRemovable = true;
    # mirroredBoots = [
    #   { devices = [ "nodev" ]; path = "/boot"; }
    # ];
  };

  # or per openzfs
  boot.supportedFilesystems = [ "zfs" ];
  boot.zfs.forceImportRoot = false;
  # generated via
  # head -c4 /dev/urandom | od -A none -t x4
  networking.hostId = "5060d0a1";

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
