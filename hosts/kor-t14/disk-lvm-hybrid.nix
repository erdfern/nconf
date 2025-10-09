{ ... }:
let
  swap = {
    size = "24G";
    hibernate = true;
    encrypt = true;
  };
  passMountPoint = "/persist/passwords";
in
{
  fileSystems.${passMountPoint}.neededForBoot = true;
  disko.devices = {
    disk = {
      one = {
        type = "disk";
        device = "/dev/disk/by-id/nvme-WDC_PC_SN730_SDBQNTY-256G-1001_194950458108_1";
        content = {
          type = "gpt";
          partitions = {
            boot = {
              size = "512M";
              type = "EF00";
              content = {
                type = "filesystem";
                format = "vfat";
                mountpoint = "/boot";
                mountOptions = [ "umask=0077" ];
              };
            };
            pass = {
              size = "32M";
              # type = "8300";
              content = {
                type = "filesystem";
                format = "vfat";
                mountpoint = passMountPoint;
                mountOptions = [ "umask=0077" ];
              };
            };
            primary = {
              # size = "100%";
              end = "-${swap.size}";
              content = {
                type = "lvm_pv";
                vg = "pool";
              };
            };
            swap = {
              size = "100%";
              content = {
                type = "swap";
                resumeDevice = swap.hibernate;
                discardPolicy = "both";
                # randomEncryption = swap.encrypt;
                # priority = 100; # high priority for encrypted swap. should be preffered if other swap exists
                # discardPolicy = "both"; # NOTE default is set to forward discard/TRIM through dm-crypt; config.discardPolicy
              };
            };
          };
        };
      };
    };
    lvm_vg = {
      pool = {
        type = "lvm_vg";
        lvs = {
          aaa = {
            size = "1M";
          };
          zzz = {
            size = "1M";
          };
          root = {
            name = "root";
            size = "100G";
            content = {
              type = "filesystem";
              format = "f2fs";
              mountpoint = "/";
              extraArgs = [
                "-O"
                "extra_attr,inode_checksum,sb_checksum,compression"
              ];
              mountOptions = [
                "compress_algorithm=zstd:6,compress_chksum,atgc,gc_merge,lazytime,nodiscard"
              ];
            };
          };
          home = {
            size = "100%FREE";
            content = {
              type = "filesystem";
              format = "xfs";
              mountpoint = "/home";
              mountOption = [ "defaults" ];
            };
          };
        };
      };
    };
  };
}

