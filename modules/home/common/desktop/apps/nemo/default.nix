{ pkgs, ... }:
{
  home.packages = (with pkgs; [ nemo-with-extensions ]);
  xdg.desktopEntries.nemo = {
    name = "Nemo";
    icon = "nemo";
    exec = "${pkgs.nemo-with-extensions}/bin/nemo %U";
    mimeType = [
      "inode/directory"
      "application/x-gnome-saved-search"
    ];
  };
  dconf = {
    settings = {
      "org/cinnamon/desktop/applications/terminal" = {
        exec = "kitty";
        # exec-arg = ""; # argument
      };
    };
  };
}
