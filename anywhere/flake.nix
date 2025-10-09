{
  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
  inputs.disko.url = "github:nix-community/disko";
  inputs.disko.inputs.nixpkgs.follows = "nixpkgs";
  inputs.nixos-facter-modules.url = "github:numtide/nixos-facter-modules";

  outputs =
    inputs @
    { nixpkgs
    , disko
    , nixos-facter-modules
    , ...
    }:
    let
      project = import ../nilla.nix;

      nillaInputs = builtins.mapAttrs
        (name: value: value.result)
        project.inputs;

      systems = builtins.mapAttrs
        (name: value: value.result)
        project.systems.nixos;

      configs = builtins.mapAttrs
        (name: value: nixpkgs.lib.nixosSystem {
          system = value.pkgs.system;
          # specialArgs = value._module.specialArgs;
          specialArgs = { inherit nillaInputs; };
          modules = value._module.args.modules;
        })
        systems;
    in
    {
      # nixosConfigurations = systems // {
      nixosConfigurations = configs // {
        # dedi =
        #   let
        #     system = systems.dedi;
        #   in
        #   nixpkgs.lib.nixosSystem {
        #     system = "x86_64-linux";
        #     specialArgs = {
        #       inherit inputs;
        #     };
        #     modules = system._module.args.modules;
        #     # modules = system.modules;
        #   };

        # https://wiki.nixos.org/wiki/Install_NixOS_on_Hetzner_Cloud
        hetzner-cloud = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          modules = [
            disko.nixosModules.disko
            ./configuration.nix
          ];
        };

        # Use this for all other targets
        # nixos-anywhere --flake .#generic --generate-hardware-config nixos-generate-config ./hardware-configuration.nix <hostname>
        generic = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          modules = [
            disko.nixosModules.disko
            ./configuration.nix
            ./hardware-configuration.nix
          ];
        };

        # Slightly experimental: Like generic, but with nixos-facter (https://github.com/numtide/nixos-facter)
        # nixos-anywhere --flake .#generic-nixos-facter --generate-hardware-config nixos-facter facter.json <hostname>
        generic-nixos-facter = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          modules = [
            disko.nixosModules.disko
            ./configuration.nix
            nixos-facter-modules.nixosModules.facter
            {
              config.facter.reportPath =
                if builtins.pathExists ./facter.json then
                  ./facter.json
                else
                  throw "Have you forgotten to run nixos-anywhere with `--generate-hardware-config nixos-facter ./facter.json`?";
            }
          ];
        };
      };
    };
}
