{ lib
, stdenvNoCC
, fetchFromGitHub
, gnome-shell
, sassc
, gnome-themes-extra
, gtk-engine-murrine
, unstableGitUpdater
, colorVariants ? [ ]
, sizeVariants ? [ ]
, themeVariants ? [ ]
, tweakVariants ? [ ]
, iconVariants ? [ ]
,
}:

let
  pname = "catppuccin-gtk-theme";
  colorVariantList = [
    "dark"
    "light"
  ];
  sizeVariantList = [
    "compact"
    "standard"
  ];
  themeVariantList =
    [
      "default"
      "blue"
      "flamingo"
      "green"
      "grey"
      "lavender"
      "maroon"
      "mauve"
      "peach"
      "pink"
      "red"
      "rosewater"
      "sapphire"
      "sky"
      "teal"
      "yellow"
      "all"
    ];
  tweakVariantList = [
    "macchiato"
    "frappe"
    "black"
    "float"
    "outline"
    "macos"
  ];
  iconVariantList = [
    "Dark-Cyan"
    "Dark"
    "Light"
    "Moon"
  ];
in
lib.checkListOfEnum "${pname}: colorVariants" colorVariantList colorVariants lib.checkListOfEnum
  "${pname}: sizeVariants"
  sizeVariantList
  sizeVariants
  lib.checkListOfEnum
  "${pname}: themeVariants"
  themeVariantList
  themeVariants
  lib.checkListOfEnum
  "${pname}: tweakVariants"
  tweakVariantList
  tweakVariants
  lib.checkListOfEnum
  "${pname}: iconVariants"
  iconVariantList
  iconVariants

  stdenvNoCC.mkDerivation
{
  inherit pname;
  version = "0-unstable-2025-10-23";

  src = fetchFromGitHub {
    owner = "Fausto-Korpsvart";
    repo = "Catppuccin-GTK-Theme";
    rev = "f25d8cf688d8f224f0ce396689ffcf5767eb647e";
    hash = lib.fakeHash;
  };

  propagatedUserEnvPkgs = [ gtk-engine-murrine ];

  nativeBuildInputs = [
    gnome-shell
    sassc
  ];
  buildInputs = [ gnome-themes-extra ];

  dontBuild = true;

  passthru.updateScript = unstableGitUpdater { };

  postPatch = ''
    patchShebangs themes/install.sh
  '';

  installPhase = ''
    runHook preInstall
    mkdir -p $out/share/themes
    cd themes
    ./install.sh -n Catppuccin \
    ${lib.optionalString (colorVariants != [ ]) "-c " + toString colorVariants} \
    ${lib.optionalString (sizeVariants != [ ]) "-s " + toString sizeVariants} \
    ${lib.optionalString (themeVariants != [ ]) "-t " + toString themeVariants} \
    ${lib.optionalString (tweakVariants != [ ]) "--tweaks " + toString tweakVariants} \
    -d "$out/share/themes"
    cd ../icons
    ${lib.optionalString (iconVariants != [ ]) ''
      mkdir -p $out/share/icons
      cp -a ${toString (map (v: "Catppuccin-${v}") iconVariants)} $out/share/icons/
    ''}
    runHook postInstall
  '';

  meta = {
    description = "GTK theme based on the Catppuccin colour palette";
    homepage = "https://github.com/Fausto-Korpsvart/Catppuccin-GTK-Theme";
    license = lib.licenses.gpl3Plus;
    # maintainers = with lib.maintainers; [ ];
    maintainers = [ ];
    platforms = lib.platforms.unix;
  };
}
