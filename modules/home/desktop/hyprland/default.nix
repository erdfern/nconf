{ lib
, config
, pkgs
, inputs
, ...
}:
let
  cfg = config.kor.desktop.hyprland;
in
{
  imports = [ ./config.nix ./hyprpaper ./hyprlock ];
  # ++ [ inputs.hyprpanel.result.homeManagerModules.hyprpanel ];

  options.kor.desktop.hyprland = with lib; {
    enable = mkEnableOption "hyprland integration";
    autostartWaybar = mkOption { type = types.bool; default = false; description = "Whether to start waybar together with Hyprland"; };

    # NOTE this instead of "standard" env vars because of uwsm  https://wiki.hyprland.org/Configuring/Environment-variables/
    uwsmEnv = mkOption {
      type = types.listOf types.lines;
      default = [ ];
      description = "List of environment variables to export in ~/.config/uwsm/env-hyprland. Format is \"export <VAR>=<value>\"";
    };
  };

  config = lib.mkIf cfg.enable {
    kor.desktop.apps.kitty.enable = true;

    kor.desktop.apps.waybar.enable = lib.mkIf cfg.autostartWaybar (lib.mkForce true);

    kor.desktop.hyprland.uwsmEnv = [
      "export EXAMPLE_DUMMY=42"
      "export EXAMPLE_DUMMY2=84"

      "export ELECTRON_OZONE_PLATFORM_HINT=auto"
      "export GRIMBLAST_HIDE_CURSOR=0"

      # QT stuff
      # "export QT_QPA_PLATFORM=wayland;xcb"
      # "export QT_QPA_PLATFORMTHEME=qt6ct"
      "export QT_WAYLAND_DISABLE_WINDOWDECORATION=1"
      "export QT_AUTO_SCREEN_SCALE_FACTOR=1"
    ] # ++ lib.lists.optional config.home.pointerCursor.hyprcursor.enable "export HYPRCURSOR_SIZE=${config.home.pointerCursor.hyprcursor.size}";
    ++ (if config.home.pointerCursor.hyprcursor.enable then [
      "export HYPRCURSOR_SIZE=${config.home.pointerCursor.hyprcursor.size}"
      # "export HYPRCURSOR_THEME=${config.home.pointerCursor.hyprcursor.size}"
    ] else [ ]);

    home.file."${config.xdg.configHome}/uwsm/TESTenv-hyprland".text = lib.mkIf (cfg.uwsmEnv != [ ]) lib.strings.concatLines cfg.uwsmEnv;

    home.packages = with pkgs; [ hyprsunset ];

    home.pointerCursor.hyprcursor.enable = true;
    home.pointerCursor.hyprcursor.size = 24;

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
    # home.sessionVariables = {
    # };

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
