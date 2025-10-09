{ pkgs, ... }: {
  imports = [ ./btop.nix ];

  home.packages = with pkgs; [
    # file system view
    # cool resource: https://dev.yorhel.nl/ncdu
    pkgs.gdu
    # pkgs.ncdu
    # pkgs.duf
    # pkgs.dust

    pkgs.npins-git
  ];

}
