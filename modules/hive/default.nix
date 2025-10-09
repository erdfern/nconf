# Definition for colmena node options and generator for nodes
{ config }:
let
  inherit (config) inputs lib;
  inherit (builtins)
    listToAttrs
    mapAttrs
    pathExists
    concatMap
    ;

  globalModules = config.modules;

  # nixLib = inputs.nixpkgs.result.lib;
  # hiveOptions = (import ./options.nix);
in
{
  includes = [
    ./lib.nix
  ];

  options = {
    hive.nodes = lib.options.create {
      description = "Colmena configuration for deployment targets.";
      default.value = { };
      # https://colmena.cli.rs/unstable/reference/deployment.html
      # https://github.com/zhaofengli/colmena/blob/main/src/nix/hive/options.nix
      type = lib.types.attrs.of (
        lib.types.submodule (
          { config }:
          {
            # unfortunatellyyyy.. i'd have to rewrite this using auxlib or implement a mapper from nixlib options -> auxlib options, which isn't worth the effort and out-of-sync potential
            # includes = [
            #   (hiveOptions.deploymentOptions { name = "idk"; lib = nixLib; })
            # ];
            options = {
              deployment = lib.options.create {
                type = lib.types.attrs.any;
                default.value = { };
              };

              # result = lib.options.create {
              #   description = "The final node definition";
              #   type = lib.types.raw;
              #   writable = false;
              #   default.value =
              #     {
              #       deployment = builtins.trace config
              #         {
              #           targetHost = "dummy";
              #         } // config.deployment;
              #     };
              # };
            };
          }
        )
      );
    };

    # generators.hive = {
    #   folder = lib.options.create {
    #     type = lib.types.nullish lib.types.path;
    #     description = "The folder to auto discover hive nodes.";
    #     default.value = null;
    #   };
    # };
  };

  # config = {
  #   assertions =
  #     (lib.lists.when config.generators.assertPaths [
  #       {
  #         assertion =
  #           config.generators.nixos.folder == null
  #           || (config.generators.hive.folder != null && pathExists config.generators.nixos.folder);
  #         message = "Hive generator's folder \"${config.generators.hive.folder}\" does not exist.";
  #       }
  #     ]);

  #   # Generate node deployment configurations from `generators.hive`
  #   hive.nodes =
  #     let
  #       inherit (builtins)
  #         readDir
  #         filter
  #         attrNames
  #         concatMap
  #         hasAttr
  #         listToAttrs
  #         ;
  #       loadNodes =
  #         dir: file:
  #         let
  #           hosts' =
  #             let
  #               contents = readDir dir;
  #             in
  #             filter (n: contents."${n}" == "directory") (attrNames contents);
  #         in
  #         concatMap
  #           (
  #             n:
  #             let
  #               contents = readDir "${dir}/${n}";
  #               hasConfig = (hasAttr file contents) && (contents.${file} == "regular");
  #             in
  #             # if hasConfig then
  #               #   [
  #               #     {
  #               #       hostname = n;
  #               #       configuration = import "${dir}/${n}/${file}";
  #               #     }
  #               #   ]
  #               # else
  #             if config.systems.nixos ? n then
  #               [{
  #                 name = n;
  #               }]
  #             else
  #               [ ]
  #           )
  #           hosts';
  #     in
  #     lib.modules.when
  #       (config.generators.hive.folder != null && pathExists config.generators.hive.folder)
  #       (
  #         listToAttrs (
  #           map
  #             (host: {
  #               name = host.name;
  #               value = {
  #                 deployment = {
  #                   targetHost = host.name;
  #                 };
  #               };
  #             })
  #             (loadNodes config.generators.hive.folder "node.nix")
  #           # (lib.utils.loadNodesFromDir config.generators.hive.folder "node.nix")
  #           # (lib.utils.loadHostsFromDir config.generators.nixos.folder "configuration.nix")
  #         )
  #       );
  # };
}
