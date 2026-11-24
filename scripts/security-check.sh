#!/bin/bash
# Static regression checks for security properties (see SECURITY_AUDIT.md). Run in CI.
set -u
cd "$(dirname "$0")/.."
fail=0
check() { # description, command that must print nothing
  local out; out=$(eval "$2")
  if [ -n "$out" ]; then echo "FAIL: $1"; echo "$out"; fail=1; else echo "ok:   $1"; fi
}
SRC="BLEUnlock Launcher"
check "no SQL built by string interpolation" "grep -rnE 'sqlite3_prepare[^;]*\\\\\\(' BLEUnlock/*.swift"
check "password never printed/logged" "grep -rniE '(print|NSLog|os_log)\\(.*pass(word|wd)' BLEUnlock/*.swift | grep -v -e 'Password is not stored' -e 'Entering password'"
check "no dangerous entitlements" "grep -E 'disable-library-validation|allow-unsigned-executable-memory|allow-dyld-environment|get-task-allow|apple-events|network.server' BLEUnlock/BLEUnlock.entitlements Launcher/Launcher.entitlements"
check "hardened runtime enabled" "grep -c 'ENABLE_HARDENED_RUNTIME = YES' BLEUnlock.xcodeproj/project.pbxproj | grep -x 0"
check "no hardcoded secrets/keys" "grep -rnEi '(api[_-]?key|secret|token|BEGIN (RSA |EC )?PRIVATE KEY)[\"'\\'' ]*[:=]' $SRC --include=*.swift --include=*.m --include=*.plist"
check "no plain-http URLs" "grep -rn 'http://' $SRC --include=*.swift --include=*.m --include=*.plist | grep -v 'apple.com/DTDs'"
check "no shell execution APIs" "grep -rnE '/bin/(ba)?sh|NSTask|system\\(|popen\\(|NSAppleScript' $SRC --include=*.swift --include=*.m --include=*.c"
check "actions pinned by commit SHA" "grep -hn \"uses:\" .github/workflows/*.yml | grep -vE \"@[0-9a-f]{40}\" || true"
check "workflows declare permissions" "for f in .github/workflows/*.yml; do grep -q '^permissions:' \$f || echo \$f; done"
check "event script ownership check present" "grep -q 'ownerAccountID' BLEUnlock/Core/ScriptGuard.swift && grep -q 'isSafeToRunScript' BLEUnlock/AppDelegate.swift || echo missing"
check "console-session guard present" "grep -q 'isSessionOnConsole' BLEUnlock/AppDelegate.swift || echo missing"
check "unlock attempt limiter present" "grep -q 'allowUnlockAttempt' BLEUnlock/AppDelegate.swift || echo missing"
check "only github hosts are ever contacted (EU/GDPR: no other endpoints)" "grep -rnoE 'https?://[A-Za-z0-9.-]+' $SRC --include=*.swift --include=*.m --include=*.c | grep -vE 'https://(api\\.)?github\\.com' || true"
check "no analytics/tracking SDK references" "grep -rniE 'firebase|crashlytics|sentry|mixpanel|amplitude|google-analytics|appcenter|bugsnag|segment' $SRC BLEUnlock.xcodeproj/project.pbxproj --include=* 2>/dev/null | head"
check "automatic network access is opt-in" "grep -q 'forKey: \"updateChecks\"' BLEUnlock/checkUpdate.swift || echo missing"
check "redirects refused for update check" "grep -q 'completionHandler(nil)' BLEUnlock/checkUpdate.swift || echo missing"
check "erase-all-data feature present" "grep -q 'eraseAllData' BLEUnlock/AppDelegate.swift || echo missing"
check "privacy manifest declares no tracking/collection" "grep -A1 'NSPrivacyTracking<' BLEUnlock/PrivacyInfo.xcprivacy | grep -q false || echo missing"
check "no legacy upstream bundle id" "grep -rn 'jp\\.sone' BLEUnlock.xcodeproj BLEUnlock Launcher scripts | head"
exit $fail
