# TODO https://yomaq.github.io/posts/zfs-encryption-backups-and-convenience
{ lib, ... }:
{
  kor.system.boot.enable = lib.mkForce false; # TODO make boot module configurable

  boot.loader.grub = { enable = false; };
  boot.loader.generic-extlinux-compatible.enable = lib.mkForce true;
}
