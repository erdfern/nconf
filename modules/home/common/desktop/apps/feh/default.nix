{ ... }:
{
  programs.feh = {
    enable = true;
    # buttons = {};
    # themes = {};
  };

  xdg.mimeApps = {
    defaultApplications = {
      "image/jpeg" = [ "feh.desktop" ];
      "image/png" = [ "feh.desktop" ];
      "image/pnm" = [ "feh.desktop" ];
      "image/tiff" = [ "feh.desktop" ];
      "image/webp" = [ "feh.desktop" ];
      "image/bmp" = [ "feh.desktop" ];
    };
  };
}
