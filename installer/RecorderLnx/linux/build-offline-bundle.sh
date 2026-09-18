#!/bin/sh
set -eu

if [ "$#" -lt 1 ] || [ "$#" -gt 2 ]; then
  echo "Usage: $0 recorderlnx_VERSION_ARCH.deb [output.tar.gz]" >&2
  exit 2
fi

script_dir=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
main_deb=$(realpath -- "$1")
[ -f "$main_deb" ] || { echo "Package not found: $main_deb" >&2; exit 2; }

package=$(dpkg-deb -f "$main_deb" Package)
[ "$package" = recorderlnx ] || { echo "Expected recorderlnx package, got $package" >&2; exit 2; }
version=$(dpkg-deb -f "$main_deb" Version)
arch=$(dpkg-deb -f "$main_deb" Architecture)
. /etc/os-release
distro=${ID:-linux}
release=${VERSION_ID:-unknown}
output=${2:-"$(dirname -- "$main_deb")/recorderlnx-offline_${version}_${arch}_${distro}-${release}.tar.gz"}
stage=$(mktemp -d)
trap 'rm -rf -- "$stage"' EXIT HUP INT TERM

mkdir "$stage/deps"
cp -- "$main_deb" "$stage/"
cp -- "$script_dir/install-offline.sh" "$stage/"
chmod 755 "$stage/install-offline.sh"
sh "$script_dir/offline-deps.sh" "$main_deb" "$stage/deps"

(
  cd "$stage"
  printf 'ID=%s\nVERSION_ID=%s\nARCH=%s\n' "$distro" "$release" "$arch" > target.env
  dpkg-scanpackages . /dev/null > Packages
  expected=$((1 + $(find deps -maxdepth 1 -type f -name '*.deb' | wc -l)))
  indexed=$(grep -c '^Package:' Packages)
  [ "$indexed" -eq "$expected" ] || {
    echo "APT index has $indexed packages; expected $expected" >&2
    exit 1
  }
  gzip -n -9 -c Packages > Packages.gz
  sha256sum target.env Packages Packages.gz "$(basename -- "$main_deb")" \
    deps/*.deb > manifest.sha256
)
tar -C "$stage" -czf "$output" .
echo "Offline installer: $output"
