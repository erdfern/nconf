{
  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
  inputs.disko.url = "github:nix-community/disko";
  inputs.disko.inputs.nixpkgs.follows = "nixpkgs";
  inputs.nixos-facter-modules.url = "github:numtide/nixos-facter-modules";
  # inputs.impermanence.result = (import ../nilla.nix).inputs.impermanence.result;

  outputs =
    inputs @
    { nixpkgs
    , disko
    , nixos-facter-modules
    , ...
    }:
    {

      nixosConfigurations.dedi = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = {
          inherit inputs;
        };
        modules = [
          ../modules/nixos
          ../hosts/dedi/configuration.nix
          # (import ../nilla.nix).inputs.disko
          # { networking. hostName = "dedi"; }
          # ./dedi/base.nix
          # ./dedi/boot.nix
          # ./dedi/networking.nix
          # ./dedi/hardware-config.nix
          # ./dedi/disk-config.nix
          disko.nixosModules.disko
          # ./configuration.nix
          # ./hardware-configuration.nix
        ];
      };

      nixosConfigurations.hetzner-cloud = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          disko.nixosModules.disko
          ./configuration.nix
        ];
      };
      # tested with 2GB/2CPU droplet, 1GB droplets do not have enough RAM for kexec
      nixosConfigurations.digitalocean = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          disko.nixosModules.disko
          { disko.devices.disk.disk1.device = "/dev/vda"; }
          {
            # do not use DHCP, as DigitalOcean provisions IPs using cloud-init
            networking.useDHCP = nixpkgs.lib.mkForce false;

            services.cloud-init = {
              enable = true;
              network.enable = true;
              settings = {
                datasource_list = [ "ConfigDrive" ];
                datasource.ConfigDrive = { };
              };
            };
          }
          ./configuration.nix
        ];
      };
      nixosConfigurations.hetzner-cloud-aarch64 = nixpkgs.lib.nixosSystem {
        system = "aarch64-linux";
        modules = [
          disko.nixosModules.disko
          ./configuration.nix
        ];
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

# {
#   inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
#   inputs.disko.url = "github:nix-community/disko";
#   inputs.disko.inputs.nixpkgs.follows = "nixpkgs";
#   inputs.nixos-facter-modules.url = "github:numtide/nixos-facter-modules";

#   outputs = inputs @
#     { nixpkgs
#     , disko
#     , nixos-facter-modules
#     , ...
#     }:
#     {
#       # nixos-anywhere --flake .#dedi --build-on remote --generate-hardware-config nixos-generate-config ./dedi.hardware-configuration.nix root@dedi
#       # or without the flake?
#       # nixos-anywhere --store-paths $(nix-build -A config.system.build.formatScript -A config.system.build.toplevel --no-out-link) root@dedi
#       # nixos-anywhere --store-paths $(nix-build nilla.nix -A systems.nixos.dedi.result.config.system.build.formatScript -A systems.nixos.dedi.result.config.system.build.toplevel --no-out-link) root@dedi
#       # nixosConfigurations.dedi = nixpkgs.lib.nixosSystem {
#       #   system = "x86_64-linux";
#       #   modules = [
#       #     # disko.nixosModules.disko
#       #     (import ../nilla.nix).systems.nixos.dedi.result
#       #     # ./configuration.nix
#       #     # ./hardware-configuration.nix
#       #   ];
#       # };
#       nixosConfigurations.dedi = nixpkgs.lib.nixosSystem {
#         system = "x86_64-linux";
#         specialArgs = { inherit inputs; };
#         modules = [
#           { networking. hostName = "dedi"; }
#           ./dedi/base.nix
#           ./dedi/boot.nix
#           ./dedi/networking.nix
#           ./dedi/hardware-config.nix
#           ./dedi/disk-config.nix
#           disko.nixosModules.disko
#           # disko.nixosModules.disko
#           # (import ../nilla.nix).systems.nixos.dedi.result
#           # ./configuration.nix
#           # ./hardware-configuration.nix
#         ];
#       };
#       nixosConfigurations.n1 = nixpkgs.lib.nixosSystem {
#         system = "x86_64-linux";
#         modules = [
#           disko.nixosModules.disko
#           ./configuration.nix
#           ./hardware-configuration.nix
#         ];
#       };

#       # Use this for all other targets
#       # nixos-anywhere --flake .#generic --generate-hardware-config nixos-generate-config ./hardware-configuration.nix <hostname>
#       nixosConfigurations.generic = nixpkgs.lib.nixosSystem {
#         system = "x86_64-linux";
#         modules = [
#           disko.nixosModules.disko
#           ./configuration.nix
#           ./hardware-configuration.nix
#         ];
#       };

#       # Slightly experimental: Like generic, but with nixos-facter (https://github.com/numtide/nixos-facter)
#       # nixos-anywhere --flake .#generic-nixos-facter --generate-hardware-config nixos-facter facter.json <hostname>
#       nixosConfigurations.generic-nixos-facter = nixpkgs.lib.nixosSystem {
#         system = "x86_64-linux";
#         modules = [
#           disko.nixosModules.disko
#           ./configuration.nix
#           nixos-facter-modules.nixosModules.facter
#           {
#             config.facter.reportPath =
#               if builtins.pathExists ./facter.json then
#                 ./facter.json
#               else
#                 throw "Have you forgotten to run nixos-anywhere with `--generate-hardware-config nixos-facter ./facter.json`?";
#           }
#         ];
#       };
#     };
# }
