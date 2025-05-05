{ lib
, config
, pkgs
, ...
}:
let
  cfg = config.kor.preset.desktop.apps.firefox;
in
{
  imports = [ ./preferences.nix ./policies.nix ./search.nix ./extensions.nix ];

  # rename suite.desktop?
  options.kor.preset.desktop.apps.firefox = with lib; {
    enable = mkEnableOption "firefox browser";
  };

  config = lib.mkIf cfg.enable {
    programs.firefox =
      {
        enable = true;

        package = (pkgs.wrapFirefox (pkgs.firefox-unwrapped.override { pipewireSupport = true; })) { };

        profiles.default =
          {
            isDefault = true;
            search =
              {
                force = true;
                default = "ddg";
              };
            settings =
              {
                # Normal firefox settings that happen to be blocked with policies
                "services.sync.declinedEngines" = "";

                "sidebar.verticalTabs" = true;
                "sidebar.main.tools" = "";
              };
          };
      };

    home = {
      file.".mozilla/firefox/profiles.ini".force = true;
      sessionVariables = {
        BROWSER = "firefox"; # `man` likes having this
        MOZ_ENABLE_WAYLAND = "1";
        MOZ_USE_XINPUT2 = "1";
      };
    };
  };
}
