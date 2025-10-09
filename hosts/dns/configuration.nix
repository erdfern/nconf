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

  facter.reportPath = ./facter.json;

  kor.basic-utils = false;

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
