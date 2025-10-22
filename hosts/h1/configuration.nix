{ lib
, config
, pkgs
, inputs
, me
, ...
}:
{
  imports = [
    # "${inputs.facter.result}/modules/nixos/facter.nix"

    # ./boot.nix
    # ./networking.nix
    ./disk-config.nix
    ./hardware-configuration.nix
    # ./gh-runner.nix
  ];

  kor.profile.server.enable = true;

  boot.loader.grub.enable = true;

  # facter.reportPath = ./facter.json;

  services.openssh = {
    enable = true;
    # ports = [ 5678 2222 ];
    settings.PermitRootLogin = "prohibit-password";
  };

  networking.firewall.allowedTCPPorts = [ 80 ] ++ config.services.openssh.ports; # NOTE adding openssh ports here is redundant

  # services.fail2ban.enable = true;
  # services.endlessh = {
  #   enable = true;
  #   port = 22;
  #   openFirewall = true;
  # };

  users.users = {
    root.openssh.authorizedKeys.keys = [ ];
    root.initialHashedPassword = "$6$2ehqOdYVpCBMv9Jm$8HC2bOKIY3s/9JnszCII19AAd/Cz3.kra2rcRg3aAcjSj9fudsUg8y3Cq25GF6PxPpr2A..kcwvwEXieEBfoA/";
    ${me.user} = {
      openssh.authorizedKeys.keys = [ ];
      initialHashedPassword = "$6$2ehqOdYVpCBMv9Jm$8HC2bOKIY3s/9JnszCII19AAd/Cz3.kra2rcRg3aAcjSj9fudsUg8y3Cq25GF6PxPpr2A..kcwvwEXieEBfoA/";
    };
  };

  system.stateVersion = "25.05";
}
