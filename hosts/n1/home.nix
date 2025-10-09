{
  pkgs,
  inputs,
  ...
}: {
  # profiles.desktop.enable = true;
  profiles.desktop.hyprland.enable = true;

  home.packages = with pkgs; [
    argocd
    npins
    inputs.nilla-cli.result.packages.nilla-cli.result.x86_64-linux
    inputs.nilla-utils.result.packages.nilla-utils-plugins.result.x86_64-linux
  ];
}
