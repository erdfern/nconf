# TODO https://yomaq.github.io/posts/zfs-encryption-backups-and-convenience
{ ... }:
{
  boot.loader.grub = { enable = false; };
  boot.loader.generic-extlinux-compatible.enable = true;
}
