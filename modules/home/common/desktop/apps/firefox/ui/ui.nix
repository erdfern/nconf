{ lib, ... }:
let
  # NOTE get from .mozilla/firefox/default/prefs.js after customizing
  # NOTE builtins.fromJSON
  # NOTE if extensions `-browser-action`s aren't specifically placed somewhere, like unified-extension-area, actions might appear in the navbar even if they aren't listed in `nav-bar`
  #
  ui_state = builtins.readFile ./uiCustomization.state.json;

  # ui_state = {
  #   placements = {
  #     widget-overflow-fixed-list = [
  #       "fxa-toolbar-menu-button"
  #       "firefox-view-button"
  #       # "open-file-button"
  #       "preferences-button"
  #     ];
  #     unified-extensions-area = [
  #       "_testpilot-containers-browser-action"
  #       "ublock0_raymondhill_net-browser-action"
  #       "sponsorblocker_ajay_app-browser-action"
  #       "gdpr_cavi_au_dk-browser-action"
  #       "redirector_einaregilsson_com-browser-action"
  #       "_0d7cafdd-501c-49ca-8ebb-e3341caaa55e_-browser-action"
  #       "jid0-3guet1r69sqnsrca5p8kx9ezc3u_jetpack-browser-action"
  #       "_74145f27-f039-47ce-a470-a662b129930a_-browser-action"
  #       "_762f9885-5a13-4abd-9c77-433dcd38b8fd_-browser-action"
  #       "_c2c003ee-bd69-42a2-b0e9-6f34222cb046_-browser-action"
  #       "_a4c4eda4-fb84-4a84-b4a1-f7c1cbf2a1ad_-browser-action"
  #       "firefoxcolor_mozilla_com-browser-action"
  #     ];
  #     nav-bar = [
  #       "sidebar-button"
  #       "alltabs-button"
  #       "back-button"
  #       "forward-button"
  #       "stop-reload-button"
  #       "vertical-spacer"
  #       "urlbar-container"
  #       "downloads-button"
  #       "unified-extensions-button"
  #       "78272b6fa58f4a1abaac99321d503a20_proton_me-browser-action"
  #     ];
  #     toolbar-menubar = [
  #       "menubar-items"
  #     ];
  #     TabsToolbar = [ ];
  #     "vertical-tabs" = [
  #       "tabbrowser-tabs"
  #     ];
  #     PersonalToolbar = [
  #       "personal-bookmarks"
  #     ];
  #   };
  #   seen = [
  #     "firefoxcolor_mozilla_com-browser-action"
  #     "gdpr_cavi_au_dk-browser-action"
  #     "redirector_einaregilsson_com-browser-action"
  #     "_0d7cafdd-501c-49ca-8ebb-e3341caaa55e_-browser-action"
  #     "jid0-3guet1r69sqnsrca5p8kx9ezc3u_jetpack-browser-action"
  #     "_762f9885-5a13-4abd-9c77-433dcd38b8fd_-browser-action"
  #     "_c2c003ee-bd69-42a2-b0e9-6f34222cb046_-browser-action"
  #     "_testpilot-containers-browser-action"
  #     "_74145f27-f039-47ce-a470-a662b129930a_-browser-action"
  #     "ublock0_raymondhill_net-browser-action"
  #     "78272b6fa58f4a1abaac99321d503a20_proton_me-browser-action"
  #     "_a4c4eda4-fb84-4a84-b4a1-f7c1cbf2a1ad_-browser-action"
  #     "sponsorblocker_ajay_app-browser-action"
  #     "developer-button"
  #   ];
  #   dirtyAreaCache = [
  #     "widget-overflow-fixed-list"
  #     "unified-extensions-area"
  #     "nav-bar"
  #     "toolbar-menubar"
  #     "TabsToolbar"
  #     "vertical-tabs"
  #     "PersonalToolbar"
  #   ];
  #   currentVersion = 23;
  #   newElementCount = 6;
  # };
  # ui_navBarWhenWerticalTabs = [
  #   "sidebar-button"
  #   "back-button"
  #   "forward-button"
  #   "stop-reload-button"
  #   # "customizableui-special-spring1"
  #   "vertical-spacer"
  #   "urlbar-container"
  #   # "customizableui-special-spring2"
  #   "downloads-button"
  #   "unified-extensions-button"
  #   "78272b6fa58f4a1abaac99321d503a20_proton_me-browser-action" # pin protonpass
  #   # "firefox-view-button"
  #   # "alltabs-button"
  # ];
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
