#!/bin/zsh
# SPDX-License-Identifier: GPL-3.0-or-later
# Build only the UxPlay static receiver library used by MirrorAct.
set -euo pipefail

ROOT=${0:A:h:h}
UXPLAY_COMMIT=3dbf7ceee65932154e85a2f83963d53520a799fa
SRC=$ROOT/Vendor/UxPlay
BUILD=$ROOT/Vendor/uxplay-build

if [[ ! -d $SRC/.git ]]; then
  mkdir -p $SRC
  git -C $SRC init -q
  git -C $SRC remote add origin https://github.com/FDH2/UxPlay.git
fi
if [[ $(git -C $SRC rev-parse HEAD 2>/dev/null) != $UXPLAY_COMMIT ]]; then
  git -C $SRC fetch -q --depth 1 origin $UXPLAY_COMMIT
  git -C $SRC checkout -q --detach $UXPLAY_COMMIT
fi

cmake -S "$ROOT/Config/AirPlayOnly" -B "$BUILD" -DCMAKE_BUILD_TYPE=Release \
  -DNO_MARCH_NATIVE=ON -DCMAKE_OSX_DEPLOYMENT_TARGET=15.0 \
  -DCMAKE_OSX_ARCHITECTURES="${MIRRORACT_ARCH:-$(uname -m)}" \
  -DPKG_CONFIG_EXECUTABLE="$ROOT/Config/AirPlayOnly/pkg-config-openssl3.sh" \
  -DLIBCRYPTO="$(brew --prefix openssl@3)/lib/libcrypto.a" \
  > "$BUILD.log" 2>&1 || { cat "$BUILD.log"; exit 1; }
cmake --build "$BUILD" --target airplay -j 8 >> "$BUILD.log" 2>&1 \
  || { tail -60 "$BUILD.log"; exit 1; }

for lib in lib/libairplay.a lib/playfair/libplayfair.a lib/llhttp/libllhttp.a lib/dns_sd/libdnssd.a; do
  [[ -f $BUILD/$lib ]] || { echo "Missing: $BUILD/$lib"; exit 1; }
done
echo "UxPlay AirPlay library built: $BUILD"
