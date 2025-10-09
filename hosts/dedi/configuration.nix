{ lib
, config
, pkgs
, inputs
, me
, ...
}:
{
  imports = [
    "${inputs.facter.result}/modules/nixos/facter.nix"

    ./boot.nix
    ./networking.nix
    # ./disk-config.nix
    ./disk-config-r1md.nix
    ./hardware-configuration.nix
    ./atticd.nix
    # ./gh-runner.nix
  ];

  kor.preset.server.enable = true;

  facter.reportPath = ./facter.json;

  services.openssh = {
    enable = true;
    ports = [ 5678 2222 ];
    settings.PermitRootLogin = "prohibit-password";
  };

  networking.firewall.allowedTCPPorts = [ ] ++ config.services.openssh.ports; # NOTE adding openssh ports here is redundant

  services.fail2ban.enable = true;
  services.endlessh = {
    enable = true;
    port = 22;
    openFirewall = true;
  };

  users.users = {
    root.openssh.authorizedKeys.keys = [ ];
    root.initialHashedPassword = "$6$uMku/hPRhyVLjtIn$auqVIGB1EtE/Dm5lAV53iS2E7XMIqqdy/5CEFj1FiLM822r1xrISuwSzZGQ/0De5.pZLAF108yFSTjGQ6NhyR/";
    ${me.user} = {
      openssh.authorizedKeys.keys = [ ];
      initialHashedPassword = "$6$Z/eGDFRxkVxT4UCg$Eb2T0xQXxFOVIrymDMW2FttHRDRGtqcW0Iu8PrVwzE171NjkGXl3QSjTsGfZXyWdkM7uBTj9Q9xGQg0xGSeDa.";
    };
  };

  system.stateVersion = "25.05";
}
