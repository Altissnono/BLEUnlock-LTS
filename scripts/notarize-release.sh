#!/bin/bash
# Local Developer ID signing + notarisation + stapling. Produces build/BLEUnlock-<version>.zip
# Prerequisites (one time, done by the account owner — never put the password in this file):
#   1. Xcode → Settings → Accounts → Manage Certificates → "+" → Developer ID Application
#   2. xcrun notarytool store-credentials "bleunlock-notary" --apple-id <your Apple ID> --team-id <TEAMID>
#      (it asks for an app-specific password from appleid.apple.com, stored in your Keychain)
set -euo pipefail
cd "$(dirname "$0")/.."
PROFILE="${NOTARY_PROFILE:-bleunlock-notary}"
IDENTITY="${SIGN_IDENTITY:-Developer ID Application}"
security find-identity -v -p codesigning | grep -q "Developer ID Application" || { echo "No Developer ID Application certificate in your Keychain."; exit 1; }
rm -rf build && mkdir -p build
xcodebuild -project BLEUnlock.xcodeproj -scheme BLEUnlock -configuration Release \
  CONFIGURATION_BUILD_DIR="$PWD/build" CODE_SIGN_IDENTITY="$IDENTITY" CODE_SIGN_STYLE=Manual \
  OTHER_CODE_SIGN_FLAGS="--timestamp" build
APP=build/BLEUnlock.app
codesign --verify --deep --strict --verbose=2 "$APP"
VER=$(/usr/libexec/PlistBuddy -c 'Print CFBundleShortVersionString' "$APP/Contents/Info.plist")
ditto -c -k --keepParent "$APP" build/notarize.zip
xcrun notarytool submit build/notarize.zip --keychain-profile "$PROFILE" --wait
xcrun stapler staple "$APP"
spctl --assess --type execute --verbose "$APP"
ditto -c -k --keepParent "$APP" "build/BLEUnlock-$VER.zip"
shasum -a 256 "build/BLEUnlock-$VER.zip" | tee build/SHA256SUMS.txt
echo "Done: build/BLEUnlock-$VER.zip (signed, notarised, stapled)"
