#!/bin/zsh
# SPDX-License-Identifier: GPL-3.0-or-later
# Build one self-contained, ad hoc signed Apple Silicon app for private testing.
set -euo pipefail

ROOT=${0:A:h:h}
VERSION=$(sed -n 's/^ *MARKETING_VERSION: "\(.*\)"$/\1/p' "$ROOT/project.yml")
[[ -n $VERSION ]] || { echo '找不到版本號。' >&2; exit 1; }

DERIVED=${MIRRORACT_DERIVED:-$ROOT/build/DerivedData}
MIRRORACT_DERIVED=$DERIVED "$ROOT/scripts/build.sh" --no-install
APP=$DERIVED/Build/Products/Release/MirrorAct.app
[[ -d $APP ]] || { echo '找不到建置完成的 App。' >&2; exit 1; }
codesign --verify --deep --strict "$APP"
[[ $(lipo -archs "$APP/Contents/MacOS/MirrorAct") == arm64 ]] || {
  echo '此測試包目前只支援 Apple Silicon。' >&2
  exit 1
}

OUT=$ROOT/build/distribution
NAME=MirrorAct-zh-TW-$VERSION-macOS-arm64
STAGING=$OUT/$NAME
ZIP=$OUT/$NAME.zip
rm -rf -- "$STAGING" "$ZIP"
mkdir -p "$STAGING"
ditto "$APP" "$STAGING/MirrorAct.app"
cp "$ROOT/LICENSE" "$STAGING/LICENSE"
cp "$ROOT/README.md" "$STAGING/使用說明.md"
ditto -c -k --keepParent "$STAGING" "$ZIP"
codesign --verify --deep --strict "$STAGING/MirrorAct.app"
shasum -a 256 "$ZIP"
echo "測試安裝包：$ZIP"
