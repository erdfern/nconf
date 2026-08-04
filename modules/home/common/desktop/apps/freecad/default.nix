{ pkgs
, lib
, config
, ...
}:
let
  cfg = config.kor.desktop.apps.freecad;

  needsCustomize =
    cfg.pythonPackages != null || cfg.modules != [ ] || cfg.makeWrapperFlags != [ ];

  # pkgs.freecad is wrapped with makeCustomizable (freecad-utils.nix in nixpkgs):
  # `pythons` functions are resolved via FreeCAD's own python.withPackages and
  # injected with --python-path; `modules` become --module-path flags. Skipping
  # customize when nothing is set keeps the plain cached derivation.
  package =
    if needsCustomize then
      cfg.package.customize
        {
          pythons = lib.optional (cfg.pythonPackages != null) cfg.pythonPackages;
          inherit (cfg) modules makeWrapperFlags;
        }
    else
      cfg.package;
in
{
  options.kor.desktop.apps.freecad = with lib; {
    enable = mkEnableOption "FreeCAD";

    package = mkOption {
      type = types.package;
      default = pkgs.freecad;
      defaultText = literalExpression "pkgs.freecad";
      description = "FreeCAD package. Must expose `.customize` (e.g. pkgs.freecad or pkgs.freecad-git).";
    };

    pythonPackages = mkOption {
      type = types.nullOr (types.functionTo (types.listOf types.package));
      default = null;
      example = literalExpression "ps: [ ps.numpy ps.pandas ]";
      description = "Extra Python packages available inside FreeCAD, resolved against FreeCAD's own Python.";
    };

    modules = mkOption {
      type = types.listOf types.path;
      default = [ ];
      description = "Extra FreeCAD module/workbench paths (added via --module-path).";
    };

    makeWrapperFlags = mkOption {
      type = types.listOf types.str;
      default = [ ];
      example = [ "--set" "QT_QPA_PLATFORM" "xcb" ];
      description = "Extra makeWrapper flags for the FreeCAD/FreeCADCmd wrappers (env vars etc.).";
    };
  };

  config = lib.mkIf cfg.enable {
    home.packages = [ package ];
  };
}
