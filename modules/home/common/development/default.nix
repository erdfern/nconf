{ pkgs
, me
, ...
}:
# let
#   cfg = config.kor.profiles.development;
# in
{
  imports = [
    ./shell
    ./helix
    ./yazi
    ./neovim.nix
    ./direnv.nix
    ./code.nix
    ./rider.nix
    ./intellij.nix
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
      # elvish
      # devenv
      gh
    ];

    programs.starship.enable = true;

    programs.nix-your-shell = {
      enable = true;
    };

    programs.zoxide = {
      enable = true;
      options = [
        "--cmd j" # j, ji instead of z, zi
      ];
    };

    programs.atuin = {
      enable = false;
      settings = {
        auto_sync = false;
        sync_frequency = "5m";
        sync_address = "https://api.atuin.sh";
        search_mode = "fuzzy";

        # session_path = config.age.secrets."atuin_session".path;
        # key_path = config.age.secrets."atuin_key".path;
      };
    };

    programs = {
      jujutsu = {
        enable = true;
        settings = {
          user.name = me.git.user;
          user.email = me.git.email;
        };
      };
      jjui.enable = true;
      git-cliff.enable = true;
      delta = {
        # syntax highlighting pager
        enable = false;
        options.navigate = true;
      };
      difftastic.enable = true;
      difftastic.git.enable = true;
      git = {
        enable = true;
        lfs.enable = false;
        settings = {
          user.name = me.git.user;
          user.email = me.git.email;
          core.exludesFile = "~/.gitignore_global";
          merge.conflictstyle = "diff3"; # or "merge";
          # merge.ff = true;
          pull.rebase = true; # rebase
          diff.colorMoved = "default";
        };
        signing.key = me.gpg.signKey;
        signing.format = "openpgp";
        signing.signByDefault = false;
      };
      fd.enable = true;
      fzf.enable = true;
      bat.enable = true;
      ripgrep.enable = true;
      ripgrep-all.enable = true;
    };

    home.sessionPath = [ "$HOME/.cargo/bin" "$HOME/.pnpm/bin" ];
    home.sessionVariables.PNPM_HOME = "$HOME/.pnpm/bin";
  };
}
