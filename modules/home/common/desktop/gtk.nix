# kinda interesting..: https://github.com/ALEX11BR/ThemeChanger
{ pkgs, config, lib, ... }:
let

  # capitalize = lib.strings.toSentenceCase;
  capitalize = str:
    if str == "" then ""
    else (lib.toUpper (builtins.substring 0 1 str)) + (builtins.substring 1 ((builtins.stringLength str) - 1) str);
in
{
  # it's ded
  # catppuccin.gtk.enable = true;
  catppuccin.gtk.icon.enable = true;

  kor.desktop.uwsm.env = [
    "GTK_THEME=${config.gtk.theme.name}"
    # NOTE set by catppuccin
    "GTK_ICON_THEME=${config.gtk.iconTheme.name}"
    # just re-export these since they get set by catppuccin.cursors module
    "XCURSOR_THEME=${config.home.pointerCursor.name}"
    "XCURSOR_SIZE=${toString config.home.pointerCursor.size}"
  ];

  # might not be needed with gtk.colorScheme set
  dconf.settings = {
    "org/gnome/desktop/interface".color-scheme = "prefer-dark";
  };

  # gtk settings viewer/editor
  home.packages = with pkgs; [
    # nwg-look
  ]; #++ (with kdePackages; [ breeze breeze.qt5 breeze-gtk breeze-icons ]);

  home.pointerCursor.enable = true;
  home.pointerCursor.size = 24;

  gtk = {
    # GTK4 stuff
    # 
    # For context, see [Please don’t theme our apps](https://stopthemingmy.app/)
    # and [Restyling apps at scale](https://blogs.gnome.org/tbernard/2018/10/15/restyling-apps-at-scale/).
    # gtk4.theme = config.gtk.theme; # legacy behavior pre HM 26.05
    gtk4.theme = null; # new 26.05 default...
    # ---
    enable = true;
    colorScheme = "dark"; # or light or null
    theme = {
      #   name = "Tokyonight-Dark";
      #   package = pkgs.tokyonight-gtk-theme;
      # package = pkgs.gnome-themes-extra;
      # name = "Adwaita";
      # TODO set the accent color; override?
      package = pkgs.catppuccin-gtk-theme.override { themeVariants = [ config.catppuccin.accent ]; };
      # package = pkgs.catppuccin-gtk-theme;
      name = "Catppuccin-${capitalize config.catppuccin.accent}-Dark";
    };
    # iconTheme = {
    #   name = "Papirus-Dark";
    #   package = pkgs.papirus-icon-theme;
    #   # name = "Tela-circle-Dark";
    #   #   package = pkgs.tela-circle-icon-theme;
    # };
    font = {
      name = "GeistMono Nerd Font";
      size = 14;
    };
  };
}
