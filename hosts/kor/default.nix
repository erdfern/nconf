{ config, me }:
{
  config = {
    # system
    # system = "x86_64-linux";
    # pkgs = 
    args = { };
    modules = [ ./configuration.nix ];

    # hive node
    deployment = {
      targetUser = me.user;
      tags = [ "workstation" ];
    };
  };
}
