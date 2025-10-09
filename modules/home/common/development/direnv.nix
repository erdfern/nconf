{
  programs = {
    direnv = {
      enable = true;
      # enableBashIntegration = true;
      # enableFishIntegration = true;
      nix-direnv.enable = true;
    };

    # bash.enable = true; # see note on other shells below
    # fish.enable = true;
  };

  home.file.".gitignore_global".text = ''
    .direnv
  '';
}
