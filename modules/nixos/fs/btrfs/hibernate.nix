# TODO configuration options, e.g. if the swap is on a swapfile or subvolume etc.
{ config, lib, ... }:
let
  cfg = config.kor.fs.btrfs.hibernate;
in
{
  options.kor.fs.btrfs.hibernate = with lib; {
    enable = mkEnableOption "btrfs hibernate/resume support";
    # resumeDevice = mkOption { type = types.str; default = "/dev/disk/by-label/nixos"; description = "Hibernate resume device"; };
  };

  config = lib.mkIf cfg.enable {
    # boot = {
    #   kernelParams = [
    #     # TODO how do I ensure this is correct and declarative?
    #     # "resume_offset=533760"
    #   ];
    #   # resumeDevice = cfg.resumeDevice;
    # };
  };
}
