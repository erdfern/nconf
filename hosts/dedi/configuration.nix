{ lib
, config
, pkgs
, inputs
, user
, ...
}:
{
  imports = [
    ./boot.nix
    ./networking.nix
    # ./disk-config.nix
    ./disk-config-r1md.nix
    ./hardware-configuration.nix
    "${inputs.facter.result}/modules/nixos/facter.nix"
  ];

  kor.preset.server.enable = true;
  kor.system.impermanence.enable = true;

  facter.reportPath = ./facter.json;

  services.openssh = {
    enable = true;
    ports = [ 5678 2222 ];
    settings.PermitRootLogin = "prohibit-password";
  };

  services.fail2ban.enable = true;
  services.endlessh = {
    enable = true;
    port = 22;
    openFirewall = true;
  };

  # NOTE this is redundant
  networking.firewall.allowedTCPPorts = [ ] ++ config.services.openssh.ports;

  # mkpasswd -m sha512crypt
  users.users.root.initialHashedPassword = "$6$Bj5CiI0JyU1ti7ue$/RtnUyhGHPKDwwIExnJi7fx.a8ai8qOWv6Z4X0rwYdzFJGEHIpJJb.bqI/hMiNhInd62nQFsrdNUlxvNKtRux1";
  users.users.${user}.initialHashedPassword = "$6$SC5Ksnj2dZmuaU2S$UDrBWt4BpjzD8ZiW3Ks1dnAupLpMX82jIVDUFbmkoa2UOJQ7vV5r0PyT.QECWJTTrnUGOj7m/k7H.bcAYYYwj/";

  # TEMP
  # boot.swraid.enable = true;
  # boot.swraid.mdadmConf = ''
  # '';
  # boot.initrd.network = {
  #   enable = true;
  #   ssh = {
  #     enable = true;
  #     # Make sure this is different from your "main" SSH port,
  #     # otherwise you'll get conflicting SSH host keys.
  #     # Also save yourself some hassle and _never_ use port 22 for SSH.
  #     port = 1234;
  #     # this is the default
  #     # authorizedKeys = config.users.users.root.openssh.authorizedKeys.keys;
  #     hostKeys = [ "/nix/secret/initrd/ssh_host_ed25519_key" ];
  #   };
  # };

  system.stateVersion = "25.05";
}
