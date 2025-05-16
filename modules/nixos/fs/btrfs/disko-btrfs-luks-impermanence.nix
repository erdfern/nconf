{ cfg }:
{
  disk0 = with cfg;  {
    type = "disk";
    device = diskDev0;
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
            mountOptions = [
              "defaults"
            ];
          };
        };
        luks = {
          size = "-${disko.swap.size}"; # make room for swap
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
            #passwordFile = "/tmp/secret.key"; # Interactive
            settings = {
              allowDiscards = true;
              # keyFile = "/tmp/secret.key";
            };
            additionalKeyFiles = [ "/tmp/additionalSecret.key" ];

            # /dev/disk/by-label/nixos
            content = {
              type = "btrfs";
              extraArgs = [ "-L" "nixos" "-f" ];
              subvolumes = {
                "/root" = {
                  mountpoint = "/";
                  mountOptions = [ "subvol=root" "compress=zstd" "noatime" ];
                };
                "/home" = {
                  mountpoint = "/home";
                  mountOptions = [ "subvol=home" "compress=zstd" "noatime" ];
                };
                "/nix" = {
                  mountpoint = "/nix";
                  mountOptions = [ "subvol=nix" "compress=zstd" "noatime" ];
                };
                "/persist" = {
                  mountpoint = "/persist";
                  mountOptions = [ "subvol=persist" "compress=zstd" "noatime" ];
                };
                "/log" = {
                  mountpoint = "/var/log";
                  mountOptions = [ "subvol=log" "compress=zstd" "noatime" ];
                };
                # "/swap" = {
                #   mountpoint = "/swap";
                #   swap.swapfile.size = "10M";
                # };
              };
            };
          };
        };
        swap = {
          size = "100%";
          content = {
            type = "swap";
            priority = 100; # prefer to encrypt as long as we have space for it
            discardPolicy = "both";
            randomEncryption = disko.swap.encrypted;
            resumeDevice = disko.swap.hibernate;
          };
        };
      };
    };
  };
}
