{ lib
, config
, pkgs
, ...
}:
let
  cfg = config.kor.profiles.laptop;
  inherit (cfg.battery) chargeThresholds;
  thresholdRule = lib.concatStringsSep ", " (
    [ ''ACTION=="add"'' ''SUBSYSTEM=="power_supply"'' ''KERNEL=="BAT*"'' ]
    ++ lib.optional (chargeThresholds.start != null)
      ''ATTR{charge_control_start_threshold}="${toString chargeThresholds.start}"''
    ++ lib.optional (chargeThresholds.end != null)
      ''ATTR{charge_control_end_threshold}="${toString chargeThresholds.end}"''
  );
in
{
  options.kor.profiles.laptop = with lib; {
    enable = mkEnableOption "laptop profile";

    battery.chargeThresholds = {
      start = mkOption {
        type = types.nullOr (types.ints.between 0 100);
        default = null;
        description = ''
          Charge level below which the battery starts charging again.
          null leaves the threshold to the firmware. Requires driver support
          (thinkpad_acpi exposes /sys/class/power_supply/BAT*/charge_control_*).
        '';
      };
      end = mkOption {
        type = types.nullOr (types.ints.between 0 100);
        default = null;
        description = "Charge level at which the battery stops charging.";
      };
    };

    suspendThenHibernate = {
      enable = mkOption {
        type = types.bool;
        default = true;
        description = "Whether to setup suspend then hibernate when closing the lid.";
      };
      delayHours = mkOption {
        type = types.int;
        default = 1;
        description = "Delay in hours before the laptop should hibernate after suspending.";
      };
      onACPower = mkOption {
        type = types.bool;
        default = false;
        description = "Whether to still hibernate after the delay while on AC power.";
      };
    };
  };

  config = lib.mkIf cfg.enable {
    kor.profiles.desktop.enable = true;
    kor.system.boot.plymouth.enable = true;

    assertions = [
      {
        assertion = (chargeThresholds.start == null || chargeThresholds.end == null)
          || chargeThresholds.start < chargeThresholds.end;
        message = "kor.profiles.laptop.battery.chargeThresholds.start must be below .end";
      }
    ];

    # Single power manager. ppd drives the firmware profile
    # (/sys/firmware/acpi/platform_profile, DYTC on ThinkPads) and the
    # intel_pstate/amd_pstate energy-performance preference, and serves
    # org.freedesktop.UPower.PowerProfiles — which is what wayle's power and
    # battery modules talk to.
    #
    # It asserts against services.tlp and services.auto-cpufreq, so neither may
    # come back. nixos-hardware's common/pc/laptop already defaults
    # services.tlp.enable to `!services.power-profiles-daemon.enable`, so the
    # t14 module stays quiet on its own.
    services.power-profiles-daemon.enable = true;

    # ppd owns CPU scaling policy; overrides the mkDefault from
    # hardware-configuration.nix, which would otherwise pull in a redundant
    # cpufreq.service oneshot + cpupower + a cpufreq_powersave modprobe.
    powerManagement.cpuFreqGovernor = null;

    # Battery/AC state for wayle's battery module (org.freedesktop.UPower
    # DisplayDevice) and for bluetooth device battery reporting.
    services.upower.enable = true;

    # Not covered by ppd.
    networking.networkmanager.wifi.powersave = true;

    # Charge thresholds live in the EC and persist across reboot/suspend/
    # hibernate, so `add` is enough — reapplying on every `change` uevent (the
    # battery emits one per capacity tick) would be pointless ACPI traffic.
    # After changing the values, apply without a reboot via
    #   sudo udevadm trigger -s power_supply -c add
    services.udev.extraRules =
      lib.mkIf (chargeThresholds.start != null || chargeThresholds.end != null)
        "${thresholdRule}\n";

    # brightnessctl goes through logind's SetBrightness on the active seat, for
    # both the backlight and *::kbd_backlight leds — no udev sysfs chgrp rules
    # and no `video` group needed (the desktop profile grants it anyway).
    environment.systemPackages = map lib.lowPrio [
      pkgs.brightnessctl
    ];

    # Suspend, then hibernate after the delay.
    services.logind.settings.Login.HandleLidSwitch =
      if cfg.suspendThenHibernate.enable
      then "suspend-then-hibernate"
      else "suspend";
    systemd.sleep.settings.Sleep = lib.mkIf cfg.suspendThenHibernate.enable {
      HibernateDelaySec = "${toString cfg.suspendThenHibernate.delayHours}h";
      HibernateOnACPower = cfg.suspendThenHibernate.onACPower;
    };
  };
}
