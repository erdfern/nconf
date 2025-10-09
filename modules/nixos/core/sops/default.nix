# from Ruixi-rebirth
{ config
, lib
, inputs
, pkgs
, me
, ...
}:
let
  inherit (me) user;

  cfg = config.kor.secrets.sops;
in
{
  options.kor.secrets.sops = with lib; {
    enable = mkOption {
      default = config.sops.secrets != { } || config.sops.templates != { };
      # default = cfg.secrets != { } || cfg.templates != { };
      # default = true;
      readOnly = true;
      description = ''
        Internal option for deciding if SOPS secret management should be enabled.
        True if any SOPS secrets or templates are defined for the host.
      '';
      # age = {};
      # gpg = {};
    };

    # secrets = mkOption {
    #   default = { };
    #   type = types.attrs;
    #   description = ''
    #     Secrets to merge into config.sops.secrets.
    #   '';
    # };

    # templates = mkOption {
    #   default = { };
    #   type = types.attrs;
    #   description = ''
    #     Templates to merge into config.sops.templates.
    #   '';
    # };
  };

  # infinite recursion, duh :[
  # imports = lib.lists.optional cfg.enable inputs.sops-nix.result.nixosModules.sops;
  imports = lib.lists.singleton inputs.sops-nix.result.nixosModules.sops;

  config = lib.mkIf cfg.enable {

    environment.systemPackages = [ pkgs.sops pkgs.age ];

    # NOTE: https://github.com/Mic92/sops-nix#initrd-secrets
    sops = {
      defaultSopsFile = ../../../secrets/secrets.yaml;
      # defaultSopsFormat = "yaml";
      # gnupg.sshKeyPaths = [ ];
      age = {
        # sshKeyPaths = [ ];
        # keyFile = "/var/lib/sops/keys.txt"; # doesn't work at this location...
        keyFile = "/home/${user}/.config/sops/age/keys.txt";
        generateKey = false;
      };
      # gnupg = {
      #   home = "/home/${me.user}/.gnupg";
      # };
    };
    # issue: https://github.com/Mic92/sops-nix/issues/149
    # workaround:
    # systemd.services.decrypt-sops = {
    #   description = "Decrypt sops secrets";
    #   wantedBy = [ "multi-user.target" ];
    #   serviceConfig = {
    #     Type = "oneshot";
    #     RemainAfterExit = true;
    #     Restart = "on-failure";
    #     RestartSec = "2s";
    #   };
    #   script = config.system.activationScripts.setupSecrets.text;
    # };

    # programs.fish = lib.mkIf config.programs.fish.enable {
    #   shellInit = ''
    #     export ANTHROPIC_API_KEY="$(cat ${config.sops.secrets.ANTHROPIC_API_KEY.path})"
    #     export OPENAI_API_KEY="$(cat ${config.sops.secrets.OPENAI_API_KEY.path})"
    #     export Config_dae="$(cat ${config.sops.secrets."config.dae".path})"
    #     export Element_securityKey="$(cat ${config.sops.secrets."Element_securityKey".path})"
    #     export CACHIX_AUTH_TOKEN="$(cat ${config.sops.secrets.CACHIX_AUTH_TOKEN.path})"
    #     export CACHIX_SIGNING_KEY="$(cat ${config.sops.secrets.CACHIX_SIGNING_KEY.path})"
    #     export GITHUB_TOKEN="$(cat ${config.sops.secrets.GITHUB_TOKEN.path})"
    #     export SSH_PVKEY="$(cat ${config.sops.secrets.SSH_PVKEY.path})"
    #     export GPG_PVKEY="$(cat ${config.sops.secrets.GPG_PVKEY.path})"
    #     export NIX_ACCESS_TOKENS="$(cat ${config.sops.secrets.NIX_ACCESS_TOKENS.path})"
    #   '';
    # };
  };
}
