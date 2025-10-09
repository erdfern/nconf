{ modulesPath
, lib
, pkgs
, ...
}:
{
  imports = [
    (modulesPath + "/installer/scan/not-detected.nix")
    (modulesPath + "/profiles/qemu-guest.nix")
    ./disk-config.nix
  ];

  networking.hostName = "n1";
  networking.useDHCP = lib.mkDefault true;

  boot.loader.grub = {
    # no need to set devices, disko will add all devices that have a EF02 partition to the list already
    # devices = [ ];
    efiSupport = true;
    efiInstallAsRemovable = true;
  };
  services.openssh.enable = true;

  environment.systemPackages = map lib.lowPrio [
    pkgs.curl
    pkgs.gitMinimal
  ];

  users.users.root.openssh.authorizedKeys.keys = [
    # change this to your ssh key
    "sk-ssh-ed25519@openssh.com AAAAGnNrLXNzaC1lZDI1NTE5QG9wZW5zc2guY29tAAAAIGbfWj2zAADpQBzrqydUq40755qifLmzOMp3We32hs7hAAAAE3NzaDpsYXguZXJkZmVybi5kZXY= ssh:lax.erdfern.dev"
  ];

  nix.extraOptions = ''
    experimental-features = nix-command flakes
    keep-outputs = true
    keep-derivations = true'';

  system.stateVersion = "25.05";
}
