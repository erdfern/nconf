
{ pkgs, lib, config, inputs, ... }:

let
  cfg = config.kor.desktop.apps.wayle;
in
{
  options.kor.desktop.apps.wayle = with lib;
    {
      enable = mkEnableOption "wayle bar";
    };

  config = lib.mkIf cfg.enable {

    programs.wayle = {
      enable = cfg.enable;
      # package = wayle-git;
      # autoInstallDependencies = true;
      # settings = {};
    };
  };
}
