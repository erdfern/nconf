{ pkgs, lib, config, ... }:
{
  catppuccin.fish.enable = true;
  # TODO use noshell?
  # use fish as interactive shell, but keep bash as login shell for compat etc.
  programs.bash = {
    initExtra = lib.mkBefore ''
      if [[ $(${pkgs.procps}/bin/ps --no-header --pid=$PPID --format=comm) != "fish" && -z ''${BASH_EXECUTION_STRING} ]]
      then
        shopt -q login_shell && LOGIN_OPTION='--login' || LOGIN_OPTION=""
        exec ${pkgs.fish}/bin/fish $LOGIN_OPTION
      fi
    '';
  };

  programs.fish = {
    enable = true;

    plugins = with pkgs.fishPlugins; [
      # { name = "bass"; src = bass.src; } # bash utility compat
      # { name = "colored-man-pages"; src = colored-man-pages.src; } # `man`-wrapper
      { name = "plugin-git"; src = plugin-git.src; } # git aliases
    ];

    loginShellInit = lib.mkIf config.wayland.windowManager.hyprland.enable ''
      set TTY1 (tty)
      # if begin uwsm check may-start; and uwsm select; end
      # 	exec uwsm start default
      # end
      # start hyprland directly
      if uwsm check may-start
        exec uwsm start hyprland-uwsm.desktop
      end
      # [ "$TTY1" = "/dev/tty1" ] && exec dbus-run-session Hyprland
      # [ "$TTY1" = "/dev/tty1" ] && exec Hyprland
    '';

    interactiveShellInit = ''
      set fish_greeting ""
    '';

    shellAliases = {
      s = "kitten ssh";
      l = "ls -ahl";
      ff = "ji";
      hf = ''hx (FZF_DEFAULT_COMMAND='fd' FZF_DEFAULT_OPTS="--preview 'bat --style=numbers --color=always --line-range :500 {}'" fzf --height 60% --layout reverse --info inline --border --color 'border:#b48ead')'';
      r = "yazi";
      top = "btop";
      # trl = "trashy list | fzf --multi | awk '{$1=$1;print}' | rev | cut -d ' ' -f1 | rev | xargs trashy restore --match=exact --force";
      # tre = "trashy list | fzf --multi | awk '{$1=$1;print}' | rev | cut -d ' ' -f1 | rev | xargs trashy empty --match=exact --force";
    };

    functions = {
      # f = ''
      #   FZF_DEFAULT_COMMAND='fd --type f --hidden --follow --exclude .git' FZF_DEFAULT_OPTS="--color=bg+:#4C566A,bg:#424A5B,spinner:#F8BD96,hl:#F28FAD  --color=fg:#D9E0EE,header:#F28FAD,info:#DDB6F2,pointer:#F8BD96  --color=marker:#F8BD96,fg+:#F2CDCD,prompt:#DDB6F2,hl+:#F28FAD --preview 'bat --style=numbers --color=always --line-range :500 {}'" fzf --height 60% --layout reverse --info inline --border --color 'border:#b48ead'
      # '';
      f = ''
        FZF_DEFAULT_COMMAND='fd --type f --hidden --follow --exclude .git' FZF_DEFAULT_OPTS=" --preview 'bat --style=numbers --color=always --line-range :500 {}'" fzf --height 60% --layout reverse --info inline --border
      '';
    };
  };

  home.file = {
    ".config/fish/completions/pnpm.fish".text = ''
      function _pnpm_completion
        set cmd (commandline -o)
        set cursor (commandline -C)
        set words (count $cmd)

        set completions (eval env DEBUG=\"" \"" COMP_CWORD=\""$words\"" COMP_LINE=\""$cmd \"" COMP_POINT=\""$cursor\"" SHELL=fish pnpm completion-server -- $cmd)

        if [ "$completions" = "__tabtab_complete_files__" ]
          set -l matches (commandline -ct)*
          if [ -n "$matches" ]
            __fish_complete_path (commandline -ct)
          end
        else
          for completion in $completions
            echo -e $completion
          end
        end
      end

      complete -f -d 'pnpm' -c pnpm -a "(_pnpm_completion)"
    '';
    # ".config/fish/functions/fish_prompt.fish".source = ./functions/fish_prompt.fish;
    # ".config/fish/conf.d/nord.fish".text = import ./nord_theme.nix;
    # ".config/fish/functions/owf.fish".source = ./functions/owf.fish;
    # ".config/fish/functions/yy.fish".source = ./functions/yy.fish;
    # ".config/fish/functions/xdg-get.fish".text = import ./functions/xdg-get.nix;
    # ".config/fish/functions/xdg-set.fish".text = import ./functions/xdg-set.nix;
  };
}
