{ config }:
let
  inherit (config) lib;
in
{
  config = {
    hive.nodes.kor-t14 = {
      deployment = {
        targetUser = "j";
        # targetHost = "192.168.178.68";
        targetHost = "kor-t14";
        # targetPort = 22;
        privilegeEscalationCommand = [ "sudo" ];

        tags = [ "laptop" ];
      };
    };

    # systems.nixos.kor-t14 = {
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
