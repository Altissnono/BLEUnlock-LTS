# Privacy Policy / Politique de confidentialité — BLEUnlock LTS

*Last updated: 2026-11-24 · applies to BLEUnlock LTS 3.x*

## English

**Summary:** BLEUnlock LTS runs entirely on your Mac. It has no accounts, no analytics, no advertising, no crash reporting and no server operated by the maintainer. The maintainer ("Altissnono") does not receive, store or process any personal data from the app.

### What the app processes (locally, on your Mac only)
| Data | Why | Where it is stored | Leaves the Mac? |
|---|---|---|---|
| Identifier (UUID), name and signal strength (RSSI) of the Bluetooth device you choose, and of nearby BLE devices while the device list is open | Detect proximity, show the device list | UUID of the chosen device in app settings (`UserDefaults`); everything else in memory only | **No** |
| Your Mac login password (only in *Lock & Unlock* mode) | Type it on the lock screen | macOS Keychain, "this device only" | **No** |
| Settings (thresholds, delays, options) | Configuration | `UserDefaults` | **No** |
| Optional user script `event` | Run your own automation | `~/Library/Application Scripts/` (yours) | Only if *your* script sends it |

*Lock only* mode never asks for or stores a password and does not need the Accessibility permission.

### Network access
- The app contacts **no server by default**.
- **Update check (opt-in):** if you allow it (first launch prompt, or *Options → Automatic Update Checks*), or when you press *Check for Updates*, the app sends one HTTPS request to `api.github.com` (GitHub, operated by GitHub, Inc., a Microsoft company, United States). GitHub sees your **IP address** and a generic `User-Agent: BLEUnlock-LTS`, as for any web request. No identifier, version, device information or setting is sent. Cookies and cache are disabled, redirects are refused, and the response is only read to compare a version number. Legal basis: your consent (Art. 6(1)(a) GDPR), revocable at any time. GitHub's own privacy statement applies to its processing.
- Links (About, Privacy Policy, Download) open in your browser **only when you click them**.
- There are no connections to any other host, in the EU or elsewhere (verified by static checks in CI: only `api.github.com` and `github.com` appear in the code).

### Your rights (GDPR Art. 15–21)
Because the maintainer holds no data about you, there is nothing to access, rectify or port at the maintainer. Everything is on your device and under your control:
- **Erasure:** *Security → Erase All Data…* deletes the Keychain password, all settings and the login item, then quits the app. You can also delete `~/Library/Preferences/io.github.altissnono.BLEUnlock.plist`.
- **Withdraw consent:** turn off *Automatic Update Checks* (or never press *Check for Updates*).
- **Minimise:** use *Lock only* mode.

### Distribution & source
Releases are built from this repository by GitHub Actions and published on GitHub Releases (GitHub, United States). Downloading from GitHub exposes your IP address to GitHub. You can build the app yourself from source and never contact GitHub from the app.

### Children
The app is not directed at children and collects no data.

### Contact
Open an issue at https://github.com/Altissnono/BLEUnlock-LTS/issues. Do **not** post personal data there.

## Français

**Résumé :** BLEUnlock LTS fonctionne entièrement sur votre Mac. Aucun compte, aucune analyse d’usage, aucune publicité, aucun rapport de plantage, aucun serveur du mainteneur. Le mainteneur (« Altissnono ») ne reçoit, ne stocke et ne traite aucune donnée personnelle issue de l’app.

**Données traitées (localement uniquement) :** identifiant, nom et puissance du signal (RSSI) de l’appareil Bluetooth choisi (et des appareils proches pendant l’affichage de la liste) ; mot de passe de session (mode *Verrouiller et déverrouiller* seulement, stocké dans le Trousseau macOS, « cet appareil uniquement ») ; réglages. Le mode *Verrouiller seulement* ne demande ni ne stocke aucun mot de passe.

**Réseau :** aucune connexion par défaut. **Recherche de mise à jour (opt‑in)** : si vous l’autorisez, ou si vous cliquez sur « Rechercher des mises à jour », l’app envoie une requête HTTPS à `api.github.com` (GitHub, Inc., société américaine du groupe Microsoft). GitHub voit votre **adresse IP**, comme pour toute requête web ; aucun autre identifiant, aucune donnée de l’appareil n’est transmis. Base légale : votre consentement (art. 6.1.a RGPD), retirable à tout moment. Aucune autre connexion (vérifié par des contrôles automatiques dans la CI).

**Vos droits :** *Sécurité → Effacer toutes les données…* supprime le mot de passe du Trousseau, tous les réglages et l’élément d’ouverture de session. Retirer le consentement : désactivez « Recherche automatique de mises à jour ». Minimisation : mode *Verrouiller seulement*.

**Contact :** https://github.com/Altissnono/BLEUnlock-LTS/issues (n’y publiez pas de données personnelles).
