# deploy <host> [user@target] [extra nilla args...]
#
# Day-2 management: rebuild and switch an already-installed host's NixOS system
# and home-manager configuration. Local when no target is given, remote (over
# SSH) when a target is given. Thin wrapper over the nilla-utils CLI.

if [ "$#" -eq 0 ] || [ "$1" = "-h" ] || [ "$1" = "--help" ]; then
  echo "usage: deploy <host> [user@target] [extra nilla args...]" >&2
  exit 1
fi

host="$1"
shift

target=""
case "${1:-}" in
  "" | -*) ;;
  *) target="$1"; shift ;;
esac

user="$(nix-instantiate --eval --strict --expr '(import ./me.nix).user' | tr -d '"')"

target_flag=()
[ -n "$target" ] && target_flag=(--target "$target")

nilla os   switch "$host"           "${target_flag[@]}" "$@"
nilla home switch "${user}@${host}" "${target_flag[@]}" "$@"
