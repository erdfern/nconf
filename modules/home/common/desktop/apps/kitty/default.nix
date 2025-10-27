{ lib, config, ... }:
let
  cfg = config.kor.desktop.apps.kitty;
in
{
  options.kor.desktop.apps.kitty = with lib; {
    enable = mkEnableOption "kitty terminal";
    makeFishAliases = mkOption { type = lib.types.bool; default = config.programs.fish.enable; };
    makeDefault = mkOption { type = lib.types.bool; default = true; };
  };

  config = lib.mkIf cfg.enable {
    programs = {
      kitty = {
        enable = cfg.enable;
        enableGitIntegration = true;
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

          # performance, maybe at the cost of energy usage
          input_delay = 0;
          repaint_delay = 2;
          sync_to_monitor = "no";
          wayland_enable_ime = "no";
        };
        quickAccessTerminalConfig =
          {
            # kitty_override ???
            # This would need to be valid, since kitty_override can appear multiple times!! :<
            # kitty_override = [
            #   "allow_remote_control=socket-only"
            #   "listen_on=unix:/tmp/quickitty"
            # ];
            kitty_override = "listen_on=unix:/tmp/quickitty";
            start_as_hidden = false;
            hide_on_focus_loss = false;
            background_opacity = 0.85;
          };
      };

      fish.shellAliases = lib.mkIf cfg.makeFishAliases {
        s = "kitten ssh";
      };

      # $TERM is set to xterm-kitty by default
      kor.desktop.uwsm.env = lib.mkIf cfg.makeDefault [ "TERMINAL=kitty" ];
    };
  };
}
