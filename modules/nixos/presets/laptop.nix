{ lib
, config
, user
, pkgs
, ...
}:
let
  cfg = config.kor.preset.laptop;
in
{
  options.kor.preset.laptop = with lib; {
    enable = mkEnableOption "laptop profile";
    # preferTLP = mkOption {
    #   type = types.bool;
    #   default = true;
    #   description = "Whether to use TLP instead of power profiles daemon.";
    # };
    plymouth = {
      enable = mkEnableOption "plymouth support";
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
        description = "Delay in hours before it should hibernate the laptop after suspending.";
      };
    };
    rebindKeyboard = {
      enable = mkOption {
        type = types.bool;
        default = false;
        description = "Whether to enable the keyboard rebinding daemon.";
      };
      devices = mkOption {
        type = types.listOf types.str;
        default = [ "0001:0001" ];
        description = ''
          List of `<vendor_id>:<product_id>` of the keyboards to apply the rebinding to. By default this only uses `0001:0001` which I've always observed for the built-in keyboard in my laptops.

          Discover with `keyd -m`.
        '';
      };
    };
  };

  config = lib.mkIf cfg.enable {
    # Enabling the laptop profile automatically enables the
    # desktop profile too.
    kor.preset.desktop.enable = lib.mkDefault true;

    # power saving for wifi connections
    networking.networkmanager.wifi.powersave = true;

    services.upower.enable = true;
    services.thermald.enable = true;
    services.tlp.enable = false; # succeeded by auto-cpufreq? would be auto-enabled by t14 hardware module, i think
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

    # Enable light to control backlight.
    programs.light.enable = true;
    users.users.${user}.extraGroups = [ "video" ]; # needed for light to have correct privs
    environment.systemPackages = map lib.lowPrio [
      pkgs.brightnessctl # prefer over light, which is abandoned
    ];

    # Enable bluetooth.
    hardware.bluetooth.enable = true;

    # Enable plymouth
    boot = lib.mkIf cfg.plymouth.enable {
      plymouth = {
        enable = true;
        theme = lib.mkDefault "bgrt";
      };
      initrd.systemd.enable = true;
      kernelParams = [ "quiet" ];
      loader.timeout = 0;
    };

    # Setup keyboard rebinding.
    services.keyd.enable = cfg.rebindKeyboard.enable;
    services.keyd.keyboards.laptop = {
      ids = cfg.rebindKeyboard.devices;

      # This mimics my mechanical keyboard with QMK firmware
      # on my laptop keyboards.
      # - Capslock is a navigation layer for various functions.
      # - Grave is escape except in the navigation layer where
      #   it's actually grave. Also shift+grave is still tilde.
      settings = {
        main = {
          grave = "esc";
          capslock = "layer(nav)";
        };

        nav = {
          grave = "grave";
          backspace = "delete";
          # Arrow navigation
          w = "up";
          s = "down";
          a = "left";
          d = "right";
          # Media controls
          z = "previoussong";
          x = "playpause";
          c = "nextsong";
          v = "volumedown";
          b = "volumeup";
          n = "mute";
        };

        shift = {
          grave = "S-grave";
        };
      };
    };

    # Setup suspend then hibernate.
    services.logind.lidSwitch =
      if cfg.suspendThenHibernate.enable
      then "suspend-then-hibernate"
      else "suspend";
    systemd.sleep.extraConfig = lib.optionalString cfg.suspendThenHibernate.enable ''
      HibernateDelaySec=${builtins.toString cfg.suspendThenHibernate.delayHours}h
    '';
  };
}
