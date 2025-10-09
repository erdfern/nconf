# TODO https://yomaq.github.io/posts/zfs-encryption-backups-and-convenience
{ lib, pkgs, ... }:
{
  kor.system.boot.enable = lib.mkForce false; # TODO make boot module configurable

  # generated via
  # head -c4 /dev/urandom | od -A none -t x4
  # or
  # head -c 8 /etc/machine-id on host
  # networking.hostId = "e1ce6466";

  # boot.loader.systemd-boot.enable = lib.mkForce false;
  boot.loader.grub = {
    enable = true;
    efiSupport = true;
    efiInstallAsRemovable = true;
  };
}
