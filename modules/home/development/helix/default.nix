{ ... }:
{
  programs.helix = {
    enable = true;
    defaultEditor = true; # set $EDITOR etc
    # package = inputs.helix.packages.${pkgs.system}.default;
    settings = {
      keys = {
        normal = {
          tab = "move_parent_node_end";
          S-tab = "move_parent_node_start";
          X = [ "select_line_above" ];
          # A-x = "extend_to_line_bounds";
        };
        insert = {
          S-tab = "move_parent_node_start";
        };
        select = {
          tab = "extend_parent_node_end";
          S-tab = "extend_parent_node_start";
          X = [ "select_line_above" ];
          # A-x = "extend_to_line_bounds";
        };
      };
      editor = {
        bufferline = "multiple";
        line-number = "relative";
        auto-completion = true;
        auto-format = true;
        completion-trigger-len = 1;
        whitespace.render = { space = "all"; tabs = "all"; };
        whitespace.characters = {
          space = "·";
          tabpad = "·"; # "→···" (depending on tab width)
        };
        indent-guides = {
          render = true;
          character = "╎"; # Some characters that work well: "▏", "┆", "┊", "⸽"
          skip-levels = 1;
        };
        lsp = {
          enable = true;
          display-messages = true;
          display-inlay-hints = false; # maybe buggy/laggy as per docs
        };
      };
    };
  };

  home.file.".config/helix/languages.toml".source = ./languages.toml;
}
