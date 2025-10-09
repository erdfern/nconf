let
  swap = {
    size = "24G";
    hibernate = true;
    encrypt = true;
  };
in
{
  # fileSystems."/persist/passwords".neededForBoot = true;
  disko.devices = {
    disk = {
      main = {
        device = "/dev/nvme0n1";
        type = "disk";
        content = {
          type = "gpt";
          partitions = {
            ESP = {
              label = "boot";
              name = "ESP";
              size = "512M";
              type = "EF00";
              content = {
                type = "filesystem";
                format = "vfat";
                mountpoint = "/boot";
                mountOptions = [ "defaults" "umask=0077" ];
              };
            };
            root = {
              end = "-${swap.size}";
              label = "nixos";
              content = {
                type = "filesystem";
                format = "xfs";
                # /dev/disk/by-label/nixos
                extraArgs = [ "-f" ];
                # extraArgs = [ "-L" "nixos" "-f" ];
                mountpoint = "/";
                mountOptions = [
                  "defaults"
                  # "discard" # NOTE recommended to use fstrim instead for perf
                  # "noatime"
                  # "nodiratime"

                  # xfs specific flags
                  "swalloc"
                  "noquota" # disable all internal quota stuff
                  # "pquota"
                ];
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
  };
}
