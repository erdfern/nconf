{ lib, ... }:
let
  # NOTE get from .mozilla/firefox/default/prefs.js after customizing
  # NOTE builtins.fromJSON
  # NOTE if extensions `-browser-action`s aren't specifically placed somewhere, like unified-extension-area, actions might appear in the navbar even if they aren't listed in `nav-bar`
  #
  ui_state = builtins.readFile ./uiCustomization.state.json;

  # ui_horizontalTabstrip = [ "firefox-view-button" "tabbrowser-tabs" "new-tab-button" "alltabs-button" ];
in
{
  # programs.firefox.policies.Preferences."browser.uiCustomization.state" = builtins.toJSON ui_state;
  programs.firefox.policies.Preferences."browser.uiCustomization.state" = ui_state;
  # programs.firefox.policies.Preferences."browser.uiCustomization.navBarWhenVerticalTabs" = builtins.toJSON ui_navBarWhenWerticalTabs;
  # programs.firefox.policies.Preferences."browser.uiCustomization.horizontalTabStrip" = builtins.toJSON ui_horizontalTabstrip;

  # programs.firefox.profiles.default.settings = {
  #   "browser.uiCustomization.state" = ui_state;
  #   "browser.uiCustomization.navBarWhenVerticalTabs" = ui_navBarWhenWerticalTabs;
  # };

  # programs.firefox.profiles.default.userChrome = lib.mkAfter
  #   /* css */
  #   ''
  #     /* Remove redundant separator */
  #     /* .titlebar-spacer {
  #       display: none;
  #     } */

  #     /* Remove bookmark star */
  #     /* #star-button-box {
  #       display: none !important;
  #     } */

  #     /* Remove "Protection shield" icon */
  #     /* #tracking-protection-icon-container {
  #       display: none !important;
  #     } */

  #     #vertical-pinned-tabs-container,
  #     scrollbox {
  #       scrollbar-width: auto !important;
  #     }
  #   '';
}
