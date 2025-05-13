{ pkgs
, inputs
, ...
}: {
  kor.preset.desktop.enable = true;
  kor.preset.desktop.hyprland.enable = true;
  kor.preset.desktop.apps.firefox.enable = true;
  kor.preset.desktop.gaming.enable = true;

  # TODO clean this uppp
  # home.file.".config/uwsm/env-hyprland" = {
  #   text = ''
  #     export HYPRLAND_TRACE=1
  #     export AQ_TRACE=1
  #     export AQ_DRM_DEVICES=/run/amd-igpu
  #     # export AQ_DRM_DEVICES=/run/nvidia-gpu


  #     export LIBVA_DRIVER_NAME=amdgpu
  # '';
  # };
  #

  home.file.".config/uwsm/env-hyprland" = {
    text = ''
      export HYPRLAND_TRACE=0
      export AQ_TRACE=1
      export AQ_DRM_DEVICES=/dev/dri/card1

      export GBM_BACKEND=nvidia-drm

      export LIBVA_DRIVER_NAME=nvidia
      export __GLX_VENDOR_LIBRARY_NAME=nvidia
      export NVD_BACKEND=direct
    '';
      # export AQ_DRM_DEVICES=/run/nvidia-gpu
      # export __GL_GSYNC_ALLOWED=1
      # export __GL_VRR_ALLOWED=0
  };

  home.packages = with pkgs; [
    npins
    inputs.nilla-cli.result.packages.nilla-cli.result.x86_64-linux
    inputs.nilla-utils.result.packages.nilla-utils-plugins.result.x86_64-linux
  ];
}
