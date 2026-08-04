# update-vscode-insiders [--project <path>]
#
# Pin the latest VS Code Insiders build into packages/vscode-insiders/meta.json.
# Queries the official update API for the commit and the tarball's sha256, so no
# download is needed; the package fetches the commit-pinned (immutable) URL.
# Rebuild/switch afterwards to pick the new build up.

die() {
  echo "update-vscode-insiders: $*" >&2
  exit 1
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

opt_project=""
while [ "$#" -gt 0 ]; do
  case "$1" in
    --project)
      [ "$#" -ge 2 ] || die "--project needs an argument"
      opt_project="$2"
      shift 2
      ;;
    -h | --help)
      echo "usage: update-vscode-insiders [--project <path>]" >&2
      exit 0
      ;;
    *)
      die "unknown argument: $1"
      ;;
  esac
done

project="$(resolve_project)"
meta="$project/packages/vscode-insiders/meta.json"
[ -f "$meta" ] || die "no meta.json at $meta"

api="https://update.code.visualstudio.com/api/update/linux-x64/insider/latest"
resp="$(curl -fsSL "$api")" || die "failed to query $api"

commit="$(jq -er .version <<<"$resp")" || die "no .version in API response"
product_version="$(jq -er .productVersion <<<"$resp")" || die "no .productVersion in API response"
sha256="$(jq -er .sha256hash <<<"$resp")" || die "no .sha256hash in API response"

old_version="$(jq -r '.productVersion // "none"' "$meta")"
old_commit="$(jq -r '.commit // "none"' "$meta")"

if [ "$commit" = "$old_commit" ]; then
  echo "vscode-insiders already at $product_version ($commit)"
  exit 0
fi

jq -n \
  --arg productVersion "$product_version" \
  --arg commit "$commit" \
  --arg sha256 "$sha256" \
  '{ productVersion: $productVersion, commit: $commit, sha256: $sha256 }' \
  >"$meta"

echo "vscode-insiders: $old_version -> $product_version"
echo "         commit: $old_commit -> $commit"
