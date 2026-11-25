# 🇪🇺 BLEUnlock LTS Privacy Policy

[English](PRIVACY.md) | [Français](PRIVACY.fr.md) | [Español](PRIVACY.es.md) | [Deutsch](PRIVACY.de.md) | [日本語](PRIVACY.ja.md) | [简体中文](PRIVACY.zh-Hans.md) | [Türkçe](PRIVACY.tr.md) | [Svenska](PRIVACY.sv.md) | [Dansk](PRIVACY.da.md) | [Norsk](PRIVACY.nb.md)

*Last updated: 2026-11-25. Applies to BLEUnlock LTS 3.x.*

> This document describes what the software does. It is a transparency statement, not legal advice or a legal certification.

## 1. Summary

- BLEUnlock LTS runs entirely on your Mac. There are no accounts, no analytics, no advertising, no tracking and no crash reporting.
- The maintainer does not operate any server for the app and does not receive, store or process personal data from it.
- The only network feature is an update check. It is **opt-in** and sends one HTTPS request to `api.github.com`, which can see your IP address (details in section 5).
- Your Mac login password is stored only if you choose the *Lock & Unlock* mode, in the macOS Keychain, on this device only. The *Lock only* mode never asks for or stores it.
- You can erase everything the app stores with one click: *Security → Erase All Data…*.

## 2. Who is responsible

- Maintainer: the GitHub account **Altissnono** ([profile](https://github.com/Altissnono), repository [BLEUnlock-LTS](https://github.com/Altissnono/BLEUnlock-LTS)). Original project by Takeshi Sone (MIT license).
- Because the app sends no personal data to the maintainer, the maintainer does not act as a data controller or processor for your data. The data described below stays under your control on your own Mac.
- The only third party involved is GitHub (section 10), and only when you opt in to update checks or download a release.

## 3. What the app processes

Everything in this table is processed locally on your Mac. Nothing in it is sent to the maintainer or to any server.

| Data | Purpose | Where it lives | Leaves your Mac? |
|---|---|---|---|
| Identifier (a CoreBluetooth UUID) of the Bluetooth device(s) you select, and its signal strength (RSSI) | Detect whether your device is near, to lock or unlock | Identifier in the app settings; signal values in memory only | No |
| Name, manufacturer, model and signal strength of nearby Bluetooth devices, **only while the Device menu is open** | Show the list so you can pick your device | Memory only, discarded after at least 30 seconds without a sighting and when the app quits | No |
| Your Mac login password (only in *Lock & Unlock* mode) | Type it on the lock screen | macOS Keychain, item service = the app's bundle identifier, "this device only" (not synced to iCloud) | No |
| Settings (thresholds, delays, options) | Configuration | App preferences file (see section 7) | No |
| Diagnostics: signal numbers, timers, lock decisions (no names, no identifiers, no password) | Troubleshooting | macOS unified log on your Mac, rotated automatically by macOS | No |
| Date of the last update check | Limit checks to once per day | App preferences file | No |
| Owner name and size of the front-most window (no content, no titles) | Make sure the lock screen is in front before typing the password | Not stored | No |
| Notifications you enabled (lock, unlock, update) | Inform you | Local macOS notifications | No |
| Optional script `event` that you write yourself | Your own automation | `~/Library/Application Scripts/io.github.altissnono.BLEUnlock/` | Only if your own script sends something |

## 4. What the app does not do

- No analytics, telemetry, usage statistics, A/B testing, advertising identifiers or fingerprinting.
- No crash reporting from the app. (macOS may offer to share diagnostics with Apple; that is a system setting under *Privacy & Security → Analytics & Improvements*, independent of this app.)
- No access to your contacts, calendar, photos, location, microphone, camera or files.
- No reading of the screen content and no Screen Recording permission. The window check reads only the owner name and size of windows.
- No sending of Bluetooth device names, identifiers or signal values anywhere.
- No account, login, e-mail address or phone number is ever requested.
- No third-party libraries or SDKs are included (the app uses only Apple system frameworks).

## 5. Network access

- By default the app **contacts no server**.
- **Update check (opt-in):** if you allow it at first launch or in *Options → Automatic Update Checks*, the app makes at most one request per day. If you press *Check for Updates* you trigger a single request yourself.
- The request is `GET https://api.github.com/repos/Altissnono/BLEUnlock-LTS/releases/latest`, with the headers `User-Agent: BLEUnlock-LTS` and `Accept: application/vnd.github+json`. No cookie, no account token, no version number, no device information and no setting is sent.
- GitHub necessarily sees your **IP address** and the time of the request, like any web server. The session is ephemeral (no cookies, no disk cache), redirects are refused, the response size is capped, and only the release tag name is read to compare version numbers.
- If the answer is invalid or the host differs from `api.github.com`, it is ignored.
- Links in the About box, the menu (*Privacy Policy*, *Download*) open in your browser only when you click them. Your browser then talks to GitHub under its own rules.
- There is no other network connection in the code. CI checks fail the build if any other host appears.

## 6. Permissions explained

- **Bluetooth:** needed to see your device's signal. While the Device menu is open the app also briefly connects to nearby devices whose signal is stronger than your minimum-signal setting, only to read the standard "Device Information" (manufacturer and model) so the list is readable. Nothing is stored or sent.
- **Accessibility** (only in *Lock & Unlock* mode): needed to type your password on the lock screen. The app does not read what is on screen.
- **Notifications:** optional, to tell you when the Mac was locked or unlocked or when an update exists.
- **Keychain:** stores your password in *Lock & Unlock* mode. The item is marked "this device only" and is not synchronized.
- **Login item:** optional "Launch at Login" uses the standard macOS service. *Erase All Data…* removes it.
- System files read: the Bluetooth cache of macOS (`/Library/Preferences/com.apple.Bluetooth.plist`, `/Library/Bluetooth/*.db`), read-only, to show device names and addresses in the list.

## 7. Preference keys (full inventory)

The app stores only these keys in `~/Library/Preferences/io.github.altissnono.BLEUnlock.plist`:

| Keys | Meaning |
|---|---|
| `mode` | Chosen mode: Lock & Unlock or Lock only |
| `device`, `device2` | Identifiers of the selected device and of the optional second device |
| `lockRSSI`, `unlockRSSI`, `thresholdRSSI`, `timeout`, `lockDelay`, `confirmDelay`, `maxUnlockAttempts`, `robustFilter`, `passiveMode` | Signal thresholds, delays, attempt limit, filter and scan mode |
| `wakeOnProximity`, `wakeWithoutUnlocking`, `pauseItunes`, `screensaver`, `sleepDisplay`, `lockOnSleep`, `lockOnBluetoothOff`, `verifyFrontWindow` | Behaviour options you can switch on or off |
| `notifications`, `notifyOnUnlock`, `showRSSI`, `launchAtLogin` | Notification and display options |
| `updateChecks`, `lastUpdateCheck` | Your update-check consent and the date of the last check |

## 8. Where your data is and how to delete it

1. **Everything at once:** menu *Security → Erase All Data…*. It deletes the Keychain password, all preferences and the login item, then quits the app.
2. **Password only:** menu *Security → Remove Stored Password*, or switch to *Lock only* mode (the password is deleted after you confirm).
3. **Manually:** delete `~/Library/Preferences/io.github.altissnono.BLEUnlock.plist`, and the Keychain item named *BLEUnlock* in *Keychain Access*, then move the app to the Trash.
4. **Diagnostics log:** it is managed by macOS and expires automatically. To erase all system logs now, run `sudo log erase --all` in Terminal.
5. **Your own `event` script** in `~/Library/Application Scripts/io.github.altissnono.BLEUnlock/` is yours; the app never creates or deletes your script.

## 9. Retention

- Preferences and the Keychain item stay until you delete them (section 8).
- Signal values and nearby-device information live in memory and are discarded when the app quits (a listed device expires after at least 30 seconds without a sighting).
- The maintainer retains nothing, since nothing is received.

## 10. Third parties and international transfers

- **GitHub (GitHub, Inc., a Microsoft company, United States):** hosts the source code and releases and answers the optional update check. When you download a release or allow the update check, GitHub receives your IP address and processes it under its own terms and privacy statement. The maintainer has no control over this and receives none of that data.
- Because GitHub is a US company, such requests can involve a transfer of your IP address outside the EU/EEA. To avoid it entirely, keep update checks off and build the app from source (section 14).
- No other recipient exists: no analytics provider, no advertising network, no crash-reporting service, no cloud.

## 11. Legal basis and your rights (GDPR)

- **Update check:** your consent (Art. 6(1)(a) GDPR), which you can withdraw at any time in *Options → Automatic Update Checks* or by never pressing *Check for Updates*.
- **Local processing on your Mac:** the data in section 3 never reaches the maintainer. You are in control of it and can inspect or delete it (section 8).
- **Your rights** (access, rectification, erasure, restriction, portability, objection, Art. 15 to 21): the maintainer holds no data about you, so there is nothing to request from the maintainer; use the tools in section 8 on your own device.
- **Complaint:** you may lodge a complaint with your national data protection authority (for example the CNIL in France, the BfDI in Germany, the AEPD in Spain, the Datatilsynet in Denmark and Norway, the IMY in Sweden).
- This is a plain-language description, not legal advice. If you deploy the app in an organisation, you remain responsible for your own compliance assessment.

## 12. Security measures

- Hardened Runtime, no third-party code, and, from version 3.2.5 on, no debugger entitlement (checked on every build; earlier 3.x releases carried one by mistake).
- Password in the Keychain only, wiped from memory after typing, typed only when the lock screen is in front, with an attempt limiter and a confirmation delay.
- Update check hardened (host check, no redirects, size cap, tag validation).
- Full details and known limits: [SECURITY_AUDIT.md](SECURITY_AUDIT.md).

## 13. Children

- The app is not directed at children and collects no personal data from anyone.

## 14. How to verify these statements yourself

1. Read the source code: it is small (a few thousand lines) and public in the [repository](https://github.com/Altissnono/BLEUnlock-LTS).
2. Run `scripts/security-check.sh`: it fails if a host other than github.com appears, if a tracking SDK is referenced, if automatic network access is not opt-in, or if the privacy manifest declares tracking or collected data. It runs on every push (CI).
3. Inspect the built app: `scripts/verify-build.sh /Applications/BLEUnlock.app` checks entitlements and linked libraries.
4. Watch the network: with Little Snitch, LuLu or `nettop -p <pid>` you will see no connection unless you trigger an update check.
5. Build it yourself with Xcode from the source; no binary from the maintainer is required.
6. Read the Apple privacy manifest in the app (`PrivacyInfo.xcprivacy`): no tracking, no collected data types.

## 15. Changes to this policy

- Changes are made in this repository; the Git history shows exactly what changed and when. The date at the top is updated with each change.
- If a future version adds any data collection or network feature, it will be described here before release and will be opt-in.

## 16. Contact

- Questions about this policy: open an issue at <https://github.com/Altissnono/BLEUnlock-LTS/issues>. Please do **not** post personal data there.
- Languages: this policy is available in English, French, Spanish, German, Japanese, Simplified Chinese, Turkish, Swedish, Danish and Norwegian. If translations differ, the English version prevails.
