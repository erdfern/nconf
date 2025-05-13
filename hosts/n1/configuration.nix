{ lib
, pkgs
, inputs
, user
, ...
}:
{
  imports = [
    ./disk-config.nix
    ./hardware-configuration.nix
  ];

  profiles.desktop.enable = true;

  networking.hostName = "n1";

  services.qemuGuest.enable = true;
  services.spice-vdagentd.enable = true;

  programs.bash.loginShellInit = ''
    if uwsm check may-start; then
      exec uwsm start default
    fi
  '';

  boot.loader.grub = {
    # no need to set devices, disko will add all devices that have a EF02 partition to the list already
    # devices = [ ];
    efiSupport = true;
    efiInstallAsRemovable = true;
  };

  system.stateVersion = "24.11";
}
