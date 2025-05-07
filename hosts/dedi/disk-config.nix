# Impermanence with ZFS
# TODO https://yomaq.github.io/posts/zfs-encryption-backups-and-convenience
{
  disko.devices = {
    disk = {
      a = {
        device = "/dev/nvme0n1";
        type = "disk";
        content = {
          type = "gpt";
          partitions = {
            boot = {
              # BIOS compat
              size = "1M";
              type = "EF02"; # for grub MBR
            };
            esp = {
              name = "ESP";
              size = "1G";
              type = "EF00";
              content = {
                type = "filesystem";
                format = "vfat";
                mountpoint = "/boot";
                mountOptions = [ "umask=0077" ];
              };
            };
            zfs = {
              size = "100%";
              content = {
                type = "zfs";
                pool = "zroot";
              };
            };
          };
        };
      };
      b = {
        device = "/dev/nvme1n1";
        type = "disk";
        content = {
          type = "gpt";
          partitions.zfs =
            {
              size = "100%";
              content = {
                type = "zfs";
                pool = "zroot";
              };
            };
        };
      };
    };
    zpool = {
      zroot = {
        type = "zpool";
        # mode = "mirror"; # mirror..?
        options.cachefile = "none"; # Workaround: cannot import 'zroot': I/O error in disko tests
        rootFsOptions = {
          # https://wiki.archlinux.org/title/Install_Arch_Linux_on_ZFS
          acltype = "posixacl";
          atime = "off";
          compression = "zstd";
          mountpoint = "none";
          xattr = "sa";
        };
        options.ashift = "12";

        datasets = {
          # nixos-anywhere currently has issues with impermanence so agenix keys are lost during the install process.
          # as such we give /etc/ssh its own zfs dataset rather than using impermanence to save the keys when we wipe the root directory on boot
          # not needed if you don't use agenix or don't use nixos-anywhere to install
          # etcssh = {
          #   type = "zfs_fs";
          #   options.mountpoint = "legacy";
          #   mountpoint = "/etc/ssh";
          #   options."com.sun:auto-snapshot" = "false";
          #   postCreateHook = "zfs snapshot zroot/etcssh@empty";
          # };
          "local" = {
            type = "zfs_fs";
            options.mountpoint = "none";
          };
          "local/home" = {
            type = "zfs_fs";
            mountpoint = "/home";
            # Used by services.zfs.autoSnapshot options.
            options."com.sun:auto-snapshot" = "true";
          };
          "local/nix" = {
            type = "zfs_fs";
            mountpoint = "/nix";
            options."com.sun:auto-snapshot" = "false";
          };
          "local/persist" = {
            type = "zfs_fs";
            mountpoint = "/persist";
            options."com.sun:auto-snapshot" = "false";
          };
          "local/root" = {
            type = "zfs_fs";
            mountpoint = "/";
            options."com.sun:auto-snapshot" = "false";
            postCreateHook = "zfs list -t snapshot -H -o name | grep -E '^zroot/local/root@blank$' || zfs snapshot zroot/local/root@blank";
          };
        };
      };
    };
  };
}
