{ lib
, config
, me
, ...
}:
let
  cfg = config.kor.profiles.development;
in
{
  options.kor.profiles.development = with lib; {
    enable = mkEnableOption "development profile";
    virtualisation = mkOption { type = types.bool; default = false; description = "Whether to enable virtualisation tools"; };
  };

  config = lib.mkIf cfg.enable {
    virtualisation.podman = lib.mkIf cfg.virtualisation {
      # Setup podman.
      enable = cfg.virtualisation;
      dockerCompat = true;
      dockerSocket.enable = true;
    };
    users.users.${me.user} = {
      extraGroups = lib.mkIf cfg.virtualisation [ "podman" ];
      subUidRanges = lib.mkIf cfg.virtualisation [
        {
          count = 65536;
          startUid = 100000;
        }
      ];
      subGidRanges = lib.mkIf cfg.virtualisation [
        {
          count = 65536;
          startGid = 100000;
        }
      ];
    };

    # Use zsh for default shell.
    # users.users.${user}.shell = lib.mkForce pkgs.zsh;
    # programs.zsh.enable = true;
  };
}
