{ lib
, config
, pkgs
, inputs
, user
, ...
}:
{
  imports = [
    ./disk-config.nix
    ./hardware-configuration.nix
    "${inputs.facter.result}/modules/nixos/facter.nix"
    # ./impermanence.nix
  ];

  kor.preset.desktop.enable = true;
  kor.preset.development.enable = true;

  facter.reportPath = ./facter.json;

  # networking.hostName = "kor";

  boot.kernelParams = [ "nvidia-drm.modeset=1" "fbdev=1" ];

  users.users.root.initialHashedPassword = "$6$orbHsnj6yKVLTMmN$bFX5tXgje5OP9HDcu4Hb46EmDkFoA58po/fTkqMgxfqMH7ARvOR6xOPj.ANROEdlUzwFIoAeW/ARU.jC4vDPh1";

  users.users.${user}.initialHashedPassword = "$6$orbHsnj6yKVLTMmN$bFX5tXgje5OP9HDcu4Hb46EmDkFoA58po/fTkqMgxfqMH7ARvOR6xOPj.ANROEdlUzwFIoAeW/ARU.jC4vDPh1";

  services = {
    xserver.videoDrivers = [ "nvidia" ];
    # xserver.videoDrivers = [ "nouveau" ];
    # xserver.videoDrivers = [ "amdgpu" ];
  };

  # boot.initrd.kernelModules = [ "amdgpu" ];

  hardware = {
    graphics.enable = true;
    graphics.extraPackages = with pkgs; [
      nvidia-vaapi-driver
      libvdpau
      libvdpau-va-gl
      vaapiVdpau

      libva-vdpau-driver # not suree
      # mesa.drivers
      # amdvlk
    ];
    graphics.enable32Bit = true;
    # graphics.extraPackages32 = with pkgs; [
    # driversi686Linux.amdvlk
    # ];
    nvidia = {
      modesetting.enable = true;
      open = false; # open module currently crashes some games
      powerManagement.enable = true; # fix suspend/wakeup issues
      nvidiaSettings = true;
      # dynamicBoost.enable = true;
      # package = config.boot.kernelPackages.nvidiaPackages.stable;
      # package = config.boot.kernelPackages.nvidiaPackages.beta;
      package = config.boot.kernelPackages.nvidiaPackages.vulkan_beta;
      # package = config.boot.kernelPackages.nvidiaPackages.production;
    };
  };

  environment = {
    systemPackages = with pkgs; [
      glxinfo
      # vulkan-validation-layers
      vulkan-tools
    ];
  };

  systemd.tmpfiles.rules = [
    "L+ /run/nvidia-gpu - - - - /dev/dri/by-path/pci-0000:01:00.0-card"
    # "L+ /run/amd-igpu - - - - /dev/dri/by-path/pci-0000:10:00.0-card"
  ];

  # environment.variables = {
  #   # AQ_DRM_DEVICES = "/run/amd-igpu:/run/nvidia-gpu";
  #   # AQ_DRM_DEVICES = "run/nvidia-gpu:/run/amd-igpu";

  #   # LIBVA_DRIVER_NAME = "nvidia";
  #   # __GLX_VENDOR_LIBRARY_NAME = "nvidia";

  #   # GBM_BACKEND = "nvidia-drm";
  #   # __GL_GSYNC_ALLOWED = "1";
  #   # __GL_VRR_ALLOWED = "0";
  # };

  system.stateVersion = "24.11";
}
