{ lib, config, ... }:
let
  cfg = config.kor.desktop.apps.kitty;
in
{
  options.kor.desktop.apps.kitty = with lib; {
    enable = mkEnableOption "kitty terminal";
  };

  config = {
    programs = lib.mkIf cfg.enable {
      kitty = {
        enable = cfg.enable;
        environment = { };
        keybindings = {
          "ctrl+alt+t" = "new_tab_with_cwd";
        };
        font.name = "monospace";
        # font.size = 16;
        settings = {
          remote_control = "yes"; # TODO make this finegrained for security? i basically just want this for fuzzel/kitty @ launch
          disable_ligatures = "cursor";
          italic_font = "auto";
          bold_italic_font = "auto";
          mouse_hide_wait = -1; # hide on typing, else compositor should handle it
          cursor_shape = "block";
          # url_color = "#0087bd";
          url_style = "dotted";
          #Close the terminal =  without confirmation;
          confirm_os_window_close = 0;
          background_opacity = "0.9";
        };
      };
    };
  };
}
