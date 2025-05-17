{ user, lib, inputs, pkgs, ... }: {
  imports = [
    ./boot.nix
    ./fs
    ./system
    ./presets/desktop.nix
    ./presets/development.nix
    ./presets/laptop.nix
    ./presets/server.nix
    # ./virtualisation/qemu.nix
  ];

  config = {
    kor.boot.enable = lib.mkDefault true;

    # TODO mv
    catppuccin.enable = false;
    catppuccin.tty.enable = true;
    catppuccin.flavor = "mocha";
    catppuccin.accent = "peach";

    boot.kernelPackages = lib.mkDefault pkgs.linuxPackages_latest;

    services.openssh = {
      enable = lib.mkDefault false;
      settings = {
        # Opinionated: forbid root login through SSH.
        PermitRootLogin = lib.mkDefault "no";
        # Opinionated: use keys only.
        # Remove if you want to SSH using passwords
        PasswordAuthentication = lib.mkDefault false;
      };
    };

    # enable nitrokey udev rules and gpg agent
    hardware.nitrokey.enable = true;
    # programs = {
    #   ssh.startAgent = false;
    #   gnupg.agent = {
    #     enable = true;
    #     enableSSHSupport = true;
    #   };
    # };
    programs.ssh.startAgent = true;
    programs.ssh.pubkeyAcceptedKeyTypes = [
      "ssh-ed25519"
      "ssh-ed25519-cert-v01@openssh.com"
      "sk-ssh-ed25519@openssh.com"
      "sk-ssh-ed25519-cert-v01@openssh.com"
      "ecdsa-sha2-nistp256"
      "ecdsa-sha2-nistp256-cert-v01@openssh.com"
      "ecdsa-sha2-nistp384"
      "ecdsa-sha2-nistp384-cert-v01@openssh.com"
      "ecdsa-sha2-nistp521"
      "ecdsa-sha2-nistp521-cert-v01@openssh.com"
      "sk-ecdsa-sha2-nistp256@openssh.com"
      "sk-ecdsa-sha2-nistp256-cert-v01@openssh.com"
      "ssh-rsa"
      "ssh-rsa-cert-v01@openssh.com"
    ];

    services.dbus = {
      enable = true;
      implementation = "broker"; # this would be set by enabling uwsm anyway, but yeah
    };

    security.sudo = {
      enable = true;
      extraConfig = ''
        ${user} ALL=(ALL) NOPASSWD:ALL
      '';
    };

    users.users = {
      root.openssh.authorizedKeys.keys = [
        "sk-ssh-ed25519@openssh.com AAAAGnNrLXNzaC1lZDI1NTE5QG9wZW5zc2guY29tAAAAIFDGW5X40nM8SGOPPGdLl3461jIFIwWgsMYrho4KItj+AAAAB3NzaDprb3I= ssh:kor"
      ];
      root.shell = pkgs.bashInteractive;
      ${user} = {
        isNormalUser = true;
        uid = 1000;
        group = "${user}";
        extraGroups = [ "wheel" ];
        home = "/home/${user}";
        openssh.authorizedKeys.keys = [
          "sk-ssh-ed25519@openssh.com AAAAGnNrLXNzaC1lZDI1NTE5QG9wZW5zc2guY29tAAAAIFDGW5X40nM8SGOPPGdLl3461jIFIwWgsMYrho4KItj+AAAAB3NzaDprb3I= ssh:kor"
        ];
        packages = map lib.lowPrio [
          pkgs.home-manager
        ];
      };
    };
    users.groups.${user} = { gid = 1000; };

    time.timeZone = lib.mkDefault "utc";

    programs.fish.enable = true;

    # use dash instead of bash
    environment.binsh = "${pkgs.dash}/bin/dash";

    # noshell
    # programs.noshell.enable = true;

    environment.systemPackages = map lib.lowPrio [
      inputs.nilla-cli.result.packages.default.result.x86_64-linux
      inputs.nilla-utils.result.packages.default.result.x86_64-linux

      pkgs.git
      pkgs.curl
      pkgs.npins

      # some basic tools
      pkgs.helix
      pkgs.inxi
      pkgs.ripgrep
      pkgs.fd
      pkgs.fzf
      pkgs.unzip
      pkgs.btop

      # pkgs.linux-firmware # maybe fix acpi?
      # TEMP hyprpanel dep
      # pkgs.pkgconf
      # pkgs.libgtop
    ];

    system.rebuild.enableNg = true;

    nix = {
      # package = pkgs.lix; # TODO use raw lix module instead
      generateNixPathFromInputs = true;
      generateRegistryFromInputs = true;
      settings = {
        trusted-users = [ "root" "${user}" ]; # maybe add @wheel
        substituters = [
          "https://nix-community.cachix.org"
          "https://kor.cachix.org"
          "https://hyprland.cachix.org"
        ];
        trusted-public-keys = [
          "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
          "kor.cachix.org-1:120l5rP3Npq4wDdbg8AkJ85J4zqilDXMGt2XQHWDHOM="
          "hyprland.cachix.org-1:a7pgxzMz7+chwVL3/pzj6jIBMioiJM7ypFP8PwtkuGc="
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
