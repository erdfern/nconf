{ lib, ... }: {
  config = {
    # Time and Locale
    # time.timeZone =  lib.mkDefault "Europe/Berlin";
    time.timeZone = lib.mkDefault "utc";

    # NOTE need to set TZDIR, some apps complain otherwise and timedatectl shows timezone offset (CET to UTC) as +0000, which is false...
    # systemd.user.sessionVariables
    # NOTE set in uwsm home config

    i18n.defaultLocale = lib.mkDefault "en_US.UTF-8";
    # i18n.supportedLocales = [ "en_US.UTF-8/UTF-8" "nl_NL.UTF-8/UTF-8" "nl_NL/ISO-8859-1" ];
    i18n.supportedLocales = [ "en_US.UTF-8/UTF-8" "de_DE.UTF-8/UTF-8" "de_DE/ISO-8859-1" ];
    # i18n.extraLocaleSettings = lib.mkDefault {
    #   # LC_CTYPE = "de_DE.UTF-8";
    #   LC_NUMERIC = "de_DE.UTF-8";
    #   LC_TIME = "de_DE.UTF-8";
    #   LC_COLLATE = "de_DE.UTF-8";
    #   LC_MONETARY = "de_DE.UTF-8";
    #   # LC_MESSAGES = "de_DE.UTF-8";
    #   LC_PAPER = "de_DE.UTF-8";
    #   LC_NAME = "de_DE.UTF-8";
    #   LC_ADDRESS = "de_DE.UTF-8";
    #   LC_TELEPHONE = "de_DE.UTF-8";
    #   LC_MEASUREMENT = "de_DE.UTF-8";
    #   LC_IDENTIFICATION = "de_DE.UTF-8";
    # };

    console.useXkbConfig = lib.mkDefault true;
  };
}
