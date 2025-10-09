{ config, pkgs, lib, ... }:
let
  cfg = config.kor.flatpak;
in
{
  options.kor.flatpak.enable = lib.mkEnableOption "flatpak with flathub";

  config = lib.mkIf cfg.enable {
    services.flatpak.enable = true;
    systemd.services.flatpak-repo = {
      wantedBy = [ "multi-user.target" ];
      path = [ pkgs.flatpak ];
      script = ''
        flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
      '';
    };
  };
}
