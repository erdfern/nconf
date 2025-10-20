{ config }:
let
  pins = import ./npins;

  flake-compat = config.inputs.flake-compat.result;
  # flake-compat-aswell = config.inputs.flake-compat-aswell;
  # hyprland = (import flake-compat { }).defaultNix;

  # TODO might be using this wrong https://github.com/nilla-nix/flake-compat
  # nixpkgs-flake = flake-compat.load { src = config.inputs.nixpkgs.src; };
  nixpkgs-unstable-flake = flake-compat.load { src = config.inputs.nixpkgs.src; };
  # don't think I need to do this; config.inputs.hyprland.result should probably work the same
  hyprland-flake = flake-compat.load { src = config.inputs.hyprland.src; };
  # hyprpanel-flake = flake-compat.load {
  #   src = config.inputs.hyprpanel.src;
  #   replacements = {
  #     nixpkgs = nixpkgs-unstable-flake;
  #   };
  # };
  # firefox-nightly-flake = flake-compat.load { src = config.inputs.firefox-nightly; };

  loaders = {
    comma = "flake";
    home-manager = "flake";
    nix-index-database = "flake";
    hyprland = "flake";
    hy3 = "flake";
    catppuccin-nix = "flake";
    sops-nix = "flake";
    # firefox-nightly = "flake";

    hardware = "raw";
    impermanence = "raw";
    disko = "raw";
    # facter = "raw";
    lix = "raw";
    lix-src = "raw";
  };

  # Per-input settings
  settings = {
    nixpkgs = {
      configuration.allowUnfree = true;
      overlays = [
        config.overlays.default
        config.inputs.neovim-nightly-overlay.result.overlays.default
      ];
    };
    nixpkgs-unstable = config.inputs.nixpkgs.settings;

    # home-manager.inputs.nixpkgs = nixpkgs-unstable-flake; # default input already is nixpkgs/nixos-unstable

    comma.inputs.nixpkgs = nixpkgs-unstable-flake;
    hyprpanel.inputs.nixpkgs = nixpkgs-unstable-flake;
    firefox-nightly.inputs.nixpkgs = nixpkgs-unstable-flake;
    nixos-generators.inputs.nixpkgs = nixpkgs-unstable-flake;

    #   #   # TODO hy3
    #   #   # hy3 = {
    #   #   #   url = "github:outfoxxed/hy3?ref=hl{version}"; # where {version} is the hyprland release version
    #   #   #   # or "github:outfoxxed/hy3" to follow the development branch.
    #   #   #   # (you may encounter issues if you dont do the same for hyprland)
    #   #   #   inputs.hyprland.follows = "hyprland";
    #   #   # };
    hy3.inputs.hyprland = hyprland-flake;
  };
in
{
  config = {
    ############
    ## Inputs ##
    ############
    # Generate inputs from npins
    inputs = builtins.mapAttrs
      (name: pin: {
        src = pin;

        loader = loaders.${name} or (config.lib.modules.when false { });
        settings = settings.${name} or (config.lib.modules.when false { });
      })
      pins;
  };
}
