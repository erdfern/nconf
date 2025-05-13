{ auxlib, inputs, ... }:
{
  imports = [
    (import "${inputs.lix.result}/module.nix" {
      lix = (auxlib.paths.into.drv inputs.lix-src.result) // {
        rev = "latest";
      };
    })
  ];
}
