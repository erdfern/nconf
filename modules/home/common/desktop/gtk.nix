# kinda interesting..: https://github.com/ALEX11BR/ThemeChanger
{ pkgs, config, lib, ... }:
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

  home.pointerCursor.size = 24;

  gtk = {
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
      name = "Catppuccin-${lib.toUpper config.catppuccin.accent}-Dark";
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
