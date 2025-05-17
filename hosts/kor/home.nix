{ pkgs
, inputs
, ...
}: {
  kor.preset.desktop.enable = true;
  kor.preset.desktop.enableHyprland = true;
  kor.desktop.apps.firefox.enable = true;
  kor.desktop.suites.gaming.enable = true;

  kor.desktop.uwsm.env = [
    "LIBVA_DRIVER_NAME=radeonsi"
    "VDPAU_DRIVER=radeonsi"

    # "export GBM_BACKEND=nvidia-drm"

    # export __GL_GSYNC_ALLOWED=1
    # export __GL_VRR_ALLOWED=0
  ];
  kor.desktop.uwsm.envHyprland = [
    "export HYPRLAND_TRACE=1"
    "export AQ_TRACE=1"
    # "export AQ_DRM_DEVICES=/dev/dri/card1"
  ];

  # home.packages = with pkgs; [
  #   npins
  #   inputs.nilla-cli.result.packages.nilla-cli.result.x86_64-linux
  #   inputs.nilla-utils.result.packages.nilla-utils-plugins.result.x86_64-linux
  # ];
}
