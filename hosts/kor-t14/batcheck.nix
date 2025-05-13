{ pkgs, ... }:
let
  battery_path  = "/sys/class/power_supply/BAT0/capacity";
  batcheck = pkgs.writeShellScript "batcheck" ''
    #!/usr/bin/env bash
    
    set -eou pipefail

    # --- Configuration ---
    BATTERY_PATH=${battery_path}
    LOW_THRESHOLD="15"
    # --- ############ ---

    # if [ ! -f "$BATTERY_PATH" ]; then
    #   echo "Error: Battery path not found: $BATTERY_PATH" >&2
    #   # notify-send -u critical "Battery Check Error" "Cannot find battery path: ''${BATTERY_PATH}"
    #   exit 1
    # fi

    CAPACITY=$(cat "$BATTERY_PATH")

    if ! [[ "$CAPACITY" =~ ^[0-9]+$ ]]; then
        echo "Error: Invalid capacity value read: $CAPACITY" >&2
        exit 1
    fi

    if [ "$CAPACITY" -lt "$LOW_THRESHOLD" ]; then
      # -u critical: Sets urgency level
      # You can customize the title and message
      notify-send -u critical \
                           "Battery level at ''${CAPACITY}%"
    fi

    # Exit successfully
    exit 0
  '';
in
{
  systemd.user.services.battery-low-notif = {
    Unit = {
      Description = "Check battery level and notify if low";
      PartOf = [ "graphical-session.target" ];
    };
    Service = {
      Type = "oneshot";
      ExecCondition = "/usr/bin/env sh -c '[ -f ${battery_path} ]'";
      ExecStart = batcheck;
    };
    Install.WantedBy = [ "graphical-session.target" ];
  };
  systemd.user.timers.battery-low-notif = {
    Unit = {
      Description = "Run battery low check periodically";
      # Documentation = [ "" ];
      PartOf = [ "graphical-session.target" ];
      After = [ "graphical-session.target" ];
    };
    Timer = {
      OnUnitActiveSec = "25s";
      # OnBootSec="15s";
      AccuracySec = "1s";
    };
    Install.WantedBy = [ "timers.target" "graphical-session.target" ];
  };
}
