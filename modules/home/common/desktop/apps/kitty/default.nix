{ lib, config, ... }:
let
  cfg = config.kor.desktop.apps.kitty;
in
{
  options.kor.desktop.apps.kitty = with lib; {
    enable = mkEnableOption "kitty terminal";
    makeFishAliases = mkOption { type = lib.types.bool; default = config.programs.fish.enable; };
  };

  config = {
    programs = lib.mkIf cfg.enable {
      kitty = {
        enable = cfg.enable;
        environment = { };
        keybindings = {
          "ctrl+alt+t" = "new_tab_with_cwd";
          "ctrl+alt+w" = "new_window_with_cwd";
        };
        font.name = "GeistMono NF";
        # font.size = 16;
        actionAliases = {
          "launch_tab" = "launch --cwd=current --type=tab";
          "launch_window" = "launch --cwd=current --type=os-window";
        };
        settings = {
          allow_remote_control = "yes"; # TODO make this finegrained for security? i basically just want this for fuzzel/kitty @ launch
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
        quickAccessTerminalConfig =
          let
            # kitty_override ???
            override = o: "kitty_override ${o}";
          in
          {
            ${override "allow_remote_control"} = "socket-only";
            ${override "listen_on"} = "unix:/tmp/quickitty";
            start_as_hidden = false;
            hide_on_focus_loss = false;
            background_opacity = 0.85;
          };
      };

      fish.shellAliases = lib.mkIf cfg.makeFishAliases {
        s = "kitten ssh";
      };
    };

  };
}
