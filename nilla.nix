let
  pins = import ./npins;

  nilla = import pins.nilla;

  me = import ./me.nix;
in
nilla.create ({ config }:
let
  inherit (config) lib;
in
{
  includes = [
    ./inputs.nix
    ./lib

    "${pins.nilla-utils}/modules"
    # ../nilla-utils/modules
    ./modules/hive

    # meeeehhhh
    ./hosts/dns
    ./hosts/kor-t14
  ];

  config = {

    # inputs.nilla-utils = { src = ./modules/nilla-utils; loader = "nilla"; };

    # TODO make lix per-system option
    # modules.nixos.lix = (import "${config.inputs.lix.result}/module.nix" {
    #   lix = (lib.paths.into.drv config.inputs.lix-src.src) // {
    #     rev = "latest";
    #   };
    # });

    ###########
    ## NixOS ##
    ###########
    # Export NixOS module
    # modules.nixos.default = ./modules/nixos;
    generators.nixosModules.folder = ./modules/nixos;

    # Generate nixos hosts from folders in ./hosts
    generators.nixos = {
      folder = ./hosts;
      # pkgs = config.inputs.nixpkgs-unstable; # unstable by default

      args = { inherit me; };

      modules = [
        config.modules.nixos.core
        config.inputs.catppuccin-nix.result.nixosModules.catppuccin
        # config.inputs.noshell.result.nixosModules.default
        # config.inputs.sops-nix.result.nixosModules.sops
        "${config.inputs.disko.result}/module.nix"
        # same thing if loader=raw... (import "${config.inputs.disko.src}/module.nix")
        # config.inputs.disko.result.nixosModules.disko

        # TODO I'd prefer to use the nixos module instead of stand-alone home-manager
        # (import "${config.inputs.home-manager.result}/nixos")
        # ({ ... }: {
        #   users.users.rando.isNormalUser = true;
        #   home-manager.users.rando = {
        #     home.stateVersion = "24.11";
        #   };
        # })
      ];
    };

    ##################
    ## Home Manager ##
    ##################
    # modules.home.default = ./modules/home;
    #
    # Generates homeModules.{folder_name} for each subfolder of ./modules/home
    generators.homeModules.folder = ./modules/home;

    # Generate home-manager configurations from folders in
    # ./hosts
    generators.home = {
      username = me.user;
      folder = ./hosts;

      args = { inherit me; };

      # TODO allow configuring home-manager input for all hosts.
      # Also, use flake-compat to set home-manager inputs nixpkgs?

      # args.nixOsConfig = config.systems.; # try to pass through osConfig to stand-alone for reading.
      # TODO could modify the generator to do that optionally, but at that point just use the nixosModule instead of stand-alone...

      modules = [
        config.modules.home.common
        config.inputs.catppuccin-nix.result.homeModules.catppuccin
        config.inputs.nix-index-database.result.homeModules.nix-index
        # config.inputs.nvim-conf.result.homeModules.default
        # ({}:{
        # })
      ];
    };

    ##############
    ## Overlays ##
    ##############
    # Generate `default` overlay from folders with `default.nix` in `./packages`
    generators.overlays.default.folder = ./packages;
    # and packages by themselves, useful for building them via just packages.<pname> or `nilla build <pname>`
    generators.packages.folder = ./packages;

    #######################
    ## Special overrides ##
    #######################
    # systems.nixos.kor.nixpkgs = config.inputs.nixpkgs-unstable;
    # systems.home."${me.user}@kor".pkgs = config.inputs.nixpkgs-unstable.result.x86_64-linux;
    # systems.home."${me.user}@kor".args.nixOsConfig = config.systems.nixos.kor.result.config;
    # HACK
    systems.home."${me.user}@kor".args.osConfig = config.systems.nixos.kor.result.config;
    systems.home."${me.user}@kor-t14".args.osConfig = config.systems.nixos.kor.result.config;

    # systems.nixos.kor-t14.nixpkgs = config.inputs.nixpkgs-unstable;
    # systems.home."${user}@kor-t14".pkgs = config.inputs.nixpkgs-unstable.result.x86_64-linux;

    systems.nixos.kor = {
      # modules = [ config.modules.nixos.lix ];
      modules = [
        ({ pkgs, ... }: {
          # nix.package = pkgs.lixPackageSets.stable.lix;
          # NOTE 16.10.25 the nixpkgs lix package does this (and more) by itself now!
          # nixpkgs.overlays = [
          #   (final: prev: {
          #     inherit (prev.lixPackageSets.stable)
          #       nixpkgs-review
          #       nix-eval-jobs
          #       nix-fast-build
          #       colmena;
          #   })
          # ];
        })
      ];
    };

    shells.default = {
      systems = [ "x86_64-linux" ];

      settings = {
        pkgs = config.inputs.nixpkgs-unstable.result;
        args.inputs = config.inputs;
      };

      # Shell definitions are declared using Nixpkgs' callPackage convention by default.
      shell = { mkShell, inputs, ... }:
        mkShell {
          packages = [
            inputs.nilla-cli.result.packages.default.result.x86_64-linux
            inputs.nilla-utils.result.packages.default.result.x86_64-linux
          ];
        };
    };
  };
})
