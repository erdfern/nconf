{ pkgs, ... }:
pkgs.writeShellScriptBin "fuzzel-powermenu" ''
  SELECTION="$(printf "1 - Lock\n2 - Suspend\n3 - Log out\n4 - Reboot\n5 - Reboot to UEFI\n6 - Shutdown" | fuzzel --dmenu -l 6 -p "Power Menu: ")"

  case $SELECTION in
  	*"Lock")
  		pidof hyprlock || hyprlock;;
  	*"Suspend")
  		systemctl suspend;;
  	*"Log out")
  		exit;;
  	*"Reboot")
  		systemctl reboot;;
  	*"Reboot to UEFI")
  		systemctl reboot --firmware-setup;;
  	*"Shutdown")
  		systemctl poweroff;;
  esac
''
