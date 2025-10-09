{ config }:
{
  config = {
    systems.nixos.dns = {
      # nixpkgs = config.inputs.nixpkgs-unstable;
      system = "aarch64-linux";
      modules = [
        # config.inputs.nixos-generators.result.nixosModules.sd-aarch64
        config.inputs.nixos-generators.result.nixosModules.all-formats
      ];
    };
  };
}
