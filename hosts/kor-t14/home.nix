{ pkgs
, inputs
, ...
}: {
  imports = [ ./batcheck.nix ];
  kor.preset.desktop.enable = true;
  kor.preset.desktop.hyprland.enable = true;
  kor.preset.desktop.apps.firefox.enable = true;
  kor.preset.desktop.gaming.enable = true;

  home.file.".config/uwsm/env-hyprland" = {
    text = ''
      export DUMMY=42
      export HYPRLAND_TRACE=1
      export AQ_TRACE=1

      export LIBVA_DRIVER_NAME=iHD
    '';
  };

  home.packages = with pkgs; [
    npins
    inputs.nilla-cli.result.packages.nilla-cli.result.x86_64-linux
    inputs.nilla-utils.result.packages.nilla-utils-plugins.result.x86_64-linux
  ];
}
