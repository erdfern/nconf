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

      systems = builtins.mapAttrs
        (name: value: value.result)
        project.systems.nixos;

      nodes = builtins.mapAttrs
        (name: value: {
          modules = value._module.args.modules;
        })
        systems;
    in
    {

      nixosConfigurations.dedi =
        let
          system = systems.dedi;
        in
        nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          specialArgs = {
            inherit inputs;
          };
          modules = system._module.args.modules;
          # modules = system.modules;
        };
      nixosConfigurations.dns =
        let
          system = systems.dns;
        in
        nixpkgs.lib.nixosSystem {
          system = "aarch64-linux";
          specialArgs = {
            inherit inputs;
          };
          modules = system._module.args.modules;
          # modules = system.modules;
        };

      # https://wiki.nixos.org/wiki/Install_NixOS_on_Hetzner_Cloud
      nixosConfigurations.hetzner-cloud = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          disko.nixosModules.disko
          ./configuration.nix
        ];
      };

      # nix run --extra-experimental-features 'nix-command flakes' github:nix-community/nixos-anywhere -- --flake .#h1 --target-host root@IP --build-on remote
      nixosConfigurations.h1 = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = {
          inherit inputs;
        };
        modules = project.systems.nixos.h1._module.args.modules;
      };

      # Use this for all other targets
      # nixos-anywhere --flake .#generic --generate-hardware-config nixos-generate-config ./hardware-configuration.nix <hostname>
      nixosConfigurations.generic = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          disko.nixosModules.disko
          ./configuration.nix
          ./hardware-configuration.nix
        ];
      };

      # Slightly experimental: Like generic, but with nixos-facter (https://github.com/numtide/nixos-facter)
      # nixos-anywhere --flake .#generic-nixos-facter --generate-hardware-config nixos-facter facter.json <hostname>
      nixosConfigurations.generic-nixos-facter = nixpkgs.lib.nixosSystem {
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
}
