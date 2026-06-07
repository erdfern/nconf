# install <host> [user@target] [options] [-- extra nixos-anywhere args]
#
# Provision a NixOS host from this Nilla config. One command, two transports:
#
#   install <host>                local on-device install -- run from the booted
#                                 installer ISO; formats THIS machine and installs.
#   install <host> root@<ip>      remote install over SSH via nixos-anywhere.
#
# Options:
#   --project <path>   use this Nilla project dir          (default: auto-detect)
#   --ref <git-ref>    fetch the config from github:erdfern/config at <ref> first
#   --facter           (remote) capture a nixos-facter report into the repo, then exit
#   --yes, -y          skip the destructive-wipe confirmation
#
# Project resolution (first match wins): --project, --ref, $NCONF_PROJECT,
# /etc/nconf (baked into the installer ISO), the current git repo, ".".
#
# WARNING: both transports ERASE and reformat the target's disks. There is no undo.

REPO_URL="https://github.com/erdfern/config.git"

die() {
  echo "install: $*" >&2
  exit 1
}

print_usage() {
  echo "usage: install <host> [user@target] [--project <path>] [--ref <git-ref>] [--facter] [--yes] [-- extra args]" >&2
}

# Resolve the Nilla project directory to build from.
resolve_project() {
  if [ -n "${opt_project:-}" ]; then
    printf '%s\n' "$opt_project"
    return
  fi
  if [ -n "${opt_ref:-}" ]; then
    echo ">> Fetching ${REPO_URL} @ ${opt_ref}" >&2
    nix-instantiate --eval --expr \
      "(builtins.fetchGit { url = \"${REPO_URL}\"; ref = \"${opt_ref}\"; }).outPath" |
      tr -d '"'
    return
  fi
  if [ -n "${NCONF_PROJECT:-}" ]; then
    printf '%s\n' "$NCONF_PROJECT"
    return
  fi
  if [ -e /etc/nconf/nilla.nix ]; then
    echo /etc/nconf
    return
  fi
  if git rev-parse --show-toplevel >/dev/null 2>&1; then
    git rev-parse --show-toplevel
    return
  fi
  echo .
}

confirm() {
  [ "${opt_yes:-0}" = 1 ] && return 0
  local ans
  printf '%s [y/N] ' "$1" >&2
  read -r ans || die "aborted"
  case "$ans" in
    [yY] | [yY][eE][sS]) return 0 ;;
    *) die "aborted" ;;
  esac
}

host=""
target=""
opt_project=""
opt_ref=""
opt_facter=0
opt_yes=0
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
    --ref)
      opt_ref="${2:?--ref needs a git ref}"
      shift 2
      ;;
    --facter)
      opt_facter=1
      shift
      ;;
    --yes | -y)
      opt_yes=1
      shift
      ;;
    --)
      shift
      extra+=("$@")
      break
      ;;
    -*)
      extra+=("$1") # unknown flag -> passthrough to nixos-anywhere
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

proj="$(resolve_project)"
[ -e "${proj}/nilla.nix" ] || die "no nilla.nix found at project '${proj}'"
# nilla-utils exposes each host as `systems.nixos.<host>.result` (a NixOS eval).
result_attr="systems.nixos.${host}.result"
build_attr="${result_attr}.config.system.build"

# --facter: capture a hardware report from a remote target into the repo, then stop.
if [ "$opt_facter" = 1 ]; then
  [ -n "$target" ] || die "--facter needs a target (user@host)"
  repo="$(git rev-parse --show-toplevel 2>/dev/null || true)"
  [ -n "$repo" ] || die "--facter must be run from inside the writable config repo"
  dest="${repo}/hosts/${host}/facter.json"
  echo ">> Capturing nixos-facter report from ${target} -> ${dest}" >&2
  ssh "$target" nixos-facter >"$dest"
  echo ">> Wrote ${dest}. Commit it, then re-run:  install ${host} ${target}" >&2
  exit 0
fi

if [ -n "$target" ]; then
  ###########
  # REMOTE  #  build on this (operator) machine, copy the closure over SSH
  ###########
  echo ">> Remote install of '${host}' onto '${target}' via nixos-anywhere" >&2
  echo "   project: ${proj}" >&2
  confirm "This will ERASE and reformat the disks on '${target}'. Continue?"
  mapfile -t paths < <(nix-build "${proj}/nilla.nix" \
    -A "${build_attr}.diskoScript" \
    -A "${build_attr}.toplevel" \
    --no-out-link)
  exec nixos-anywhere --store-paths "${paths[@]}" "${extra[@]}" "$target"
fi

###########
# LOCAL   #  run from the installer ISO; format + install THIS machine
###########
# The live ISO's /nix/store is a RAM-backed tmpfs overlay (~50% of RAM), far too
# small for a desktop closure. The trick is to never realize that closure in the
# installer's store: `nixos-install` (by-attrset mode, `--file`/`--attr`) builds
# the system with `--store /mnt`, so the whole closure is built/substituted
# straight onto the freshly-formatted target disk. We must NOT pre-build the
# toplevel here -- doing so would fill RAM before nixos-install ever runs.
[ "$(id -u)" = 0 ] || die "local install must run as root (boot the installer ISO)"
echo ">> Local install of '${host}' onto THIS machine -- disks will be WIPED" >&2
echo "   project: ${proj}" >&2
confirm "This will ERASE and reformat THIS machine's disks. Continue?"

echo ">> Partitioning with disko" >&2
disko="$(nix-build "${proj}/nilla.nix" -A "${build_attr}.diskoScript" --no-out-link)"
"$disko"

echo ">> Building + installing '${host}' directly into /mnt (substitutes from cache)" >&2
nixos-install \
  --file "${proj}/nilla.nix" \
  --attr "${result_attr}" \
  --root /mnt \
  --no-root-passwd \
  --no-channel-copy

echo ">> Done. Reboot into '${host}'." >&2
