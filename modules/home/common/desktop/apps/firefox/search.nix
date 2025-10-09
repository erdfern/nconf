{ lib, ... }:
{
  programs.firefox.profiles.default.search.engines =
    {
      # Disable all the stupid "This time, search with" icons
      # ddg.metaData.hidden = true;
      bing.metaData.hidden = true;
      ebay.metaData.hidden = true;
      amazondotcom.metaData.hidden = true;
      wikipedia.metaData.hidden = true;

      # Thanks to xunuwu on github for being a reference for use of these functions
      "Github Search Nix" =
        {
          urls = lib.singleton
            {
              template = "https://github.com/search?type=code&q=lang:nix+NOT+is:fork+{searchTerms}";
            };

          icon = "https://github.com/favicon.ico";
          definedAliases = lib.singleton "@gn";
        };

      "Github Search" =
        {
          urls = lib.singleton
            {
              template = "https://github.com/search?type=code&q=NOT+is:fork+{searchTerms}";
            };

          icon = "https://github.com/favicon.ico";
          definedAliases = lib.singleton "@gh";
        };

      # "Github Search Fish" =
      #   {
      #     urls = lib.singleton
      #       {
      #         template = "https://github.com/search?type=code&q=lang:fish+NOT+is:fork+{searchTerms}";
      #       };

      #     icon = "https://fishshell.com/favicon.ico";
      #     definedAliases = lib.singleton "@gf";
      #   };

      "Github Search Home Manager" =
        {
          urls = lib.singleton
            {
              template = "https://github.com/search?type=code&q=repo:nix-community/home-manager+lang:nix+{searchTerms}";
            };

          definedAliases = lib.singleton "@ghm";
        };

      "Noogle" =
        {
          urls = lib.singleton
            {
              template = "https://noogle.dev/q?term={searchTerms}";
            };

          icon = "https://noogle.dev/favicon.png";
          definedAliases = lib.singleton "@ng";
        };

      "Nixpkgs" =
        {
          urls = lib.singleton
            {
              # template = "https://github.com/search?type=code&q=repo:NixOS/nixpkgs+lang:nix+{searchTerms}";
              template = "https://search.nixos.org/packages?channel=unstable&from=0&size=50&sort=relevance&type=packages&query={searchTerms}";
            };

          definedAliases = lib.singleton "@np";
        };

      "Home Manager Options" =
        {
          urls = lib.singleton
            {
              template = "https://home-manager-options.extranix.com/?query={searchTerms}&release=master";
            };

          icon = "https://home-manager-options.extranix.com/images/favicon.png";
          definedAliases = lib.singleton "@hm";
        };

      "NixOS Options" =
        {
          urls = lib.singleton
            {
              template = "https://search.nixos.org/options?channel=unstable&from=0&size=100&sort=alpha_asc&query={searchTerms}";
            };

          definedAliases = lib.singleton "@no";
        };

      "MyNixOS" =
        {
          urls = lib.singleton
            {
              template = "https://mynixos.com/search?q={searchTerms}";
            };

          definedAliases = lib.singleton "@mn";
        };
    };
}
