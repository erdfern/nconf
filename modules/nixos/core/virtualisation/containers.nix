{ pkgs, user, me, config, lib, ... }:
let
  cfg = config.kor.virtualisation.containers;
in
{
  options.kor.virtualisation.containers = {
    enable = lib.mkEnableOption "container virtualisation";
  };

  config = lib.mkIf cfg.enable {

    virtualisation.containers.enable = true;
    virtualisation = {
      podman = {
        enable = true;
        dockerCompat = true;
        defaultNetwork.settings.dns_enabled = true;
      };
    };

    users.users.${me.user} = {
      extraGroups = [ "podman" ];
    };

    # environment.etc."containers/registries.conf".text = lib.mkForce ''
    #   [registries.search]
    #   registries = ['docker.io']
    # '';

    # virtualisation.docker.enable = true;

    # users.groups.docker.members = [ "${user}" ];

    environment.systemPackages = with pkgs; [
      dive
      # docker-compose
      podman-compose
      podman-tui
    ];
  };
}
