{ config, me, lib, inputs, pkgs, ... }:
let
  cfg = config.kor;
in
{
  imports = [
    ./system
    ./sops
    ./profiles
    ./hardware
    ./virtualisation
    ./users.nix
    ./flatpak.nix
  ];

  options.kor.ssh.enable = lib.mkEnableOption "SSH";
  options.kor.basic-utils = lib.mkEnableOption "Basic utility programs";

  config = {
    kor.system.boot.enable = lib.mkDefault true;
    kor.basic-utils = lib.mkDefault true;

    # documentation.man.generateCaches.enable = lib.mkForce false; # sometimes _veryy_ slow, and i don't use man often tbh. Enabled by fish.

    # TODO mv
    catppuccin.enable = lib.mkDefault true;
    # catppuccin.tty.enable = true;
    catppuccin.flavor = "mocha";
    catppuccin.accent = "peach";

    # TODO mv
    # programs.nix-ld.enable = true;
    # programs.nix-ld.libraries = [];

    services.openssh = {
      enable = lib.mkDefault false;
      settings = {
        # Opinionated: forbid root login through SSH.
        PermitRootLogin = lib.mkDefault "no";
        # Opinionated: use keys only.
        PasswordAuthentication = lib.mkDefault false;
      };
    };

    programs.ssh.startAgent = lib.mkDefault true;
    programs.ssh.pubkeyAcceptedKeyTypes = lib.mkDefault [
      "ssh-ed25519"
      "ssh-ed25519-cert-v01@openssh.com"
      "sk-ssh-ed25519@openssh.com"
      "sk-ssh-ed25519-cert-v01@openssh.com"
      "sk-ecdsa-sha2-nistp256@openssh.com"
      "sk-ecdsa-sha2-nistp256-cert-v01@openssh.com"
      "ssh-rsa"
      "ssh-rsa-cert-v01@openssh.com"
    ];

    environment.systemPackages = lib.mkIf cfg.basic-utils (map lib.lowPrio [
      # some basic tools
      pkgs.git
      pkgs.curl
      pkgs.inxi
      pkgs.ripgrep
      pkgs.fd
      pkgs.fzf
      pkgs.unzip
      pkgs.file
      pkgs.btop
      pkgs.helix
      # pkgs.neovim
      # pkgs.glow
      pkgs.trashy
      pkgs.trash-cli

      # things that should probably be in a dev shell (and home profile, but don't need to be in initial system after clean install)
      inputs.nilla-cli.result.packages.default.result.x86_64-linux
      inputs.nilla-utils.result.packages.default.result.x86_64-linux
      pkgs.colmena
      # pkgs.npins-git
      pkgs.npins
      # pkgs.attic-client
      # pkgs.sops
    ]);

    nix = {
      # package = pkgs.lix; # TODO use raw lix module instead
      generateNixPathFromInputs = true;
      generateRegistryFromInputs = true;
      settings = {
        trusted-users = [ "root" "${me.user}" ]; # maybe add @wheel
        substituters = [
          "https://cache.nixos.org"
          "https://nix-community.cachix.org"
          "https://hyprland.cachix.org"
          "https://kor.cachix.org"
        ];
        trusted-public-keys = [
          "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
          "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
          "hyprland.cachix.org-1:a7pgxzMz7+chwVL3/pzj6jIBMioiJM7ypFP8PwtkuGc="
          "kor.cachix.org-1:120l5rP3Npq4wDdbg8AkJ85J4zqilDXMGt2XQHWDHOM="
        ];
        keep-derivations = true;
        keep-outputs = true;
      };
      extraOptions = ''
        experimental-features = nix-command flakes
        keep-outputs          = true
        keep-derivations      = true
      '';
    };
  };
}
