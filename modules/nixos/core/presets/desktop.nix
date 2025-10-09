{ lib
, config
, inputs
, pkgs
, me
, ...
}:
let
  inherit (me) user;
  cfg = config.kor.preset.desktop;
in
{
  options.kor.preset.desktop = with lib; {
    enable = mkEnableOption "desktop preset (hyprland compositor)";
    autologin = mkOption { type = types.bool; default = true; description = "Whether to login me.user on startup"; };
    # TODO for machines which don't have wifi or bluetooth
    # wifi = mkEnableOption "wifi support";
    # bluetooth = mkEnableOption "bluetooth support";
  };

  config = lib.mkIf cfg.enable {
    # enable audio support
    kor.system.audio.enable = true;

    # services.getty.autologinOnce = cfg.autologin; # only once per boot on first tty
    services.getty.autologinUser = lib.mkIf cfg.autologin me.user; # always login this user at console

    time.timeZone = "Europe/Berlin";
    # services.automatic-timezoned.enable = true; # figure it out

    # enable graphics support
    hardware.graphics.enable = true;
    hardware.graphics.enable32Bit = true;

    # enable wifi and bluetooth support
    networking.networkmanager.enable = true;

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
    # configure PAM for hyprlock auth
    security.pam.services.hyprlock = { };

    services.dbus = {
      enable = true;
      implementation = lib.mkForce "broker"; # uwsm suggestion/soft requirement
    };

    xdg.portal = {
      # enable = true;
      xdgOpenUsePortal = true;
      # config.common.default = "*";
      # config.common.default = "hyprland;gtk"; # portal-hyprland is only for interfaces which portal-gtk doesn't handle, like screenshare
      config.common."org.freedesktop.impl.portal.Secret" = "gnome-keyring";

      # # extraPortals = [ xdg-desktop-portal-gtk inputs.hyprland.result.packages.${pkgs.stdenv.hostPlatform.system}.xdg-desktop-portal-hyprland];
      # extraPortals = [ pkgs.xdg-desktop-portal-gtk ];
    };

    # Secrets portal
    services.gnome.gnome-keyring.enable = true;

    # wanted by file managers for MTP transfer, e.g. Nemo
    services.gvfs.enable = true;

    # removable media automounting
    # services.devmon.enable = true;
    services.udisks2.enable = true;
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
      dnssec = "true";
      domains = [ "~." ];
      fallbackDns = [
        "1.1.1.1"
        "1.0.0.1"
      ];
      dnsovertls = "true";
    };
    networking.nameservers = [
      "1.1.1.1"
      "1.0.0.1"
    ];

    # TEMP ports for wake on lan
    # networking.firewall.rejectPackets = true;
    # networking.firewall.allowedTCPPorts = [ 9 ];
    # networking.firewall.allowedUDPPorts = [ 9 ];
    # 
    environment.systemPackages = map lib.lowPrio [
      pkgs.kitty
      pkgs.starship
      pkgs.networkmanagerapplet
      # pkgs.app2unit # for properly starting apps in uwsm
      pkgs.app2unit-kor # for properly starting apps in uwsm
      pkgs.xdg-terminal-exec # app2unit terminal support
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
          # serif = [ "Noto Serif" ];
          # sansSerif = [ "Noto Sans" ];
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
        hack # sans
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
