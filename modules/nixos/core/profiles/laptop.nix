{ lib
, config
, me
, pkgs
, ...
}:
let
  inherit (me) user;
  cfg = config.kor.profiles.laptop;
in
{
  options.kor.profiles.laptop = with lib; {
    enable = mkEnableOption "laptop profile";
    # preferTLP = mkOption {
    #   type = types.bool;
    #   default = true;
    #   description = "Whether to use TLP instead of power profiles daemon.";
    # };
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
    };
  };

  config = lib.mkIf cfg.enable {
    kor.profiles.desktop.enable = true;
    kor.system.boot.plymouth.enable = true;

    # power saving for wifi connections
    networking.networkmanager.wifi.powersave = true;

    services.upower.enable = true;
    services.tlp.enable = true; # succeeded by auto-cpufreq? uh, or ppd ig. would be default-enabled by t14 hardware module (or rather generic laptop module) if ppd is disabled, i think
    services.auto-cpufreq = {
      enable = true;
      settings = {
        battery = {
          governor = "powersave";
          turbo = "auto";
        };
        charger = {
          governor = "performance";
          turbo = "auto";
        };
      };
    };
    # TODO consider replacing with tuned, see
    # - https://wiki.archlinux.org/title/CPU_frequency_scaling#tuned
    # - https://fedoraproject.org/wiki/Changes/TunedAsTheDefaultPowerProfileManagementDaemon#Make_Tuned_the_Default_Power_Profile_Management_Daemon#see
    # but consider https://discussion.fedoraproject.org/t/f41-change-proposal-make-tuned-the-default-power-profile-management-daemon-system-wide/118554/29
    # services.power-profiles-daemon.enable = true; # more modern way of managing power than tlp. clashes with tlp (or other power management services) if enabled simultaneously

    # Enable light to control backlight.
    programs.light.enable = true;
    hardware.acpilight.enable = true; # might be nice for compat

    users.users.${user}.extraGroups = [ "video" ]; # needed for light and acpilight to work
    environment.systemPackages = map lib.lowPrio [
      pkgs.brightnessctl # prefer over light, which seems abandoned
    ];

    # Setup suspend then hibernate.
    services.logind.settings.Login.HandleLidSwitch =
      if cfg.suspendThenHibernate.enable
      then "suspend-then-hibernate"
      else "suspend";
    systemd.sleep.extraConfig = lib.optionalString cfg.suspendThenHibernate.enable ''
      HibernateDelaySec=${builtins.toString cfg.suspendThenHibernate.delayHours}h
    '';
  };
}
