{ config }:
{
  config = {
    # system
    # system = "x86_64-linux";
    # pkgs = 
    args = { };
    modules = [ ./configuration.nix ];

    # hive node
    deployment = {
      targetUser = "j";
      tags = [ "workstation" ];
    };
  };
}
