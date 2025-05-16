{
  programs.firefox.policies =
    {
      AppAutoUpdate = false;
      ExtensionUpdate = false;

      DisableTelemetry = true;
      DisableFirefoxStudies = true;
      DisablePocket = true;
      DisableFirefoxScreenshots = true;
      DisableSetDesktopBackground = true;
      DisableSystemAddonUpdate = true;

      DisplayBookmarksToolbar = "never";
      DisplayMenuBar = "never"; # Previously appeared when pressing alt

      DontCheckDefaultBrowser = true;

      NoDefaultBookmarks = true;

      SkipTermsOfUse = true;

      OverrideFirstRunPage = "";
      OverridePostUpdatePage = "";

      Homepage.StartPage = "previous-session";
      NewTabPage = false; # trying this to get rid of "tridactyl changed newpage" message

      # let extension handle it
      OfferToSaveLogins = false;
      OfferToSaveLoginsDefault = false;

      PictureInPicture.Enabled = false;
      PromptForDownloadLocation = false;

      HardwareAcceleration = true;
      TranslateEnabled = true;

      UserMessaging =
        {
          UrlbarInterventions = false;
          SkipOnboarding = true;
          ExtensionRecommendations = false;
          FeatureRecommendations = false;
          MoreFromMozilla = false;
          FirefoxLabs = false;
        };

      FirefoxSuggest =
        {
          WebSuggestions = false;
          SponsoredSuggestions = false;
          ImproveSuggest = false;
        };

      EnableTrackingProtection =
        {
          Value = true;
          Cryptomining = true;
          Fingerprinting = true;
        };

      # Make new tab only show search
      FirefoxHome =
        {
          Search = true;
          TopSites = false;
          SponsoredTopSites = false;
          Highlights = false;
          Pocket = false;
          SponsoredPocket = false;
          Snippets = false;
        };

      Handlers.schemes.vscode =
        {
          action = "useSystemDefault"; # Open VSCode app
          ask = false;
        };

      Handlers.schemes.element =
        {
          action = "useSystemDefault"; # Open Element app
          ask = false;
        };
    };
}
