#!/bin/sh
# Collect the full APT dependency closure for a RecorderLnx .deb.
# Run on the same Debian/Astra release and architecture as the offline target.
set -eu

usage() {
  echo "Usage: $0 MAIN_DEB OUTPUT_DEPS_DIR" >&2
  exit 2
}

[ "$#" -eq 2 ] || usage
main_deb=$1
deps_dir=$2
[ -f "$main_deb" ] || { echo "Package not found: $main_deb" >&2; exit 1; }
for command in apt-get dpkg-deb dpkg mktemp cp find; do
  command -v "$command" >/dev/null 2>&1 || {
    echo "Required command is missing: $command" >&2
    exit 1
  }
done

package_arch=$(dpkg-deb -f "$main_deb" Architecture)
host_arch=$(dpkg --print-architecture)
if [ "$package_arch" != all ] && [ "$package_arch" != "$host_arch" ]; then
  echo "Package architecture $package_arch differs from this host ($host_arch)." >&2
  exit 1
fi

main_deb=$(cd "$(dirname "$main_deb")" && pwd -P)/$(basename "$main_deb")
mkdir -p "$deps_dir"
deps_dir=$(cd "$deps_dir" && pwd -P)
work_dir=$(mktemp -d)
trap 'rm -rf "$work_dir"' EXIT HUP INT TERM
: > "$work_dir/empty-dpkg-status"

# An empty dpkg status forces APT to download dependencies even if they happen
# to be installed on the build host. Recommends are intentionally excluded.
# APT itself resolves alternatives, versions, Pre-Depends, and transitive deps.
mkdir -p "$work_dir/archives/partial"

echo "Resolving dependencies from this host's configured APT repositories..."
if ! apt-get -o "Dir::State::status=$work_dir/empty-dpkg-status" \
    -o "Dir::Cache::archives=$work_dir/archives" \
    -o Debug::NoLocking=1 \
    -o APT::Install-Recommends=false -o APT::Install-Suggests=false \
    --yes --download-only install "$main_deb" chrony; then
  echo "Dependency download failed. Refresh/configure repositories for the target distribution and retry." >&2
  exit 1
fi

# A second APT pass must resolve solely from the downloaded cache. This catches
# missing archives before the output bundle is published.
if ! apt-get -o "Dir::State::status=$work_dir/empty-dpkg-status" \
    -o "Dir::Cache::archives=$work_dir/archives" \
    -o Debug::NoLocking=1 \
    -o APT::Install-Recommends=false -o APT::Install-Suggests=false \
    --yes --no-download --download-only install "$main_deb" chrony; then
  echo "Downloaded dependency set is incomplete; output was not updated." >&2
  exit 1
fi

count=$(find "$work_dir/archives" -maxdepth 1 -type f -name '*.deb' | wc -l)
if [ "$count" -eq 0 ]; then
  echo "APT produced no dependency archives; refusing an empty offline bundle." >&2
  exit 1
fi

# This directory is dedicated to the collector. Clear stale versions only
# after a complete, verified download, then publish the new package set.
find "$deps_dir" -maxdepth 1 -type f -name '*.deb' -exec rm -f -- {} +
cp "$work_dir/archives/"*.deb "$deps_dir/"
echo "Collected $count dependency packages in $deps_dir"
echo "Source release: $(. /etc/os-release && printf '%s %s' "${ID:-unknown}" "${VERSION_ID:-unknown}") ($host_arch)"
