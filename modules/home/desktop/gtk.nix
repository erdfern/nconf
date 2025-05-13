{ pkgs, ... }:
{
  # dconf.settings = {
  #   "org/gnome/desktop/interface".color-scheme = "prefer-dark";
  # };

  # gtk settings viewer/editor
  home.packages = with pkgs; [ nwg-look ]; #++ (with kdePackages; [ breeze breeze.qt5 breeze-gtk breeze-icons ]);

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
