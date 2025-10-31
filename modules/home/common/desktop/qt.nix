# kinda interesting..: https://github.com/ALEX11BR/ThemeChanger
{ pkgs, config, ... }:
{
  # using kvantum since catppuccin requires it to apply their theme
  qt = {
    enable = true;
    platformTheme.name = "kvantum";
    style.name = "kvantum";
  };

  kor.desktop.uwsm.env = [
    # QT
    "QT_QPA_PLATFORM='wayland;xcb'" # don't forget to quote (single) if it's separated by semicolons!! uwsm interprets semicolon as end of command
    # "QT_QPA_PLATFORMTHEME=qtct"
    # also set by home-manager qt module, but I want it in uwsm env..
    "QT_QPA_PLATFORMTHEME=${config.qt.platformTheme.name}"
    "QT_STYLE_OVERRIDE=${config.qt.style.name}"
    "QT_WAYLAND_DISABLE_WINDOWDECORATION=1"
    "QT_AUTO_SCREEN_SCALE_FACTOR=1"
  ];

  # gtk settings viewer/editor
  home.packages = with pkgs; [
    # needed for QT qt5ct platformtheme setting?
    # libsForQt5.qt5ct
    # qt6Packages.qt6ct
  ]; #++ (with kdePackages; [ breeze breeze.qt5 breeze-gtk breeze-icons ]);
}
