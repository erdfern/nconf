{ pkgs
, inputs
, ...
}: {
  kor.preset.desktop.enable = true;
  kor.preset.desktop.hyprland.enable = true;

  home.file.".config/uwsm/env-hyprland" = {
    text = ''
      export DUMMY=42
      export HYPRLAND_TRACE=1
      export AQ_TRACE=1

      export GDK_BACKEND=wayland,x11,*
      export QT_QPA_PLATFORM=wayland;xcb
      export SDL_VIDEODRIVER=wayland
      export CLUTTER_BACKEND=wayland

      export LIBVA_DRIVER_NAME=iHD
    '';
  };

  kor.preset.desktop.apps.firefox.enable = true;

  home.packages = with pkgs; [
    npins
    inputs.nilla-cli.result.packages.nilla-cli.result.x86_64-linux
    inputs.nilla-utils.result.packages.nilla-utils-plugins.result.x86_64-linux
  ];
}
