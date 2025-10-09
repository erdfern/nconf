{ me, pkgs, lib, config, ... }:
let
  cfg = config.kor.users;
in
{
  options.kor.users = {
    me = {
      useFish = lib.mkOption {
        type = lib.types.bool;
        default = true;
      };
    };
  };
  config = {

    security.sudo = {
      enable = true;
      extraConfig = ''
        ${me.user} ALL=(ALL) NOPASSWD:ALL
      '';
    };

    users.users = {
      # defaultShell = pkgs.bash;

      root.openssh.authorizedKeys.keys = [ ] ++ me.ssh.pubKeys;

      ${me.user} = {
        isNormalUser = true;
        uid = 1000;
        group = "${me.user}";
        extraGroups = [ "wheel" ];
        home = "/home/${me.user}";
        openssh.authorizedKeys.keys = [ ] ++ me.ssh.pubKeys;
        packages = map lib.lowPrio [
          pkgs.home-manager
        ];

        # useDefaultShell = !cfg.me.useFish;
        shell = lib.mkIf cfg.me.useFish pkgs.fish;
      };
    };

    users.groups.${me.user} = { gid = 1000; };

    # use dash instead of bash
    # environment.binsh = "${pkgs.dash}/bin/dash";
    programs.fish.enable = lib.mkDefault cfg.me.useFish;

    # noshell
    # programs.noshell.enable = true;
  };
}
