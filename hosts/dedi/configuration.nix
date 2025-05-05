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
    ./disk-config.nix
    ./hardware-configuration.nix
    "${inputs.facter.result}/modules/nixos/facter.nix"
  ];

  kor.preset.server.enable = true;
  kor.preset.immutable.enable = true;

  facter.reportPath = ./facter.json;

  services.openssh = {
    enable = true;
    ports = [ 5678 2222 ];
    # settings.PermitRootLogin = "prohibit-password";
  };

  # NOTE this is redundant
  networking.firewall.allowedTCPPorts = [ ] ++ config.services.openssh.ports;

  # mkpasswd -m sha512crypt
  users.users.root.initialHashedPassword = "$6$CjYJ4ijMofQeNLFY$N3g.40lT.j2FDiWpt6Jv2grSFvY/mTJWuQ9q.AVlT5gtwzjwGmocWI9X2IvuiEDsXMs3Rrxs2Kmove3y.yXMO1";
  users.users.${user}.initialHashedPassword = "$6$CjYJ4ijMofQeNLFY$N3g.40lT.j2FDiWpt6Jv2grSFvY/mTJWuQ9q.AVlT5gtwzjwGmocWI9X2IvuiEDsXMs3Rrxs2Kmove3y.yXMO1";

  # TEMP
  # boot.swraid.enable = true;
  # boot.swraid.mdadmConf = ''
  #   MAILADDR root
  #   HOMEHOST ${config.networking.hostName}
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
