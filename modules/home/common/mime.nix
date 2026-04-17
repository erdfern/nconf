{ pkgs, ... }:
{
  xdg.mimeApps = {
    enable = true;
    defaultApplications = {
      "application/pdf" = [ "firefox-nightly.desktop" "firefox.desktop" ];
    };
  };
}
