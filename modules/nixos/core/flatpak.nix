{ config, pkgs, lib, ... }:
let
  cfg = config.kor.flatpak;
in
{
  options.kor.flatpak = {
    enable = lib.mkEnableOption "flatpak with flathub";

    packages = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ ];
      example = [ "com.orcaslicer.OrcaSlicer" ];
      description = ''
        Flathub application IDs to install system-wide on activation.

        Used for apps that are broken or unavailable in nixpkgs. OrcaSlicer,
        for instance, runs against the Freedesktop runtime's mesa instead of
        the host driver, sidestepping the mesa-26.1 GL regression that leaves
        the nixpkgs build's 3D viewport blank.
      '';
    };
  };

  config = lib.mkIf cfg.enable {
    services.flatpak.enable = true;

    systemd.services.flatpak-repo = {
      wantedBy = [ "multi-user.target" ];
      wants = [ "network-online.target" ];
      after = [ "network-online.target" ];
      path = [ pkgs.flatpak ];
      script = ''
        flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
        ${lib.concatMapStringsSep "\n"
          (app: "flatpak install --system --assumeyes --noninteractive flathub ${app} || true")
          cfg.packages}
      '';
    };
  };
}
