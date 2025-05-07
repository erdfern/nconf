{ lib
, config
, ...
}:
let
  cfg = config.kor.boot;
in
{
  options.kor.boot = with lib; {
    enable = mkEnableOption "system bootloader";
    plymouth = {
      enable = mkEnableOption "use plymouth";
    };
  };

  config = lib.mkIf cfg.enable {
    # kor.boot.plymouth.enable = lib.mkDefault true;

    boot = {
      initrd.systemd.enable = true; # systemd-stage-1 
      # initrd.verbose = false;
      # consoleLogLevel = 0;
      plymouth = lib.mkIf cfg.plymouth.enable {
        enable = true;
        # theme = 
      };

      loader = {
        timeout = 0; # if 0, press any key to show OS selection
        systemd-boot = {
          enable = true;
          editor = false;
          consoleMode = "auto";
        };
        efi.canTouchEfiVariables = true;
      };
    };

    # silence acpi errors and such
    boot.kernelParams = lib.mkDefault [
      "quiet"
      "loglevel=3" # KERN_ERR or higher
      # "rd.systemd.show_status=false"
      # "rd.udev.log_level=3"
      # "udev.log_priority=3"
    ];
  };
}
