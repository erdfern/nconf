{ pkgs, config, ... }:
{
  kor.desktop.uwsm.env = [
    # "GTK_THEME=${config.gtk.theme.name}"
    # just re-export these since they get set by catppuccin cursors module
    "XCURSOR_THEME=${config.home.pointerCursor.name}"
    "XCURSOR_SIZE=${toString config.home.pointerCursor.size}"
  ];

  # dconf.settings = {
  #   "org/gnome/desktop/interface".color-scheme = "prefer-dark";
  # };

  # gtk settings viewer/editor
  home.packages = with pkgs; [ nwg-look ]; #++ (with kdePackages; [ breeze breeze.qt5 breeze-gtk breeze-icons ]);

  home.pointerCursor.size = 24;

  gtk = {
    enable = true;
    theme = {
      name = "Tokyonight-Dark";
      package = pkgs.tokyonight-gtk-theme;
    };
    iconTheme = {
      name = "Papirus-Dark";
      package = pkgs.papirus-icon-theme;
      # name = "Tela-circle-Dark";
      #   package = pkgs.tela-circle-icon-theme;
    };
    # font = {
    #   name = "JetBrainsMono Nerd Font";
    #   size = 12;
    # };
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
