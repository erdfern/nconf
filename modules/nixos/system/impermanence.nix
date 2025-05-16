# Taken from https://github.com/NotAShelf/nyx/blob/2a8273ed3f11a4b4ca027a68405d9eb35eba567b/modules/core/common/system/impermanence/default.nix
{ lib
, config
, inputs
, user
  # , options # could get the persistence option types from here maybe?
, ...
}:
let
  inherit (lib) mkEnableOption mkOption literalExpression types;

  strOrAttrs = with types; either str attrs;
  listOfStrOrAttrs = with types; listOf strOrAttrs;

  defaultPersistedDirsRoot = [
    "/var/lib/nixos"

    # TODO move or don't idk
    "/etc/nixos"
    "/etc/nix"
    "/etc/secureboot"
    "/var/db/sudo"
    "/var/lib/flatpak"
    "/var/lib/libvirt"
    "/var/lib/bluetooth"
    "/var/lib/nixos"
    "/var/lib/pipewire"
    "/var/lib/systemd/coredump"
    "/var/cache/tailscale"
    "/var/lib/tailscale"
  ];
  defaultPersistedFilesRoot = [ "/etc/machine-id" ];

  cfg = config.kor.system.impermanence;
in
{
  imports = [ "${inputs.impermanence.result}/nixos.nix" ];

  options.kor.system.impermanence = {
    enable = mkOption {
      default = cfg.root.enable || cfg.home.enable;
      readOnly = true;
      description = ''
        Internal option for deciding if filesystem impermanence should be enabled
        based on the values of `modules.system.impermanence.root.enable`
        and `modules.system.impermanence.home.enable`.
      '';
    };

    device = mkOption {
      type = types.str;
      default = "/persist";
      example = literalExpression ''["/etc/nix/id_rsa"]'';
      description = "Persistence device";
    };

    root = {
      enable = mkEnableOption ''
        the Impermanence module for persisting important state directories.
        By default, Impermanence will not touch user's $HOME, which is not
        ephemeral unlike root.
      '';

      extraFiles = mkOption {
        type = listOfStrOrAttrs;
        default = [ ];
        example = literalExpression ''["/etc/nix/id_rsa"]'';
        description = ''
          Additional files in the root to link to persistent storage.
        '';
      };

      extraDirectories = mkOption {
        type = listOfStrOrAttrs;
        default = [ ];
        example = literalExpression ''["/var/lib/libvirt"]'';
        description = ''
          Additional directories in the root to link to persistent
          storage.
        '';
      };
    };

    home = {
      enable = mkEnableOption ''
        the Impermanence module for persisting important state directories.
        This option will also make user's home ephemeral, on top of the root subvolume
      '';

      extraFiles = mkOption {
        type = listOfStrOrAttrs;
        default = [ ];
        example = literalExpression ''
          [
            ".gnupg/pubring.kbx"
            ".gnupg/sshcontrol"
            ".gnupg/trustdb.gpg"
            ".gnupg/random_seed"
          ]
        '';
        description = ''
          Additional files in the home directory to link to persistent
          storage.
        '';
      };

      extraDirectories = mkOption {
        type = listOfStrOrAttrs;
        default = [ ];
        example = literalExpression ''[".config/gsconnect"]'';
        description = ''
          Additional directories in the home directory to link to
          persistent storage.
        '';
      };
    };
  };

  config = lib.mkIf cfg.enable {
    # Disable sudo nag.
    security.sudo.extraConfig = ''
      Defaults lecture = never
    '';

    # Persisting user password
    users.mutableUsers = false;

    # mkpasswd -m sha-512 > /persist/passwords/<user>
    users.users = {
      root.hashedPasswordFile = "${cfg.path}/passwords/root";
      ${user}.hashedPasswordFile = "${cfg.path}/passwords/${user}";
    };
    fileSystems."${cfg.device}".neededForBoot = true;

    environment.persistence."${cfg.device}" = {
      hideMounts = true;
      # Global persistent directories and files
      directories = defaultPersistedDirsRoot ++ cfg.root.extraDirectories;
      files = defaultPersistedFilesRoot ++ cfg.root.extraFiles;

      # TODO per-user for arbitrary users? don't need it right now
      users.${user} = {
        directories = lib.mkIf (cfg.home.extraDirectories != [ ]) cfg.home.extraDirectories;
        files = lib.mkIf (cfg.home.extraFiles != [ ]) cfg.home.extraFiles;
      };
    };

    assertions = [
      {
        assertion = cfg.home.enable -> !cfg.root.enable;
        message = ''
          You have enabled home impermanence without root impermanence. This
          is not supported due to the fact that we handle all all impermanence
          related deletions and creations in a single service. Please enable
          `modules.system.impermanence.root.enable` if you wish to proceed.
        '';
      }
    ];

    warnings =
      if cfg.home.enable
      then [ "Home impermanence is enabled, beware." ]
      else [ ];
  };
}
