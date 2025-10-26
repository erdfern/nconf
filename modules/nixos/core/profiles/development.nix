{ lib
, config
, me
, inputs
, system
, ...
}:
let
  cfg = config.kor.profiles.development;
in
{
  options.kor.profiles.development = with lib; {
    enable = mkEnableOption "development profile";
    virtualisation = mkOption { type = types.bool; default = false; description = "Whether to enable virtualisation tools"; };
  };

  config = lib.mkIf cfg.enable
    {
      virtualisation.podman = lib.mkIf cfg.virtualisation {
        # Setup podman.
        enable = cfg.virtualisation;
        dockerCompat = true;
        dockerSocket.enable = true;
      };
      users.users.${me.user} = {
        extraGroups = lib.mkIf cfg.virtualisation [ "podman" ];
        subUidRanges = lib.mkIf cfg.virtualisation [
          {
            count = 65536;
            startUid = 100000;
          }
        ];
        subGidRanges = lib.mkIf cfg.virtualisation [
          {
            count = 65536;
            startGid = 100000;
          }
        ];
      };

      # Use zsh for default shell.
      # users.users.${user}.shell = lib.mkForce pkgs.zsh;
      # programs.zsh.enable = true;
      #
      # https://nixos-and-flakes.thiscute.world/best-practices/run-downloaded-binaries-on-nixos

      # NOTE nix-alien is awesome 🥺
      environment.systemPackages = [ inputs.nix-alien.result.packages.${system}.nix-alien ];
      # could also use nix-alien-ld  
      programs.nix-ld.enable = true;
      # programs.nix-ld.libraries = [];

      # NOTE maybe nix-ld could be useful here, too??? ?? e.g. https://brianmckenna.org/blog/running_binaries_on_nixos https://blog.thalheim.io/2022/12/31/nix-ld-a-clean-solution-for-issues-with-pre-compiled-executables-on-nixos/
      # Create an FHS environment using the command `fhs`, enabling the execution of non-NixOS packages in NixOS!
      # environment.systemPackages = with pkgs; [
      #   (
      #     let base = pkgs.appimageTools.defaultFhsEnvArgs;
      #     in
      #     pkgs.buildFHSEnv (base // {
      #       name = "fhs";
      #       targetPkgs = pkgs:
      #         # pkgs.buildFHSEnv provides only a minimal FHS environment,
      #         # lacking many basic packages needed by most software.
      #         # Therefore, we need to add them manually.
      #         #
      #         # pkgs.appimageTools provides basic packages required by most software.
      #         (base.targetPkgs pkgs) ++ (with pkgs; [
      #           pkg-config
      #           ncurses
      #           # ...
      #         ]
      #         );
      #       profile = "export FHS=1";
      #       # runScript = "bash";
      #       runScript = "bash";
      #       extraOutputsToInstall = [ "dev" ];
      #     })
      #   )
      ];
      };
      }
