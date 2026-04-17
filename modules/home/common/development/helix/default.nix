{ pkgs, ... }:
let
  # treesitter-surrealql-highlights-queries = builtins.fetchurl "https://raw.githubusercontent.com/erdfern/tree-sitter-surrealql/refs/heads/main/queries/highlights.scm";
in
{
  programs.helix = {
    enable = true;
    defaultEditor = true; # set $EDITOR etc
    settings = {
      keys = {
        normal = {
          tab = "move_parent_node_end";
          S-tab = "move_parent_node_start";
          X = [ "select_line_above" ];
          # A-x = "extend_to_line_bounds";
          # On tiling wm, alt+{h,j,k,l} will be bound
          # TODO maybe just make a hyprland submapppp?
          C-J = "join_selections_space";
          C-K = "remove_selections";
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
  # meh. muh. mrah
  # home.file.".config/helix/runtime/queries/surrealql/highlights.scm".source = treesitter-surrealql-highlights-queries;

  # some lsps
  home.packages = with pkgs; [
    marksman
    markdown-oxide
    taplo
    tombi
    # json etc.
    # vscode-langservers-extracted # OLD, but has HTML :[
    vscode-json-languageserver
    vscode-css-languageserver
  ];
}
