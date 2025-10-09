let
  project = import ./nilla.nix;

  systems = builtins.mapAttrs
    (name: value: value.result)
    project.systems.nixos;

  nodes = builtins.mapAttrs
    (name: value: {
      imports = value._module.args.modules ++ (
        if custom ? ${name} then [ custom.${name} ] else [ ]
      );
    })
    systems;

  custom = project.hive.nodes;
in
{
  meta = {
    description = "Colmena deployment configuration :3";

    nixpkgs = project.inputs.nixpkgs.result;

    nodeNixpkgs = builtins.mapAttrs
      (name: value: value.pkgs)
      systems;

    nodeSpecialArgs = builtins.mapAttrs
      (name: value: value._module.specialArgs)
      systems;
  };
} // nodes
