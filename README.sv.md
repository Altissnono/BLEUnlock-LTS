# 🇪🇺 BLEUnlock LTS

[English](README.md) | [Français](README.fr.md) | [Español](README.es.md) | [Deutsch](README.de.md) | [日本語](README.ja.md) | [简体中文](README.zh-Hans.md) | [Türkçe](README.tr.md) | [Svenska](README.sv.md) | [Dansk](README.da.md) | [Norsk](README.nb.md)

![CI](https://github.com/Altissnono/BLEUnlock-LTS/actions/workflows/test.yml/badge.svg)
[![Latest release](https://img.shields.io/github/v/release/Altissnono/BLEUnlock-LTS?display_name=tag&cacheSeconds=300)](https://github.com/Altissnono/BLEUnlock-LTS/releases/latest)
![GDPR friendly](https://img.shields.io/badge/%F0%9F%87%AA%F0%9F%87%BA-GDPR--friendly-003399?labelColor=FFCC00) ![No telemetry](https://img.shields.io/badge/telemetry-none-brightgreen) ![Languages](https://img.shields.io/badge/languages-10-informational)

BLEUnlock är ett litet verktyg i menyraden som låser och låser upp din Mac utifrån hur nära din iPhone, Apple Watch eller annan Bluetooth Low Energy-enhet är.

## Funktioner

- Ingen iPhone-app behövs: fungerar med iPhone, Apple Watch eller valfri BLE-enhet med fast adress.
- Låser Macen när enheten går bort och låser upp den när den kommer tillbaka.
- Två lägen: **Lås och lås upp** eller **Endast lås** (inget lösenord sparas och ingen behörighet för Tillgänglighet behövs).
- Kalibreringsassistent, andra enhet (Watch och iPhone), robust signalfilter.
- Valfritt: väck vid närhet, pausa media, lås vid vila eller när locket stängs, lås när Bluetooth stängs av.
- Finns på 10 språk.

## 🇪🇺 Integritet och GDPR

- Inga konton, ingen analys, inga annonser och inga kraschrapporter. Allt stannar på din Mac.
- Uppdateringskontrollen är valfri: ett HTTPS-anrop till `api.github.com`, som ser din IP-adress.
- Radera med ett klick: Säkerhet → Radera all data…
- Lösenordet (endast i upplåsningsläge) sparas i macOS Nyckelring, endast på den här enheten.
- Inga beroenden från tredje part, Hardened Runtime och enhetstester för säkerhetslogiken.

> Detta beskriver appens tekniska beteende, inte en juridisk certifiering. Detaljer: [PRIVACY.md](PRIVACY.sv.md).

## Krav

- En Mac med Bluetooth Low Energy
- macOS 12 (Monterey) eller senare
- iPhone, Apple Watch eller annan BLE-enhet med fast adress

## Installation

Ladda ner zip-filen från [Releases](https://github.com/Altissnono/BLEUnlock-LTS/releases), packa upp den och flytta appen till Program.

> Appen är inte notariserad: högerklicka och välj **Öppna** första gången (eller kör `xattr -dr com.apple.quarantine /Applications/BLEUnlock.app`). Verifiera zip-filen med `SHA256SUMS.txt` eller med attesteringen: `gh attestation verify BLEUnlock-<version>.zip --repo Altissnono/BLEUnlock-LTS`.

## Kom igång

1. Öppna appen (låsikonen i menyraden) och välj ett läge vid första starten.
2. Tillåt Bluetooth och aviseringar. Tillåt Tillgänglighet bara om du väljer **Lås och lås upp**.
3. Meny → **Enhet**: håll iPhone eller Apple Watch nära Macen. Den hamnar överst i listan, välj den.
4. Meny → **Närhet** → **Kalibrera signal…**: följ de två stegen (12 s nära, 12 s långt bort).
5. Valfritt: **Andra enheten** för att övervaka både Watch och iPhone.
6. Testa: gå bort, så låses Macen efter låsfördröjningen.

## Bra att veta

- Bluetooth-signalen varierar mycket (en Apple Watch kan hoppa 25 till 30 dB mellan två mätningar). Håll tröskelvärdena minst 10 dB från värdena för ”nära” och ”långt bort”. En signaltimeout under 5 s kan ge felaktiga låsningar.
- Upplåsning med närhet kan efterliknas av någon med rätt utrustning. Välj **Endast lås** i känsliga miljöer.

## Mer information

- Fullständig dokumentation (engelska): [README.md](README.md)
- Integritetspolicy: [PRIVACY.md](PRIVACY.sv.md)
- Säkerhetsgranskning: [SECURITY_AUDIT.md](SECURITY_AUDIT.md)

---

MIT-licens. Ursprungligt projekt av [Takeshi Sone](https://github.com/ts1/BLEUnlock). Underhålls av [Altissnono](https://github.com/Altissnono).
