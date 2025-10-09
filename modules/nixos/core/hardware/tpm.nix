{ lib
, config
, pkgs
, me
, ...
}:
let
  cfg = config.kor.hardware.tpm;
in
{
  options.kor.hardware.tpm = with lib; {
    enable = mkEnableOption "tpm support";
  };

  config = lib.mkIf cfg.enable {
    security.tpm2 = {
      enable = true;
      abrmd.enable = true; # userspace resource manager daemon
      pkcs11.enable = true; # expose /run/current-system/sw/lib/libtpm2_pkcs11.so
      tctiEnvironment.enable = true; # TPM2TOOLS_TCTI and TPM2_PKCS11_TCTI env variables
    };

    # systemd.tpm2.enable = true;
    # boot.initrd.systemd.tpm2.enable = true;

    users.users.${me.user}.extraGroups = [ "tss" ]; # tss group has access to TPM devices

    environment.systemPackages = [ pkgs.tpm2-tools ];

    # boot.kernelModules = [ "uhid" ];

    # users.users.tss = {
    #   name = "tss";
    #   group = "tss";
    #   isSystemUser = true;
    # };
    # users.groups.tss.name = "tss";
    # users.groups.uhid.name = "uhid";

    # users.users.${me.user}.extraGroups = [ "tss" "uhid" ];

    # services.udev.extraRules = ''
    #   # tpm devices can only be accessed by the tss user but the tss
    #   # group members can access tpmrm devices
    #   KERNEL=="tpm[0-9]*", TAG+="systemd", MODE="0660", OWNER="tss"
    #   KERNEL=="tpmrm[0-9]*", TAG+="systemd", MODE="0660", OWNER="tss", GROUP="tss"

    #   # uhid group can access /dev/uhid
    #   KERNEL=="uhid", SUBSYSTEM=="misc", MODE="0660", GROUP="uhid"
    # '';
  };
}
