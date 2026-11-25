# 🇪🇺 Datenschutzerklärung von BLEUnlock LTS

[English](PRIVACY.md) | [Français](PRIVACY.fr.md) | [Español](PRIVACY.es.md) | [Deutsch](PRIVACY.de.md) | [日本語](PRIVACY.ja.md) | [简体中文](PRIVACY.zh-Hans.md) | [Türkçe](PRIVACY.tr.md) | [Svenska](PRIVACY.sv.md) | [Dansk](PRIVACY.da.md) | [Norsk](PRIVACY.nb.md)

*Zuletzt aktualisiert: 25.11.2026. Gilt für BLEUnlock LTS 3.x.*

> Dieses Dokument beschreibt, was die Software tut. Es ist eine Transparenzerklärung, keine Rechtsberatung und keine rechtliche Zertifizierung.

## 1. Zusammenfassung

- BLEUnlock LTS läuft vollständig auf Ihrem Mac. Es gibt keine Konten, keine Analyse, keine Werbung, kein Tracking und keine Absturzberichte.
- Der Betreuer betreibt keinen Server für die App und erhält, speichert oder verarbeitet keine personenbezogenen Daten daraus.
- Die einzige Netzwerkfunktion ist die Update-Suche. Sie ist **freiwillig** und sendet eine HTTPS-Anfrage an `api.github.com`, das Ihre IP-Adresse sehen kann (Details in Abschnitt 5).
- Ihr Anmeldepasswort wird nur gespeichert, wenn Sie den Modus *Sperren & Entsperren* wählen, im macOS-Schlüsselbund und nur auf diesem Gerät. Der Modus *Nur sperren* fragt es nie ab und speichert es nie.
- Sie können alles, was die App speichert, mit einem Klick löschen: *Sicherheit → Alle Daten löschen…*.

## 2. Wer verantwortlich ist

- Betreuer: das GitHub-Konto **Altissnono** ([Profil](https://github.com/Altissnono), Repository [BLEUnlock-LTS](https://github.com/Altissnono/BLEUnlock-LTS)). Ursprungsprojekt von Takeshi Sone (MIT-Lizenz).
- Da die App keine personenbezogenen Daten an den Betreuer sendet, handelt dieser weder als Verantwortlicher noch als Auftragsverarbeiter für Ihre Daten. Die unten beschriebenen Daten bleiben unter Ihrer Kontrolle auf Ihrem eigenen Mac.
- Der einzige beteiligte Dritte ist GitHub (Abschnitt 10), und nur wenn Sie die Update-Suche erlauben oder eine Version herunterladen.

## 3. Was die App verarbeitet

Alles in dieser Tabelle wird lokal auf Ihrem Mac verarbeitet. Nichts davon wird an den Betreuer oder einen Server gesendet.

| Daten | Zweck | Wo sie liegen | Verlässt den Mac? |
|---|---|---|---|
| Kennung (CoreBluetooth-UUID) der gewählten Bluetooth-Geräte und deren Signalstärke (RSSI) | Erkennen, ob Ihr Gerät in der Nähe ist, zum Sperren oder Entsperren | Kennung in den App-Einstellungen; Signalwerte nur im Arbeitsspeicher | Nein |
| Name, Hersteller, Modell und Signalstärke von Bluetooth-Geräten in der Nähe, **nur solange das Menü Gerät geöffnet ist** | Die Liste anzeigen, damit Sie Ihr Gerät wählen können | Nur im Arbeitsspeicher, verworfen nach mindestens 30 Sekunden ohne Sichtung und beim Beenden der App | Nein |
| Ihr Anmeldepasswort (nur im Modus *Sperren & Entsperren*) | Auf dem Sperrbildschirm eintippen | macOS-Schlüsselbund, Dienst = Bundle-Kennung der App, „nur dieses Gerät“ (keine iCloud-Synchronisierung) | Nein |
| Einstellungen (Schwellenwerte, Verzögerungen, Optionen) | Konfiguration | Einstellungsdatei der App (Abschnitt 7) | Nein |
| Diagnose: Signalwerte, Timer, Sperrentscheidungen (keine Namen, keine Kennungen, kein Passwort) | Fehlersuche | Einheitliches macOS-Protokoll auf Ihrem Mac, von macOS automatisch rotiert | Nein |
| Datum der letzten Update-Suche | Suche auf einmal pro Tag begrenzen | Einstellungsdatei der App | Nein |
| Besitzername und Größe des vordersten Fensters (kein Inhalt, keine Titel) | Sicherstellen, dass der Sperrbildschirm vorne ist, bevor das Passwort getippt wird | Nicht gespeichert | Nein |
| Aktivierte Mitteilungen (Sperren, Entsperren, Update) | Sie informieren | Lokale macOS-Mitteilungen | Nein |
| Optionales Skript `event`, das Sie selbst schreiben | Ihre eigene Automatisierung | `~/Library/Application Scripts/io.github.altissnono.BLEUnlock/` | Nur wenn Ihr eigenes Skript etwas sendet |

## 4. Was die App nicht tut

- Keine Analyse, Telemetrie, Nutzungsstatistik, A/B-Tests, Werbekennungen oder Fingerprinting.
- Keine von der App gesendeten Absturzberichte. (macOS kann anbieten, Diagnosedaten mit Apple zu teilen; das ist eine Systemeinstellung unter *Datenschutz & Sicherheit → Analyse & Verbesserungen*, unabhängig von dieser App.)
- Kein Zugriff auf Kontakte, Kalender, Fotos, Standort, Mikrofon, Kamera oder Dateien.
- Kein Lesen des Bildschirminhalts und keine Berechtigung zur Bildschirmaufnahme. Die Fensterprüfung liest nur Besitzername und Größe von Fenstern.
- Kein Senden von Namen, Kennungen oder Signalwerten von Bluetooth-Geräten irgendwohin.
- Es werden nie Konto, Anmeldename, E-Mail-Adresse oder Telefonnummer verlangt.
- Keine Drittanbieter-Bibliotheken oder SDKs (die App nutzt nur Apple-Systemframeworks).

## 5. Netzwerkzugriff

- Standardmäßig **kontaktiert die App keinen Server**.
- **Update-Suche (freiwillig):** Wenn Sie sie beim ersten Start oder unter *Optionen → Automatische Update-Suche* erlauben, sendet die App höchstens eine Anfrage pro Tag. Wenn Sie *Nach Updates suchen* drücken, lösen Sie selbst eine einzelne Anfrage aus.
- Die Anfrage lautet `GET https://api.github.com/repos/Altissnono/BLEUnlock-LTS/releases/latest` mit den Headern `User-Agent: BLEUnlock-LTS` und `Accept: application/vnd.github+json`. Es werden kein Cookie, kein Konto-Token, keine Versionsnummer, keine Geräteinformation und keine Einstellung gesendet.
- GitHub sieht zwangsläufig Ihre **IP-Adresse** und den Zeitpunkt der Anfrage, wie jeder Webserver. Die Sitzung ist flüchtig (keine Cookies, kein Festplatten-Cache), Weiterleitungen werden abgelehnt, die Antwortgröße ist begrenzt und nur der Versionsname wird gelesen, um Nummern zu vergleichen.
- Ist die Antwort ungültig oder weicht der Host von `api.github.com` ab, wird sie ignoriert.
- Links im Info-Fenster und im Menü (*Datenschutzerklärung*, *Laden*) öffnen sich nur bei Ihrem Klick im Browser. Ihr Browser spricht dann nach eigenen Regeln mit GitHub.
- Im Code gibt es keine weitere Netzwerkverbindung. Die CI lässt den Build fehlschlagen, sobald ein anderer Host auftaucht.

## 6. Berechtigungen erklärt

- **Bluetooth:** nötig, um das Signal Ihres Geräts zu sehen. Solange das Menü Gerät geöffnet ist, verbindet sich die App außerdem kurz mit Geräten in der Nähe, deren Signal stärker als Ihre Mindestsignal-Einstellung ist, nur um die Standard-„Geräteinformation“ (Hersteller und Modell) zu lesen, damit die Liste lesbar ist. Nichts wird gespeichert oder gesendet.
- **Bedienungshilfen** (nur im Modus *Sperren & Entsperren*): nötig, um Ihr Passwort auf dem Sperrbildschirm zu tippen. Die App liest nicht, was auf dem Bildschirm steht.
- **Mitteilungen:** optional, um Sie über Sperren, Entsperren oder ein Update zu informieren.
- **Schlüsselbund:** speichert Ihr Passwort im Modus *Sperren & Entsperren*. Das Objekt ist als „nur dieses Gerät“ markiert und wird nicht synchronisiert.
- **Anmeldeobjekt:** die Option „Bei Anmeldung öffnen“ nutzt den Standarddienst von macOS. *Alle Daten löschen…* entfernt es.
- Gelesene Systemdateien: der Bluetooth-Cache von macOS (`/Library/Preferences/com.apple.Bluetooth.plist`, `/Library/Bluetooth/*.db`), nur lesend, um Namen und Adressen in der Liste anzuzeigen.

## 7. Einstellungsschlüssel (vollständiges Inventar)

Die App speichert nur diese Schlüssel in `~/Library/Preferences/io.github.altissnono.BLEUnlock.plist`:

| Schlüssel | Bedeutung |
|---|---|
| `mode` | Gewählter Modus: Sperren & Entsperren oder Nur sperren |
| `device`, `device2` | Kennungen des gewählten Geräts und des optionalen zweiten Geräts |
| `lockRSSI`, `unlockRSSI`, `thresholdRSSI`, `timeout`, `lockDelay`, `confirmDelay`, `maxUnlockAttempts`, `robustFilter`, `passiveMode` | Signalschwellen, Verzögerungen, Versuchslimit, Filter und Suchmodus |
| `wakeOnProximity`, `wakeWithoutUnlocking`, `pauseItunes`, `screensaver`, `sleepDisplay`, `lockOnSleep`, `lockOnBluetoothOff`, `verifyFrontWindow` | Verhaltensoptionen, die Sie ein- oder ausschalten können |
| `notifications`, `notifyOnUnlock`, `showRSSI`, `launchAtLogin` | Mitteilungs- und Anzeigeoptionen |
| `updateChecks`, `lastUpdateCheck` | Ihre Einwilligung zur Update-Suche und das Datum der letzten Suche |

## 8. Wo Ihre Daten liegen und wie Sie sie löschen

1. **Alles auf einmal:** Menü *Sicherheit → Alle Daten löschen…*. Es löscht das Passwort im Schlüsselbund, alle Einstellungen und das Anmeldeobjekt und beendet dann die App.
2. **Nur das Passwort:** Menü *Sicherheit → Gespeichertes Passwort entfernen* oder wechseln Sie in den Modus *Nur sperren* (das Passwort wird nach Ihrer Bestätigung gelöscht).
3. **Manuell:** löschen Sie `~/Library/Preferences/io.github.altissnono.BLEUnlock.plist` und das Schlüsselbund-Objekt *BLEUnlock* in der *Schlüsselbundverwaltung*, und legen Sie die App in den Papierkorb.
4. **Diagnoseprotokoll:** wird von macOS verwaltet und läuft automatisch ab. Um jetzt alle Systemprotokolle zu löschen, führen Sie `sudo log erase --all` im Terminal aus.
5. **Ihr eigenes `event`-Skript** in `~/Library/Application Scripts/io.github.altissnono.BLEUnlock/` gehört Ihnen; die App erstellt oder löscht Ihr Skript nie.

## 9. Speicherdauer

- Einstellungen und das Schlüsselbund-Objekt bleiben, bis Sie sie löschen (Abschnitt 8).
- Signalwerte und Informationen über Geräte in der Nähe liegen im Arbeitsspeicher und werden beim Beenden der App verworfen (ein gelistetes Gerät läuft nach mindestens 30 Sekunden ohne Sichtung ab).
- Der Betreuer speichert nichts, da er nichts erhält.

## 10. Dritte und internationale Übermittlungen

- **GitHub (GitHub, Inc., ein US-Unternehmen von Microsoft):** hostet den Quellcode und die Versionen und beantwortet die optionale Update-Suche. Wenn Sie eine Version herunterladen oder die Update-Suche erlauben, erhält GitHub Ihre IP-Adresse und verarbeitet sie nach eigenen Bedingungen und Datenschutzhinweisen. Der Betreuer hat darauf keinen Einfluss und erhält diese Daten nicht.
- Da GitHub ein US-Unternehmen ist, können solche Anfragen eine Übermittlung Ihrer IP-Adresse außerhalb der EU/des EWR bedeuten. Um das ganz zu vermeiden, lassen Sie die Update-Suche aus und bauen Sie die App aus dem Quellcode (Abschnitt 14).
- Es gibt keinen weiteren Empfänger: keinen Analyse-Anbieter, kein Werbenetzwerk, keinen Absturzbericht-Dienst, keine Cloud.

## 11. Rechtsgrundlage und Ihre Rechte (DSGVO)

- **Update-Suche:** Ihre Einwilligung (Art. 6 Abs. 1 lit. a DSGVO), die Sie jederzeit unter *Optionen → Automatische Update-Suche* widerrufen können oder indem Sie *Nach Updates suchen* nie drücken.
- **Lokale Verarbeitung auf Ihrem Mac:** Die Daten aus Abschnitt 3 erreichen den Betreuer nie. Sie haben die Kontrolle und können sie einsehen oder löschen (Abschnitt 8).
- **Ihre Rechte** (Auskunft, Berichtigung, Löschung, Einschränkung, Übertragbarkeit, Widerspruch, Art. 15 bis 21): Der Betreuer hält keine Daten über Sie, daher gibt es bei ihm nichts anzufordern; nutzen Sie die Werkzeuge aus Abschnitt 8 auf Ihrem Gerät.
- **Beschwerde:** Sie können sich bei Ihrer nationalen Datenschutzbehörde beschweren (zum Beispiel BfDI oder die Landesbehörde in Deutschland, CNIL in Frankreich, AEPD in Spanien, Datatilsynet in Dänemark und Norwegen, IMY in Schweden).
- Dies ist eine allgemein verständliche Beschreibung, keine Rechtsberatung. Wenn Sie die App in einer Organisation einsetzen, bleiben Sie für Ihre eigene Compliance-Bewertung verantwortlich.

## 12. Sicherheitsmaßnahmen

- Hardened Runtime, kein Drittanbieter-Code und, ab Version 3.2.5, keine Debugger-Berechtigung (bei jedem Build geprüft; frühere 3.x-Versionen enthielten sie versehentlich).
- Passwort nur im Schlüsselbund, nach dem Tippen aus dem Speicher gelöscht, nur getippt, wenn der Sperrbildschirm vorne ist, mit Versuchslimit und Bestätigungsverzögerung.
- Gehärtete Update-Suche (Host-Prüfung, keine Weiterleitungen, Größenlimit, Prüfung des Versionsnamens).
- Details und bekannte Grenzen: [SECURITY_AUDIT.md](SECURITY_AUDIT.md).

## 13. Kinder

- Die App richtet sich nicht an Kinder und erhebt von niemandem personenbezogene Daten.

## 14. Wie Sie diese Aussagen selbst überprüfen

1. Lesen Sie den Quellcode: Er ist klein (einige tausend Zeilen) und öffentlich im [Repository](https://github.com/Altissnono/BLEUnlock-LTS).
2. Führen Sie `scripts/security-check.sh` aus: Es schlägt fehl, wenn ein anderer Host als github.com auftaucht, ein Tracking-SDK referenziert wird, der automatische Netzwerkzugriff nicht freiwillig ist oder das Datenschutz-Manifest Tracking oder erhobene Daten angibt. Es läuft bei jedem Push (CI).
3. Prüfen Sie die gebaute App: `scripts/verify-build.sh /Applications/BLEUnlock.app` prüft Berechtigungen und gelinkte Bibliotheken.
4. Beobachten Sie das Netzwerk: Mit Little Snitch, LuLu oder `nettop -p <pid>` sehen Sie keine Verbindung, solange Sie keine Update-Suche auslösen.
5. Bauen Sie die App selbst mit Xcode aus dem Quellcode; ein Binärpaket des Betreuers ist nicht nötig.
6. Lesen Sie das Apple-Datenschutz-Manifest in der App (`PrivacyInfo.xcprivacy`): kein Tracking, keine erhobenen Datentypen.

## 15. Änderungen dieser Erklärung

- Änderungen erfolgen in diesem Repository; der Git-Verlauf zeigt genau, was sich wann geändert hat. Das Datum oben wird bei jeder Änderung aktualisiert.
- Falls eine künftige Version Datenerhebung oder eine Netzwerkfunktion hinzufügt, wird sie hier vor der Veröffentlichung beschrieben und freiwillig sein.

## 16. Kontakt

- Fragen zu dieser Erklärung: Öffnen Sie ein Issue unter <https://github.com/Altissnono/BLEUnlock-LTS/issues>. Veröffentlichen Sie dort **keine** personenbezogenen Daten.
- Sprachen: Diese Erklärung gibt es auf Englisch, Französisch, Spanisch, Deutsch, Japanisch, vereinfachtem Chinesisch, Türkisch, Schwedisch, Dänisch und Norwegisch. Bei Abweichungen gilt die englische Fassung.
