#!/bin/bash
# Verifies the SIGNED build product (not just the source): usage scripts/verify-build.sh path/to/BLEUnlock.app
set -u
APP="${1:?usage: verify-build.sh path/to/BLEUnlock.app}"
fail=0
for target in "$APP" "$APP/Contents/Library/LoginItems/Launcher.app"; do
  [ -d "$target" ] || continue
  ents=$(codesign -d --entitlements - "$target" 2>&1)
  if echo "$ents" | grep -q "get-task-allow"; then echo "FAIL: $target carries get-task-allow (lets a debugger attach and read memory, e.g. the typed password)"; fail=1; else echo "ok:   $target has no debugger entitlement"; fi
  for bad in disable-library-validation allow-unsigned-executable-memory allow-dyld-environment-variables allow-jit; do
    echo "$ents" | grep -q "$bad" && { echo "FAIL: $target has $bad"; fail=1; }
  done
done
flags=$(codesign -dv "$APP" 2>&1 | grep -o "flags=0x[0-9a-f]*([^)]*)")
echo "$flags" | grep -q "runtime" && echo "ok:   hardened runtime ($flags)" || { echo "FAIL: hardened runtime missing ($flags)"; fail=1; }
codesign --verify --deep --strict "$APP" 2>&1 && echo "ok:   signature valid" || fail=1
libs=$(otool -L "$APP/Contents/MacOS/BLEUnlock" | tail -n +2 | grep -v "/usr/lib\|/System/Library\|@rpath" | grep -v "$APP")
[ -z "$libs" ] && echo "ok:   no non-system libraries linked" || { echo "FAIL: unexpected libraries: $libs"; fail=1; }
exit $fail
