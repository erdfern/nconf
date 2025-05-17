{ pkgs
, ...
}: {
  services.xserver.enable = true;
  services.xserver.videoDrivers = [ "amdgpu" ];
  # services.xserver.videoDrivers = [
  #   "modesetting"
  #   "fbdev"
  #   "nvidia"
  # ];

  # boot.initrd.kernelModules = [ "amdgpu" ];
  # boot.initrd.kernelModules = [ "nvidia" ];

  hardware = {
    graphics.enable = true;
    graphics.enable32Bit = true;
    graphics.extraPackages = with pkgs; [
      # amdvlk # sometimes problematic
    ];
    # graphics.extraPackages32 = with pkgs; [
    #   driversi686Linux.amdvlk
    # ];

    amdgpu.initrd.enable = true; # load in stage 1; boot.initrd.kernelModules = ["amdgpu"]
    # amdgpu.opencl.enable = true;

    # alternative way of using amdvlk
    # amdgpu.amdvlk.enable = true;
    # amdgpu.amdvlk.support32Bit= true;
    # amdgpu.amdvlk.supportExperimental= true;
    # amdgpu.amdvlk.settings = {};
    # 
  };

  environment = {
    systemPackages = with pkgs; [
      # vulkan-validation-layers
      vulkan-tools
      eglinfo
      glxinfo
    ];
  };

  # systemd.tmpfiles.rules = [
  # "L+ /run/nvidia-gpu - - - - /dev/dri/by-path/pci-0000:01:00.0-card"
  # "L+ /run/amd-igpu - - - - /dev/dri/by-path/pci-0000:10:00.0-card"
  # ];
}
