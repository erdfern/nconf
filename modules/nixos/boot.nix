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
      catppuccinTheme = mkOption {
        type = types.bool;
        default = true;
        description = "Whether to enable the catppuccin theme for plymouth.";
      };
    };
  };

  config = lib.mkIf cfg.enable {
    # kor.boot.plymouth.enable = lib.mkDefault true;
    catppuccin.plymouth.enable = cfg.plymouth.catppuccinTheme;

    boot = {
      initrd.systemd.enable = true; # systemd-stage-1 
      # initrd.verbose = false;
      # consoleLogLevel = 0;
      plymouth = lib.mkIf cfg.plymouth.enable {
        enable = true;
        # theme = 
      };

      # silent boot
      consoleLogLevel = 3;
      initrd.verbose = false;
      kernelParams = [
        "quiet"
        "splash"
        "boot.shell_on_fail"
        "udev.log_priority=3"
        "rd.systemd.show_status=auto"
      ];
      # stop low level messages (acpi errors and such) flooding the console after boot
      # kernel.sysctl = { "kernel.printk" = "3 4 1 3"; };

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
  };
}
