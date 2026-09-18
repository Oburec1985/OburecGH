#!/usr/bin/env bash
# Install a self-contained RecorderLnx bundle without consulting network repositories.
set -euo pipefail

fail() {
  printf 'Offline installation failed: %s\n' "$*" >&2
  exit 1
}

command -v apt-get >/dev/null 2>&1 || fail 'apt-get is required (Debian/Astra Linux).'
command -v dpkg-deb >/dev/null 2>&1 || fail 'dpkg-deb is required.'
command -v dpkg >/dev/null 2>&1 || fail 'dpkg is required.'
command -v sha256sum >/dev/null 2>&1 || fail 'sha256sum is required.'

bundle_dir=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd -P)
cd "$bundle_dir"
[[ -f manifest.sha256 ]] || fail 'manifest.sha256 is missing from the bundle.'
[[ -f target.env ]] || fail 'target.env is missing from the bundle.'
[[ -f Packages && -f Packages.gz ]] || fail 'Local APT index is missing from the bundle.'
[[ -d deps ]] || fail 'deps/ is missing from the bundle.'

target_field() {
  local key=$1
  local count
  count=$(awk -F= -v key="$key" '$1 == key { n++ } END { print n+0 }' target.env)
  (( count == 1 )) || fail "target.env must contain exactly one $key entry."
  awk -F= -v key="$key" '$1 == key { print substr($0, length(key)+2) }' target.env
}

target_id=$(target_field ID)
target_version=$(target_field VERSION_ID)
target_arch=$(target_field ARCH)
[[ -n "$target_id" && -n "$target_version" && -n "$target_arch" ]] ||
  fail 'target.env has an empty ID, VERSION_ID, or ARCH.'
[[ -r /etc/os-release ]] || fail '/etc/os-release is missing on this computer.'
# /etc/os-release is a trusted operating-system file.
source /etc/os-release
host_id=${ID:-linux}
host_version=${VERSION_ID:-unknown}
host_arch=$(dpkg --print-architecture)
[[ "$target_id" == "$host_id" && "$target_version" == "$host_version" &&
   "$target_arch" == "$host_arch" ]] ||
  fail "Bundle targets $target_id $target_version $target_arch, but this computer is $host_id $host_version $host_arch."

shopt -s nullglob
main_debs=(recorderlnx_*.deb)
(( ${#main_debs[@]} == 1 )) || fail "Expected exactly one recorderlnx_*.deb; found ${#main_debs[@]}."
dependency_debs=(deps/*.deb)
(( ${#dependency_debs[@]} > 0 )) || fail 'deps/ contains no .deb packages.'

packages=("${main_debs[@]}" "${dependency_debs[@]}")
for package in "${packages[@]}"; do
  [[ -f "$package" ]] || fail "Missing package: $package"
  awk -v path="$package" '$2 == path { found=1 } END { exit !found }' manifest.sha256 ||
    fail "Package is absent from manifest.sha256: $package"
  dpkg-deb --field "$package" Package >/dev/null || fail "Invalid Debian package: $package"
done
for index_file in target.env Packages Packages.gz; do
  awk -v path="$index_file" '$2 == path { found=1 } END { exit !found }' manifest.sha256 ||
    fail "$index_file is absent from manifest.sha256."
done
manifest_entries=$(awk 'END { print NR }' manifest.sha256)
(( manifest_entries == ${#packages[@]} + 3 )) ||
  fail "manifest.sha256 contains an unexpected number of entries."

# --strict also rejects malformed checksum lines; all bundle files are checked
# before apt is allowed to change the installed system.
sha256sum --check --strict --status manifest.sha256 ||
  fail 'A bundled file is missing or has a different SHA-256 checksum.'

if (( EUID != 0 )); then
  command -v sudo >/dev/null 2>&1 || fail 'Run this script as root (sudo is unavailable).'
  exec sudo -- "$bundle_dir/$(basename -- "${BASH_SOURCE[0]}")" "$@"
fi

# The only APT source is the file repository inside this verified bundle.
apt_root=$(mktemp -d)
trap 'rm -rf -- "$apt_root"' EXIT
mkdir -p "$apt_root/lists/partial" "$apt_root/sourceparts"
printf 'deb [trusted=yes] file:%s ./\n' "$bundle_dir" > "$apt_root/sources.list"
apt_options=(
  -o "Dir::Etc::sourcelist=$apt_root/sources.list"
  -o "Dir::Etc::sourceparts=$apt_root/sourceparts"
  -o "Dir::State::lists=$apt_root/lists"
  -o APT::Get::List-Cleanup=0
  -o Acquire::Retries=0
)
package_version=$(dpkg-deb --field "${main_debs[0]}" Version)
if ! apt-get "${apt_options[@]}" update > "$apt_root/update.log" 2>&1; then
  cat "$apt_root/update.log" >&2
  fail 'Could not read the bundled APT index.'
fi

printf 'Checking local package dependencies...\n'
if ! apt-get "${apt_options[@]}" --no-download --no-install-recommends \
  --no-remove --simulate install "recorderlnx=$package_version" \
  > "$apt_root/simulation.log" 2>&1; then
  cat "$apt_root/simulation.log" >&2
  fail 'Dependencies cannot be resolved from installed packages and deps/*.deb. Rebuild the bundle for this Linux release and architecture.'
fi
if grep -q '^Remv ' "$apt_root/simulation.log"; then
  fail 'APT would remove an installed package.'
fi
if awk '/^Inst / && $2 != "recorderlnx" && $3 ~ /^\[/ { exit 1 }' \
  "$apt_root/simulation.log"; then :; else
  fail 'APT would upgrade a system package; installation was not started.'
fi

printf 'Installing RecorderLnx and bundled dependencies...\n'
DEBIAN_FRONTEND=noninteractive apt-get "${apt_options[@]}" \
  --no-install-recommends --no-remove --yes \
  install "recorderlnx=$package_version" ||
  fail 'apt could not install the local packages. See its error above.'

printf 'Offline installation completed. Run recorderlnx-install-check to verify application files.\n'
