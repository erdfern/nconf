{ lib
, config
, pkgs
, user
, ...
}:
let
  cfg = config.kor.preset.development;
in
{
  options.kor.preset.development = with lib; {
    enable = mkEnableOption "development preset";
    virtualisation = mkOption { type = types.bool; default = false; description = "Whether to enable virtualisation tools"; };
  };

  config = lib.mkIf cfg.enable {
    # virtualisation.podman = lib.mkIf cfg.virtualisation {
    #   # Setup podman.
    #   enable = cfg.virtualisation;
    #   dockerCompat = true;
    #   dockerSocket.enable = true;
    # };
    # users.users.${user}.extraGroups = lib.mkIf cfg.virtualisation [ "podman" ];
    # users.users.${user}.subUidRanges = lib.mkIf cfg.virtualisation [
    #   {
    #     count = 65536;
    #     startUid = 100000;
    #   }
    # ];
    # users.users.${user}.subGidRanges = lib.mkIf cfg.virtualisation [
    #   {
    #     count = 65536;
    #     startGid = 100000;
    #   }
    # ];

    # Use zsh for default shell.
    # users.users.${user}.shell = lib.mkForce pkgs.zsh;
    # programs.zsh.enable = true;
  };
}
