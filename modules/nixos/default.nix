{ user, lib, inputs, pkgs, ... }: {
  imports = [
    ./boot.nix
    ./presets/desktop.nix
    ./presets/development.nix
    ./presets/laptop.nix
    ./presets/immutable.nix
    ./presets/server.nix
    # ./virtualisation/qemu.nix
  ];

  config = {
    kor.boot.enable = lib.mkDefault true;

    # TODO mv
    catppuccin.enable = false;
    catppuccin.flavor = "mocha";
    catppuccin.accent = "peach";

    boot.kernelPackages = lib.mkDefault pkgs.linuxPackages_latest;

    services.openssh = {
      enable = true;
      # settings = {
        # Opinionated: forbid root login through SSH.
        # PermitRootLogin = "no";
        # Opinionated: use keys only.
        # Remove if you want to SSH using passwords
        # PasswordAuthentication = false;
      # };
    };

    programs.ssh.startAgent = true;

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
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIE/rupin71C/GxJ9r74UNanoxuUR7FA3u+Wc88Z/5oYh lk@kor"
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJw9d44H5L7ivkWwWhzV6TEycwpMe8wA3jHXydoBqbaj lk@kor-t14"
      ];
      root.shell = pkgs.bashInteractive;
      ${user} = {
        isNormalUser = true;
        uid = 1000;
        group = "${user}";
        extraGroups = [ "wheel" ];
        home = "/home/${user}";
        openssh.authorizedKeys.keys = [
          "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIE/rupin71C/GxJ9r74UNanoxuUR7FA3u+Wc88Z/5oYh lk@kor"
          "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJw9d44H5L7ivkWwWhzV6TEycwpMe8wA3jHXydoBqbaj lk@kor-t14"
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
      pkgs.git
      pkgs.helix
      pkgs.curl
      pkgs.npins
      pkgs.inxi
      pkgs.ripgrep
      pkgs.fd
      pkgs.fzf
      pkgs.unzip
      pkgs.btop
      inputs.nilla-cli.result.packages.default.result.x86_64-linux
      inputs.nilla-utils.result.packages.default.result.x86_64-linux

      # pkgs.linux-firmware # maybe fix acpi?
      # TEMP hyprpanel dep
      pkgs.pkgconf
      pkgs.libgtop
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
