#  https://github.com/llakala/nixos/blob/3ae839c3b3d5fd4db2b78fa2dbb5ea1080a903cd/apps/programs/firefox/extensions.nix
{ inputs, pkgs, ... }:
let
  # Search extension names with below command:
  # nix flake show --json "gitlab:rycee/nur-expressions?dir=pkgs/firefox-addons" --all-systems | jq -r '.packages."x86_64-linux" | keys[]' | rg QUERY
  # ryceeAddons = with inputs.firefox-addons.result.packages.${pkgs.system};
  # ryceeAddons = with inputs.firefox-addons.result; # only x86_64 for now
  ryceeAddons = with (inputs.rycee-nur-expressions.result { pkgs = pkgs; }).firefox-addons;
    [
      proton-pass

      ublock-origin
      sponsorblock
      return-youtube-dislikes
      indie-wiki-buddy

      refined-github
      movie-web

      # bypass-paywalls-clean (can't use, was creating popups)
      consent-o-matic
      terms-of-service-didnt-read

      auto-tab-discard
      clearurls
      link-cleaner

      redirector # For nixos wiki
      darkreader
    ];

  customAddons =
    [

    ];
in
{
  imports = [ ./tridactyl.ext.nix ];

  programs.firefox.profiles.default.extensions.packages = ryceeAddons ++ customAddons;

  programs.firefox.policies."3rdparty".extensions = {
    "uBlock0@raymondhill.net" =
      {
        permissions = [ "internal:privateBrowsingAllowed" ];
        origins = [ ];
      };

    "{b0a674f9-f848-9cfd-0feb-583d211308b0}" = # Movie-web
      {
        "permissions" = [ "<all_urls>" ];
        "origins" = [ "<all_urls>" ];
      };

    "gdpr@cavi.au.dk" =
      {
        "permissions" = [ "<all_urls>" ];
        "origins" = [ "<all_urls>" ];
      };
  };
}
