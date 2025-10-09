{ lib
, config
, pkgs
, ...
}:
let
  cfg = config.kor.desktop;
in
{
  imports = [
    ./apps
    ./hyprland
    ./suites
    ./gtk.nix
    ./uwsm.nix
    ./notifications.nix
  ];

  options.kor.desktop = with lib; {
    enable = mkEnableOption "desktop preset";
    enableHyprland = mkEnableOption "Hyprland compositor";
  };

  config = lib.mkIf (cfg.enable || cfg.enableHyprland) {
    kor.desktop.hyprland.enable = lib.mkIf cfg.enableHyprland true; # mkIf so it could be set outside of preset without conflict
    kor.desktop.notifications.fnott.enable = true;

    # TEMP HACK
    # this should absolutely be linked with the system config
    # see https://mynixos.com/home-manager/option/xdg.portal.enable
    # and https://flatpak.github.io/xdg-desktop-portal/docs/index.html
    # NOTE this sets NIX_XDG_DESKTOP_PORTAL_DIR to "~/.nix-profile/share/xdg-desktop-portal/portals"
    # thus overriding the env var which is also set by the nixos module, to /run/current-system/sw/share/xdg-desktop-portal/portals/hyprland.portal!
    # I'll disable this for now since it breaks all portal configuration from nixos modules, e.g. the gnome-keyring nixos module.
    xdg.portal = {
      enable = lib.mkForce false;
      # config.common.default = "*";
      # config.common.default = "gtk"; # portal-hyprland is only for interfaces which portal-gtk doesn't handle, like screenshare
      # config.common."org.freedesktop.portal.Settings" = "gtk";

      # extraPortals = [ xdg-desktop-portal-gtk inputs.hyprland.result.packages.${pkgs.stdenv.hostPlatform.system}.xdg-desktop-portal-hyprland];
      # extraPortals = [ pkgs.xdg-desktop-portal-gtk ];
    };

    home.packages = with pkgs; [
      wl-clipboard
      wev
    ];
  };
}
