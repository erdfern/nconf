#Qemu/KVM with virt-manager
{ pkgs, user, ... }:
{
  environment = {
    systemPackages = with pkgs; [
      swtpm # TMP emulation
    ];
  };
  programs.virt-manager.enable = true;
  virtualisation.libvirtd = {
    enable = true;
    qemu = {
      package = pkgs.qemu_kvm;
      runAsRoot = true;
      swtpm.enable = true;
      ovmf = {
        enable = true;
        packages = [
          (pkgs.OVMF.override {
            secureBoot = true;
            tpmSupport = true;
          }).fd
        ];
      };
    };

    # hooks = {
    #   qemu = {
    #     "win/prepare/begin/bind_vfio.sh" = ./bind_vfio.sh;
    #     "win/release/end/unbind_vfio.sh" = ./unbind_vfio.sh;
    #   };
    # };
  };

  virtualisation.spiceUSBRedirection.enable = true;

  services.spice-vdagentd.enable = true;  

  networking.firewall.trustedInterfaces = [ "virbr0" ];
  programs.dconf.enable = true;
  users.groups.libvirtd.members = [ "${user}" ];

  environment.etc."libvirt/hooks/qemu" = {
    source = pkgs.writeText "qemu" ''
      #!/usr/bin/env bash
      #
      # Author: SharkWipf
      #
      # Copy this file to /etc/libvirt/hooks, make sure it's called "qemu".
      # After this file is installed, restart libvirt.
      # From now on, you can easily add per-guest qemu hooks.
      # Add your hooks in /etc/libvirt/hooks/qemu.d/vm_name/hook_name/state_name.
      # For a list of available hooks, please refer to https://www.libvirt.org/hooks.html
      #

      GUEST_NAME="$1"
      HOOK_NAME="$2"
      STATE_NAME="$3"
      MISC="''${@:4}"

      BASEDIR="$(dirname $0)"

      HOOKPATH="$BASEDIR/qemu.d/$GUEST_NAME/$HOOK_NAME/$STATE_NAME"

      set -e # If a script exits with an error, we should as well.

      # check if it's a non-empty executable file
      if [ -f "$HOOKPATH" ] && [ -s "$HOOKPATH" ] && [ -x "$HOOKPATH" ]; then
          eval \"$HOOKPATH\" "$@"
      elif [ -d "$HOOKPATH" ]; then
          while read file; do
              # check for null string
              if [ ! -z "$file" ]; then
                eval \"$file\" "$@"
              fi
          done <<< "$(find -L "$HOOKPATH" -maxdepth 1 -type f -executable -print;)"
      fi
    '';

    mode = "0755"; # make it executable and world (?) readable
  };

  environment.etc."libvirt/hooks/kvm.conf" = {
    source = pkgs.writeText "kvm.conf" ''
      ## Virsh devices
      VIRSH_GPU_VIDEO=pci_0000_01_00_0
      VIRSH_GPU_AUDIO=pci_0000_01_00_1
      VIRSH_GPU_USB=pci_0000_01_00_2
      VIRSH_GPU_SERIAL=pci_0000_01_00_3

      VIRSH_NVME_SSD=pci_0000_0f_00_0
    '';
  };

  environment.etc."libvirt/hooks/qemu.d/win/prepare/begin/bind_vfio.sh" = {
    source = ./bind_vfio.sh;
    mode = "0755";
  };

  environment.etc."libvirt/hooks/qemu.d/win/release/end/unbind_vfio.sh" = {
    source = ./unbind_vfio.sh;
    mode = "0755";
  };

}
