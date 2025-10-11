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
    inputs.facter.result.nixosModules.facter

    ./boot.nix
    ./networking.nix
    ./hardware-configuration.nix

    ./adguardhome.nix
  ];

  kor.basic-utils = false;

  facter.reportPath = ./facter.json;

  documentation.man.generateCaches = lib.mkForce false;

  # environment.systemPackages = [ ];

  users.users = {
    root.openssh.authorizedKeys.keys = [ "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIFC/7GNB7BzQQP9Au/tKFPSKOiyL18HJaUwCqy/sSdrf j@kor" ];
    root.initialHashedPassword = "$6$tdKqjdDlHB55JViJ$yZmv/XchjdrGN3iH79oVSe1cLYsKYXsiP2kSPMt1hN84yvY.orRR6Gujx.qNLVDzfqaKiNWhtSiojMWku3ETg0";
    ${me.user} = {
      openssh.authorizedKeys.keys = [ "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIFC/7GNB7BzQQP9Au/tKFPSKOiyL18HJaUwCqy/sSdrf j@kor" ];
      initialHashedPassword = "$6$tdKqjdDlHB55JViJ$yZmv/XchjdrGN3iH79oVSe1cLYsKYXsiP2kSPMt1hN84yvY.orRR6Gujx.qNLVDzfqaKiNWhtSiojMWku3ETg0";
    };
  };

  system.stateVersion = "25.11";
}
