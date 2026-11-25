# 🇪🇺 BLEUnlock LTS

[English](README.md) | [Français](README.fr.md) | [Español](README.es.md) | [Deutsch](README.de.md) | [日本語](README.ja.md) | [简体中文](README.zh-Hans.md) | [Türkçe](README.tr.md) | [Svenska](README.sv.md) | [Dansk](README.da.md) | [Norsk](README.nb.md)

![CI](https://github.com/Altissnono/BLEUnlock-LTS/actions/workflows/test.yml/badge.svg)
[![Latest release](https://img.shields.io/github/v/release/Altissnono/BLEUnlock-LTS?display_name=tag&cacheSeconds=300)](https://github.com/Altissnono/BLEUnlock-LTS/releases/latest)
![GDPR friendly](https://img.shields.io/badge/%F0%9F%87%AA%F0%9F%87%BA-GDPR--friendly-003399?labelColor=FFCC00) ![No telemetry](https://img.shields.io/badge/telemetry-none-brightgreen) ![Languages](https://img.shields.io/badge/languages-10-informational)

BLEUnlock est un petit utilitaire de barre des menus qui verrouille et déverrouille votre Mac selon la proximité de votre iPhone, de votre Apple Watch ou de tout autre appareil Bluetooth Low Energy.

## Fonctionnalités

- Aucune app iPhone nécessaire : fonctionne avec un iPhone, une Apple Watch ou tout appareil BLE à adresse statique.
- Verrouille le Mac quand votre appareil s'éloigne et le déverrouille à son retour.
- Deux modes : **Verrouiller et déverrouiller** ou **Verrouiller seulement** (aucun mot de passe stocké, aucune autorisation Accessibilité).
- Assistant de calibrage, second appareil (Watch et iPhone), filtre de signal robuste.
- Options : réveil à l'approche, pause des médias, verrouillage à la mise en veille ou à la fermeture du capot, verrouillage si le Bluetooth est coupé.
- Disponible en 10 langues.

## 🇪🇺 Confidentialité et RGPD

- Aucun compte, aucune analyse d'usage, aucune publicité, aucun rapport de plantage. Tout reste sur votre Mac.
- La recherche de mise à jour est facultative : une requête HTTPS vers `api.github.com`, qui voit votre adresse IP.
- Effacement en un clic : Sécurité → Effacer toutes les données…
- Le mot de passe (mode déverrouillage seulement) est stocké dans le Trousseau macOS, sur cet appareil uniquement.
- Aucune dépendance tierce, Hardened Runtime, tests unitaires sur la logique de sécurité.

> Ceci décrit le comportement technique de l'app, pas une certification juridique. Détails : [PRIVACY.md](PRIVACY.md).

## Prérequis

- Un Mac compatible Bluetooth Low Energy
- macOS 12 (Monterey) ou plus récent
- iPhone, Apple Watch ou autre appareil BLE à adresse statique

## Installation

Téléchargez le zip depuis les [Releases](https://github.com/Altissnono/BLEUnlock-LTS/releases), décompressez-le et déplacez l'app dans Applications.

> L'app n'est pas notariée : au premier lancement, faites un clic droit puis **Ouvrir** (ou `xattr -dr com.apple.quarantine /Applications/BLEUnlock.app`). Vérifiez le zip avec `SHA256SUMS.txt` ou avec l'attestation : `gh attestation verify BLEUnlock-<version>.zip --repo Altissnono/BLEUnlock-LTS`.

## Premiers pas

1. Ouvrez l'app (icône cadenas dans la barre des menus) et choisissez un mode au premier lancement.
2. Autorisez Bluetooth et les notifications. N'autorisez Accessibilité que si vous choisissez **Verrouiller et déverrouiller**.
3. Menu → **Appareil** : approchez votre iPhone ou votre Apple Watch du Mac. Il passe en haut de la liste, sélectionnez-le.
4. Menu → **Proximité** → **Calibrer le signal…** : suivez les deux étapes (12 s près, 12 s loin).
5. Facultatif : **Second appareil** pour surveiller la Watch et l'iPhone.
6. Testez : éloignez-vous, le Mac se verrouille après le délai de verrouillage.

## Bon à savoir

- Le signal Bluetooth est instable (une Apple Watch peut varier de 25 à 30 dB entre deux lectures). Gardez les seuils à au moins 10 dB des valeurs « près » et « loin ». Un délai sans signal inférieur à 5 s peut verrouiller à tort.
- Le déverrouillage par proximité peut être imité par une personne équipée du bon matériel. Pour un usage sensible, choisissez **Verrouiller seulement**.

## Pour aller plus loin

- Documentation complète (anglais) : [README.md](README.md)
- Politique de confidentialité : [PRIVACY.md](PRIVACY.md)
- Audit de sécurité : [SECURITY_AUDIT.md](SECURITY_AUDIT.md)

---

Licence MIT. Projet d'origine de [Takeshi Sone](https://github.com/ts1/BLEUnlock). Maintenu par [Altissnono](https://github.com/Altissnono).
