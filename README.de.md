# 🇪🇺 BLEUnlock LTS

[English](README.md) | [Français](README.fr.md) | [Español](README.es.md) | [Deutsch](README.de.md) | [日本語](README.ja.md) | [简体中文](README.zh-Hans.md) | [Türkçe](README.tr.md) | [Svenska](README.sv.md) | [Dansk](README.da.md) | [Norsk](README.nb.md)

![CI](https://github.com/Altissnono/BLEUnlock-LTS/actions/workflows/test.yml/badge.svg)
[![Latest release](https://img.shields.io/github/v/release/Altissnono/BLEUnlock-LTS?display_name=tag&cacheSeconds=300)](https://github.com/Altissnono/BLEUnlock-LTS/releases/latest)
![GDPR friendly](https://img.shields.io/badge/%F0%9F%87%AA%F0%9F%87%BA-GDPR--friendly-003399?labelColor=FFCC00) ![No telemetry](https://img.shields.io/badge/telemetry-none-brightgreen) ![Languages](https://img.shields.io/badge/languages-10-informational)

BLEUnlock ist ein kleines Menüleisten-Programm, das Ihren Mac je nach Nähe Ihres iPhones, Ihrer Apple Watch oder eines anderen Bluetooth-Low-Energy-Geräts sperrt und entsperrt.

## Funktionen

- Keine iPhone-App nötig: funktioniert mit iPhone, Apple Watch oder jedem BLE-Gerät mit fester Adresse.
- Sperrt den Mac, wenn sich Ihr Gerät entfernt, und entsperrt ihn bei Rückkehr.
- Zwei Modi: **Sperren & Entsperren** oder **Nur sperren** (kein Passwort gespeichert, keine Bedienungshilfen-Berechtigung).
- Kalibrierungsassistent, zweites Gerät (Watch und iPhone), robuster Signalfilter.
- Optional: Aufwecken bei Annäherung, Medien pausieren, Sperren beim Ruhezustand oder Zuklappen, Sperren bei ausgeschaltetem Bluetooth.
- In 10 Sprachen verfügbar.

## 🇪🇺 Datenschutz und DSGVO

- Keine Konten, keine Analyse, keine Werbung, keine Absturzberichte. Alles bleibt auf Ihrem Mac.
- Die Update-Suche ist freiwillig: eine HTTPS-Anfrage an `api.github.com`, die Ihre IP-Adresse sieht.
- Löschen mit einem Klick: Sicherheit → Alle Daten löschen…
- Das Passwort (nur im Entsperr-Modus) liegt im macOS-Schlüsselbund, nur auf diesem Gerät.
- Keine Drittanbieter-Abhängigkeiten, Hardened Runtime, Unit-Tests für die Sicherheitslogik.

> Dies beschreibt das technische Verhalten der App, keine rechtliche Zertifizierung. Details: [PRIVACY.md](PRIVACY.de.md).

## Voraussetzungen

- Ein Mac mit Bluetooth Low Energy
- macOS 12 (Monterey) oder neuer
- iPhone, Apple Watch oder anderes BLE-Gerät mit fester Adresse

## Installation

Laden Sie das Zip von [Releases](https://github.com/Altissnono/BLEUnlock-LTS/releases) herunter, entpacken Sie es und verschieben Sie die App in den Ordner Programme.

> Die App ist nicht notarisiert: Beim ersten Start mit Rechtsklick **Öffnen** wählen (oder `xattr -dr com.apple.quarantine /Applications/BLEUnlock.app`). Prüfen Sie das Zip mit `SHA256SUMS.txt` oder per Attestierung: `gh attestation verify BLEUnlock-<version>.zip --repo Altissnono/BLEUnlock-LTS`.

## Erste Schritte

1. Öffnen Sie die App (Schloss-Symbol in der Menüleiste) und wählen Sie beim ersten Start einen Modus.
2. Erlauben Sie Bluetooth und Mitteilungen. Bedienungshilfen nur erlauben, wenn Sie **Sperren & Entsperren** wählen.
3. Menü → **Gerät**: Halten Sie iPhone oder Apple Watch an den Mac. Das Gerät steht dann oben in der Liste, wählen Sie es aus.
4. Menü → **Nähe** → **Signal kalibrieren…**: Folgen Sie den zwei Schritten (12 s nah, 12 s weit).
5. Optional: **Zweites Gerät**, um Watch und iPhone zu überwachen.
6. Testen: Gehen Sie weg, der Mac sperrt nach der Sperrverzögerung.

## Gut zu wissen

- Das Bluetooth-Signal schwankt stark (eine Apple Watch kann zwischen zwei Messungen um 25 bis 30 dB springen). Halten Sie die Schwellenwerte mindestens 10 dB von den Werten für »nah« und »weit« entfernt. Ein Signal-Timeout unter 5 s kann zu Fehlsperren führen.
- Entsperren per Nähe kann von jemandem mit passender Ausrüstung nachgeahmt werden. Wählen Sie für sensible Umgebungen **Nur sperren**.

## Mehr

- Vollständige Dokumentation (Englisch): [README.md](README.md)
- Datenschutzerklärung: [PRIVACY.md](PRIVACY.de.md)
- Sicherheitsaudit: [SECURITY_AUDIT.md](SECURITY_AUDIT.md)

---

MIT-Lizenz. Ursprüngliches Projekt von [Takeshi Sone](https://github.com/ts1/BLEUnlock). Gepflegt von [Altissnono](https://github.com/Altissnono).
