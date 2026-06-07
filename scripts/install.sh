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

# On the installer the writable /nix/store is an overlay whose upper layer is a
# RAM-backed tmpfs (~50% of RAM). Building or substituting a full system closure
# there exhausts RAM long before nixos-install copies it to /mnt. After disko has
# formatted and mounted /mnt, give the build room on the freshly-formatted disk.
# Two strategies, in order of preference; both are no-ops on an on-disk machine:
#   1. Re-stack the /nix/store overlay with its writable upper on /mnt.
#   2. Fall back to a swapfile on /mnt so the RAM-backed store can spill to disk.
INSTALL_STORE=/mnt/.nconf-install-store
SWAPFILE=/mnt/.nconf-install-swap
STORE_RELOCATED=0
SWAP_ENABLED=0

# Read one comma-separated mount option ($1) out of the option string in $2.
mount_opt() { printf '%s' "$2" | tr ',' '\n' | sed -n "s/^$1=//p" | head -n1; }

# Strategy 1: stack a disk-backed overlay over /nix/store.
relocate_store_via_overlay() {
  local opts lower upper

  # The overlay is created in the initrd, so its recorded lowerdir/upperdir are
  # rooted at /sysroot (the future root) and are NOT rewritten for stage 2.
  opts="$(awk '$5=="/nix/store"{sep=0; for(i=6;i<=NF;i++) if($i=="-"){sep=i;break}; if(sep && $(sep+1)=="overlay") print $(sep+3)}' /proc/self/mountinfo | tail -n1)"
  [ -n "$opts" ] || return 1

  lower="$(mount_opt lowerdir "$opts")"
  lower="${lower%%:*}"      # the squashfs (read-only) layer
  upper="$(mount_opt upperdir "$opts")"
  lower="${lower#/sysroot}" # rewrite initrd paths to the live root
  upper="${upper#/sysroot}"
  [ -n "$lower" ] && [ -n "$upper" ] && [ -d "$lower" ] && [ -d "$upper" ] || return 1

  echo ">> Relocating the writable Nix store onto /mnt (was RAM-backed)" >&2
  mkdir -p "${INSTALL_STORE}/store" "${INSTALL_STORE}/work"
  # Preserve paths realized so far (e.g. the disko script) by copying the small
  # RAM upper to disk. We then use the squashfs as the ONLY lower -- reusing the
  # live, in-use RAM upper as a lower is undefined behavior in overlayfs.
  cp -a "${upper}/." "${INSTALL_STORE}/store/" 2>/dev/null || true
  if ! mount -t overlay overlay \
    -o "lowerdir=${lower},upperdir=${INSTALL_STORE}/store,workdir=${INSTALL_STORE}/work" \
    /nix/store; then
    rm -rf "$INSTALL_STORE" 2>/dev/null || true
    return 1
  fi
  STORE_RELOCATED=1
  # Restart the daemon so it serves the freshly re-stacked store.
  systemctl restart nix-daemon 2>/dev/null || true
  sleep 1
}

# Strategy 2: swapfile on /mnt; tmpfs store pages can then spill out of RAM.
add_swap_on_mnt() {
  local fstype avail_mib size_mib
  fstype="$(findmnt -no FSTYPE /mnt)"
  avail_mib="$(df -BM --output=avail /mnt | tail -1 | tr -dc '0-9')"
  # ~40% of free space, capped at 48 GiB, floored at 8 GiB.
  size_mib=$((avail_mib * 4 / 10))
  [ "$size_mib" -gt 49152 ] && size_mib=49152
  [ "$size_mib" -lt 8192 ] && size_mib=8192

  echo ">> Adding ${size_mib} MiB of swap on /mnt (${fstype}) for the build" >&2
  if [ "$fstype" = btrfs ]; then
    btrfs filesystem mkswapfile --size "${size_mib}m" "$SWAPFILE"
  else
    dd if=/dev/zero of="$SWAPFILE" bs=1M count="$size_mib" status=none
    chmod 600 "$SWAPFILE"
    mkswap "$SWAPFILE" >/dev/null
  fi
  swapon "$SWAPFILE"
  SWAP_ENABLED=1
}

# Make room for the build on disk when /nix/store is RAM-backed.
ensure_disk_build_space() {
  local fstype
  fstype="$(findmnt -no FSTYPE /nix/store 2>/dev/null || true)"
  case "$fstype" in
    overlay | tmpfs) ;;
    *)
      echo ">> /nix/store is on disk; building in place" >&2
      return 0
      ;;
  esac
  mountpoint -q /mnt || die "/mnt is not mounted (did disko run?)"
  relocate_store_via_overlay && return 0
  echo ">> overlay relocation unavailable; falling back to swap" >&2
  add_swap_on_mnt
}

# Drop the transient build store / swap so neither persists on the new disk.
cleanup_build_space() {
  if [ "${SWAP_ENABLED:-0}" = 1 ]; then
    swapoff "$SWAPFILE" 2>/dev/null || true
    rm -f "$SWAPFILE" 2>/dev/null || true
  fi
  if [ "${STORE_RELOCATED:-0}" = 1 ]; then
    umount /nix/store 2>/dev/null || umount -l /nix/store 2>/dev/null || true
    rm -rf "$INSTALL_STORE" 2>/dev/null || true
  fi
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
prefix="systems.nixos.${host}.result.config.system.build"

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
    -A "${prefix}.diskoScript" \
    -A "${prefix}.toplevel" \
    --no-out-link)
  exec nixos-anywhere --store-paths "${paths[@]}" "${extra[@]}" "$target"
fi

###########
# LOCAL   #  run from the installer ISO; format + install THIS machine
###########
[ "$(id -u)" = 0 ] || die "local install must run as root (boot the installer ISO)"
echo ">> Local install of '${host}' onto THIS machine -- disks will be WIPED" >&2
echo "   project: ${proj}" >&2
confirm "This will ERASE and reformat THIS machine's disks. Continue?"

trap cleanup_build_space EXIT

echo ">> Partitioning with disko" >&2
disko="$(nix-build "${proj}/nilla.nix" -A "${prefix}.diskoScript" --no-out-link)"
"$disko"

ensure_disk_build_space

echo ">> Building the system closure for '${host}' (substitutes from cache when available)" >&2
top="$(nix-build "${proj}/nilla.nix" -A "${prefix}.toplevel" --no-out-link)"

echo ">> Installing" >&2
nixos-install --no-root-passwd --no-channel-copy --root /mnt --system "$top"

echo ">> Done. Reboot into '${host}'." >&2
