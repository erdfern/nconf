{ inputs, pkgs, ... }:
let
  # NOTE needs to be installed for catppuccin module to have an effect, since it just configures this extension!
  firefox-color = inputs.nur.repos.rycee.firefox-addons.firefox-color;
in
{
  catppuccin.firefox = {
    enable = true;
    force = true;
    # profiles = { };
  };
  programs.firefox.profiles.default.extensions.packages = [ firefox-color ];
}
