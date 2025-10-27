{ config, me }:
let
  inherit (config) lib;
in
{
  config = {
    hive.nodes.kor-t14 = {
      deployment = {
        targetUser = me.user;
        # targetHost = "192.168.178.68";
        # targetPort = 22;
        targetHost = "kor-t14";
        # 
        privilegeEscalationCommand = [ "sudo" "-H" "--" ];

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
