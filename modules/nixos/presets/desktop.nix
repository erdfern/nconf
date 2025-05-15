{ lib
, config
, inputs
, pkgs
, user
, ...
}:
let
  cfg = config.kor.preset.desktop;
in
{
  imports = [
    ../hardware/audio.nix
    ../gaming.nix
  ];
  options.kor.preset.desktop = with lib; {
    enable = mkEnableOption "desktop preset";
  };

  config = lib.mkIf cfg.enable {
    # enable audio support
    kor.hardware.audio.enable = true;

    kor.gaming.enable = lib.mkDefault true;

    # time.timeZone = lib.mkDefault "Europe/Berlin";
    services.automatic-timezoned.enable = true; # figure it out

    # enable graphics support
    hardware.graphics.enable = true;
    hardware.graphics.enable32Bit = true;

    # enable wifi and bluetooth support
    networking.networkmanager.enable = true;
    services.resolved.enable = true;

    hardware.bluetooth.enable = true;
    hardware.bluetooth.powerOnBoot = true;
    hardware.bluetooth.settings = { General = { Experimental = true; }; }; # enable battery reporting to upower
    services.blueman.enable = true;
    services.upower.enable = true;

    programs.dconf.enable = true;

    # enable hyprland compositor
    programs.hyprland = {
      enable = true;
      xwayland.enable = true;
      package = inputs.hyprland.result.packages.${pkgs.stdenv.hostPlatform.system}.hyprland;
      portalPackage = inputs.hyprland.result.packages.${pkgs.stdenv.hostPlatform.system}.xdg-desktop-portal-hyprland;

      withUWSM = true; # means that home.wayland.windowManager.hyprland.systemd.enable should be false
    };
    # sync mesa version with hyprlands
    hardware.graphics.package = inputs.hyprland.result.inputs.nixpkgs.legacyPackages.${pkgs.stdenv.hostPlatform.system}.mesa;
    hardware.graphics.package32 = inputs.hyprland.result.inputs.nixpkgs.legacyPackages.${pkgs.stdenv.hostPlatform.system}.pkgsi686Linux.mesa;

    environment.systemPackages = map lib.lowPrio [
      pkgs.kitty
      pkgs.starship
      pkgs.networkmanagerapplet
      pkgs.app2unit # for uwsm
    ];

    # Setup persisted directories.
    kor.preset.immutable = lib.mkIf config.kor.preset.immutable.enable {
      directories = [
        "/var/lib/bluetooth"
        "/etc/NetworkManager/system-connections"
      ];
      files = [
        "/var/lib/NetworkManager/secret_key"
        "/var/lib/NetworkManager/seen-bssids"
        "/var/lib/NetworkManager/timestamps"
      ];
    };

    fonts = {
      enableDefaultPackages = true;
      packages = with pkgs; [
        inconsolata
        powerline-fonts
      ] ++ (with nerd-fonts ; [ jetbrains-mono ]);
    };

    users.users.${user}.extraGroups = [
      "cdrom"
      "input"
      "tty"
      "video"
      "dialout"
      "networkmanager"

      "render" # not suree. might be important for vulkan stuff
    ];
  };
}
