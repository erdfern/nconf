{ lib
, config
, pkgs
, inputs
, user
, ...
}:
{
  imports = [
    ./hardware-configuration.nix

    "${inputs.hardware.result}/lenovo/thinkpad/t14"
    # "${inputs.facter.result}/modules/nixos/facter.nix"
    # "${inputs.hardware.result}/common/cpu/intel/tiger-lake"
  ];

  # TEMP
  users.users = {
    root.hashedPasswordFile = "${cfg.path}/passwords/root";
    ${user}.hashedPasswordFile = "${cfg.path}/passwords/${user}";
  };
  fileSystems."${cfg.device}".neededForBoot = true;
  services.flatpak.enable = true;

  # networking.hostName = "kor-t14";
  kor.preset.laptop.enable = true;
  kor.preset.development.enable = true;
  kor.boot.plymouth.enable = true;

  kor.fs.btrfs.enable = true;
  kor.system.impermanence.root.enable = false;
  kor.system.impermanence.home.enable = false;

  # sudo nix run \
  #   --option experimental-features "nix-command flakes" \
  #   --option extra-substituters https://numtide.cachix.org \
  #   --option extra-trusted-public-keys numtide.cachix.org-1:2ps1kLBUWjxIneOy1Ik6cQjb41X0iXVXeHigGmycPPE= \
  #   github:numtide/nixos-facter -- -o facter.json
  # facter.reportPath = ./facter.json;

  # prevent CPU overheating
  # TODO figure out: [WARN][/sys/devices/platform/thinkpad_acpi/dytc_lapmode] present: Thermald can't run on this platform
  # Really just unsupported or misconfigured?
  # I guess lenovo firmware is managing stuff already? hm
  services.thermald.enable = false;

  hardware.nitrokey.enable = true;

  hardware.logitech.wireless.enable = true;
  hardware.logitech.wireless.enableGraphical = true;

  # graphics
  services.xserver.videoDrivers = [ "modesetting" ];
  # use intel Xe driver
  boot.initrd.kernelModules = [ "xe" ]; # load GPU kernel module at stage 1 boot
  boot.kernelParams = [
    "i915.force_probe=!9a49"
    "xe.force_probe=9a49"
  ];

  hardware.graphics.extraPackages = with pkgs;
    [
      # intel-vaapi-driver intel-ocl # LIBVA_DRIVER_NAME=i915
      intel-media-driver # LIBVA_DRIVER_NAME=iHD
      intel-compute-runtime
      vpl-gpu-rt
    ];
  # hardware.graphics.extraPackages = with pkgs; [ intel-media-driver intel-ocl intel-vaapi-driver vpl-gpu-rt ];
  hardware.graphics.extraPackages32 = with pkgs.pkgsi686Linux; [ intel-media-driver ];

  system.stateVersion = "24.11";
}
