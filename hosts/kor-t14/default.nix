{ config }:
let
  inherit (config) lib;
in
{
  config = {
    hive.nodes.kor-t14 = {
      deployment = {
        targetUser = "j";
        targetHost = "192.168.178.54";
        targetPort = 22;
        privilegeEscalationCommand = [ "sudo" ];

        tags = [ "laptop" ];
      };
    };

    # systems.nixos.adamite = {
    #   pkgs = config.inputs.nixpkgs.result.x86_64-linux;
    #   args = {
    #     project = config;
    #     host = "adamite";
    #   };
    #   modules = [
    #     ./configuration.nix
    #     ../modules
    #     config.inputs.home-manager.result.nixosModules.home-manager
    #     config.modules.nixos.lix
    #   ];
    # };
  };
}
