#!/bin/zsh
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
PROJECT_PATH="$ROOT_DIR/FlashCards.xcodeproj"
DERIVED_DATA_PATH="$ROOT_DIR/.derivedData-iphoneos"
RELEASE_DIR="$ROOT_DIR/release"
APP_PATH="$DERIVED_DATA_PATH/Build/Products/Release-iphoneos/FlashCards.app"
IPA_PATH="$RELEASE_DIR/FlashCards-sideload.ipa"
CHECKSUM_PATH="$RELEASE_DIR/FlashCards-sideload.ipa.sha256"

mkdir -p "$RELEASE_DIR"

xcodebuild \
  -project "$PROJECT_PATH" \
  -scheme FlashCards \
  -configuration Release \
  -derivedDataPath "$DERIVED_DATA_PATH" \
  -destination 'generic/platform=iOS' \
  CODE_SIGNING_ALLOWED=NO \
  build

TMP_DIR="$(mktemp -d /tmp/flashcards-release.XXXXXX)"
trap 'rm -rf "$TMP_DIR"' EXIT

mkdir -p "$TMP_DIR/Payload"
cp -R "$APP_PATH" "$TMP_DIR/Payload/FlashCards.app"
ditto -c -k --sequesterRsrc --keepParent "$TMP_DIR/Payload" "$IPA_PATH"
shasum -a 256 "$IPA_PATH" > "$CHECKSUM_PATH"

echo "Created:"
echo "  $IPA_PATH"
echo "  $CHECKSUM_PATH"
