{ config, lib, ... }: {
  services.udiskie = lib.mkIf config.kor.desktop.enable {
    # enable = true;
    enable = true;
    automount = true;
    settings = {
      # workaround for
      # https://github.com/nix-community/home-manager/issues/632
      # program_options = {
      #   # replace with your favorite file manager
      #   file_manager = "${pkgs.nemo-with-extensions}/bin/nemo";
      # };
    };
  };
}
