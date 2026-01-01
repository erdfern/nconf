# see https://huantian.dev/blog/unity3d-rider-nixos/
{ config, lib, pkgs, me, ... }:
let
  cfg = config.kor.development.rider;

  extra-path = with pkgs; [

    dotnet-sdk_9
    dotnetPackages.Nuget
    mono
    # msbuild

    # Any extra binaries we want accessible to Rider go here
    # ...
  ];


  extra-lib = with pkgs;[
    # Any extra libraries we want accessible to Rider go here
    # ...
  ];


  rider-pkg = pkgs.jetbrains.rider.overrideAttrs (attrs: {
    # original here: https://github.com/NixOS/nixpkgs/blob/dc9637876d0dcc8c9e5e22986b857632effeb727/pkgs/applications/editors/jetbrains/default.nix#L351
    postInstall =
      (attrs.postInstall or "")
      + lib.optionalString (pkgs.stdenv.hostPlatform.isLinux) ''
        # Wrap rider with extra tools and libraries
        # echo "Hi :3" >> $out/IWASHERE.file
        mv $out/bin/rider $out/bin/.rider-toolless

        makeWrapper $out/bin/.rider-toolless $out/bin/rider \
          --argv0 rider \
          --prefix PATH : "${lib.makeBinPath extra-path}" \
          --prefix LD_LIBRARY_PATH : "${lib.makeLibraryPath extra-lib}"

        (
          cd $out/rider

          ls -d $PWD/plugins/cidr-debugger-plugin/bin/lldb/linux/*/lib/python3.8/lib-dynload/* |
          xargs patchelf \
            --replace-needed libssl.so.10 libssl.so \
            --replace-needed libcrypto.so.10 libcrypto.so \
            --replace-needed libcrypt.so.1 libcrypt.so

          for dir in lib/ReSharperHost/linux-*; do
            rm -rf $dir/dotnet
            ln -s ${pkgs.dotnet-sdk}/share/dotnet $dir/dotnet
          done
        )
      '';
    #   postInstall = ''

    #     # Wrap rider with extra tools and libraries

    #     mv $out/bin/rider $out/bin/.rider-toolless

    #     makeWrapper $out/bin/.rider-toolless $out/bin/rider \

    #       --argv0 rider \

    #       --prefix PATH : "${lib.makeBinPath extra-path}" \

    #       --prefix LD_LIBRARY_PATH : "${lib.makeLibraryPath extra-lib}"


    #     # Making Unity Rider plugin work!
    #     # The plugin expects the binary to be at /rider/bin/rider,
    #     # with bundled files at /rider/
    #     # It does this by going up two directories from the binary path
    #     # Our rider binary is at $out/bin/rider, so we need to link $out/rider/ to $out/

    #     shopt -s extglob

    #     ln -s $out/rider/!(bin) $out/

    #     shopt -u extglob

    #   '' + attrs.postInstall or "";
  });
in
{
  options.kor.development.rider.enable = lib.mkEnableOption "Rider IDE";

  config = lib.mkIf cfg.enable {
    home.packages = [
      rider-pkg
      # TODO move
      # pkgs.unityhub
    ]
    ++ (with pkgs; [
      # jetbrains.rider
      # mono
      # dotnetCorePackages.sdk_9_0
      # same as?
      # dotnet-sdk_9
      # dotnet-sdk
    ]);
    # home.sessionVariables = {
    #   DOTNET_ROOT = "${pkgs.dotnet-sdk}/share/dotnet/";
    # };
  };
}
