{ pkgs
, config
, inputs
, lib
, ...
}:
let
  authorizedKeys = [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIE/rupin71C/GxJ9r74UNanoxuUR7FA3u+Wc88Z/5oYh lk@kor"
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJw9d44H5L7ivkWwWhzV6TEycwpMe8wA3jHXydoBqbaj lk@kor-t14"
  ];
in
{
  users.users.kor = {
    isNormalUser = true;
    extraGroups = [ "wheel" ];
    openssh.authorizedKeys.keys = authorizedKeys;
  };
  environment.variables.EDITOR = "vim";
  users.users.root.openssh.authorizedKeys.keys = authorizedKeys;

  security.sudo.wheelNeedsPassword = false;
  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  nix.settings.trusted-users = [ "kor" ];

  services.openssh = {
    enable = true;
    settings.PasswordAuthentication = false;
    settings.KbdInteractiveAuthentication = false;
    settings.PermitRootLogin = lib.mkForce "no"; # force needed for making live images
  };
}
