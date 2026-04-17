{ lib
, config
, inputs
, pkgs
, me
, ...
}:
let
  inherit (me) user;
  cfg = config.kor.profiles.desktop;
in
{
  imports = [
    # https://wiki.hypr.land/Nix/Hyprland-on-NixOS/#upstream-module
    # inputs.hyprland.result.nixosModules.default
    ./hyprland
    ./gaming.nix
  ];

  options.kor.profiles.desktop = with lib; {
    enable = mkEnableOption "desktop profile (hyprland compositor)";
    autologin = mkOption { type = types.bool; default = true; description = "Whether to login me.user on startup"; };
    # TODO for machines which don't have wifi or bluetooth
    # wifi = mkEnableOption "wifi support";
    # bluetooth = mkEnableOption "bluetooth support";
  };

  config = lib.mkIf cfg.enable {
    kor.system.audio.enable = true;
    kor.system.graphics.enable = true;
    kor.system.wifi.enable = true;
    kor.system.bluetooth.enable = true;
    kor.system.networking.networkmanager = true;

    kor.desktop.hyprland.enable = true;

    # https://github.com/hyprwm/Hyprland/issues/9064
    # https://wiki.archlinux.org/title/ICC_profiles
    # services.colord.enable = true;

    # services.getty.autologinOnce = cfg.autologin; # only once per boot on first tty
    services.getty.autologinUser = lib.mkIf cfg.autologin me.user; # always login this user at console

    time.timeZone = "Europe/Berlin";
    # services.automatic-timezoned.enable = true; # figure it out

    programs.dconf.enable = true;

    xdg.portal = {
      enable = true;
      xdgOpenUsePortal = true;
      # config.common.default = "*";
      # config.common.default = "hyprland;gtk"; # portal-hyprland is only for interfaces which portal-gtk doesn't handle, like screenshare
      config.common."org.freedesktop.impl.portal.Secret" = "gnome-keyring";

      # # extraPortals = [ xdg-desktop-portal-gtk inputs.hyprland.result.packages.${pkgs.stdenv.hostPlatform.system}.xdg-desktop-portal-hyprland];
      # extraPortals = [ pkgs.xdg-desktop-portal-gtk ];
    };

    # Secrets portal
    services.gnome.gnome-keyring.enable = true;

    # wanted by file managers for MTP transfer, e.g. Nemo, Nautilus
    services.gvfs.enable = true;

    # removable media automounting
    # services.devmon.enable = true;
    services.udisks2.enable = true;
    programs.gnome-disks.enable = true; # UDisks2 graphical front-end; nemo likes having this for gnome-disk-image-mounter
    # services.udisks2.settings = {
    #   "udisks2.conf" = {
    #     defaults = {
    #       encryption = "luks2";
    #     };
    #     udisks2 = {
    #       modules = [
    #         "*"
    #       ];
    #       modules_load_preference = "ondemand";
    #     };
    #   };
    #   "WDC-WD10EZEX-60M2NA0-WD-WCC3F3SJ0698.conf" = {
    #     ATA = {
    #       StandbyTimeout = 50;
    #     };
    #   };
    # };

    # use public Cloudflare DNS resolver
    services.resolved = {
      enable = true;
      settings = {
        Resolve = {
          DNSSEC = "true";
          Domains = [ "~." ];
          fallbackDNS = [
            "1.1.1.1"
            "1.0.0.1"
          ];
          DNSOverTLS = "true";
        };
      };
    };
    networking.nameservers = lib.mkDefault [
      "1.1.1.1"
      "1.0.0.1"
    ];
    # since we manage dns manually..
    networking.useDHCP = false;
    networking.dhcpcd.enable = false;
    networking.networkmanager.dhcp = "internal";
    # networking.networkmanager.dns = "systemd-resolved";

    # TEMP ports for wake on lan
    # networking.firewall.rejectPackets = true;
    # networking.firewall.allowedTCPPorts = [ 9 ];
    # networking.firewall.allowedUDPPorts = [ 9 ];

    environment.systemPackages = map lib.lowPrio [
      pkgs.kitty
      pkgs.starship
      pkgs.networkmanagerapplet
      # pkgs.app2unit # for properly starting apps in uwsm
      pkgs.app2unit-kor # for properly starting apps in uwsm
      # pkgs.xdg-terminal-exec # app2unit terminal support
    ];

    # Setup persisted directories.
    kor.system.impermanence.root = lib.mkIf config.kor.system.impermanence.enable {
      extraDirectories = [
        "/var/lib/bluetooth"
        "/etc/NetworkManager/system-connections"
      ];
      extraFiles = [
        "/var/lib/NetworkManager/secret_key"
        "/var/lib/NetworkManager/seen-bssids"
        "/var/lib/NetworkManager/timestamps"
      ];
    };

    fonts = {
      enableDefaultPackages = true;
      enableGhostscriptFonts = false;

      fontDir.enable = true;
      # fontDir.decompressFonts = # default if xwayland is enabled

      fontconfig = {
        enable = true;
        antialias = true;
        allowBitmaps = false; # no bitmap fonts
        # useEmbeddedBitmaps = false; # default
        # allowType1 = false; # default

        # for dpi < 200
        subpixel.lcdfilter = "default";
        subpixel.rgba = "rgb"; # default none
        # for dpi < 200
        hinting.enable = true;
        # hinting.autohint = false;
        hinting.style = "slight";

        # defaultFonts = {
        #   emoji = [ "Noto Color Emoji" ];
        #   serif = [ "Noto Serif" ];
        #   sansSerif = [ "Noto Sans" ];
        #   monospace = [ "Noto Sans Mono" ];
        # };
        defaultFonts = {
          emoji = [ "Noto Color Emoji" ];
          serif = [ "NotoSerif NFP" ];
          sansSerif = [ "NotoSans NFP" ];
          monospace = [ "GeistMono Nerd Font" ];
        };

        # localConf = '''';
      };

      packages = with pkgs; [
        # noto-fonts # smaller than nerdfont by a LOT, buut... missing unicode symbols, ironically?
        noto-fonts-color-emoji
      ] ++
      (with nerd-fonts ; [
        noto # everything... also huge as nerdfont
        # inconsolata
        # ubuntu
        # ubuntu-sans
        # ubuntu-mono
        # jetbrains-mono
        space-mono # sans mono
        zed-mono # sans mono
        caskaydia-cove
        # caskaydia-mono # cove but no ligatures?
        geist-mono # sans mono
        hack # sans mono
        # profont
        # monaspace
        #md-io        
        droid-sans-mono # good for small screens or font sizes
      ]);
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

    # xkb config
    services.xserver.xkb = {
      layout = "us,de";
      options = "caps:escape_shifted_capslock,grp:shifts_toggle";
    };
    # make TTY use xkb config
    console.useXkbConfig = true;
    # not needed for xkb or anything! but i like the more immediate prompt
    console.earlySetup = true;
  };
}
