{ config }:
{
  config = {
    hive.nodes.dns = {
      deployment = {
        targetUser = "j";
        privilegeEscalationCommand = [ "sudo" ];
        targetPort = 2222;
        targetHost = "192.178.168.42";

        tags = [ "dns" "home" ];
      };
    };
    systems.nixos.dns = {
      # nixpkgs = config.inputs.nixpkgs-unstable;
      system = "aarch64-linux";
      modules = [
        # config.inputs.nixos-generators.result.nixosModules.sd-aarch64
        config.inputs.nixos-generators.result.nixosModules.all-formats
      ];
    };
  };
}
