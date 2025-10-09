# kinda interesting..: https://github.com/ALEX11BR/ThemeChanger
{ pkgs, config, ... }:
{
  # TODO move qt config
  # using kvantum since catppuccin requires it to apply their theme
  qt = {
    enable = true;
    platformTheme.name = "kvantum";
    style.name = "kvantum";
  };

  kor.desktop.uwsm.env = [
    "GTK_THEME=${config.gtk.theme.name}"
    "GTK_ICON_THEME=${config.gtk.iconTheme.name}"
    # just re-export these since they get set by catppuccin cursors module
    "XCURSOR_THEME=${config.home.pointerCursor.name}"
    "XCURSOR_SIZE=${toString config.home.pointerCursor.size}"

    # QT
    "QT_QPA_PLATFORM=wayland;xcb"
    # "QT_QPA_PLATFORMTHEME=qtct"
    # also set by home-manager qt module, but I want it in uwsm env..
    "QT_QPA_PLATFORMTHEME=${config.qt.platformTheme.name}"
    "QT_STYLE_OVERRIDE=${config.qt.style.name}"
    "QT_WAYLAND_DISABLE_WINDOWDECORATION=1"
    "QT_AUTO_SCREEN_SCALE_FACTOR=1"
  ];

  dconf.settings = {
    "org/gnome/desktop/interface".color-scheme = "prefer-dark";
  };

  # gtk settings viewer/editor
  home.packages = with pkgs; [

    # needed for QT qt5ct platformtheme setting?
    # libsForQt5.qt5ct
    # qt6Packages.qt6ct

    nwg-look
  ]; #++ (with kdePackages; [ breeze breeze.qt5 breeze-gtk breeze-icons ]);

  home.pointerCursor.size = 24;

  gtk = {
    enable = true;
    theme = {
      name = "Tokyonight-Dark";
      package = pkgs.tokyonight-gtk-theme;
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
    # gtk4.extraConfig = {
    #   gtk-application-prefer-dark-theme = true;
    # };
    # gtk3.extraConfig = {
    #   gtk-application-prefer-dark-theme = true;
    #   gtk-xft-antialias = 1;
    #   gtk-xft-hinting = 1;
    #   gtk-xft-hintstyle = "hintslight";
    #   gtk-xft-rgba = "rgb";
    # };
    # gtk2.extraConfig = ''
    #   gtk-xft-antialias=1
    #   gtk-xft-hinting=1
    #   gtk-xft-hintstyle="hintslight"
    #   gtk-xft-rgba="rgb"
    # '';
  };
}
