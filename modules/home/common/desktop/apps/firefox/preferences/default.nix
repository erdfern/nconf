{
  imports = [ ./ui.nix ];

  # https://mozilla.github.io/policy-templates/
  programs.firefox.policies.Preferences =
    {
      # sync
      "services.sync.declinedEngines" = "passwords,addons,prefs,addresses,creditcards";
      "services.sync.engine.addons" = false;
      "services.sync.engine.addresses.available" = true;
      "services.sync.engine.passwords" = false;
      "services.sync.engine.prefs" = false;
      "services.sync.engine.prefs.modified" = false;
      # may be interesting
      # user_pref("identity.fxaccounts.account.device.name", "j’s Firefox on kor");
      # user_pref("identity.fxaccounts.account.telemetry.sanitized_uid", "...");
      # user_pref("identity.fxaccounts.lastSignedInUserHash", "...=");
      # user_pref("identity.fxaccounts.toolbar.syncSetup.panelAccessed", true);

      # for inspecting browser UI
      # # "devtools.chrome.enabled" = true;
      # "devtools.debugger.remote-enabled" = true;

      "browser.startup.homepage" = "about:blank"; # don't want to get stuck on home. maybe this should be tridactyls' page so it can load?
      # "browser.newtabpage.enabled" = false;

      "browser.urlbar.suggest.searches" = true; # Need this for basic search suggestions
      "browser.urlbar.shortcuts.bookmarks" = false;
      "browser.urlbar.shortcuts.history" = false;
      "browser.urlbar.shortcuts.tabs" = false;

      "browser.tabs.tabMinWidth" = 75; # Make tabs able to be smaller to prevent scrolling

      # "browser.urlbar.placeholderName" = "DuckDuckGo";
      # "browser.urlbar.placeholderName.private" = "DuckDuckGo";

      "browser.aboutConfig.showWarning" = false; # No warning when going to config
      "browser.warnOnQuitShortcut" = false;

      "browser.tabs.loadInBackground" = true; # Load tabs automatically

      "media.ffmpeg.vaapi.enabled" = true; # Enable hardware acceleration
      "layers.acceleration.force-enabled" = true;
      "gfx.webrender.all" = true;

      # "browser.in-content.dark-mode" = true; # Use dark mode
      # "ui.systemUsesDarkTheme" = true;

      # Automatically enable extensions
      "extensions.autoDisableScopes" = 0;

      # Keep from updating
      "extensions.update.autoUpdateDefault" = false;
      "extensions.update.enabled" = false;

      "widget.use-xdg-desktop-portal.file-picker" = 1; # Use new gtk file picker instead of legacy one

      # Privacy
      privacy.globalprivacycontrol.enabled = true;
      privacy.globalprivacycontrol.was_ever_enabled = true;
    };
}
