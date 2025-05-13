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
    ./impermanence.nix

    "${inputs.hardware.result}/lenovo/thinkpad/t14"
    "${inputs.facter.result}/modules/nixos/facter.nix"
    # "${inputs.hardware.result}/common/cpu/intel/tiger-lake"
  ];

  # networking.hostName = "kor-t14";
  kor.preset.laptop.enable = true;
  kor.preset.development.enable = true;
  kor.boot.plymouth.enable = true;

  # sudo nix run \
  #   --option experimental-features "nix-command flakes" \
  #   --option extra-substituters https://numtide.cachix.org \
  #   --option extra-trusted-public-keys numtide.cachix.org-1:2ps1kLBUWjxIneOy1Ik6cQjb41X0iXVXeHigGmycPPE= \
  #   github:numtide/nixos-facter -- -o facter.json
  facter.reportPath = ./facter.json;

  # prevent CPU overheating
  # TODO figure out: [WARN][/sys/devices/platform/thinkpad_acpi/dytc_lapmode] present: Thermald can't run on this platform
  # Really just unsupported or misconfigured?
  # I guess lenovo firmware is managing stuff already? hm
  services.thermald.enable = true;

  hardware.nitrokey.enable = true;

  hardware.logitech.enable = true;
  hardware.logitech.enableGraphical = true;
  hardware.logitech.wireless.enable = true;
  hardware.logitech.wireless.enableGraphical = true;

  hardware.graphics.extraPackages = with pkgs; [ intel-media-driver intel-ocl intel-vaapi-driver vpl-gpu-rt ];
  hardware.graphics.extraPackages32 = with pkgs.pkgsi686Linux; [ intel-vaapi-driver ];
  services.xserver.videoDrivers = [ "modesetting" ];

  # stop low level messages (acpi errors and such) flooding the console
  boot.kernel.sysctl = { "kernel.printk" = "3 4 1 3"; };
  boot.kernelParams = [
    "quiet"
    "splash"
  ];

  system.stateVersion = "24.11";
}
