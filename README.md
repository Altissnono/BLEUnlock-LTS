# BLEUnlock

## 🇪🇺 BLEUnlock LTS — privacy‑first, EU‑friendly proximity lock for macOS

*Not on the Mac App Store. Free and open source (MIT).*

![CI](https://github.com/Altissnono/BLEUnlock-LTS/actions/workflows/test.yml/badge.svg)
[![Latest release](https://img.shields.io/github/v/release/Altissnono/BLEUnlock-LTS?display_name=tag&cacheSeconds=300)](https://github.com/Altissnono/BLEUnlock-LTS/releases/latest)
[![Downloads](https://img.shields.io/github/downloads/Altissnono/BLEUnlock-LTS/total?cacheSeconds=300)](https://github.com/Altissnono/BLEUnlock-LTS/releases)

![GDPR friendly](https://img.shields.io/badge/%F0%9F%87%AA%F0%9F%87%BA-GDPR--friendly-003399?labelColor=FFCC00) ![No telemetry](https://img.shields.io/badge/telemetry-none-brightgreen) ![No third-party deps](https://img.shields.io/badge/dependencies-0-brightgreen) ![Hardened Runtime](https://img.shields.io/badge/Hardened%20Runtime-on-blue) ![Languages](https://img.shields.io/badge/languages-10-informational)

BLEUnlock LTS is a maintained fork of [ts1/BLEUnlock](https://github.com/ts1/BLEUnlock) (MIT) with modernized APIs, extra security hardening and more settings. See [What's new in LTS](#whats-new-in-lts).

BLEUnlock is a small menu bar utility that locks and unlocks your Mac by proximity of your iPhone, Apple Watch, or any other Bluetooth Low Energy device.

This document is also available in [Japanese (日本語版はこちら)](README.ja.md).

## Features

- No iPhone app is required
- Works with any BLE devices that periodically transmits signal from [static MAC address](#notes-on-mac-address)
- Unlocks your Mac for you when the BLE device is near your Mac, without entering password
- Locks your Mac when the BLE device is away from your Mac
- Optionally runs your own script upon lock/unlock
- Optionally wakes from display sleep
- Optionally pauses and unpauses music/video playback when you're away and back
- Password is securely stored in Keychain
- **Two modes**: *Lock & Unlock*, or *Lock only* — in lock-only mode no password is ever asked for or stored, and no Accessibility permission is needed
- Menu organised in *Device / Mode / Proximity / Security / Options* with SF Symbols
- Languages: English, Français, Español, Deutsch, 日本語, 简体中文, Türkçe, Svenska, Dansk, Norsk

## Requirements

- A Mac with Bluetooth Low Energy support
- macOS 12 (Monterey) or later
- iPhone 5s or newer, Apple Watch (all), or another BLE device that has [static MAC address](#notes-on-mac-address) and transmits signal periodically

## Installation

Download the zip file from [Releases](https://github.com/Altissnono/BLEUnlock-LTS/releases), unzip and move to the Applications folder.

> Releases are built by GitHub Actions and are **ad-hoc signed, not notarized**. On first launch, right-click the app and choose *Open* (or run `xattr -dr com.apple.quarantine /Applications/BLEUnlock.app`). Verify the download with `SHA256SUMS.txt` attached to each release, or build it yourself from source with Xcode.
> Each new build has a different signature, so macOS may ask you to grant Bluetooth/Accessibility again after an update.

## Setting up

On the first launch, it asks for the following permissions, which you must grant:

Permission | Description
-----------|---
Bluetooth | Obviously, Bluetooth access is required. Choose *OK*.
Accessibility | This is required to unlock the locked screen. Click *Open System Preferences*, click the lock icon on the bottom left to unlock, and turn on BLEUnlock.
Keychain | (Not always asked) If asked, you have to choose **Always Allow** because it is required while the screen is locked.
Notification | (Optional) BLEUnlock shows a message on the lock screen when it locks the screen. It is helpful to know if it's working properly. Additionally, to see the message on the lock screen, you need to set *Show previews* to *always* in the *Notification* preference pane. 

> NOTE: The number of permissions required increases with each version of macOS, so if you are using an older OS, you may not be asked for one or more permissions.

Then it asks your login password to unlock the lock screen.
It will be stored safely in Keychain. 

Finally, from the menu bar icon, select *Device*.
It starts scanning nearby BLE devices.
Select your device, and you're done!

## Options

Option | Description
-------|---
Lock Screen Now | It locks the screen regardless of whether the BLE device is nearby or not; it will unlock once the BLE device moves away and then moves closer again. This is useful to ensure that the screen is locked before you leave your seat.
Unlock RSSI | Bluetooth signal strength to unlock. Larger value indicates that the BLE device needs to be closer to the Mac to unlock. Choose *Disable* to disable unlocking.
Lock RSSI | Bluetooth signal strength to lock. Smaller value indicates that the BLE device needs to be farther away from the Mac to lock. Choose *Disable* to disable locking.
Delay to Lock | Duration of time before it locks the Mac when it detects that the BLE device is away. If the BLE device comes closer within that time, no lock will occur.
No-Signal Timeout | Time between last signal reception and locking. If you experience frequent "Signal is lost" locking, increase this value.
Wake on Proximity | Wakes up the display from sleep when the BLE device approaches while locking.
Wake without Unlocking | BLEUnlock will not unlock the Mac when the display wakes up from sleep, whether automatically via "Wake on Proximity" or manually. This allows for compatibility with the macOS built-in unlock with Apple Watch feature (which can operate immediately after BLEUnlock wakes the screen), or if you just prefer the lock screen to appear more quickly but don't want it to auto-unlock.
Pause "Now Playing" while Locked | On lock/unlock, BLEUnlock pauses/unpauses playback of music or video (including Apple Music, QuickTime Player and Spotify) that is controlled by *Now Playing* widget or the ⏯ key on the keyboard.
Use Screensaver to Lock | If this option is set, BLEUnlock launches screensaver instead of locking. For this option to work properly, you need to set *Require password **immediately** after sleep or screen saver begins* option in *Security & Privacy* preference pane.
Turn Off Screen on Lock | Turn off the display immediately when locking.
Set Password... | If you changed your login password, use this.
Passive Mode | By default it actively tries to connect to the BLE device and read the RSSI. Most of the time, the default is recommended and works stably. However, if you are using other Bluetooth things like keyboard, mouse, track pad or most notably Bluetooth Personal Hotspot, the default mode may interfere with each other. 2.4GHz WiFi may interfere as well. If you are experiencing instability of Bluetooth, turn on Passive Mode.
Launch at Login | Launches BLEUnlock when you login.
Set Minimum RSSI | Devices with RSSI below this value will not be displayed in the device scan list.

## Troubleshooting

### Can't find my device in the list

If your BLE device is not from Apple, BLEUnlock may not able to find the device name.
If that is the case, your device is displayed as a UUID (long hexadecimal numbers and hyphens).
To identify the device, try moving the device closer to or farther away from the Mac and see if the RSSI (dB value) changes accordingly.

If you don't see *any* device in the list, try resetting the Bluetooth module as described below.

### It fails to unlock

Make sure BLEUnlock is turned on in *System Preferences* > *Security & Privacy* > *Privacy* > *Accessibility*.
If it is already on, try turning it off and on again.

If it asks for permission to access its own password in Keychain, you must choose *Always Allow*, because it is needed while the screen is locked.

### "Signal is lost" occurs frequently

Increase *No-Signal Timeout*.
Or try *Passive Mode*.

### My Bluetooth keyboard, mouse, Personal Hotspot, or whatever Bluetooth, went nuts!

Firstly, Shift + Option + Click the Bluetooth icon in the menubar or Control Center, then click *Reset the Bluetooth module*.

In macOS 12 Monterey, this option is no longer available.
Instead, type the command below in Terminal to reset the Bluetooth module:

```
sudo pkill bluetoothd
```

This command will ask your login password.

If the problem persists, turn on *Passive Mode*.

## Notes on MAC address

Unlike classic Bluetooth, Bluetooth Low Energy devices can use *private* MAC address.
That private address can be random, and can be changed from time to time.

Recent smart devices, both iOS and Android, tend to use private addresses that change every 15 minutes or so. This is probably to prevent tracking.

On the other hand, in order for BLEUnlock to track your device, its MAC address must be static.

Fortunately, on Apple devices, if you are signed in with the same Apple ID as your Mac, the MAC address is resolved to the true (public) address.

For other devices, including Android, the way to resolve the address is unknown.
If your non-Apple device changes its MAC address over time, unfortunately BLEUnlock can't support it.

To check if the MAC address is resolved correctly, compare the MAC address displayed in the *Device* scan list of BLEUnlock with the one that is displayed on your device.

## Run script on lock/unlock

On locking and unlocking, BLEUnlock runs a script located here:

```
~/Library/Application Scripts/io.github.altissnono.BLEUnlock/event
```

An argument is passed depending on the type of event:

|Event|Argument|
|-----|--------|
|Locked by BLEUnlock because of low RSSI|`away`|
|Locked by BLEUnlock because of no signal|`lost`|
|Unlocked by BLEUnlock|`unlocked`|
|Unlocked manually|`intruded`|

> NOTE: for `intruded` event works properly, you have to set *Require password **immediately** after sleep* in *Security & Privacy* preference pane.

### Example

Here is an example script which sends a LINE Notify message, with a photo of the person in front of the Mac when it is unlocked manually.

```sh
#!/bin/bash

set -eo pipefail

LINE_TOKEN=xxxxx

notify() {
    local message=$1
    local image=$2
    if [ "$image" ]; then
        img_arg="-F imageFile=@$image"
    else
        img_arg=""
    fi
    curl -X POST -H "Authorization: Bearer $LINE_TOKEN" -F "message=$message" \
        $img_arg https://notify-api.line.me/api/notify
}

capture() {
    open -Wa SnapshotUnlocker
    ls -t /tmp/unlock-*.jpg | head -1
}

case $1 in
    away)
        notify "$(hostname -s) is locked by BLEUnlock because iPhone is away."
        ;;
    lost)
        notify "$(hostname -s) is locked by BLEUnlock because signal is lost."
        ;;
    unlocked)
        #notify "$(hostname -s) is unlocked by BLEUnlock."
        ;;
    intruded)
        notify "$(hostname -s) is manually unlocked." $(capture)
        ;;
esac
```

`SnapshotUnlocker` is an .app created with Script Editor with this script:

```
do shell script "/usr/local/bin/ffmpeg -f avfoundation -r 30 -i 0 -frames:v 1 -y /tmp/unlock-$(date +%Y%m%d_%H%M%S).jpg"
```

This app is required because BLEUnlock does not have Camera permission.
Giving permission to this app resolves the problem.

## Credits

Original author: [Takeshi Sone (ts1)](https://github.com/ts1/BLEUnlock). Contributors to the original project:


- [peiit](https://github.com/peiit): Chinese translation
- [wenmin-wu](https://github.com/wenmin-wu): Minimum RSSI and moving average
- [stephengroat](https://github.com/stephengroat): CI
- [joeyhoer](https://github.com/joeyhoer): Homebrew Cask
- [Skyearn](https://github.com/Skyearn): Big Sur style icon
- [cyberclaus](https://github.com/cyberclaus): German, Swedish, Norwegian (Bokmål) and Danish localizations
- [alonewolfx2](https://github.com/alonewolfx2): Turkish localization
- [wernjie](https://github.com/wernjie): Wake without Unlocking
- [tokfrans03](https://github.com/tokfrans03): Language fixes


Icons are based on SVGs downloaded from materialdesignicons.com.
They are originally designed by Google LLC and licensed under Apache License version 2.0.

## License

MIT

Copyright © 2019-2022 Takeshi Sone. LTS modifications © 2026 Altissnono.


## 🇪🇺 Privacy, GDPR & EU

> This is a technical description of how the app behaves, not a legal certification.

- **Local‑only by design** — no account, no analytics, no ads, no crash reporting, no server run by the maintainer. Nothing about you is collected ([Privacy Policy / Politique de confidentialité](PRIVACY.md), EN + FR).
- **Data minimisation** — new **Lock only** mode never asks for or stores a password and needs no Accessibility permission.
- **Consent by default off** — the only network feature (update check, one HTTPS call to `api.github.com`) is **opt‑in**, refuses redirects, uses no cookies/cache and sends nothing but your IP address (as any web request does). CI fails if any other host appears in the code.
- **Right to erasure built in** — *Security → Erase All Data…* wipes the Keychain password, settings and login item in one click.
- **Privacy manifest** (`PrivacyInfo.xcprivacy`): no tracking, no collected data types.
- **EU languages** — English, Français, Español, Deutsch, Svenska, Dansk, Norsk (+ 日本語, 简体中文, Türkçe).
- **Independent identity** — bundle id `io.github.altissnono.BLEUnlock` (no upstream/third‑country identifiers).
- **Honest limits** — releases are hosted on GitHub (United States); downloading or checking for updates exposes your IP to GitHub. Build from source if you want zero contact. The app itself contacts no server in Asia or anywhere else.

| | |
|---|---|
| Third‑party code | **0** dependencies |
| Network hosts contacted | `api.github.com` only, opt‑in |
| Data sent | IP address only (inherent to HTTPS) |
| Data stored | Keychain password (unlock mode), settings, chosen device UUID — all local |
| Telemetry / tracking | none |

## What's new in LTS

### 3.2.3
- **Apple Watch reliability** (found from a real diagnostics log: a Watch's raw RSSI jumps by 25–30 dB between two readings):
  - A pending lock is now cancelled only when the signal recovers **5 dB above** the lock threshold (before, a signal hovering at the threshold kept cancelling the lock, so the Mac never locked).
  - "Device is close" (→ unlock) now needs **at least 2 of the last 3** readings above the unlock threshold, so a single spike can no longer unlock the Mac.
  - Unlock decisions are logged (which guard blocked, or "typing password"). 54 unit tests.

### 3.2.2
- **Local diagnostics:** key presence/lock decisions (signal numbers, timers, lock result) are written to the macOS unified log (subsystem `io.github.altissnono.BLEUnlock`, view with `log show --predicate 'subsystem == "io.github.altissnono.BLEUnlock"' --info --last 10m`). No device names/identifiers, passwords or personal data; nothing leaves the Mac.

### 3.2.1
- **Readable device lists** (*Device* and *Second Device*): iPhone / Apple Watch / iPad are listed first with icons, strongest signal on top; other named devices and anonymous ones (raw UUIDs) are folded into an *Other devices (N)* submenu. Apple model identifiers get readable names (e.g. `Watch7,5` → "Apple Watch (Watch7,5)"). Tip: hold your device next to the Mac — it jumps to the top. 49 unit tests.

### 3.2.0
- **Signal calibration assistant** (*Proximity → Calibrate Signal…*): measures the signal where you sit and where the Mac should lock (12 s each) and suggests the lock/unlock thresholds.
- **Second device** (*Second Device*): monitor an Apple Watch **and** an iPhone. The Mac unlocks when *either* is near and locks only when *both* are away.
- **Robust Signal Filter** (median instead of mean, off by default) to ignore isolated signal spikes/dropouts.
- **Lock When Mac Sleeps or Lid Closes** and **Lock When Bluetooth Turns Off** (both off by default). After a sleep lock the Mac is not auto-unlocked until you unlock it or the device leaves and returns.
- 44 unit tests (calibration, median filter, presence combination, …); all new texts translated in the 10 languages.
- Xcode project: automatic signing with the maintainer's team for local builds (CI still builds ad-hoc).

### 3.1.1
- **Reliability/security fix:** failed or unavailable Bluetooth signal readings (RSSI 127/0, read errors) were treated as "device is very close", which could keep the Mac unlocked or delay locking after the device left. They are now ignored, so the "No-Signal Timeout" locks the Mac as intended. Covered by unit tests (35 total).

### 3.1.0
- Release process: `scripts/release.sh X.Y.Z` bumps the version, runs the tests, tags and pushes; GitHub Actions then builds, attests and publishes (publishing on a plain push to `master` was removed: the workflow token cannot create tags on commits that modify workflow files).
- **Tests:** 33 unit tests for the security-critical logic (`swift test`, run in CI) + extended static checks.
- **Window check before typing:** the password is typed only if the lock screen is really in front (option *Security → Verify Lock Screen Before Typing*, on by default).
- **Release provenance:** releases carry a Sigstore build-provenance attestation — `gh attestation verify BLEUnlock-<version>.zip --repo Altissnono/BLEUnlock-LTS`. GitHub Actions pinned by commit SHA; `CODEOWNERS`.

### 3.0.0 — 🇪🇺 privacy release
- **Breaking:** new bundle identifier `io.github.altissnono.BLEUnlock` (replaces the upstream `jp.sone.*`). Settings, Keychain password, login item and the `event` script folder (`~/Library/Application Scripts/io.github.altissnono.BLEUnlock/`) start fresh — re‑select your device and re‑enter the password once.
- Update checks are now **opt‑in** (consent prompt), hardened (ephemeral session, no redirects, size/host checks), plus *Automatic Update Checks* toggle.
- **Erase All Data…**, **Privacy Policy** menu item, `PRIVACY.md` (EN/FR), privacy manifest.
- Signing/notarisation: `scripts/notarize-release.sh` and CI support for Developer ID + notarisation when repository secrets are set.
- CI checks extended (single allowed host, no tracking SDKs, opt‑in network, erase feature, privacy manifest).

### 2.0.1
- Update check reworked: the *Check for Updates* item now always answers with a dialog (update available / up to date / failed) and a *Download* button; an automatic check also adds an "Update Available" item to the menu. It no longer depends on notification permission.
- `SECURITY_AUDIT.md` (full audit) and `scripts/security-check.sh` (static security regression checks run in CI).
- SQLite lookups use bound parameters and a read-only database; text from nearby BLE devices is sanitised before display; fixed a manufacturer/model check bug.

### 2.0.0
**New**
- *Lock only* mode (no password stored, no Accessibility permission) alongside *Lock & Unlock*; chosen on first launch, switchable anytime from the **Mode** menu. Switching to lock-only deletes the stored password.
- Redesigned menu: grouped submenus with SF Symbols, status line, *Remove Stored Password*.
- New app icon (blue gradient, signal arcs).
- French and Spanish localizations; all new strings translated in every supported language.

**Security**
- Never types the password if the session is not on the console (fast user switching).
- Least privilege: Accessibility permission only requested when unlocking is enabled.
- Stored settings are range-checked (RSSI, delays); RSSI threshold input is validated.
- Release builds do not log to the console.

### 1.14.1
- About box shows the LTS name and fork copyright.

### 1.14.0
**Security**
- Auto-unlock lockout after N failed attempts (default 3 in 2 min) until you unlock manually.
- Unlock confirmation delay (0–10 s): the device must still be near before the password is typed.
- Optional `event` script only runs if owned by you and not group/world-writable.
- Password buffer wiped and freed after typing; Keychain item is `ThisDeviceOnly`; no force-unwraps.
- Removed the unused Apple Events entitlement; update check validates the release tag.

**Customization**: signal strength in the menu bar, notification toggles, "Check for Updates".

### 1.13.0
- `UserNotifications`, `SMAppService`, no deprecated APIs; update checker points to this fork; macOS 12+.

---
Maintained by [Altissnono](https://github.com/Altissnono). Original project by [Takeshi Sone](https://github.com/ts1/BLEUnlock).
