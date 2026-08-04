{ lib
, config
, pkgs
, ...
}:
let
  cfg = config.kor.desktop.defaultApps;
  apps = config.kor.desktop.apps;

  # Curated per-category MIME lists -- the single source of truth for what each
  # category covers. Override per host via categories.<name>.mimeTypes, or add
  # one-off types via extraAssociations.
  defaultMimeTypes = {
    image = [
      "image/jpeg"
      "image/png"
      "image/gif"
      "image/webp"
      "image/bmp"
      "image/tiff"
      "image/svg+xml"
      "image/avif"
      "image/heif"
      "image/pnm"
    ];
    video = [
      "video/mp4"
      "video/webm"
      "video/x-matroska"
      "video/mpeg"
      "video/ogg"
      "video/quicktime"
      "video/x-msvideo"
      "video/x-m4v"
      "video/x-flv"
      "video/3gpp"
    ];
    audio = [
      "audio/mpeg"
      "audio/mp4"
      "audio/x-m4a"
      "audio/flac"
      "audio/x-flac"
      "audio/ogg"
      "audio/x-vorbis+ogg"
      "audio/x-opus+ogg"
      "audio/wav"
      "audio/x-wav"
      "audio/aac"
      "audio/webm"
    ];
    # The explicit list matters for the app2unit/xdg-mime path, which does
    # exact-match lookups only; gio/Nemo/the portal walk shared-mime-info
    # subclasses and fall back to text/plain for anything missing here.
    text = [
      "text/plain"
      "application/x-zerosize" # empty files (touch foo)
      "text/markdown"
      "text/csv"
      "text/xml"
      "application/xml"
      "application/json"
      "application/yaml"
      "application/x-yaml"
      "application/toml"
      "text/x-shellscript"
      "application/x-shellscript"
      "application/x-perl"
      "text/x-python"
      "text/x-python3"
      "text/x-script.python"
      "text/x-c"
      "text/x-csrc"
      "text/x-chdr"
      "text/x-c++"
      "text/x-c++src"
      "text/x-c++hdr"
      "text/x-makefile"
      "text/x-cmake"
      "text/x-rust"
      "text/x-go"
      "text/x-java"
      "text/x-lua"
      "text/x-tex"
      "text/x-log"
      "text/x-readme"
    ];
    # zathura's wrapped build ships pdf-mupdf/djvu/ps plugins; mupdf also reads epub.
    document = [
      "application/pdf"
      "application/epub+zip"
      "image/vnd.djvu"
      "image/vnd.djvu+multipage"
      "application/postscript"
    ];
    archive = [
      "application/zip"
      "application/gzip"
      "application/x-tar"
      "application/x-compressed-tar"
      "application/x-bzip-compressed-tar"
      "application/x-xz-compressed-tar"
      "application/x-zstd-compressed-tar"
      "application/zstd"
      "application/x-7z-compressed"
      "application/vnd.rar"
      "application/x-rar"
    ];
    directory = [
      "inode/directory"
      "application/x-gnome-saved-search"
    ];
    # text/html here for organization, not in text.
    browser = [
      "text/html"
      "application/xhtml+xml"
      "x-scheme-handler/http"
      "x-scheme-handler/https"
      "x-scheme-handler/about"
      "x-scheme-handler/unknown"
    ];
  };

  categoryType = lib.types.submodule ({ name, ... }: {
    options = with lib; {
      handler = mkOption {
        type = types.nullOr types.str;
        default = null;
        example = "imv.desktop";
        description = "Desktop file ID to open this category with, or null to leave it unmanaged.";
      };
      mimeTypes = mkOption {
        type = types.listOf types.str;
        default = defaultMimeTypes.${name} or [ ];
        description = "MIME types covered by this category.";
      };
    };
  });

  # mime -> [ handler ] for every category with a non-null handler
  managed = lib.concatMapAttrs
    (_: cat:
      lib.optionalAttrs (cat.handler != null)
        (lib.genAttrs cat.mimeTypes (_: [ cat.handler ])))
    cfg.categories;
in
{
  options.kor.desktop.defaultApps = with lib; {
    enable = mkEnableOption "central default application (MIME) management";

    categories = mkOption {
      type = types.attrsOf categoryType;
      default = { };
      description = "Per-category default application assignment.";
    };

    extraAssociations = mkOption {
      type = types.attrsOf (types.listOf types.str);
      default = { };
      example = { "x-scheme-handler/magnet" = [ "transmission-gtk.desktop" ]; };
      description = "Extra MIME -> desktop-id lists merged over the generated ones (wins on collision).";
    };

    terminal = mkOption {
      type = types.nullOr types.str;
      default = "kitty.desktop";
      description = "Desktop file ID written to xdg-terminals.list; used by xdg-terminal-exec (app2unit + glib) to run Terminal=true entries like Helix.";
    };

    shimXdgOpen = mkOption {
      type = types.bool;
      default = true;
      description = "Shadow xdg-open with app2unit-open so opens land in proper systemd units/slices under uwsm.";
    };
  };

  config = lib.mkIf cfg.enable {
    # Auto-derived handlers: one if/else chain per category, so two apps can
    # never both claim a category. Hosts override with a plain assignment
    # (beats mkDefault), e.g.
    #   kor.desktop.defaultApps.categories.image.handler = "feh.desktop";
    kor.desktop.defaultApps.categories = {
      image.handler = lib.mkDefault
        (if apps.imv.enable then "imv.desktop"
        else if apps.feh.enable then "feh.desktop"
        else null);
      video.handler = lib.mkDefault (if apps.mpv.enable then "mpv.desktop" else null);
      audio.handler = lib.mkDefault (if apps.mpv.enable then "mpv.desktop" else null);
      text.handler = lib.mkDefault "Helix.desktop"; # helix module is unconditional
      directory.handler = lib.mkDefault "nemo.desktop"; # nemo module is unconditional
      document.handler = lib.mkDefault
        (if apps.zathura.enable then "org.pwmt.zathura.desktop" else null);
      # browser.handler is fed by the firefox module (makeDefault); archive stays null.
    };

    xdg.mimeApps = {
      enable = true; # sole enable site; keep this module the only xdg.mimeApps writer
      defaultApplications = managed // cfg.extraAssociations;
      # Register as added associations too so handlers appear in "Open With"
      # lists even when their .desktop lacks the type (Helix.desktop declares
      # no markdown/json/yaml/...).
      associations.added = managed // cfg.extraAssociations;
    };

    # Writes ~/.config/xdg-terminals.list and puts xdg-terminal-exec on the
    # user PATH (glib tries xdg-terminal-exec first for Terminal=true entries).
    xdg.terminal-exec = lib.mkIf (cfg.terminal != null) {
      enable = true;
      settings.default = [ cfg.terminal ];
    };

    home.packages = lib.mkIf cfg.shimXdgOpen [
      (lib.hiPrio (pkgs.writeShellScriptBin "xdg-open" ''
        exec ${lib.getExe' pkgs.app2unit "app2unit-open"} "$@"
      ''))
    ];
  };
}
