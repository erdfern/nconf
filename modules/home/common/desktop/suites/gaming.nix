{ lib
, config
, pkgs
, osConfig
, ...
}:
let
  cfg = config.kor.desktop.suites.gaming;
in
{
  options.kor.desktop.suites.gaming = with lib; {
    enable = mkEnableOption "gaming stuff";
    # enable = mkOption {
    #   default = false;
    #   # readOnly = true;
    #   description = "";
    # };
    # lutris.enable = mkOption {
    #   type = types.bool;
    #   default = true;
    #   description = "Whether to install and configure the Lutris launcher";
    # };
  };

  config = lib.mkIf cfg.enable {
    programs.lutris = {
      # enable = cfg.lutris.enable;
      enable = true;
      # protonPackages = [ pkgs.proton-ge-bin ];
      winePackages = [ pkgs.wineWow64Packages.full ]; # waylandFull?
      steamPackage = osConfig.programs.steam.package;
      extraPackages = with pkgs; [
        mangohud
        winetricks
        gamescope
        gamemode
        umu-launcher
        protobuf # Battle.net??
      ];
    };

    home.packages = [
      # pkgs.wineWow64Packages.full
    ];
  };
}
