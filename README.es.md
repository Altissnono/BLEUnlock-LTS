# 🇪🇺 BLEUnlock LTS

[English](README.md) | [Français](README.fr.md) | [Español](README.es.md) | [Deutsch](README.de.md) | [日本語](README.ja.md) | [简体中文](README.zh-Hans.md) | [Türkçe](README.tr.md) | [Svenska](README.sv.md) | [Dansk](README.da.md) | [Norsk](README.nb.md)

![CI](https://github.com/Altissnono/BLEUnlock-LTS/actions/workflows/test.yml/badge.svg)
[![Latest release](https://img.shields.io/github/v/release/Altissnono/BLEUnlock-LTS?display_name=tag&cacheSeconds=300)](https://github.com/Altissnono/BLEUnlock-LTS/releases/latest)
![GDPR friendly](https://img.shields.io/badge/%F0%9F%87%AA%F0%9F%87%BA-GDPR--friendly-003399?labelColor=FFCC00) ![No telemetry](https://img.shields.io/badge/telemetry-none-brightgreen) ![Languages](https://img.shields.io/badge/languages-10-informational)

BLEUnlock es una pequeña utilidad de la barra de menús que bloquea y desbloquea tu Mac según la proximidad de tu iPhone, tu Apple Watch o cualquier otro dispositivo Bluetooth Low Energy.

## Características

- No necesita app en el iPhone: funciona con un iPhone, un Apple Watch o cualquier dispositivo BLE con dirección estática.
- Bloquea el Mac cuando tu dispositivo se aleja y lo desbloquea cuando vuelve.
- Dos modos: **Bloquear y desbloquear** o **Solo bloquear** (no se guarda ninguna contraseña ni se pide el permiso de Accesibilidad).
- Asistente de calibración, segundo dispositivo (Watch y iPhone) y filtro de señal robusto.
- Opciones: activar al acercarse, pausar contenido multimedia, bloquear al suspender o cerrar la tapa, bloquear si se apaga el Bluetooth.
- Disponible en 10 idiomas.

## 🇪🇺 Privacidad y RGPD

- Sin cuentas, analíticas, publicidad ni informes de fallos. Todo se queda en tu Mac.
- La búsqueda de actualizaciones es opcional: una petición HTTPS a `api.github.com`, que ve tu dirección IP.
- Borrado en un clic: Seguridad → Borrar todos los datos…
- La contraseña (solo en modo desbloqueo) se guarda en el Llavero de macOS, solo en este dispositivo.
- Sin dependencias de terceros, Hardened Runtime y pruebas unitarias de la lógica de seguridad.

> Esto describe el comportamiento técnico de la app, no una certificación legal. Detalles: [PRIVACY.md](PRIVACY.es.md).

## Requisitos

- Un Mac compatible con Bluetooth Low Energy
- macOS 12 (Monterey) o posterior
- iPhone, Apple Watch u otro dispositivo BLE con dirección estática

## Instalación

Descarga el zip desde [Releases](https://github.com/Altissnono/BLEUnlock-LTS/releases), descomprímelo y mueve la app a Aplicaciones.

> La app no está notarizada: la primera vez, haz clic derecho y elige **Abrir** (o ejecuta `xattr -dr com.apple.quarantine /Applications/BLEUnlock.app`). Comprueba el zip con `SHA256SUMS.txt` o con la atestación: `gh attestation verify BLEUnlock-<version>.zip --repo Altissnono/BLEUnlock-LTS`.

## Primeros pasos

1. Abre la app (icono de candado en la barra de menús) y elige un modo en el primer arranque.
2. Permite Bluetooth y las notificaciones. Permite Accesibilidad solo si eliges **Bloquear y desbloquear**.
3. Menú → **Dispositivo**: acerca tu iPhone o tu Apple Watch al Mac. Aparece arriba en la lista, selecciónalo.
4. Menú → **Proximidad** → **Calibrar señal…**: sigue los dos pasos (12 s cerca, 12 s lejos).
5. Opcional: **Segundo dispositivo** para vigilar el Watch y el iPhone.
6. Prueba: aléjate y el Mac se bloqueará tras el retraso de bloqueo.

## Conviene saber

- La señal Bluetooth es inestable (un Apple Watch puede variar de 25 a 30 dB entre lecturas). Mantén los umbrales al menos a 10 dB de los valores de «cerca» y «lejos». Un tiempo sin señal inferior a 5 s puede bloquear por error.
- El desbloqueo por proximidad puede ser imitado por alguien con el equipo adecuado. Para entornos sensibles, elige **Solo bloquear**.

## Más información

- Documentación completa (inglés): [README.md](README.md)
- Política de privacidad: [PRIVACY.md](PRIVACY.es.md)
- Auditoría de seguridad: [SECURITY_AUDIT.md](SECURITY_AUDIT.md)

---

Licencia MIT. Proyecto original de [Takeshi Sone](https://github.com/ts1/BLEUnlock). Mantenido por [Altissnono](https://github.com/Altissnono).
