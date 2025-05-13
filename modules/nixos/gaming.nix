{ config, lib, pkgs, ... }:
let
  cfg = config.kor.gaming;
in
{
  options.kor.gaming = with lib; {
    enable = mkEnableOption "gaming";
  };

  config = lib.mkIf cfg.enable {
    programs.steam = {
      enable = false;
      remotePlay.openFirewall = true;
      dedicatedServer.openFirewall = true;
      localNetworkGameTransfers.openFirewall = true;

      gamescopeSession = { enable = true; };

      # extest.enable = true; # translate x11 input event to uinput (for steam input on wayland?)
      # protontricks.enable = true;

      extraCompatPackages = [ pkgs.proton-ge-bin ];

      # package = pkgs.steam.override {
      #   # extraPkgs = pkgs: [
      #   #   pkgs.openssl_1_1
      #   #   (pkgs.callPackage ../pkgs/openldap_2_4.nix { })
      #   #   pkgs.libnghttp2
      #   #   pkgs.libidn2
      #   #   pkgs.rtmpdump
      #   #   pkgs.libpsl
      #   # ];
      #   extraLibraries = pkgs: (with config.hardware.graphics;
      #     if pkgs.hostPlatform.is64bit
      #     then [ package ] ++ extraPackages
      #     else [ package32 ] ++ extraPackages32);
      # };
    };

    # udev rules for steam-supported controllers and such
    hardware.steam-hardware.enable = true;
    # gamecube controller support
    # services.udev.packages = with pkgs; [ dolphin-emu ];

    programs.gamemode.enable = true;

    environment = {
      systemPackages = with pkgs; [
        (heroic.override {
          extraPkgs = pkgs: [ pkgs.gamescope pkgs.gamemode ];
        })
        bottles
        usbutils # steam wants this in some shell script i think
        # wineWowPackages.stable
        # wineWowPackages.full
        # protonup-qt
      ];
      sessionVariables = {
        STEAM_COMPAT_DATA_PATH = "$HOME/.local/share/Steam/steamapps/compatdata";
        STEAM_EXTRA_COMPAT_TOOLS_PATHS = "$HOME/.steam/root/compatibilitytools.d";
      };
    };
  };
}
