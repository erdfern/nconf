{ config, lib, pkgs, ... }:
let
  cfg = config.kor.development.idea;

  java = pkgs.jdk17;
  gradle = pkgs.gradle.override { inherit java; };
  kotlin = pkgs.kotlin.override { jre = java; };


  extra-path = with pkgs; [
    java
    gradle
    kotlin

    # Any extra binaries we want accessible
    # ...
  ];


  extra-lib = with pkgs;[
    # Any extra libraries we want accessible
    # ...
  ];

  idea-pkg = pkgs.jetbrains.idea-community-bin.overrideAttrs (attrs: {
    # original here: https://github.com/NixOS/nixpkgs/blob/dc9637876d0dcc8c9e5e22986b857632effeb727/pkgs/applications/editors/jetbrains/default.nix#L351
    postInstall =
      (attrs.postInstall or "")
      + lib.optionalString (pkgs.stdenv.hostPlatform.isLinux) ''
        # Wrap with extra tools and libraries
        mv $out/bin/idea-community $out/bin/.idea-community-toolless

        makeWrapper $out/bin/.idea-community-toolless $out/bin/idea-community \
          --argv0 idea-community \
          --prefix PATH : "${lib.makeBinPath extra-path}" \
          --prefix LD_LIBRARY_PATH : "${lib.makeLibraryPath extra-lib}"
      '';
  });
in
{
  options.kor.development.idea.enable = lib.mkEnableOption "Rider IDE";

  config = lib.mkIf cfg.enable {
    home.packages = [
      java
      gradle
      kotlin
      # idea-pkg
    ]
    ++ (with pkgs; [
      jetbrains.idea-community
    ]);
    # home.sessionVariables = {
    #   DOTNET_ROOT = "${pkgs.dotnet-sdk}/share/dotnet/";
    # };
  };
}
