{ config, lib, pkgs, me, ... }:
let
  cfg = config.kor.virtualisation.waydroid;
in
{
  options.kor.virtualisation.waydroid.enable = lib.mkEnableOption "Waydroid Android emulator";

  config = lib.mkIf cfg.enable {
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
