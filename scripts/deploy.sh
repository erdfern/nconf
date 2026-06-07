# deploy <host> [user@target] [options] [extra nilla args...]
#
# Day-2 management: rebuild and switch an already-installed host's NixOS system
# and home-manager configuration. Local when no target is given, remote (over
# SSH) when a target is given. Thin wrapper over the nilla-utils CLI.
#
# Options:
#   --project <path>   run against this Nilla project dir   (default: current repo)
#
# For whole-fleet / tag-based rollouts use Colmena instead (see hive.nix):
#   colmena apply --on @<tag>

print_usage() {
  echo "usage: deploy <host> [user@target] [--project <path>] [extra nilla args...]" >&2
}

host=""
target=""
opt_project=""
extra=()

while [ "$#" -gt 0 ]; do
  case "$1" in
    -h | --help)
      print_usage
      exit 0
      ;;
    --project)
      opt_project="${2:?--project needs a path}"
      shift 2
      ;;
    --)
      shift
      extra+=("$@")
      break
      ;;
    -*)
      extra+=("$1")
      shift
      ;;
    *)
      if [ -z "$host" ]; then
        host="$1"
      elif [ -z "$target" ]; then
        target="$1"
      else
        extra+=("$1")
      fi
      shift
      ;;
  esac
done

[ -n "$host" ] || {
  print_usage
  exit 1
}

# nilla resolves the project by searching upward for nilla.nix from the cwd.
if [ -n "$opt_project" ]; then
  cd "$opt_project" || exit 1
fi

user="$(nix-instantiate --eval --strict --expr '(import ./me.nix).user' | tr -d '"')"

target_flag=()
[ -n "$target" ] && target_flag=(--target "$target")

nilla os switch "$host" "${target_flag[@]}" "${extra[@]}"
nilla home switch "${user}@${host}" "${target_flag[@]}" "${extra[@]}"
