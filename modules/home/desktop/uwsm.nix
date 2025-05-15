{ lib
, config
, ...
}:
let
  cfg = config.kor.desktop.uwsm;

  formatEnvVarLine = envVarString:
    (if lib.strings.hasPrefix "export " envVarString
    then envVarString
    else "export " + envVarString
    ) + "\n";
in
{
  imports = [
    ./apps
    ./hyprland
    ./gtk.nix
    ./suites
  ];

  options.kor.desktop.uwsm = with lib; {
    # TODO check format and automatically prepend "export"
    # TODO deduplicate
    env = mkOption {
      # type = types.listOf (types.strMatching "^export ([a-zA-Z0-9_]+)=(.*)$");
      type = types.listOf (types.strMatching "^(export )?([a-zA-Z0-9_]+)=(.*)$");
      default = [ ];
      description = "List of environment variables to export in ~/.config/uwsm/env. Format is \"VAR=value\"";
    };
    envHyprland = mkOption {
      type = types.listOf (types.strMatching "^(export )?([a-zA-Z0-9_]+)=(.*)$");
      default = [ ];
      description = "List of environment variables to export in ~/.config/uwsm/env. Format is \"VAR=value\"";
    };
  };

  config = {
    home.file."${config.xdg.configHome}/uwsm/env".text = lib.mkIf (cfg.env != [ ])
      (lib.strings.concatMapStrings formatEnvVarLine cfg.env);
    home.file."${config.xdg.configHome}/uwsm/env-hyprland".text = lib.mkIf (config.kor.desktop.hyprland.enable && cfg.envHyprland != [ ])
      (lib.strings.concatMapStrings formatEnvVarLine cfg.envHyprland);
  };
}
