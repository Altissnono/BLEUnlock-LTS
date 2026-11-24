#!/bin/bash
# Usage: scripts/release.sh X.Y.Z   — bumps the version, commits, tags vX.Y.Z and pushes.
# GitHub Actions then builds, attests and publishes the release (the tag must be pushed by a person:
# the workflow token cannot create tags on commits that touch workflow files).
set -euo pipefail
cd "$(dirname "$0")/.."
VER="${1:?usage: scripts/release.sh X.Y.Z}"
[[ "$VER" =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]] || { echo "version must look like 3.2.0"; exit 1; }
[ -z "$(git status --porcelain)" ] || { echo "working tree not clean"; exit 1; }
git rev-parse "v$VER" >/dev/null 2>&1 && { echo "tag v$VER already exists"; exit 1; }
/usr/libexec/PlistBuddy -c "Set :CFBundleShortVersionString $VER" BLEUnlock/Info.plist
swift test --scratch-path "${TMPDIR:-/tmp}/bleunlock-swiftbuild" >/dev/null
./scripts/security-check.sh >/dev/null
git commit -am "Release $VER"
git tag "v$VER"
git push origin HEAD "v$VER"
echo "Pushed v$VER — watch https://github.com/Altissnono/BLEUnlock-LTS/actions"
