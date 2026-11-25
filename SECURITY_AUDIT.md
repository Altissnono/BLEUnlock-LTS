# SECURITY_AUDIT.md — BLEUnlock LTS 2.0.x

**Scope:** full source of this repository (≈1 900 lines of Swift / C / Objective‑C, 2 Xcode targets, 2 GitHub Actions workflows, release pipeline). Audit by static review of the actual code and flows, plus build and runtime checks of individual mechanisms (e.g. Keychain attribute behaviour).
**Method:** several passes (mapping → data flow → attacker profiles → tests → pipeline). Each finding carries a confidence level: **Confirmed** (read in code / reproduced), **Probable**, **Suspicion**, **Not verifiable** (with what is missing).
**Important framing:** BLEUnlock is a *local macOS menu‑bar utility*. It has **no server, no database, no user accounts, no HTTP API, no uploads, no web frontend**. Large parts of a generic web‑app audit checklist (SQLi on a backend, CSRF, IDOR, JWT, CORS, SSRF on user URLs, RBAC…) are **not applicable**; they are listed in the matrix as *N/A* rather than silently skipped. Nothing here is "proven secure": the residual risks below are inherent to the product idea (proximity = authentication).

---

# Executive Summary

| | |
|---|---|
| Overall posture | **Good for its category, with one inherent, unfixable design risk** (proximity‑based auth can be spoofed/relayed). |
| Critical findings | **0** |
| High | **1** (inherent: BLE proximity can be spoofed or relayed — *accepted / mitigated, not removable*) |
| Medium | **3** (2 fixed in this audit, 1 open: unsigned/non‑notarised distribution) |
| Low / Info | 8 |
| Automated tests | **None existed.** A static security regression script was added (`scripts/security-check.sh`, runs in CI). No XCTest target exists yet (see *Missing Tests*). |

Fixed during this audit (2.0.1): SQL built by string interpolation in `LEDeviceInfo.swift` (low practical risk, now bound parameters + read‑only open + finalised statements), untrusted BLE strings shown unsanitised in the menu, a copy‑paste logic bug (`device.model != nil && device.model != nil`), and missing least‑privilege / session guards on password typing (shipped in 2.0.0).

# Security Score

**7.0 / 10** (for a local utility that automates login).
- (+) Password only in Keychain, never logged/printed in release builds, buffer wiped; new *Lock only* mode stores nothing and asks for no Accessibility permission; auto‑unlock lockout; confirmation delay; console‑session guard; hardened runtime; no third‑party dependencies; no network except one HTTPS GitHub API read; no dangerous entitlements; event script permission check.
- (−) Proximity authentication is inherently weak (RSSI is forgeable/relayable); the app is **not sandboxed** and, when unlock is enabled, needs Accessibility (can post keystrokes system‑wide); distribution is ad‑hoc signed (no Developer ID / notarisation yet); no automated tests.

# Test Coverage Score

**1 / 10 at the time of the original audit (now ≈ 4/10, see the 3.1.0 addendum).** There was no test target. Only static regression checks (11 assertions, `scripts/security-check.sh`) and a CI build exist. Core logic (unlock state machine, RSSI averaging, attempt limiter, version comparison, string sanitiser) is untested.

---

# Architecture Review

```
Menu bar app (AppDelegate)  ──►  BLE (CoreBluetooth scan/RSSI, presence state machine)
   │  prefs (UserDefaults)         └─ LEDeviceInfo (read‑only SQLite of /Library/Bluetooth, name/MAC lookup)
   ├─ Keychain (generic password, ThisDeviceOnly)  [only in Lock & Unlock mode]
   ├─ CGEvent keystroke injection (Accessibility)  [only in Lock & Unlock mode]
   ├─ SACLockScreenImmediate / IOKit display sleep / MediaRemote (private)
   ├─ Optional user script  ~/Library/Application Scripts/<bundle>/event
   └─ Update check: HTTPS GET api.github.com (tag_name only)
Launcher.app (login item helper, macOS < 13)
CI: GitHub Actions (build + static checks) / Release (ad‑hoc signed zip + SHA256SUMS)
```

Trust boundaries: (1) nearby BLE radio environment → app (untrusted advertisements, names, RSSI); (2) filesystem user‑writable `event` script → process execution; (3) GitHub API → update notification (read‑only, validated); (4) lock‑screen session ↔ synthetic keystrokes.

Observations
- **Least privilege:** now honoured per mode (Lock only = no Accessibility, no password). Good.
- **Defence in depth:** lockout + confirmation delay + console check + screen‑locked re‑check immediately before typing.
- **Single point of trust:** RSSI. No second factor (see V‑01).
- **Not sandboxed:** required for CoreBluetooth‑at‑lock, CGEvent injection and private APIs; blast radius of a compromise of the app is the user account.

# Attack Surface

| Surface | Reachable by | Notes |
|---|---|---|
| BLE advertisements / GATT reads (name, manufacturer, model, iBeacon data) | Anyone within radio range | Parsed in `BLE.swift`. Lengths bounded; strings now sanitised. |
| BLE RSSI of the monitored device | Anyone able to transmit/relay | Drives lock/unlock decisions (V‑01). |
| `UserDefaults` (plist in `~/Library/Preferences`) | Same‑user processes | Values range‑checked on load (2.0.0). |
| Keychain item | Same‑user app (ACL = creating app) | Only in unlock mode. |
| `event` script | Same‑user processes | Executed only if regular file, owned by user, not group/world‑writable. |
| Synthetic keystrokes (CGEvent HID tap) | — (outgoing) | Must never land in a wrong window (V‑04). |
| `/Library/Bluetooth/*.db`, `com.apple.Bluetooth.plist` | System files, read‑only | Opened `SQLITE_OPEN_READONLY`; bound parameters. |
| HTTPS `api.github.com` | Network attacker (TLS) | Result only used for a "new version" notification; tag regex‑validated. |
| Release artifacts | GitHub / user download | Ad‑hoc signed, not notarised (V‑03). |

---

# Vulnerabilities

| ID | Sévérité | Statut | Catégorie | Composant | Description | Impact | Exploitabilité | Correction |
|---|---|---|---|---|---|---|---|---|
| V‑01 | **HIGH** (inherent) | Confirmed, accepted | Authentication design | `BLE.swift` presence/RSSI | Unlock decision rests on RSSI of a BLE device; advertisements can be cloned and signal relayed/amplified. | Physical‑proximity attacker may unlock the Mac. | Needs hardware, knowledge of device identifier, and physical access to the locked Mac. | Mitigations: confirmation delay, attempt lockout, *Lock only* mode, active (connected) mode preferred over passive. Not removable without changing the product. |
| V‑02 | **MEDIUM** | Fixed 2.0.1 | Injection (hardening) | `LEDeviceInfo.swift` | SQL built with `'\(uuid)'` interpolation; statements never finalised; DB opened read/write mode. | UUID comes from `CBPeripheral.identifier` (`UUID` type → hex only) so exploitation is **not realistic**, but the pattern is dangerous and leaked handles. | Very low | Bound parameters (`?1`), `sqlite3_finalize`, `SQLITE_OPEN_READONLY`. Static check forbids regression. |
| V‑03 | **MEDIUM** | Open | Supply chain / distribution | Release workflow | Release zip is ad‑hoc signed, not notarised; users must bypass Gatekeeper. Each build has a different code identity → TCC permissions reset. | Users trained to bypass Gatekeeper; no Apple malware scan. | Requires compromising repo/Actions | Developer ID signing + notarisation in CI (needs the owner's certificate + app‑specific password as GitHub secrets). SHA256SUMS already published. |
| V‑04 | **MEDIUM** | Mitigated | Keystroke injection | `fakeKeyStrokes` | Password is typed via global HID events. If the screen unlocks (or focus changes) between the check and the typing, the password lands in another app. | Password disclosure to a focused app / text field. | Narrow race window | Re‑check `isScreenLocked`, presence, and console‑session immediately before typing (done). Residual: the check and the typing are not atomic (*Probable*, low likelihood). |
| V‑05 | LOW | Fixed 2.0.1 | Input validation | `BLE.swift` | Manufacturer/model/name strings from arbitrary nearby devices were displayed verbatim (control chars, bidi override, unlimited length). | Menu‑item spoofing / UI clutter (e.g. a device named like another). | Anyone in BLE range | `sanitizeDeviceString` (strip controls + bidi overrides, 64 chars, 256‑byte read cap). |
| V‑06 | LOW | Fixed 2.0.1 | Logic bug | `BLE.swift` | `device.model != nil && device.model != nil` (should test `manufacture`). | GATT connection kept open longer than needed. | n/a | Corrected. |
| V‑07 | LOW | Open | Privilege | App (not sandboxed) | Runs with user privileges, unsandboxed; Accessibility allows posting keystrokes anywhere. | Compromise of the app = user‑level control. | Needs another vulnerability | Inherent; Lock only mode avoids the Accessibility grant. |
| V‑08 | LOW | Open | Private API | `MediaRemote` | Uses private framework symbols for pause/play. | Breakage on OS updates; no security impact known. | n/a | Keep behind the option; monitor releases. |
| V‑09 | LOW | Open | Same‑user tampering | `UserDefaults` | A same‑user process can change settings (e.g. set `maxUnlockAttempts` = 0, loosen RSSI). | Weakens mitigations. | Needs code execution as the user, at which point most protections are moot | Accepted; documented. |
| V‑10 | LOW | Open | CI hardening | Workflows | Third‑party actions pinned by tag (`actions/checkout@v4`), not commit SHA. | Supply‑chain risk if tag is moved. | Requires compromise of the action repo | Pin by SHA (Dependabot can maintain). |
| V‑11 | INFO | Confirmed | Logging | Debug builds | `print` statements exist; Release builds compile them out (2.0.0). No secret is ever printed (checked statically). | — | — | Kept; CI check forbids logging passwords. |
| V‑12 | INFO | Confirmed | Crypto | Keychain | No custom cryptography. Item uses `kSecAttrAccessibleWhenUnlockedThisDeviceOnly` (verified: accepted by the login Keychain). | — | — | — |
| V‑13 | INFO | Not verifiable | Update channel | `checkUpdate.swift` | HTTPS via `URLSession` default ATS; no pinning. Result only triggers a notification, no download/execute. | Spoofed "update available" text at worst. | Needs TLS break | Accepted. |

# Critical Findings

None confirmed.

# High Findings

### V‑01 — Proximity authentication can be spoofed or relayed (inherent)
- **Cause:** The only factor is "a BLE device with this identifier is within X dBm". RSSI is attacker‑influenceable; identifiers are observable for devices with static addresses (the README already warns that devices with rotating MACs don't work).
- **Exploit (in this project's context):** attacker with physical access to the locked Mac clones the advertising packets of the monitored device (or relays them from the real device kept elsewhere) and raises power until the averaged RSSI passes the unlock threshold; the app then types the stored password.
- **Components:** `BLE.updateMonitoredPeripheral`, `AppDelegate.tryUnlockScreen`.
- **Mitigations present:** moving‑average RSSI (5 samples), confirmation delay (0–10 s, device must still be near), max 3 auto‑unlock attempts / 2 min, active mode (GATT connection) rather than passive, *Lock only* mode which removes the unlock risk entirely.
- **Why not "fixed":** a second factor (e.g. require the unlock to be confirmed on the phone) would need an iPhone companion app — out of scope of a BLE‑beacon utility.
- **Recommendation:** document clearly (done in README); for high‑risk environments use *Lock only*.

# Medium Findings

- **V‑02** — see table; **fixed**. Practical exploitability is very low (UUID type), but string‑built SQL is a latent hazard; the CI script now fails the build if `sqlite3_prepare` is combined with interpolation.
- **V‑03** — Unsigned distribution. You said you have a paid Apple Developer account: the remaining work is (1) create a *Developer ID Application* certificate (Xcode → Settings → Accounts → Manage Certificates), (2) export it as `.p12`, (3) add `DEVELOPER_ID_P12`, `DEVELOPER_ID_P12_PASSWORD`, `APPLE_ID`, `APPLE_APP_PASSWORD`, `APPLE_TEAM_ID` as GitHub secrets, (4) extend `release.yml` to import the cert, sign with hardened runtime, `notarytool submit --wait`, `stapler staple`. Secrets must be entered by the owner.
- **V‑04** — Typing race. Guards: `unlockEnabled`, `isScreenLocked()`, `isSessionOnConsole()`, `ble.presence`, attempt limiter — all evaluated in the same run‑loop turn immediately before posting events. Residual window is microseconds; an additional check that the frontmost app is `loginwindow`/screensaver would be defence in depth but `NSWorkspace.frontmostApplication` is not reliable on the lock screen (**Not verifiable** without testing on every macOS version).

# Low Findings

V‑05 … V‑10 as in the table. V‑09 and V‑07 are accepted consequences of an unsandboxed per‑user app.

---

# Test Audit

- **Existing tests:** none (no XCTest target, no UI tests). CI previously only compiled the app (and, on the original upstream, with a signing configuration that could not work on a runner).
- **Added:** `scripts/security-check.sh` — 11 static assertions (no SQL interpolation, no password logging, no dangerous entitlements, hardened runtime on, no hard‑coded secrets, no plain‑HTTP URLs, no shell/AppleScript APIs, workflow permissions declared, presence of the event‑script ownership check, console‑session guard and unlock limiter). They are designed to fail if the corresponding protection is removed, but **this was not demonstrated for every rule** (only the first run was observed: it flagged a legitimate log line and a workflow without `permissions`, both fixed).
- **Limits:** these are grep‑level checks, not behavioural tests. They prove presence of controls, not correctness.

# Missing Tests

| Priority | Missing test |
|---|---|
| **Critical** | Unlock state machine: no typing when `unlockEnabled == false`, when screen not locked, when session not on console, when presence lost during confirmation delay. |
| **Critical** | Attempt limiter: N attempts → pause → notification once → reset on `onUnlock`; window expiry after 120 s. |
| **High** | Keychain: store/fetch/delete round‑trip; delete on switch to Lock only; fetch with missing item does not crash. |
| **High** | `runScript`: refuses group/world‑writable, symlink, wrong owner, directory. |
| **High** | RSSI estimator: bounded window, bouncing, `UNLOCK_DISABLED`/`LOCK_DISABLED` sentinels, positive RSSI clamp. |
| **High** | `sanitizeDeviceString`: control chars, RTL override, 10 000‑char input, empty, emoji/Unicode. |
| **Medium** | `isNewer` version comparison (`2.0.0` vs `2.0.10`, `v` prefix, pre‑release suffix, garbage tag). |
| **Medium** | Prefs clamping on load (RSSI, timeouts, delays) with hostile plist values. |
| **Medium** | `LEDeviceInfo` with hostile UUID strings (quotes, `;`, very long) returns nil without crash. |
| **Low** | Localisation completeness: every key in `Base.lproj` exists in every language. |
| **Low** | Menu construction in both modes (items hidden/visible). |

# Security Test Matrix

| Fonctionnalité | Auth | Authorization | Input validation | Abuse cases | Edge cases | Regression | Status |
|---|---|---|---|---|---|---|---|
| Auto‑unlock (typing password) | N/A (proximity) | N/A | n/a | Lockout, delay (code) | ✗ untested | static check only | Controls present, **no behavioural tests** |
| Lock on away | N/A | N/A | RSSI clamp | — | ✗ | ✗ | Untested |
| Keychain storage | OS ACL | OS | empty pw rejected | delete on mode switch | ✗ | ✗ | Untested |
| Event script | file owner/perm check | — | args constant | swap/symlink | ✗ | static check | Partially covered |
| BLE parsing | — | — | sanitiser, size caps | hostile advertisements | ✗ | ✗ | Untested |
| Update check | TLS | — | tag regex | spoofed tag | ✗ | ✗ | Untested |
| SQLite lookup | — | read‑only | bound param | hostile UUID | ✗ | static check | Partially covered |
| Release pipeline | token scoped `contents: write` | — | — | tag/version mismatch | — | — | Reviewed |

# Dependency Audit

- **Third‑party code dependencies: none** (system frameworks only: Cocoa, CoreBluetooth, Accelerate, SQLite3, Security, ServiceManagement, UserNotifications, IOKit, MediaRemote (private)). No package manager manifests, no vendored libraries → no known CVE surface from libraries.
- **CI dependencies:** `actions/checkout@v4` (tag‑pinned; V‑10). `gh` CLI preinstalled on runner.
- **Toolchain:** Xcode 27 / macOS 12+ deployment target; deprecated APIs removed in 1.13.
- `apple-device-names` is a build‑time helper script that reads `/System/Library/...`; not shipped, no network.

# Secrets Audit

- Source tree (current working tree, Swift/ObjC/plist/yaml): **no secrets, tokens or keys** (checked by regex in CI).
- The `release` script (legacy, local) takes the notarisation password from the `PASSWORD` environment variable; it contains an Apple ID e‑mail address and Team ID (not secrets). Git history of the fork contains upstream author e‑mails (already public).
- **Git history was not scanned for secrets exhaustively** with a dedicated tool (e.g. gitleaks): *Not verifiable here*; upstream history is public and long‑lived.
- Runtime: the only secret is the user's login password in the Keychain (unlock mode only).

# Configuration Audit

- Hardened Runtime: **on**; entitlements: **none** (empty dict) — the unused `apple-events` entitlement was removed in 1.14.
- App Sandbox: **off** (required by design).
- `Info.plist`: Bluetooth usage description present; no URL schemes registered (no inbound IPC through URL handlers); no `NSAppTransportSecurity` exceptions.
- Distribution: ad‑hoc signed (V‑03).
- Workflows: `release.yml` has `contents: write` (needed to create releases), runs on pushes to `master`/`v*` tags and `workflow_dispatch`; `test.yml` read‑only. Release step uses only `github.sha` / PlistBuddy output in shell, no untrusted PR input (`pull_request` triggers CI only, with no secrets).

# Business Logic Audit

No financial or multi‑user logic. State‑machine concerns reviewed:
- *Manual lock then immediate re‑unlock:* prevented by `manualLock` flag.
- *Wake‑on‑proximity retry loop:* timer cancelled on display wake; bounded by the display state.
- *Repeated wrong password:* handled by the attempt limiter (V‑01 mitigations); counter resets on any successful unlock.
- *Mode switching:* switching to Lock only deletes the stored password after confirmation and sets the effective unlock RSSI to disabled **without overwriting** the saved preference (switching back restores it). `setUnlockRSSI` can no longer re‑enable unlocking in Lock only mode.
- *Concurrency:* all state is touched from the main run loop (timers/notifications/CoreBluetooth with `queue: nil` = main). No background threads found → no data races identified (**Probable** — not formally verified with Thread Sanitizer).

# Attack Chains

1. **Radio spoof + dwell:** clone advertisements (V‑01) → raise RSSI → wait out confirmation delay → password typed. *Break the chain:* Lock only mode, long confirmation delay, low attempt limit.
2. **Same‑user malware → weakened settings:** write `maxUnlockAttempts=0`, lower RSSI (V‑09) → then chain 1 becomes easier. Needs prior code execution as the user.
3. **Planted `event` script:** requires write access to the user's Application Scripts folder → blocked by ownership/permission check unless the attacker already is the user.
4. **Supply chain:** compromise of repo/Actions → malicious release. Mitigations: SHA256SUMS, but no notarisation/SLSA provenance yet (V‑03, V‑10).

# Remediation Plan

| Priority | Action | Status |
|---|---|---|
| P0 | Notarised, Developer ID‑signed releases | Open — needs owner's certificate/secrets |
| P1 | XCTest target covering *Critical/High* missing tests | Open |
| P1 | Pin GitHub Actions by SHA + Dependabot | Open |
| P2 | Frontmost‑app check before typing (after cross‑OS testing) | Open |
| P2 | Provenance attestation for releases (`actions/attest-build-provenance`) | Open |
| Done | SQL bound params + read‑only DB; sanitised BLE strings; logic bug; lockout; console guard; least privilege; script permission check; static regression CI | ✔ |

# Recommended Security Tests

See *Missing Tests*. Also: manual red‑team test with a BLE spoofing tool (e.g. nRF Connect advertiser) against *passive* vs *active* mode to quantify V‑01 on current macOS; Thread Sanitizer and Address Sanitizer runs of the app; `gitleaks` on full history.

# Regression Tests

- Keep `scripts/security-check.sh` mandatory in CI (already wired in `.github/workflows/test.yml`).
- For each fixed item add a unit test once the XCTest target exists: V‑02 (hostile UUID), V‑05 (sanitiser), V‑06 (manufacturer/model both required), mode‑switch password deletion, `runScript` permission matrix.

# Final Assessment

For a local proximity‑unlock utility the implementation is **careful and small**, has no third‑party dependencies, no server surface, and the dangerous operations (password storage, keystroke injection, script execution) are now guarded at several layers and optional via *Lock only* mode. The **dominant risk is architectural** (RSSI as the sole factor, V‑01) and cannot be eliminated in code. The **largest engineering gap is the absence of automated behavioural tests** and the **lack of notarised distribution**. Items marked *Not verifiable* (git‑history secret scan, thread‑safety under sanitizers, frontmost‑app behaviour across macOS versions, real‑world BLE spoofing difficulty) were not claimed secure.

---

# Addendum — 3.0.0 privacy / EU review

- **Network inventory (confirmed by CI regex):** the code references only `github.com` (links opened in the browser on click) and `api.github.com` (update check). No other host, no SDK with network code, no tracking/analytics identifiers. *No endpoint in Asia or any other third country is contacted by the app.* The remaining third‑country exposure is **GitHub itself** (US) when the user opts in to update checks or downloads a release.
- **Data flow:** none leaves the device except the IP address with the opt‑in request. Update check: ephemeral `URLSession` (no cookie jar, no URL cache), redirects refused, host and status verified, body capped at 1 MB, tag regex‑validated.
- **Identity:** bundle id changed from the upstream `jp.sone.*` to `io.github.altissnono.*` (side effect: a one‑time reset of settings/Keychain/TCC for existing installs).
- **V‑03 (notarisation):** tooling now exists (`scripts/notarize-release.sh`, conditional CI steps). **Still open until the owner creates the Developer ID Application certificate and, for CI, the five repository secrets** — no certificate of that type is present on this Mac, so notarisation was **not performed or tested**.
- **New residual risks:** "Erase All Data" quits the app (intended); same‑user processes can still alter `updateChecks`/consent (V‑09 class). GDPR compliance as a legal status is **not asserted**: no DPIA/lawyer review was done.

---

# Addendum — 3.1.0 tests, provenance, window verification

**Tests (real, `swift test`, 33 tests, run in CI).** The pure security logic was extracted to `BLEUnlock/Core/` (compiled into the app *and* into a SwiftPM test target): unlock policy (`UnlockPolicy`), attempt limiter, front-window policy, prefs clamping, RSSI averaging, BLE string sanitiser, release-tag validation / version comparison, event-script guard, Keychain store, plus a localisation-completeness test (every language defines every key).
- **Mutation check actually performed:** I temporarily removed (a) the console-session guard, (b) the group-write check of the script guard, (c) the limiter threshold. Each mutation made at least one test fail (`testEveryGuardBlocks – session not on console`, `testRejectsGroupWritable`, `testAllowsUpToLimitThenDeniesOnceNotified`); sources were restored and the suite is green again. Other guards are covered by `testEveryGuardBlocks` by construction (one violated condition at a time) but were not each mutated individually.
- **Still untested:** the glue in `AppDelegate` (menus, timers, CGEvent posting, real lock screen), CoreBluetooth behaviour, notification delivery, the real HTTPS update call. Keychain tests skip themselves if the environment has no usable Keychain.
- **Test Coverage Score: 1/10 → ~4/10** (core decision logic covered; UI/OS integration not).

**Front-window verification (V‑04 hardening).** Immediately before typing, the front-most large on-screen window must belong to `loginwindow`/`ScreenSaverEngine`/`SecurityAgent`/`UserNotificationCenter`/`Window Server`; otherwise the password is not typed (setting *Security → Verify Lock Screen Before Typing*, default on). Only window metadata (owner name, size) is read — no Screen Recording permission. **Limits (honest):** the decision function is unit-tested, but the CoreGraphics query was **not** exercised on a real lock screen on every macOS version; if no qualifying window is found the check fails open (other guards still apply). If auto-unlock stops working after updating, turn this option off and report the macOS version.

**Supply chain (V‑10 closed).** All GitHub Actions are pinned to full commit SHAs (checked by `scripts/security-check.sh`). Releases now carry a signed **build-provenance attestation** (Sigstore, `actions/attest-build-provenance`); verify with `gh attestation verify BLEUnlock-<version>.zip --repo Altissnono/BLEUnlock-LTS`. *Not yet observed working end-to-end on GitHub at the time of writing.*

**Repository governance (open, needs the owner in GitHub settings).** Pushing to the repository is limited to the owner and invited collaborators; outside contributors can only open pull requests from forks. To *enforce* this, enable a branch ruleset on `master`: require pull request + status check `build`, block force pushes and deletions, require code-owner review (`.github/CODEOWNERS` is in place), and in Settings → Actions → General require approval for all outside collaborators.

---

# Addendum — 3.1.1 signal-reliability finding

**V‑14 — MEDIUM (reliability + security) — fixed in 3.1.1.** *Confirmed in the code, effect on real hardware not verified (no Apple Watch/iPhone available to test).*
- **Cause:** in `BLE.swift` every RSSI value `> 0` was rewritten to `0 dBm` ("strongest possible signal"), and `peripheral(_:didReadRSSI:error:)` ignored its `error` parameter. CoreBluetooth reports `127` when RSSI is unavailable and an undefined value when a read fails (e.g. device disconnected).
- **Impact:** a failed/unavailable read looked like "the device is touching the Mac": it cancelled the pending lock timer and reset the "signal lost" timer, and `lastReadAt` kept active mode alive. Result: the Mac may fail to lock after the device (e.g. a Watch) walked away, or treat a gone device as present for unlocking.
- **Fix:** `validRSSI()` (Core, unit-tested) accepts only −127…−1 dBm; failed or implausible reads are ignored — they no longer reset timers, so the existing "signal lost" timeout locks the Mac.
- **Residual:** a BLE tag that reports exactly 0 dBm legitimately would now be ignored (considered implausible). RSSI itself remains forgeable (V‑01).
