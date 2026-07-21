# wake <host|mac> [options]
#
# Send a Wake-on-LAN magic packet to bring a powered-off host online.
#
#   wake kor                    look 'kor' up in ./wol.nix and wake it
#   wake d8:bb:c1:12:34:56      wake an explicit MAC directly
#   wake --list                 show the hosts known to ./wol.nix
#
# Host names resolve through ./wol.nix (a plain attrset of <host>.mac /
# <host>.broadcast). That indirection exists because a host's MAC can't be read
# while it's off -- the moment you actually need it -- so it's persisted there.
#
# Options:
#   -b, --broadcast <addr>  target/broadcast IP   (default: host's, else 255.255.255.255)
#   -p, --port <n>          UDP port              (default: 9)
#   -l, --list              list hosts in wol.nix and exit
#   -n, --dry-run           print the wakeonlan invocation without sending
#   --project <path>        dir containing wol.nix   (default: $NCONF_PROJECT, git root, or .)

die() {
  echo "wake: $*" >&2
  exit 1
}

print_usage() {
  echo "usage: wake <host|mac> [-b broadcast] [-p port] [-l] [-n] [--project <path>]" >&2
}

# Bare MAC address, colon- or dash-separated.
is_mac() {
  [[ "$1" =~ ^([0-9A-Fa-f]{2}[:-]){5}[0-9A-Fa-f]{2}$ ]]
}

resolve_project() {
  if [ -n "${opt_project:-}" ]; then
    printf '%s\n' "$opt_project"
    return
  fi
  if [ -n "${NCONF_PROJECT:-}" ]; then
    printf '%s\n' "$NCONF_PROJECT"
    return
  fi
  if git rev-parse --show-toplevel >/dev/null 2>&1; then
    git rev-parse --show-toplevel
    return
  fi
  echo .
}

# Evaluate a Nix expression to a raw string; never fail the caller (missing key
# / eval error -> empty string, handled by the caller).
nix_eval() {
  nix eval --extra-experimental-features nix-command \
    --raw --impure --expr "$1" 2>/dev/null || true
}

arg=""
opt_broadcast=""
opt_port="9"
opt_list=0
opt_dry=0
opt_project=""

while [ "$#" -gt 0 ]; do
  case "$1" in
    -h | --help)
      print_usage
      exit 0
      ;;
    -b | --broadcast)
      opt_broadcast="${2:?--broadcast needs an address}"
      shift 2
      ;;
    -p | --port)
      opt_port="${2:?--port needs a number}"
      shift 2
      ;;
    -l | --list)
      opt_list=1
      shift
      ;;
    -n | --dry-run)
      opt_dry=1
      shift
      ;;
    --project)
      opt_project="${2:?--project needs a path}"
      shift 2
      ;;
    -*)
      die "unknown option: $1"
      ;;
    *)
      [ -z "$arg" ] || die "unexpected argument: $1"
      arg="$1"
      shift
      ;;
  esac
done

proj="$(resolve_project)"
inventory="${proj}/wol.nix"

if [ "$opt_list" = 1 ]; then
  [ -e "$inventory" ] || die "no wol.nix found at '${proj}'"
  echo ">> hosts in ${inventory}:" >&2
  nix_eval "
    let e = import ${inventory};
    in builtins.concatStringsSep \"\n\" (map
      (n: let h = e.\${n}; in
        n + \"  \" + (if (h.mac or null) == null then \"(no mac set)\" else h.mac))
      (builtins.attrNames e))"
  exit 0
fi

[ -n "$arg" ] || {
  print_usage
  exit 1
}

if is_mac "$arg"; then
  mac="$arg"
else
  [ -e "$inventory" ] || die "no wol.nix at '${proj}' to resolve host '${arg}' (or pass a MAC directly)"
  mac="$(nix_eval "let e = import ${inventory}; h = e.\"${arg}\" or null;
    in if h == null || (h.mac or null) == null then \"\" else h.mac")"
  [ -n "$mac" ] || die "no MAC known for host '${arg}'. Set it in ${inventory} \
(on the host: cat /sys/class/net/<iface>/address), or run: wake <mac>"
  if [ -z "$opt_broadcast" ]; then
    opt_broadcast="$(nix_eval "let e = import ${inventory}; h = e.\"${arg}\" or null;
      in if h == null || (h.broadcast or null) == null then \"\" else h.broadcast")"
  fi
fi

broadcast="${opt_broadcast:-255.255.255.255}"

cmd=(wakeonlan -i "$broadcast" -p "$opt_port" "$mac")
if [ "$opt_dry" = 1 ]; then
  echo "would run: ${cmd[*]}" >&2
  exit 0
fi

echo ">> waking '${arg}' (${mac}) via ${broadcast}:${opt_port}" >&2
exec "${cmd[@]}"
