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

  # TODO include the relevant modules. How should I handle disk templates? As an option, orrr...
  imports = [ ./impermanence.nix ./hibernate.nix ];

  config = lib.mkIf cfg.enable {
    disko.devices.disk = lib.mkIf cfg.disko.enable (import ./disko-btrfs-luks-impermanence.nix { cfg = cfg; });

    fileSystems."/persist".neededForBoot = lib.mkIf cfg.disko.enable true;
    fileSystems."/var/log".neededForBoot = lib.mkIf cfg.disko.enable true;
  };
}
