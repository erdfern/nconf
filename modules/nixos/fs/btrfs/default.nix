# TODO make more configurable
# based on https://haseebmajid.dev/posts/2024-07-30-how-i-setup-btrfs-and-luks-on-nixos-using-disko/
# also see https://www.reddit.com/r/NixOS/comments/1bqm7hv/do_you_use_btrfs/ for snapper config (i'd need .snapshots subvolumes)
{ config, lib, ... }:
let
  cfg = config.kor.fs.btrfs;
in
{
  options.kor.fs.btrfs = with lib; {
    enable = mkEnableOption "btrfs filesystem config";
    diskDev0 = mkOption {
      type = types.str;
      default = "/dev/nvme0n1";
    };
    disko = {
      enable = mkOption {
        type = types.bool;
        default = true;
        description = "Whether to use the disko module for configuring filesystems";
      };
      swap = {
        size = mkOption {
          type = types.strMatching "[0-9]+[KMGTP]?";
          default = "32G";
          description = "Swap partition size";
        };
        hibernate = mkOption {
          type = types.bool;
          default = true;
          description = "Whether to use this swap partition for hibernation";
        };
        encrypted = mkOption {
          type = types.bool;
          default = true;
          description = "Whether to use random encryption for the swap partition";
        };
      };
    };
  };

  imports = [ ./impermanence.nix ./hibernate.nix ];

  config = lib.mkIf cfg.enable {
    disko.devices.disk = lib.mkIf cfg.disko.enable (import ./disko-btrfs-luks-impermanence.nix { cfg = cfg; });

    fileSystems."/persist".neededForBoot = lib.mkIf cfg.disko.enable true;
    fileSystems."/var/log".neededForBoot = lib.mkIf cfg.disko.enable true;

    # TODO move
    # enable fido2 support for unlocking luks
    boot.initrd.luks.fido2Support = true;
    boot.initrd.luks.devices.cryptroot.fido2.credential = "a300582d361f82eaaf0d1cc1bda042811933ed89a08b838d4275fb2f914f61315459af0f06387532d388d1feb9c4a72f1b014c3b5843299d63d184d21a41890250e638d47d01d46f0886fc011cadbb0268";
    boot.initrd.luks.devices.cryptroot.fido2.passwordLess = true;
  };
}
