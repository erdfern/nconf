{ ... }:
{
  programs.yazi = {
    enable = true;
    enableFishIntegration = true;
    enableBashIntegration = true;
    # enableNushellIntegration = true;
  };

  home.file = {
    ".config/yazi/yazi.toml".source = ./yazi.toml;
    ".config/yazi/keymap.toml".source = ./keymap.toml;
    # ".config/yazi/theme.toml".source = ./theme.toml;
  };
}
