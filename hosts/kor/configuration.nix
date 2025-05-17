{ inputs
, user
, ...
}:
{
  imports = [
    ./hardware-configuration.nix
    # ./disk-config.nix
    ./f2fs.nix
    ./graphics.nix
    "${inputs.facter.result}/modules/nixos/facter.nix"
  ];

  kor.preset.desktop.enable = true;
  kor.preset.development.enable = true;
  kor.gaming.enable = false;

  # facter.reportPath = ./facter.json;

  # networking.hostName = "kor";

  users.mutableUsers = false;
  users.users.root.initialHashedPassword = "$6$orbHsnj6yKVLTMmN$bFX5tXgje5OP9HDcu4Hb46EmDkFoA58po/fTkqMgxfqMH7ARvOR6xOPj.ANROEdlUzwFIoAeW/ARU.jC4vDPh1";
  users.users.${user}.initialHashedPassword = "$6$orbHsnj6yKVLTMmN$bFX5tXgje5OP9HDcu4Hb46EmDkFoA58po/fTkqMgxfqMH7ARvOR6xOPj.ANROEdlUzwFIoAeW/ARU.jC4vDPh1";

  services.flatpak.enable = true;

  system.stateVersion = "25.05";
}
