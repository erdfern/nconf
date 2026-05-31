{ lib, ... }:
{
  imports = [
    ./apps
    ./desktop
    ./development
    ./gpg.nix
    ./udiskie.nix
    ./mime.nix
  ];

  # TODO move
  catppuccin.enable = true;
  catppuccin.cursors.enable = true;
  catppuccin.flavor = "mocha";
  catppuccin.accent = "peach";

  programs.nix-index.enable = true;
  programs.nix-index-database.comma.enable = true;

  xdg.enable = true;

  # TODO move
  dconf.settings = {
    "org/virt-manager/virt-manager/connections" = {
      autoconnect = [ "qemu:///system" ];
      uris = [ "qemu:///system" ];
    };
  };
  # # ~/.config/libvirt/qemu.conf
  # xdg.configFile."libvirt/qemu.conf" = { text = ''nvram = [ "/run/libvirt/nix-ovmf/AAVMF_CODE.fd:/run/libvirt/nix-ovmf/AAVMF_VARS.fd", "/run/libvirt/nix-ovmf/OVMF_CODE.fd:/run/libvirt/nix-ovmf/OVMF_VARS.fd" ]''; };

  # https://github.com/nix-community/home-manager/issues/3342
  manual.manpages.enable = false;

  home.stateVersion = lib.mkDefault "26.05";
}
