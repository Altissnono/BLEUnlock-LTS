# 🇪🇺 BLEUnlock LTS

[English](README.md) | [Français](README.fr.md) | [Español](README.es.md) | [Deutsch](README.de.md) | [日本語](README.ja.md) | [简体中文](README.zh-Hans.md) | [Türkçe](README.tr.md) | [Svenska](README.sv.md) | [Dansk](README.da.md) | [Norsk](README.nb.md)

![CI](https://github.com/Altissnono/BLEUnlock-LTS/actions/workflows/test.yml/badge.svg)
[![Latest release](https://img.shields.io/github/v/release/Altissnono/BLEUnlock-LTS?display_name=tag&cacheSeconds=300)](https://github.com/Altissnono/BLEUnlock-LTS/releases/latest)
![GDPR friendly](https://img.shields.io/badge/%F0%9F%87%AA%F0%9F%87%BA-GDPR--friendly-003399?labelColor=FFCC00) ![No telemetry](https://img.shields.io/badge/telemetry-none-brightgreen) ![Languages](https://img.shields.io/badge/languages-10-informational)

BLEUnlock er et lille værktøj i menulinjen, der låser og låser din Mac op ud fra, hvor tæt din iPhone, Apple Watch eller en anden Bluetooth Low Energy-enhed er.

## Funktioner

- Ingen iPhone-app nødvendig: virker med iPhone, Apple Watch eller en hvilken som helst BLE-enhed med fast adresse.
- Låser Mac’en, når enheden går væk, og låser den op, når den vender tilbage.
- To tilstande: **Lås og lås op** eller **Kun lås** (ingen adgangskode gemmes, og tilladelsen Tilgængelighed er ikke nødvendig).
- Kalibreringsassistent, anden enhed (Watch og iPhone), robust signalfilter.
- Valgfrit: væk ved nærhed, sæt medier på pause, lås ved dvale eller når låget lukkes, lås når Bluetooth slås fra.
- Fås på 10 sprog.

## 🇪🇺 Privatliv og GDPR

- Ingen konti, ingen analyse, ingen reklamer og ingen nedbrudsrapporter. Alt bliver på din Mac.
- Opdateringstjekket er valgfrit: én HTTPS-forespørgsel til `api.github.com`, som ser din IP-adresse.
- Slet med ét klik: Sikkerhed → Slet alle data…
- Adgangskoden (kun i oplåsningstilstand) gemmes i macOS Nøglering, kun på denne enhed.
- Ingen tredjepartsafhængigheder, Hardened Runtime og enhedstest af sikkerhedslogikken.

> Dette beskriver appens tekniske adfærd, ikke en juridisk certificering. Detaljer: [PRIVACY.md](PRIVACY.da.md).

## Krav

- En Mac med Bluetooth Low Energy
- macOS 12 (Monterey) eller nyere
- iPhone, Apple Watch eller en anden BLE-enhed med fast adresse

## Installation

Hent zip-filen fra [Releases](https://github.com/Altissnono/BLEUnlock-LTS/releases), pak den ud, og flyt appen til Programmer.

> Appen er ikke notariseret: højreklik og vælg **Åbn** første gang (eller kør `xattr -dr com.apple.quarantine /Applications/BLEUnlock.app`). Kontroller zip-filen med `SHA256SUMS.txt` eller med attesteringen: `gh attestation verify BLEUnlock-<version>.zip --repo Altissnono/BLEUnlock-LTS`.

## Kom i gang

1. Åbn appen (låseikonet i menulinjen), og vælg en tilstand ved første start.
2. Tillad Bluetooth og underretninger. Tillad kun Tilgængelighed, hvis du vælger **Lås og lås op**.
3. Menu → **Enhed**: hold din iPhone eller Apple Watch tæt på Mac’en. Den kommer øverst på listen, vælg den.
4. Menu → **Nærhed** → **Kalibrer signal…**: følg de to trin (12 s tæt på, 12 s langt væk).
5. Valgfrit: **Anden enhed** for at overvåge både Watch og iPhone.
6. Test: gå væk, så låses Mac’en efter låseforsinkelsen.

## Godt at vide

- Bluetooth-signalet svinger meget (en Apple Watch kan hoppe 25 til 30 dB mellem to målinger). Hold tærsklerne mindst 10 dB fra værdierne for “tæt på” og “langt væk”. En signaltimeout under 5 s kan give forkerte låsninger.
- Oplåsning ved nærhed kan efterlignes af en person med det rette udstyr. Vælg **Kun lås** i følsomme miljøer.

## Mere information

- Fuld dokumentation (engelsk): [README.md](README.md)
- Privatlivspolitik: [PRIVACY.md](PRIVACY.da.md)
- Sikkerhedsgennemgang: [SECURITY_AUDIT.md](SECURITY_AUDIT.md)

---

MIT-licens. Oprindeligt projekt af [Takeshi Sone](https://github.com/ts1/BLEUnlock). Vedligeholdes af [Altissnono](https://github.com/Altissnono).
