{ lib
, config
, ...
}:
let
  cfg = config.kor.desktop.apps.zathura;
in
{
  options.kor.desktop.apps.zathura = with lib; {
    enable = mkEnableOption "zathura document viewer";
  };

  config = {
    # catppuccin theming comes automatically via catppuccin.autoEnable.
    programs.zathura = {
      enable = cfg.enable;
      options = {
        selection-clipboard = "clipboard";
      };
    };
  };
}
