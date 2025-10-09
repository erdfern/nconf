{ config
, pkgs
, ...
}:
let
  gh-runner-name = "nconf-gh-runner";
in
{
  sops.secrets = {
    "dedi.gh-runner.token" = {
      sopsFile = ./secrets/gh-runner.token;
      format = "binary";
      mode = "0600";
      owner = gh-runner-name;
      # neededForUsers = true;
    };
  };

  services.github-runners = {
    ${gh-runner-name} = {
      enable = true;

      user = gh-runner-name;
      group = gh-runner-name;

      replace = true;
      name = gh-runner-name;
      extraLabels = [ "nixos" "dedi" ];
      url = "https://github.com/erdfern/nconf";
      tokenFile = config.sops.secrets."dedi.gh-runner.token".path;

      extraPackages = [ pkgs.cachix pkgs.attic-client ];
    };
  };

  users = {
    groups.${gh-runner-name} = { };
    users.${gh-runner-name} = {
      group = gh-runner-name;
      isSystemUser = true;

      # extraGroups = [ "docker" ];
    };
  };

  nix.settings.trusted-users = [ gh-runner-name ];
}
