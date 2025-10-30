# TODO I'd like to use floorp or maybe zen.. :3
{ lib
, config
, pkgs
, inputs
, ...
}:
let
  cfg = config.kor.desktop.apps.firefox;
in
{
  imports = [ ./preferences ./extensions ./policies.nix ./search.nix ];

  # rename suite.desktop/browser?
  options.kor.desktop.apps.firefox = with lib; {
    enable = mkEnableOption "firefox browser";
    nightly = mkOption {
      type = types.bool;
      default = false;
      description = ''
        Whether to use the nightly version of Firefox.
      '';
    };
    makeDefault = mkOption {
      type = types.bool;
      default = true;
      description = ''
        Whether to make Firefox the default browser for opening associated mime types.
      '';
    };
  };

  config = lib.mkIf cfg.enable {
    programs.firefox =
      {
        enable = true;

        # package = (pkgs.wrapFirefox (pkgs.firefox-unwrapped.override { pipewireSupport = true; })) { };
        # TODO use nightly option to decide which package to use
        package = inputs.firefox-nightly.result.packages.${pkgs.system}.firefox-nightly-bin;

        profiles.default =
          {
            isDefault = true;
            search =
              {
                force = true;
                default = "ddg";
              };
            extensions.force = true; # Using 'programs.firefox.profiles.default.extensions.settings' will override all previous extensions settings. Enable [...].extensions.force to acknowledge
            settings =
              {
                # Normal firefox settings that happen to be blocked with policies
                "services.sync.declinedEngines" = "";

                "sidebar.verticalTabs" = true;
                "sidebar.visibility" = "hide-sidebar";

                # NOTE tridactyl places itself here and I don't know how to stop/relocate it
                # also, if this is just an empty string, defaults apply (all tools selected)
                "sidebar.main.tools" = "history";
              };
          };
      };

    # programs.firefox.profiles.default.extensions.force
    home = {
      # file.".mozilla/firefox/profiles.ini".force = true;
      sessionVariables = {
        BROWSER = "firefox"; # `man` likes having this
        MOZ_ENABLE_WAYLAND = "1";
        MOZ_USE_XINPUT2 = "1";
      };
    };

    xdg.mimeApps.defaultApplications = lib.mkIf cfg.makeDefault {
      "text/html" = "firefox.desktop";
      "x-scheme-handler/http" = "firefox.desktop";
      "x-scheme-handler/https" = "firefox.desktop";
      "x-scheme-handler/about" = "firefox.desktop";
      "x-scheme-handler/unknown" = "firefox.desktop";
    };
  };
}
