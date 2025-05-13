let
  pins = import ./npins;

  nilla = import pins.nilla;

  user = "lk";
in
nilla.create ({ config }:
{
  includes = [
    "${pins.nilla-utils}/modules"
  ];

  config = {
    ############
    ## Inputs ##
    ############
    # Generate inputs from npins
    generators.inputs.pins = pins;

    # Override specific input settings and loaders
    inputs = {
      nixpkgs.settings = {
        configuration.allowUnfree = true;
        overlays = [ config.overlays.default config.inputs.hyprpanel.result.overlay ];
      };
      # nixpkgs-unstable.settings = config.inputs.nixpkgs.settings;
      nixpkgs-stable.settings = config.inputs.nixpkgs.settings;

      home-manager.loader = "flake";
      nix-index-database.loader = "flake";
      hyprland.loader = "flake";
      hyprpanel.loader = "flake";
      catppuccin-nix.loader = "flake";
      noshell.loader = "flake";

      hardware.loader = "raw";
      impermanence.loader = "raw";
      disko.loader = "raw";
      facter.loader = "raw";
      lix.loader = "raw";
      lix-src.loader = "raw";

      # uhm... there has to be a cleaner way, but idk, this works fine for now.
      rycee-nur-expressions.loader = "legacy";
      # only downloading the tar for the addons dir is nice, but seems to create hash mismatches:
      # "type": "Tarball",
      # "url": "https://gitlab.com/rycee/nur-expressions/-/archive/master/nur-expressions-master.tar?path=pkgs/firefox-addons",
      # soo, i'll use the whole repo for now
      # firefox-addons.loader = "legacy";
      # firefox-addons.settings.target = "pkgs/firefox-addons/default.nix";
      # firefox-addons.settings.args =
      #   let
      #     pkgs = config.inputs.nixpkgs.result."x86_64-linux"; # obv only works on one system, but i realistically won't be running firefox on arm or smth
      #   in
      #   { fetchurl = pkgs.fetchurl; lib = pkgs.lib; stdenv = pkgs.stdenv; };
    };

    ###########
    ## NixOS ##
    ###########
    # Generate nixos hosts from folders in ./hosts
    generators.nixos = {
      folder = ./hosts;
      args.user = user;

      modules = [
        config.modules.nixos.default
        config.inputs.catppuccin-nix.result.nixosModules.catppuccin
        config.inputs.noshell.result.nixosModules.default
        "${config.inputs.disko.result}/module.nix"
        # TODO make lix per-system option
        (import "${config.inputs.lix.result}/module.nix" {
          lix = (config.lib.paths.into.drv config.inputs.lix-src.result) // { rev = "latest"; };
        })
        # same thing if loader=raw... (import "${config.inputs.disko.src}/module.nix")
        # config.inputs.disko.result.nixosModules.disko

        # (import "${config.inputs.home-manager.result}/nixos")
        # ({ ... }: {
        #   users.users.rando.isNormalUser = true;
        #   home-manager.users.rando = {
        #     home.stateVersion = "24.11";
        #   };
        # })
      ];
    };

    # Export NixOS module
    modules.nixos.default = ./modules/nixos;

    ##################
    ## Home Manager ##
    ##################
    # Generate home-manager configurations from folders in
    # ./hosts
    generators.home = {
      username = user;
      folder = ./hosts;
      modules = [
        config.modules.home.default
        config.inputs.catppuccin-nix.result.homeModules.catppuccin
        config.inputs.nix-index-database.result.hmModules.nix-index
        { programs.nix-index-database.comma.enable = true; }
        # ({}:{
        # })
      ];
    };

    # Export home-manager module
    modules.home.default = ./modules/home;

    ##############
    ## Overlays ##
    ##############
    # Generate `default` overlay using `./packages`
    # folder structure
    generators.overlays.default.folder = ./packages;

    #######################
    ## Special overrides ##
    #######################
    # systems.nixos.n1.nixpkgs = config.inputs.nixpkgs-unstable;
    # systems.home."${user}@n1" = {
    #   pkgs = config.inputs.nixpkgs-unstable.result.x86_64-linux;
    #   # home-manager = config.inputs.home-manager.result.nixosModules.home-manager { };
    # };

    # systems.nixos.kor.nixpkgs = config.inputs.nixpkgs-unstable;
    # systems.home."${user}@kor".pkgs = config.inputs.nixpkgs-unstable.result.x86_64-linux;

    # systems.nixos.kor-t14.nixpkgs = config.inputs.nixpkgs-unstable;
    # systems.home."${user}@kor-t14".pkgs = config.inputs.nixpkgs-unstable.result.x86_64-linux;

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
