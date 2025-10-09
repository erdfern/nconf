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

    ./boot.nix
    ./networking.nix
    ./hardware-configuration.nix
  ];

  # facter.reportPath = ./facter.json;

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
    root.initialHashedPassword = "$6$tdKqjdDlHB55JViJ$yZmv/XchjdrGN3iH79oVSe1cLYsKYXsiP2kSPMt1hN84yvY.orRR6Gujx.qNLVDzfqaKiNWhtSiojMWku3ETg0";
    ${me.user} = {
      openssh.authorizedKeys.keys = [ ];
      initialHashedPassword = "$6$tdKqjdDlHB55JViJ$yZmv/XchjdrGN3iH79oVSe1cLYsKYXsiP2kSPMt1hN84yvY.orRR6Gujx.qNLVDzfqaKiNWhtSiojMWku3ETg0";
    };
  };

  system.stateVersion = "25.11";
}
