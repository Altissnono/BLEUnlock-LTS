# 🇪🇺 Política de privacidad de BLEUnlock LTS

[English](PRIVACY.md) | [Français](PRIVACY.fr.md) | [Español](PRIVACY.es.md) | [Deutsch](PRIVACY.de.md) | [日本語](PRIVACY.ja.md) | [简体中文](PRIVACY.zh-Hans.md) | [Türkçe](PRIVACY.tr.md) | [Svenska](PRIVACY.sv.md) | [Dansk](PRIVACY.da.md) | [Norsk](PRIVACY.nb.md)

*Última actualización: 25/11/2026. Se aplica a BLEUnlock LTS 3.x.*

> Este documento describe lo que hace el software. Es una declaración de transparencia, no asesoramiento jurídico ni una certificación legal.

## 1. Resumen

- BLEUnlock LTS funciona por completo en tu Mac. No hay cuentas, analíticas, publicidad, seguimiento ni informes de fallos.
- El mantenedor no gestiona ningún servidor para la app y no recibe, almacena ni trata datos personales procedentes de ella.
- La única función de red es la búsqueda de actualizaciones. Es **opcional** y envía una petición HTTPS a `api.github.com`, que puede ver tu dirección IP (detalles en la sección 5).
- La contraseña de inicio de sesión de tu Mac solo se guarda si eliges el modo *Bloquear y desbloquear*, en el Llavero de macOS y solo en este dispositivo. El modo *Solo bloquear* nunca la pide ni la guarda.
- Puedes borrar todo lo que guarda la app con un clic: *Seguridad → Borrar todos los datos…*.

## 2. Quién es responsable

- Mantenedor: la cuenta de GitHub **Altissnono** ([perfil](https://github.com/Altissnono), repositorio [BLEUnlock-LTS](https://github.com/Altissnono/BLEUnlock-LTS)). Proyecto original de Takeshi Sone (licencia MIT).
- Como la app no envía datos personales al mantenedor, este no actúa como responsable ni como encargado del tratamiento de tus datos. Los datos descritos abajo permanecen bajo tu control en tu propio Mac.
- El único tercero implicado es GitHub (sección 10), y solo si activas la búsqueda de actualizaciones o descargas una versión.

## 3. Qué trata la app

Todo lo de esta tabla se trata localmente en tu Mac. Nada se envía al mantenedor ni a ningún servidor.

| Dato | Finalidad | Dónde está | ¿Sale de tu Mac? |
|---|---|---|---|
| Identificador (UUID de CoreBluetooth) del dispositivo o dispositivos Bluetooth que elijas e intensidad de su señal (RSSI) | Detectar si tu dispositivo está cerca, para bloquear o desbloquear | Identificador en los ajustes de la app; valores de señal solo en memoria | No |
| Nombre, fabricante, modelo e intensidad de señal de los dispositivos Bluetooth cercanos, **solo mientras el menú Dispositivo está abierto** | Mostrar la lista para que elijas tu dispositivo | Solo en memoria, descartados tras al menos 30 segundos sin detección y al cerrar la app | No |
| Contraseña de inicio de sesión del Mac (solo en modo *Bloquear y desbloquear*) | Escribirla en la pantalla de bloqueo | Llavero de macOS, servicio = identificador de la app, «solo este dispositivo» (no se sincroniza con iCloud) | No |
| Ajustes (umbrales, retrasos, opciones) | Configuración | Archivo de preferencias de la app (sección 7) | No |
| Diagnóstico: valores de señal, temporizadores, decisiones de bloqueo (sin nombres, sin identificadores, sin contraseña) | Resolución de problemas | Registro unificado de macOS en tu Mac, rotado automáticamente por macOS | No |
| Fecha de la última búsqueda de actualizaciones | Limitar las búsquedas a una al día | Archivo de preferencias de la app | No |
| Nombre del propietario y tamaño de la ventana en primer plano (sin contenido ni títulos) | Comprobar que la pantalla de bloqueo está delante antes de escribir la contraseña | No se guardan | No |
| Notificaciones que activaste (bloqueo, desbloqueo, actualización) | Informarte | Notificaciones locales de macOS | No |
| Script opcional `event` que escribes tú | Tu propia automatización | `~/Library/Application Scripts/io.github.altissnono.BLEUnlock/` | Solo si tu propio script envía algo |

## 4. Lo que la app no hace

- Sin analíticas, telemetría, estadísticas de uso, pruebas A/B, identificadores publicitarios ni huellas digitales.
- Sin informes de fallos enviados por la app. (macOS puede ofrecerte compartir diagnósticos con Apple; es un ajuste del sistema en *Privacidad y seguridad → Analíticas y mejoras*, independiente de esta app.)
- Sin acceso a tus contactos, calendario, fotos, ubicación, micrófono, cámara ni archivos.
- Sin lectura del contenido de la pantalla ni permiso de grabación de pantalla. La comprobación de ventana solo lee el nombre del propietario y el tamaño de las ventanas.
- Sin envío de nombres, identificadores ni valores de señal de dispositivos Bluetooth a ninguna parte.
- Nunca se pide cuenta, inicio de sesión, correo electrónico ni teléfono.
- Sin bibliotecas ni SDK de terceros (la app solo usa frameworks del sistema de Apple).

## 5. Acceso a la red

- Por defecto, la app **no contacta con ningún servidor**.
- **Búsqueda de actualizaciones (opcional):** si la permites en el primer arranque o en *Opciones → Búsqueda automática de actualizaciones*, la app hace como máximo una petición al día. Si pulsas *Buscar actualizaciones*, lanzas tú mismo una sola petición.
- La petición es `GET https://api.github.com/repos/Altissnono/BLEUnlock-LTS/releases/latest`, con las cabeceras `User-Agent: BLEUnlock-LTS` y `Accept: application/vnd.github+json`. No se envía cookie, token de cuenta, número de versión, información del dispositivo ni ajustes.
- GitHub ve necesariamente tu **dirección IP** y la hora de la petición, como cualquier servidor web. La sesión es efímera (sin cookies ni caché en disco), se rechazan las redirecciones, el tamaño de la respuesta está limitado y solo se lee el nombre de la versión para comparar números.
- Si la respuesta no es válida o el servidor no es `api.github.com`, se ignora.
- Los enlaces del cuadro Acerca de y del menú (*Política de privacidad*, *Descargar*) se abren en tu navegador solo cuando haces clic. Tu navegador habla entonces con GitHub según sus propias normas.
- No hay ninguna otra conexión de red en el código. La integración continua hace fallar la compilación si aparece otro servidor.

## 6. Permisos explicados

- **Bluetooth:** necesario para ver la señal de tu dispositivo. Mientras el menú Dispositivo está abierto, la app también se conecta brevemente a dispositivos cercanos cuya señal supera tu ajuste de señal mínima, solo para leer la «Información del dispositivo» estándar (fabricante y modelo) y que la lista sea legible. No se guarda ni se envía nada.
- **Accesibilidad** (solo en modo *Bloquear y desbloquear*): necesaria para escribir tu contraseña en la pantalla de bloqueo. La app no lee lo que hay en pantalla.
- **Notificaciones:** opcionales, para avisarte de un bloqueo, un desbloqueo o una actualización.
- **Llavero:** guarda tu contraseña en modo *Bloquear y desbloquear*. El elemento está marcado «solo este dispositivo» y no se sincroniza.
- **Elemento de inicio de sesión:** la opción «Abrir al iniciar sesión» usa el servicio estándar de macOS. *Borrar todos los datos…* lo elimina.
- Archivos del sistema leídos: la caché Bluetooth de macOS (`/Library/Preferences/com.apple.Bluetooth.plist`, `/Library/Bluetooth/*.db`), solo lectura, para mostrar nombres y direcciones en la lista.

## 7. Claves de preferencias (inventario completo)

La app solo guarda estas claves en `~/Library/Preferences/io.github.altissnono.BLEUnlock.plist`:

| Claves | Significado |
|---|---|
| `mode` | Modo elegido: Bloquear y desbloquear, o Solo bloquear |
| `device`, `device2` | Identificadores del dispositivo elegido y del segundo dispositivo opcional |
| `lockRSSI`, `unlockRSSI`, `thresholdRSSI`, `timeout`, `lockDelay`, `confirmDelay`, `maxUnlockAttempts`, `robustFilter`, `passiveMode` | Umbrales de señal, retrasos, límite de intentos, filtro y modo de escaneo |
| `wakeOnProximity`, `wakeWithoutUnlocking`, `pauseItunes`, `screensaver`, `sleepDisplay`, `lockOnSleep`, `lockOnBluetoothOff`, `verifyFrontWindow` | Opciones de comportamiento que puedes activar o desactivar |
| `notifications`, `notifyOnUnlock`, `showRSSI`, `launchAtLogin` | Opciones de notificación y visualización |
| `updateChecks`, `lastUpdateCheck` | Tu consentimiento para buscar actualizaciones y la fecha de la última búsqueda |

## 8. Dónde están tus datos y cómo borrarlos

1. **Todo a la vez:** menú *Seguridad → Borrar todos los datos…*. Elimina la contraseña del Llavero, todas las preferencias y el elemento de inicio de sesión, y cierra la app.
2. **Solo la contraseña:** menú *Seguridad → Eliminar contraseña guardada*, o cambia al modo *Solo bloquear* (la contraseña se borra tras confirmar).
3. **A mano:** elimina `~/Library/Preferences/io.github.altissnono.BLEUnlock.plist` y el elemento del Llavero llamado *BLEUnlock* en *Acceso a Llaveros*, y mueve la app a la papelera.
4. **Registro de diagnóstico:** lo gestiona macOS y caduca automáticamente. Para borrar ahora todos los registros del sistema, ejecuta `sudo log erase --all` en Terminal.
5. **Tu script `event`** en `~/Library/Application Scripts/io.github.altissnono.BLEUnlock/` es tuyo; la app nunca crea ni borra tu script.

## 9. Conservación

- Las preferencias y el elemento del Llavero permanecen hasta que los borres (sección 8).
- Los valores de señal y la información de dispositivos cercanos viven en memoria y se descartan al cerrar la app (un dispositivo de la lista caduca tras al menos 30 segundos sin detección).
- El mantenedor no conserva nada, porque no recibe nada.

## 10. Terceros y transferencias internacionales

- **GitHub (GitHub, Inc., empresa estadounidense de Microsoft):** aloja el código fuente y las versiones y responde a la búsqueda de actualizaciones opcional. Cuando descargas una versión o permites la búsqueda de actualizaciones, GitHub recibe tu dirección IP y la trata según sus propias condiciones y su declaración de privacidad. El mantenedor no tiene control sobre ello y no recibe esos datos.
- Como GitHub es una empresa estadounidense, estas peticiones pueden implicar una transferencia de tu dirección IP fuera de la UE/EEE. Para evitarlo por completo, deja desactivada la búsqueda de actualizaciones y compila la app desde el código fuente (sección 14).
- No existe ningún otro destinatario: ni proveedor de analíticas, ni red publicitaria, ni servicio de informes de fallos, ni nube.

## 11. Base jurídica y tus derechos (RGPD)

- **Búsqueda de actualizaciones:** tu consentimiento (art. 6.1.a RGPD), que puedes retirar en cualquier momento en *Opciones → Búsqueda automática de actualizaciones* o no pulsando nunca *Buscar actualizaciones*.
- **Tratamiento local en tu Mac:** los datos de la sección 3 nunca llegan al mantenedor. Tú los controlas y puedes consultarlos o borrarlos (sección 8).
- **Tus derechos** (acceso, rectificación, supresión, limitación, portabilidad, oposición, arts. 15 a 21): el mantenedor no conserva datos sobre ti, así que no hay nada que pedirle; usa las herramientas de la sección 8 en tu propio dispositivo.
- **Reclamación:** puedes presentar una reclamación ante tu autoridad nacional de protección de datos (por ejemplo la AEPD en España, la CNIL en Francia, la BfDI en Alemania, la Datatilsynet en Dinamarca y Noruega, la IMY en Suecia).
- Esta es una descripción en lenguaje sencillo, no asesoramiento jurídico. Si despliegas la app en una organización, sigues siendo responsable de tu propia evaluación de cumplimiento.

## 12. Medidas de seguridad

- Hardened Runtime, sin código de terceros y, desde la versión 3.2.5, sin permiso de depuración (comprobado en cada compilación; las versiones 3.x anteriores lo incluían por error).
- Contraseña solo en el Llavero, borrada de la memoria tras escribirla, escrita solo cuando la pantalla de bloqueo está delante, con límite de intentos y retraso de confirmación.
- Búsqueda de actualizaciones reforzada (comprobación del servidor, sin redirecciones, tamaño limitado, validación del nombre de versión).
- Detalles y límites conocidos: [SECURITY_AUDIT.md](SECURITY_AUDIT.md).

## 13. Menores

- La app no está dirigida a menores y no recopila datos personales de nadie.

## 14. Cómo comprobar estas afirmaciones por ti mismo

1. Lee el código fuente: es breve (unos pocos miles de líneas) y público en el [repositorio](https://github.com/Altissnono/BLEUnlock-LTS).
2. Ejecuta `scripts/security-check.sh`: falla si aparece un servidor distinto de github.com, si se referencia un SDK de seguimiento, si el acceso automático a la red no es opcional o si el manifiesto de privacidad declara seguimiento o datos recopilados. Se ejecuta en cada push (integración continua).
3. Inspecciona la app compilada: `scripts/verify-build.sh /Applications/BLEUnlock.app` comprueba los permisos y las bibliotecas enlazadas.
4. Vigila la red: con Little Snitch, LuLu o `nettop -p <pid>` no verás ninguna conexión salvo que lances una búsqueda de actualizaciones.
5. Compílala tú mismo con Xcode desde el código fuente; no hace falta ningún binario del mantenedor.
6. Lee el manifiesto de privacidad de Apple incluido en la app (`PrivacyInfo.xcprivacy`): sin seguimiento, sin tipos de datos recopilados.

## 15. Cambios en esta política

- Los cambios se hacen en este repositorio; el historial de Git muestra exactamente qué cambió y cuándo. La fecha de arriba se actualiza con cada cambio.
- Si una versión futura añade recopilación de datos o una función de red, se describirá aquí antes de publicarla y será opcional.

## 16. Contacto

- Preguntas sobre esta política: abre una incidencia en <https://github.com/Altissnono/BLEUnlock-LTS/issues>. **No** publiques datos personales allí.
- Idiomas: esta política está disponible en inglés, francés, español, alemán, japonés, chino simplificado, turco, sueco, danés y noruego. Si las traducciones difieren, prevalece la versión inglesa.
