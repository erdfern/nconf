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
  imports = [ ./config ./hyprpaper ./hyprlock ./hypridle.nix ];
  # ++ [ inputs.hyprpanel.result.homeManagerModules.hyprpanel ];

  options.kor.desktop.hyprland = with lib; {
    enable = mkEnableOption "hyprland compositor";
  };

  config = lib.mkIf cfg.enable {
    kor.desktop.apps.kitty.enable = true;

    # kor.desktop.apps.waybar.enable = lib.mkIf cfg.autostartWaybar (lib.mkForce true);

    kor.desktop.hyprland.hyprpaper.enable = lib.mkDefault true;

    kor.desktop.uwsm.envHyprland = [
      "ELECTRON_OZONE_PLATFORM_HINT=auto"
      "GRIMBLAST_HIDE_CURSOR=0"

      "SDL_VIDEODRIVER=wayland" #;x11 fallback?
      "GDK_BACKEND=wayland,x11"
      "CLUTTER_BACKEND=wayland"
    ] # ++ lib.lists.optional config.home.pointerCursor.hyprcursor.enable "export HYPRCURSOR_SIZE=${config.home.pointerCursor.hyprcursor.size}";
    ++ (if config.home.pointerCursor.hyprcursor.enable then [
      # NOTE redundant, since catppuccin.cursors sets this anyway
      "HYPRCURSOR_SIZE=${toString config.home.pointerCursor.hyprcursor.size}"
      "HYPRCURSOR_THEME=${config.home.pointerCursor.name}"
    ] else [ ]);

    # home.packages = with pkgs; [ hyprsunset ];
    home.packages = with pkgs; [ hyprprop ];

    home.pointerCursor.hyprcursor.enable = true;
    home.pointerCursor.hyprcursor.size = 24;

    # programs.bash.enable = true;
    # programs.bash.profileExtra = ''
    #   echo "Login shell init on $(${pkgs.coreutils}/bin/tty)"
    #   if [ "$(${pkgs.coreutils}/bin/tty)" = "/dev/tty1" ] && uwsm check may-start; then
    #     # exec uwsm start default
    #     exec uwsm start hyprland-uwsm.desktop
    #   fi
    # '';
    programs.fish.loginShellInit = ''
      set TTY (tty)
      if test "$TTY" = "/dev/tty1"
         and uwsm check may-start
         exec uwsm start hyprland-uwsm.desktop
      end
    '';

    wayland.windowManager.hyprland = {
      enable = true;
      # package = null; # https://github.com/nix-community/home-manager/blob/542078066b1a99cdc5d5fce1365f98b847ca0b5a/modules/services/window-managers/hyprland.nix#L72
      # portalPackage = null; # TODO check if this is right. Maybe I need to enable the xdg portal in nixos conf if package/portalPackage are null
      # NOTE keep in sync with nixos module!!! see for why this is needed instead of null: https://github.com/nix-community/home-manager/issues/7484
      package = inputs.hyprland.result.packages.${pkgs.stdenv.hostPlatform.system}.hyprland;
      portalPackage = inputs.hyprland.result.packages.${pkgs.stdenv.hostPlatform.system}.xdg-desktop-portal-hyprland;
      systemd.enable = lib.mkForce false; # conflicts with nixos option programs.hyprland.withUWSM
      plugins = [
        # inputs.hycov.packages.${pkgs.system}.hycov
      ];
    };

    services.hyprpolkitagent.enable = true;

    services.hyprsunset = {
      enable = true;

      # https://wiki.hypr.land/Hypr-Ecosystem/hyprsunset/
      settings = {
        # max-gamma = 100;
        # profile = [
        #   { }
        # ];
      };
    };
  };
}
