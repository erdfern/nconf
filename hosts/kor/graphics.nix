{ pkgs
, ...
}: {
  # services.xserver.enable = true;
  services.xserver.videoDrivers = [ "amdgpu" ];

  boot.initrd.kernelModules = [ "amdgpu" ];

  hardware = {
    graphics.enable = true;
    graphics.enable32Bit = true;

    amdgpu.initrd.enable = true; # load in stage 1; boot.initrd.kernelModules = ["amdgpu"]
    amdgpu.opencl.enable = true;
    amdgpu.overdrive.enable = false; # overclocking support

    # NOTE: amdvlk is said to sometimes be problematic
    # NOTE: discontinued in favor of radv: https://www.gamingonlinux.com/2025/09/amdvlk-has-been-discontinued-as-amd-are-throwing-their-full-support-behind-radv/
    # amdgpu.amdvlk.enable = true;
  };

  environment = {
    systemPackages = with pkgs; [
      vulkan-validation-layers
      vulkan-tools
      mesa-demos # formerly glxinfo
      nvtopPackages.amd
      amdgpu_top
      lact
    ];
  };
  systemd.packages = with pkgs; [ lact ];
  systemd.services.lactd.wantedBy = [ "multi-user.target" ];

  # systemd.tmpfiles.rules = [
  # "L+ /run/rx-gpu - - - - /dev/dri/by-path/pci-0000:03:00.0-card"
  # "L+ /run/amd-igpu - - - - /dev/dri/by-path/pci-0000:10:00.0-card"
  # ];
}
