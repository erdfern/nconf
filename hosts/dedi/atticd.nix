{ lib
, config
, pkgs
, me
, ...
}:
let
  atticdUser = "atticd";
  # atticdUser = me.user;
  # listenAddr = "127.0.0.1";
  listenAddr = "0.0.0.0";
  listenPort = "8081";
  allowedPorts = [ 80 443 ];
in
{
  services.atticd = {
    enable = true;
    group = atticdUser;
    user = atticdUser;
    environmentFile = config.sops.secrets."dedi.atticd.env".path;
    mode = "monolithic";
    settings = {
      listen = "${listenAddr}:${listenPort}";
      # listen = "[::]:8080";
      allowed-hosts = [ ]; # Allow all hosts
      api-endpoint = "https://cache.erdfern.dev/";

      soft-delete-caches = false;
      require-proof-of-possession = false;

      # database.url = "sqlite://${config.services.atticd.settings.storage.path}/server.db?mode=rwc";
      database.url = "postgresql:///${atticdUser}?host=/var/run/postgresql";

      storage = {
        type = "local";
        #   path = "/mnt/hd/attic";
        path = "/var/lib/${atticdUser}";
      };

      compression.type = "none";

      garbage-collection.interval = "0 hours"; # disable garbage collection

      chunking = {
        nar-size-threshold = 64 * 1024; # 64 KiB
        min-size = 16 * 1024; # 16 KiB
        avg-size = 64 * 1024; # 64 KiB
        max-size = 256 * 1024; # 256 KiB
      };
    };
  };

  systemd.tmpfiles.rules = [
    "d config.services.atticd.settings.storage.path 770 ${atticdUser} ${atticdUser}"
  ];

  users = {
    groups.${atticdUser} = { };
    users.${atticdUser} = {
      isSystemUser = true;
      group = atticdUser;

      home = config.services.atticd.settings.storage.path;
      createHome = true;
    };
  };

  systemd.services.atticd = {
    serviceConfig = {
      DynamicUser = lib.mkForce false;
    };
  };

  sops.secrets = {
    "dedi.atticd.env" = {
      sopsFile = ./secrets/atticd.env;
      format = "dotenv";
      mode = "0600";
      owner = atticdUser;
      # neededForUsers = true;
    };
  };

  environment.systemPackages = [ pkgs.attic-client ];

  # postgres DB - https://github.com/NixOS/nixpkgs/blob/fe51d34885f7b5e3e7b59572796e1bcb427eccb1/nixos/modules/services/databases/postgresql.md
  services.postgresql = {
    enable = true;
    package = pkgs.postgresql_17_jit; # need to specify version for stability; upgrading requires database dump
    # package = pkgs.postgresql_15;
    # ensureUsers.${atticdUser}.ensureDBOwnership = true; # will accept a passwordless connection via unix domain socket for user
    ensureUsers = [{ name = atticdUser; ensureDBOwnership = true; }];
    # dataDir = "/var/db/postgresql/attic"; # default /var/lib/postgresql/$psqlSchema
    ensureDatabases = [ atticdUser ];
    authentication = pkgs.lib.mkOverride 10 ''
      #type database  DBuser  auth-method
      local all       all     trust
    '';
  };

  # reverse proxy to atticd listenPort...
  networking.firewall.allowedTCPPorts = allowedPorts;

  security.acme.defaults.email = me.email;
  security.acme.acceptTerms = true;

  services.caddy = {
    enable = true;
    virtualHosts."cache.erdfern.dev".extraConfig = ''
      reverse_proxy http://${listenAddr}:${listenPort}
    '';
    # virtualHosts."another.example.org".extraConfig = ''
    #   reverse_proxy unix//run/gunicorn.sock
    # ''
    # real ip
    # virtualHosts."example.org".extraConfig = ''
    #   reverse_proxy http://10.25.40.6 {
    #     header_down X-Real-IP {http.request.remote}
    #     header_down X-Forwarded-For {http.request.remote}
    #   }
    # '';
  };
}
