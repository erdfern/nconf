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
    amdgpu.opencl.enable = false; # 20.06.25, caused a weird build issue (error: output '/nix/store/...-clr-6.3.3-icd' is not allowed to refer to the following paths: /nix/store/...-gcc-14.3.0)
    # alternative way of using amdvlk
    # NOTE: amdvlk is said to sometimes be problematic
    # amdgpu.amdvlk.enable = true;
    # amdgpu.amdvlk.support32Bit.enable = true;
    # amdgpu.amdvlk.supportExperimental.enable = true;
    # amdgpu.amdvlk.settings = {};

    # graphics.extraPackages = with pkgs; [ amdvlk ];
  };

  environment = {
    systemPackages = with pkgs; [
      vulkan-validation-layers
      vulkan-tools
      glxinfo
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
