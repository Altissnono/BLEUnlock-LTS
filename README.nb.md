# 🇪🇺 BLEUnlock LTS

[English](README.md) | [Français](README.fr.md) | [Español](README.es.md) | [Deutsch](README.de.md) | [日本語](README.ja.md) | [简体中文](README.zh-Hans.md) | [Türkçe](README.tr.md) | [Svenska](README.sv.md) | [Dansk](README.da.md) | [Norsk](README.nb.md)

![CI](https://github.com/Altissnono/BLEUnlock-LTS/actions/workflows/test.yml/badge.svg)
[![Latest release](https://img.shields.io/github/v/release/Altissnono/BLEUnlock-LTS?display_name=tag&cacheSeconds=300)](https://github.com/Altissnono/BLEUnlock-LTS/releases/latest)
![GDPR friendly](https://img.shields.io/badge/%F0%9F%87%AA%F0%9F%87%BA-GDPR--friendly-003399?labelColor=FFCC00) ![No telemetry](https://img.shields.io/badge/telemetry-none-brightgreen) ![Languages](https://img.shields.io/badge/languages-10-informational)

BLEUnlock er et lite verktøy i menylinjen som låser og låser opp Macen din ut fra hvor nær iPhonen, Apple Watch eller en annen Bluetooth Low Energy-enhet er.

## Funksjoner

- Ingen iPhone-app nødvendig: fungerer med iPhone, Apple Watch eller en hvilken som helst BLE-enhet med fast adresse.
- Låser Macen når enheten går bort, og låser den opp når den kommer tilbake.
- To moduser: **Lås og lås opp** eller **Bare lås** (ingen passord lagres, og tillatelsen Tilgjengelighet trengs ikke).
- Kalibreringsassistent, andre enhet (Watch og iPhone), robust signalfilter.
- Valgfritt: vekk ved nærhet, sett media på pause, lås ved hvilemodus eller når lokket lukkes, lås når Bluetooth slås av.
- Tilgjengelig på 10 språk.

## 🇪🇺 Personvern og GDPR

- Ingen kontoer, ingen analyse, ingen reklame og ingen krasjrapporter. Alt blir på Macen din.
- Oppdateringssjekken er valgfri: én HTTPS-forespørsel til `api.github.com`, som ser IP-adressen din.
- Slett med ett klikk: Sikkerhet → Slett alle data…
- Passordet (bare i opplåsingsmodus) lagres i macOS Nøkkelring, bare på denne enheten.
- Ingen tredjepartsavhengigheter, Hardened Runtime og enhetstester av sikkerhetslogikken.

> Dette beskriver appens tekniske oppførsel, ikke en juridisk sertifisering. Detaljer: [PRIVACY.md](PRIVACY.nb.md).

## Krav

- En Mac med Bluetooth Low Energy
- macOS 12 (Monterey) eller nyere
- iPhone, Apple Watch eller en annen BLE-enhet med fast adresse

## Installasjon

Last ned zip-filen fra [Releases](https://github.com/Altissnono/BLEUnlock-LTS/releases), pakk den ut og flytt appen til Programmer.

> Appen er ikke notarisert: høyreklikk og velg **Åpne** første gang (eller kjør `xattr -dr com.apple.quarantine /Applications/BLEUnlock.app`). Kontroller zip-filen med `SHA256SUMS.txt` eller med attesteringen: `gh attestation verify BLEUnlock-<version>.zip --repo Altissnono/BLEUnlock-LTS`.

## Kom i gang

1. Åpne appen (låsikonet i menylinjen) og velg en modus ved første oppstart.
2. Tillat Bluetooth og varsler. Tillat Tilgjengelighet bare hvis du velger **Lås og lås opp**.
3. Meny → **Enhet**: hold iPhonen eller Apple Watch nær Macen. Den havner øverst i listen, velg den.
4. Meny → **Nærhet** → **Kalibrer signal…**: følg de to trinnene (12 s nær, 12 s langt unna).
5. Valgfritt: **Andre enhet** for å overvåke både Watch og iPhone.
6. Test: gå bort, så låses Macen etter låseforsinkelsen.

## Greit å vite

- Bluetooth-signalet svinger mye (en Apple Watch kan hoppe 25 til 30 dB mellom to målinger). Hold tersklene minst 10 dB unna verdiene for «nær» og «langt unna». En signaltidsavbrudd under 5 s kan gi feil låsing.
- Opplåsing ved nærhet kan etterlignes av noen med riktig utstyr. Velg **Bare lås** i sensitive miljøer.

## Mer informasjon

- Full dokumentasjon (engelsk): [README.md](README.md)
- Personvernerklæring: [PRIVACY.md](PRIVACY.nb.md)
- Sikkerhetsgjennomgang: [SECURITY_AUDIT.md](SECURITY_AUDIT.md)

---

MIT-lisens. Opprinnelig prosjekt av [Takeshi Sone](https://github.com/ts1/BLEUnlock). Vedlikeholdes av [Altissnono](https://github.com/Altissnono).
