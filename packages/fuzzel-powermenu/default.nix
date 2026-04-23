{ writeShellScriptBin
  # deps
  # ... TODO
}:
writeShellScriptBin "fuzzel-powermenu" ''
  SELECTION="$(printf "1 - Shutdown\n2 - Suspend\n3 - Lock\n4 - Log out\n5 - Reboot\n6 - Reboot to UEFI" | fuzzel --dmenu -l 6 -p "Power Menu: ")"

  case $SELECTION in
  	*"Shutdown")
  		systemctl poweroff;;
  	*"Suspend")
  		systemctl suspend;;
  	*"Lock")
  		pidof hyprlock || hyprlock;;
  	*"Log out")
  		# loginctl terminate-user "";;
  		uwsm stop;;
  	*"Reboot")
  		systemctl reboot;;
  	*"Reboot to UEFI")
  		systemctl reboot --firmware-setup;;
  esac
''
