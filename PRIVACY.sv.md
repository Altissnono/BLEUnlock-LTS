# 🇪🇺 Integritetspolicy för BLEUnlock LTS

[English](PRIVACY.md) | [Français](PRIVACY.fr.md) | [Español](PRIVACY.es.md) | [Deutsch](PRIVACY.de.md) | [日本語](PRIVACY.ja.md) | [简体中文](PRIVACY.zh-Hans.md) | [Türkçe](PRIVACY.tr.md) | [Svenska](PRIVACY.sv.md) | [Dansk](PRIVACY.da.md) | [Norsk](PRIVACY.nb.md)

*Senast uppdaterad: 2026-11-25. Gäller BLEUnlock LTS 3.x.*

> Det här dokumentet beskriver vad programvaran gör. Det är en transparensförklaring, inte juridisk rådgivning eller en juridisk certifiering.

## 1. Sammanfattning

- BLEUnlock LTS körs helt på din Mac. Inga konton, ingen analys, ingen reklam, ingen spårning och inga kraschrapporter.
- Underhållaren driver ingen server för appen och tar inte emot, lagrar eller behandlar personuppgifter från den.
- Den enda nätverksfunktionen är uppdateringskontrollen. Den är **frivillig** och skickar ett HTTPS-anrop till `api.github.com`, som kan se din IP-adress (detaljer i avsnitt 5).
- Ditt inloggningslösenord till Macen lagras bara om du väljer läget *Lås och lås upp*, i macOS Nyckelring och endast på den här enheten. Läget *Endast lås* ber aldrig om och lagrar aldrig lösenordet.
- Du kan radera allt appen lagrar med ett klick: *Säkerhet → Radera all data…*.

## 2. Vem som är ansvarig

- Underhållare: GitHub-kontot **Altissnono** ([profil](https://github.com/Altissnono), repository [BLEUnlock-LTS](https://github.com/Altissnono/BLEUnlock-LTS)). Ursprungligt projekt av Takeshi Sone (MIT-licens).
- Eftersom appen inte skickar några personuppgifter till underhållaren är denne varken personuppgiftsansvarig eller personuppgiftsbiträde för dina uppgifter. Uppgifterna som beskrivs nedan stannar under din kontroll på din egen Mac.
- Den enda tredje part som är inblandad är GitHub (avsnitt 10), och bara om du tillåter uppdateringskontrollen eller laddar ner en version.

## 3. Vad appen behandlar

Allt i den här tabellen behandlas lokalt på din Mac. Inget av det skickas till underhållaren eller någon server.

| Uppgift | Syfte | Var den finns | Lämnar den Macen? |
|---|---|---|---|
| Identifierare (CoreBluetooth-UUID) för de Bluetooth-enheter du väljer och deras signalstyrka (RSSI) | Avgöra om din enhet är nära, för att låsa eller låsa upp | Identifieraren i appens inställningar; signalvärden endast i minnet | Nej |
| Namn, tillverkare, modell och signalstyrka för Bluetooth-enheter i närheten, **endast medan menyn Enhet är öppen** | Visa listan så att du kan välja din enhet | Endast i minnet, kastas efter minst 30 sekunder utan observation och när appen avslutas | Nej |
| Ditt inloggningslösenord till Macen (endast i läget *Lås och lås upp*) | Skriva det på låsskärmen | macOS Nyckelring, tjänst = appens paketidentifierare, ”endast den här enheten” (synkas inte med iCloud) | Nej |
| Inställningar (tröskelvärden, fördröjningar, alternativ) | Konfiguration | Appens inställningsfil (avsnitt 7) | Nej |
| Diagnostik: signalvärden, timers, låsbeslut (inga namn, inga identifierare, inget lösenord) | Felsökning | macOS enhetliga logg på din Mac, roteras automatiskt av macOS | Nej |
| Datum för senaste uppdateringskontrollen | Begränsa kontrollerna till en per dag | Appens inställningsfil | Nej |
| Ägarnamn och storlek för det översta fönstret (inget innehåll, inga titlar) | Säkerställa att låsskärmen ligger överst innan lösenordet skrivs | Lagras inte | Nej |
| Aviseringar du aktiverat (låsning, upplåsning, uppdatering) | Informera dig | Lokala macOS-aviseringar | Nej |
| Valfritt skript `event` som du skriver själv | Din egen automatisering | `~/Library/Application Scripts/io.github.altissnono.BLEUnlock/` | Bara om ditt eget skript skickar något |

## 4. Vad appen inte gör

- Ingen analys, telemetri, användningsstatistik, A/B-test, reklam-ID eller fingeravtryck.
- Inga kraschrapporter skickas av appen. (macOS kan erbjuda att dela diagnostik med Apple; det är en systeminställning under *Integritet och säkerhet → Analys och förbättringar*, oberoende av den här appen.)
- Ingen åtkomst till dina kontakter, din kalender, dina foton, din plats, mikrofon, kamera eller dina filer.
- Ingen läsning av skärminnehåll och ingen behörighet för skärminspelning. Fönsterkontrollen läser bara ägarnamn och storlek på fönster.
- Ingen sändning av Bluetooth-enheters namn, identifierare eller signalvärden någonstans.
- Inget konto, ingen inloggning, ingen e-postadress och inget telefonnummer efterfrågas någonsin.
- Inga tredjepartsbibliotek eller SDK:er (appen använder bara Apples systemramverk).

## 5. Nätverksåtkomst

- Som standard **kontaktar appen ingen server**.
- **Uppdateringskontroll (frivillig):** Om du tillåter den vid första start eller under *Alternativ → Automatisk uppdateringskontroll* gör appen högst ett anrop per dag. Om du trycker på *Sök efter uppdateringar* utlöser du själv ett enda anrop.
- Anropet är `GET https://api.github.com/repos/Altissnono/BLEUnlock-LTS/releases/latest` med rubrikerna `User-Agent: BLEUnlock-LTS` och `Accept: application/vnd.github+json`. Ingen cookie, inget kontotoken, inget versionsnummer, ingen enhetsinformation och ingen inställning skickas.
- GitHub ser nödvändigtvis din **IP-adress** och tidpunkten för anropet, som vilken webbserver som helst. Sessionen är tillfällig (inga cookies, ingen diskcache), omdirigeringar avvisas, svarets storlek är begränsad och bara versionstaggens namn läses för att jämföra versionsnummer.
- Om svaret är ogiltigt eller värden inte är `api.github.com` ignoreras det.
- Länkar i Om-rutan och menyn (*Integritetspolicy*, *Hämta*) öppnas i din webbläsare bara när du klickar. Din webbläsare pratar sedan med GitHub enligt sina egna regler.
- Det finns ingen annan nätverksanslutning i koden. CI låter bygget misslyckas om en annan värd dyker upp.

## 6. Behörigheter förklarade

- **Bluetooth:** behövs för att se din enhets signal. Medan menyn Enhet är öppen ansluter appen också kort till enheter i närheten vars signal är starkare än din inställning för minsta signal, bara för att läsa standardens ”Enhetsinformation” (tillverkare och modell) så att listan blir läsbar. Inget lagras eller skickas.
- **Tillgänglighet** (endast i läget *Lås och lås upp*): behövs för att skriva ditt lösenord på låsskärmen. Appen läser inte vad som visas på skärmen.
- **Aviseringar:** valfria, för att tala om att Macen låsts, låsts upp eller att en uppdatering finns.
- **Nyckelring:** lagrar ditt lösenord i läget *Lås och lås upp*. Objektet är markerat ”endast den här enheten” och synkas inte.
- **Inloggningsobjekt:** det valfria ”Starta vid inloggning” använder macOS standardtjänst. *Radera all data…* tar bort det.
- Systemfiler som läses: macOS Bluetooth-cache (`/Library/Preferences/com.apple.Bluetooth.plist`, `/Library/Bluetooth/*.db`), skrivskyddat, för att visa namn och adresser i listan.

## 7. Inställningsnycklar (fullständig förteckning)

Appen lagrar bara dessa nycklar i `~/Library/Preferences/io.github.altissnono.BLEUnlock.plist`:

| Nycklar | Betydelse |
|---|---|
| `mode` | Valt läge: Lås och lås upp, eller Endast lås |
| `device`, `device2` | Identifierare för vald enhet och den valfria andra enheten |
| `lockRSSI`, `unlockRSSI`, `thresholdRSSI`, `timeout`, `lockDelay`, `confirmDelay`, `maxUnlockAttempts`, `robustFilter`, `passiveMode` | Signaltrösklar, fördröjningar, försöksgräns, filter och sökläge |
| `wakeOnProximity`, `wakeWithoutUnlocking`, `pauseItunes`, `screensaver`, `sleepDisplay`, `lockOnSleep`, `lockOnBluetoothOff`, `verifyFrontWindow` | Beteendealternativ som du kan slå på eller av |
| `notifications`, `notifyOnUnlock`, `showRSSI`, `launchAtLogin` | Alternativ för aviseringar och visning |
| `updateChecks`, `lastUpdateCheck` | Ditt samtycke till uppdateringskontroll och datum för senaste kontroll |

## 8. Var dina uppgifter finns och hur du raderar dem

1. **Allt på en gång:** menyn *Säkerhet → Radera all data…*. Den raderar lösenordet i Nyckelringen, alla inställningar och inloggningsobjektet och avslutar sedan appen.
2. **Bara lösenordet:** menyn *Säkerhet → Ta bort sparat lösenord*, eller byt till läget *Endast lås* (lösenordet raderas efter att du bekräftat).
3. **Manuellt:** radera `~/Library/Preferences/io.github.altissnono.BLEUnlock.plist` och Nyckelringsobjektet *BLEUnlock* i *Nyckelhanterare*, och lägg appen i papperskorgen.
4. **Diagnostikloggen:** hanteras av macOS och löper ut automatiskt. För att radera alla systemloggar nu, kör `sudo log erase --all` i Terminal.
5. **Ditt eget `event`-skript** i `~/Library/Application Scripts/io.github.altissnono.BLEUnlock/` är ditt; appen skapar eller raderar aldrig ditt skript.

## 9. Lagringstid

- Inställningar och Nyckelringsobjektet finns kvar tills du raderar dem (avsnitt 8).
- Signalvärden och information om enheter i närheten finns i minnet och kastas när appen avslutas (en listad enhet försvinner efter minst 30 sekunder utan observation).
- Underhållaren lagrar inget, eftersom inget tas emot.

## 10. Tredje part och internationella överföringar

- **GitHub (GitHub, Inc., ett amerikanskt företag inom Microsoft):** är värd för källkoden och versionerna och svarar på den valfria uppdateringskontrollen. När du laddar ner en version eller tillåter uppdateringskontrollen får GitHub din IP-adress och behandlar den enligt sina egna villkor och sitt integritetsmeddelande. Underhållaren har ingen kontroll över detta och får inga av dessa uppgifter.
- Eftersom GitHub är ett amerikanskt företag kan sådana anrop innebära en överföring av din IP-adress utanför EU/EES. För att helt undvika det, låt uppdateringskontrollen vara av och bygg appen från källkoden (avsnitt 14).
- Det finns ingen annan mottagare: ingen analysleverantör, inget reklamnätverk, ingen kraschrapporttjänst, inget moln.

## 11. Rättslig grund och dina rättigheter (GDPR)

- **Uppdateringskontroll:** ditt samtycke (art. 6.1 a GDPR), som du när som helst kan återkalla under *Alternativ → Automatisk uppdateringskontroll* eller genom att aldrig trycka på *Sök efter uppdateringar*.
- **Lokal behandling på din Mac:** uppgifterna i avsnitt 3 når aldrig underhållaren. Du har kontrollen och kan granska eller radera dem (avsnitt 8).
- **Dina rättigheter** (tillgång, rättelse, radering, begränsning, dataportabilitet, invändning, art. 15 till 21): underhållaren har inga uppgifter om dig, så det finns inget att begära därifrån; använd verktygen i avsnitt 8 på din egen enhet.
- **Klagomål:** du kan lämna klagomål till din nationella dataskyddsmyndighet (till exempel IMY i Sverige, Datatilsynet i Danmark och Norge, CNIL i Frankrike, BfDI i Tyskland, AEPD i Spanien).
- Det här är en beskrivning på klarspråk, inte juridisk rådgivning. Om du använder appen i en organisation ansvarar du själv för din egen efterlevnadsbedömning.

## 12. Säkerhetsåtgärder

- Hardened Runtime, ingen tredjepartskod och, från version 3.2.5, ingen felsökningsbehörighet (kontrolleras vid varje bygge; tidigare 3.x-versioner hade en av misstag).
- Lösenordet finns bara i Nyckelringen, raderas ur minnet efter inmatning, skrivs bara när låsskärmen ligger överst, med försöksgräns och bekräftelsefördröjning.
- Härdad uppdateringskontroll (värdkontroll, inga omdirigeringar, storleksgräns, validering av taggnamn).
- Detaljer och kända begränsningar: [SECURITY_AUDIT.md](SECURITY_AUDIT.md).

## 13. Barn

- Appen riktar sig inte till barn och samlar inte in personuppgifter från någon.

## 14. Så kontrollerar du de här påståendena själv

1. Läs källkoden: den är liten (några tusen rader) och offentlig i [repositoryt](https://github.com/Altissnono/BLEUnlock-LTS).
2. Kör `scripts/security-check.sh`: det misslyckas om en annan värd än github.com dyker upp, om ett spårnings-SDK refereras, om automatisk nätverksåtkomst inte är frivillig eller om integritetsmanifestet deklarerar spårning eller insamlade data. Det körs vid varje push (CI).
3. Granska den byggda appen: `scripts/verify-build.sh /Applications/BLEUnlock.app` kontrollerar behörigheter och länkade bibliotek.
4. Övervaka nätverket: med Little Snitch, LuLu eller `nettop -p <pid>` ser du ingen anslutning om du inte utlöser en uppdateringskontroll.
5. Bygg själv med Xcode från källkoden; ingen binär från underhållaren behövs.
6. Läs Apples integritetsmanifest i appen (`PrivacyInfo.xcprivacy`): ingen spårning, inga insamlade datatyper.

## 15. Ändringar i den här policyn

- Ändringar görs i det här repositoryt; Git-historiken visar exakt vad som ändrats och när. Datumet högst upp uppdateras vid varje ändring.
- Om en framtida version lägger till datainsamling eller en nätverksfunktion beskrivs den här före lansering och blir frivillig.

## 16. Kontakt

- Frågor om den här policyn: öppna ett ärende på <https://github.com/Altissnono/BLEUnlock-LTS/issues>. Publicera **inte** personuppgifter där.
- Språk: den här policyn finns på engelska, franska, spanska, tyska, japanska, förenklad kinesiska, turkiska, svenska, danska och norska. Om översättningarna skiljer sig gäller den engelska versionen.
