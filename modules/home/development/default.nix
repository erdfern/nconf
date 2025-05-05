{ lib
, config
, pkgs
, inputs
, ...
}:
# let
#   cfg = config.kor.profiles.development;
# in
{
  imports = [
    ./fish
    ./helix
    ./yazi
  ];

  # options.kor.profiles.desktop = with lib; {
  #   enable = mkEnableOption "desktop profile";
  # };

  # config = lib.mkIf (cfg.enable) {
  config = {
    home.packages = with pkgs; [
      nil
      nixd
      nixpkgs-fmt
      elvish
    ];

    programs = {
      git-cliff.enable = true;
      git = {
        enable = true;
        lfs.enable = true;
        userName = "erdfern";
        userEmail = "rexsomnia@pm.me";
        delta = {
          # syntax highlighting pager
          enable = false;
          options.navigate = true;
        };
        difftastic = {
          enable = true;
        };
        extraConfig = {
          core.exludesFile = "~/.gitignore_global";
          merge.conflictstyle = "diff3"; # "merge";
          # merge.ff = true;
          diff.colorMoved = "default";
        };
      };
      fd.enable = true;
      fzf.enable = true;
      bat.enable = true;
      ripgrep.enable = true;
      ripgrep-all.enable = true;
    };

    home.file.".gitignore_global".text = ''
      .direnv
    '';
  };
}
