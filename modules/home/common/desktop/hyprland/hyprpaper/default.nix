{ config, lib, ... }:
let
  cfg = config.kor.desktop.hyprland.hyprpaper;
in
{
  options.kor.desktop.hyprland.hyprpaper = with lib; {
    enable = mkEnableOption "hyprpaper wallpaper service";
    wall = mkOption {
      type = lib.types.path;
      default = ./wallcat.png;
    };
  };

  config = lib.mkIf cfg.enable {
    home.file.".wall".source = cfg.wall;

    services.hyprpaper = {
      enable = true;
      settings = {
        ipc = "on";
        splash = false;
        splash_offset = "2.0";
        preload = [ "$HOME/.wall" ];
        wallpaper = [
          ",$HOME/.wall"
          # (wp (builtins.elemAt wallpapers 1) null)
          # (wp (builtins.elemAt wallpapers 2) null)
          # (wp (builtins.elemAt wallpapers 3) null)
        ];
      };
    };
  };
}
