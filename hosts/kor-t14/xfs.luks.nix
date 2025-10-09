let
  swap = {
    size = "24G";
    hibernate = true;
    encrypt = true;
  };
in
{
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
            luks = {
              end = "-${swap.size}";
              label = "luks";
              content = {
                type = "luks";
                name = "cryptroot";
                extraOpenArgs = [
                  "--allow-discards"
                  "--perf-no_read_workqueue"
                  "--perf-no_write_workqueue"
                ];

                # https://0pointer.net/blog/unlocking-luks2-volumes-with-tpm2-fido2-pkcs11-security-hardware-on-systemd-248.html
                settings = { crypttabExtraOpts = [ "fido2-device=auto" "token-timeout=10" ]; };
                # disable settings.keyFile if you want to use interactive password entry
                passwordFile = "/tmp/secret.key"; # Interactive
                settings = {
                  allowDiscards = true; # uh. maybe redundant with --allow-discards arg
                  # keyFile = "/tmp/secret.key";
                };
                # additionalKeyFiles = [ "/tmp/additionalSecret.key" ];

                # /dev/disk/by-label/nixos
                content = {
                  type = "filesystem";
                  format = "xfs";
                  extraArgs = [ "-L" "nixos" "-f" ];
                  # extraArgs = [ "-L" "nixos" ];
                  mountpoint = "/";
                  mountOptions = [
                    "defaults"
                    # "discard" # NOTE recommended to use fstrim instead for perf
                    # "noatime"
                    # "nodiratime"

                    # xfs flags
                    "swalloc"
                    "noquota" # disable all internal quota stuff
                    # "pquota"
                  ];
                };
              };
            };

            swap = {
              size = "100%";
              content = {
                type = "swap";
                resumeDevice = swap.hibernate;
                randomEncryption = swap.encrypt;
                priority = 100; # high priority for encrypted swap. should be preffered if other swap exists
                # discardPolicy = "both"; # NOTE default is set to forward discard/TRIM through dm-crypt; config.discardPolicy
              };
            };
          };
        };
      };
    };
  };
}
