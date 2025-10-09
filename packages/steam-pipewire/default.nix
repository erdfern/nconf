{ makeDesktopItem, symlinkJoin, ... }:
let
  steam-pipewire = makeDesktopItem {
    name = "SteamPipewire";
    desktopName = "SteamPipewire";
    genericName = "Application for managing and playing games on Steam.";
    categories = [
      "Network"
      "FileTransfer"
      "Game"
    ];
    type = "Application";
    icon = "steam";
    exec = "steam -pipewire -pipewire-dmabuf";
    terminal = false;
  };
  steam-pipewire-gamepadui = makeDesktopItem {
    name = "SteamPipewireGamepadUI";
    desktopName = "SteamPipewireGamepadUI";
    genericName = "Application for managing and playing games on Steam.";
    categories = [
      "Network"
      "FileTransfer"
      "Game"
    ];
    type = "Application";
    icon = "steam";
    exec = "steam -pipewire -pipewire-dmabuf -gamepadui";
    terminal = false;
  };

  package = symlinkJoin {
    name = "steam-desktop-items";
    paths = [
      steam-pipewire
      steam-pipewire-gamepadui
    ];
  };
in
package
