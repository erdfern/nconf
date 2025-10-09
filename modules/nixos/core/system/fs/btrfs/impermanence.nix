# Taken from https://github.com/NotAShelf/nyx/blob/2a8273ed3f11a4b4ca027a68405d9eb35eba567b/modules/core/common/system/impermanence/default.nix
{ config, lib, ... }:
let
  inherit (lib) optionalString mkOption;

  cfgBtrfs = config.kor.fs.btrfs;
  cfgImpermanence = config.kor.system.impermanence;
  cfg = config.kor.fs.btrfs.impermanence;
in
{
  options.kor.fs.btrfs.impermanence = {
    enable = mkOption {
      default = cfgBtrfs.enable && cfgImpermanence.enable;
      readOnly = true;
      description = ''
        Internal option for deciding if Impermanence module is enabled
        based on the values of `kor.system.impermanence.enable`
        and `kor.system.btrfs.enable`.
      '';
    };
  };

  config = lib.mkIf cfg.enable {
    boot.initrd.systemd.services.rollback = {
      description = "Rollback BTRFS root subvolume to a pristine state";
      wantedBy = [ "initrd.target" ];
      # make sure it's done after encryption
      # i.e. LUKS/TPM process
      after = [ "systemd-cryptsetup@enc.service" ];
      # mount the root fs before clearing
      before = [ "sysroot.mount" ];
      unitConfig.DefaultDependencies = "no";
      serviceConfig.Type = "oneshot";
      script = ''
        mkdir -p /mnt

        # We first mount the btrfs root to /mnt
        # so we can manipulate btrfs subvolumes.
        mount -o subvol=/ /dev/mapper/enc /mnt

        # If home is meant to be impermanent, also mount the home subvolume to be deleted later
        ${optionalString cfgImpermanence.home.enable "mount -o subvol=/home /dev/mapper/enc /mnt/home"}

        # While we're tempted to just delete /root and create
        # a new snapshot from /root-blank, /root is already
        # populated at this point with a number of subvolumes,
        # which makes `btrfs subvolume delete` fail.
        # So, we remove them first.
        #
        # /root contains subvolumes:
        # - /root/var/lib/portables
        # - /root/var/lib/machines

        btrfs subvolume list -o /mnt/root |
          cut -f9 -d' ' |
          while read subvolume; do
            echo "deleting /$subvolume subvolume..."
            btrfs subvolume delete "/mnt/$subvolume"
          done &&
          echo "deleting /root subvolume..." &&
          btrfs subvolume delete /mnt/root

        echo "restoring blank /root subvolume..."
        btrfs subvolume snapshot /mnt/root-blank /mnt/root

        ${optionalString cfgImpermanence.home.enable ''
          echo "restoring blank /home subvolume..."
          mount -o subvol=/home /dev/mapper/enc /mnt/home
        ''}

        # Once we're done rolling back to a blank snapshot,
        # we can unmount /mnt and continue on the boot process.
        umount /mnt
      '';
    };
  };
}
