{ config, lib, pkgs, me, ... }:
let
  cfg = config.kor.virtualisation.waydroid;
in
{
  options.kor.virtualisation.waydroid.enable = lib.mkEnableOption "Waydroid Android emulator";

  config = lib.mkIf cfg.enable {
    # TODO handle this differently! this module should not change the firewall by itself.
    #  atm, though, iptables doesn't work for me with waydroid.. maybe using iptables-legacy would work?
    networking.nftables.enable = true;
    virtualisation.waydroid.package = pkgs.waydroid-nftables;

    virtualisation.waydroid.enable = true;
    environment.systemPackages = [
      pkgs.waydroid-helper
      pkgs.cage
      # pkgs.cagebreak
    ];

    programs.adb.enable = true;
    users.users.${me.user}.extraGroups = [ "adbusers" ];
  };
}
