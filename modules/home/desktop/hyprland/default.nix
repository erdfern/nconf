{ lib
, config
, pkgs
, inputs
, ...
}:
let
  cfg = config.kor.preset.desktop;
in
{
  imports = [ ./config.nix ./hyprpaper ./hyprlock ];
  # ++ [ inputs.hyprpanel.result.homeManagerModules.hyprpanel ];

  options.kor.preset.desktop.hyprland = with lib; {
    enable = mkEnableOption "hyprland integration";
  };

  config = lib.mkIf cfg.hyprland.enable {
    kor.preset.desktop.enable = true;

    home.packages = with pkgs; [ hyprsunset ];

    programs.kitty.enable = true;

    programs.bash.enable = true;
    programs.bash.profileExtra = ''
      echo "Login shell init on $(${pkgs.coreutils}/bin/tty)"
      if [ "$(${pkgs.coreutils}/bin/tty)" = "/dev/tty1" ] && uwsm check may-start; then
        # exec uwsm start default
        exec uwsm start hyprland-uwsm.desktop
      fi
    '';

    wayland.windowManager.hyprland = {
      enable = true;
      package = null; # https://github.com/nix-community/home-manager/blob/542078066b1a99cdc5d5fce1365f98b847ca0b5a/modules/services/window-managers/hyprland.nix#L72
      portalPackage = null; # TODO check if this is right. Maybe I need to enable the xdg portal in nixos conf if package/portalPackage are null
      systemd.enable = false; # conflicts with nixos option programs.hyprland.withUWSM
      plugins = [
        # inputs.hycov.packages.${pkgs.system}.hycov
      ];
    };


    # TODO
    # uwsm users should avoid placing environment variables in the hyprland.conf file.
    # Instead, use ~/.config/uwsm/env for theming, xcursor, nvidia and toolkit variables,
    # and ~/.config/uwsm/env-hyprland for HYPR* and AQ_* variables.
    # The format is export KEY=VAL.
    # export XCURSOR_SIZE=24
    #
    # might work too?
    home.sessionVariables = {
      ELECTRON_OZONE_PLATFORM_HINT = "auto";
      GRIMBLAST_HIDE_CURSOR = 0;
    };

    # TODO clean this up, merge env vars from different sources etc.
    home.file.".config/uwsm/env" = {
      text = ''
        export ELECTRON_OZONE_PLATFORM_HINT="auto"
        export GRIMBLAST_HIDE_CURSOR=0
        export XCURSOR_SIZE=24

        export SDL_VIDEODRIVER=wayland,x11
        export GDK_BACKEND=wayland,x11,*
        export QT_QPA_PLATFORM=wayland;xcb
        export CLUTTER_BACKEND=wayland
      '';
    };

    services.hyprpolkitagent.enable = true;

    services.hyprsunset = {
      enable = true;
      transitions = { };
    };

    # programs.hyprpanel = {
    #   enable = true;

    #   # systemd.enable = true;

    #   overwrite.enable = false;

    #   settings = {
    #     theme.font = {
    #       # name = "CaskaydiaCove NF";
    #       size = "12px";
    #     };
    #   };
    # };
  };
}
