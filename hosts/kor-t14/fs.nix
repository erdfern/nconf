{
  imports = [ ./xfs.nix ];
  # imports = [ ./disk-lvm-hybrid.nix ];
  services.fstrim.enable = true;
  services.fstrim.interval = "daily"; # default weekly; systemd calendar specification
}
