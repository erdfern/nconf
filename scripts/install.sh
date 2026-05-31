# install <host> [user@target] [extra nixos-anywhere args...]
#
#   With a target:  remote / LAN install via nixos-anywhere. Nilla is not a flake,
#                   so we feed it the two store paths it needs (--store-paths).
#   Without:        local on-device install -- run this from the installer ISO on
#                   the target machine itself (disko formats, then nixos-install).
#
# WARNING: both paths destroy and reformat the host's disks.

if [ "$#" -eq 0 ] || [ "$1" = "-h" ] || [ "$1" = "--help" ]; then
  echo "usage: install <host> [user@target] [extra nixos-anywhere args...]" >&2
  exit 1
fi

host="$1"
shift

target=""
case "${1:-}" in
  "" | -*) ;; # no positional target (next arg is a flag, or there is none)
  *) target="$1"; shift ;;
esac

attr="systems.nixos.${host}.result.config.system.build"

if [ -n "$target" ]; then
  echo ">> Remote install of '${host}' onto '${target}' via nixos-anywhere" >&2
  mapfile -t paths < <(nix-build nilla.nix \
    -A "${attr}.diskoScript" \
    -A "${attr}.toplevel" \
    --no-out-link)
  exec nixos-anywhere --store-paths "${paths[@]}" "$@" "$target"
else
  echo ">> Local install of '${host}' onto THIS machine -- disks will be wiped" >&2
  disko="$(nix-build nilla.nix -A "${attr}.diskoScript" --no-out-link)"
  "$disko"
  top="$(nix-build nilla.nix -A "${attr}.toplevel" --no-out-link)"
  exec nixos-install --no-root-passwd --no-channel-copy --root /mnt --system "$top"
fi
