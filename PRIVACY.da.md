# 🇪🇺 Privatlivspolitik for BLEUnlock LTS

[English](PRIVACY.md) | [Français](PRIVACY.fr.md) | [Español](PRIVACY.es.md) | [Deutsch](PRIVACY.de.md) | [日本語](PRIVACY.ja.md) | [简体中文](PRIVACY.zh-Hans.md) | [Türkçe](PRIVACY.tr.md) | [Svenska](PRIVACY.sv.md) | [Dansk](PRIVACY.da.md) | [Norsk](PRIVACY.nb.md)

*Sidst opdateret: 25.11.2026. Gælder for BLEUnlock LTS 3.x.*

> Dette dokument beskriver, hvad softwaren gør. Det er en gennemsigtighedserklæring, ikke juridisk rådgivning eller en juridisk certificering.

## 1. Resumé

- BLEUnlock LTS kører helt og holdent på din Mac. Ingen konti, ingen analyse, ingen reklamer, ingen sporing og ingen nedbrudsrapporter.
- Vedligeholderen driver ingen server til appen og modtager, gemmer eller behandler ikke personoplysninger fra den.
- Den eneste netværksfunktion er opdateringstjekket. Det er **valgfrit** og sender én HTTPS-forespørgsel til `api.github.com`, som kan se din IP-adresse (detaljer i afsnit 5).
- Din Mac's loginadgangskode gemmes kun, hvis du vælger tilstanden *Lås og lås op*, i macOS Nøglering og kun på denne enhed. Tilstanden *Kun lås* beder aldrig om og gemmer aldrig adgangskoden.
- Du kan slette alt, appen gemmer, med ét klik: *Sikkerhed → Slet alle data…*.

## 2. Hvem der er ansvarlig

- Vedligeholder: GitHub-kontoen **Altissnono** ([profil](https://github.com/Altissnono), repository [BLEUnlock-LTS](https://github.com/Altissnono/BLEUnlock-LTS)). Oprindeligt projekt af Takeshi Sone (MIT-licens).
- Fordi appen ikke sender personoplysninger til vedligeholderen, er vedligeholderen hverken dataansvarlig eller databehandler for dine oplysninger. Oplysningerne beskrevet nedenfor forbliver under din kontrol på din egen Mac.
- Den eneste tredjepart er GitHub (afsnit 10), og kun hvis du tillader opdateringstjekket eller henter en version.

## 3. Hvad appen behandler

Alt i denne tabel behandles lokalt på din Mac. Intet af det sendes til vedligeholderen eller nogen server.

| Oplysning | Formål | Hvor den findes | Forlader den Mac’en? |
|---|---|---|---|
| Identifikator (CoreBluetooth-UUID) for de Bluetooth-enheder, du vælger, og deres signalstyrke (RSSI) | Afgøre om din enhed er tæt på, for at låse eller låse op | Identifikatoren i appens indstillinger; signalværdier kun i hukommelsen | Nej |
| Navn, producent, model og signalstyrke for Bluetooth-enheder i nærheden, **kun mens menuen Enhed er åben** | Vise listen, så du kan vælge din enhed | Kun i hukommelsen, kasseres efter mindst 30 sekunder uden observation og når appen afsluttes | Nej |
| Din Mac’s loginadgangskode (kun i tilstanden *Lås og lås op*) | Indtaste den på låseskærmen | macOS Nøglering, tjeneste = appens bundle-identifikator, “kun denne enhed” (synkroniseres ikke med iCloud) | Nej |
| Indstillinger (tærskler, forsinkelser, valgmuligheder) | Konfiguration | Appens indstillingsfil (afsnit 7) | Nej |
| Diagnostik: signalværdier, timere, låsebeslutninger (ingen navne, ingen identifikatorer, ingen adgangskode) | Fejlfinding | macOS’ samlede log på din Mac, roteres automatisk af macOS | Nej |
| Dato for sidste opdateringstjek | Begrænse tjek til ét om dagen | Appens indstillingsfil | Nej |
| Ejerens navn og størrelsen på det forreste vindue (intet indhold, ingen titler) | Sikre at låseskærmen er forrest, før adgangskoden indtastes | Gemmes ikke | Nej |
| Underretninger du har slået til (låsning, oplåsning, opdatering) | Informere dig | Lokale macOS-underretninger | Nej |
| Valgfrit script `event`, som du selv skriver | Din egen automatisering | `~/Library/Application Scripts/io.github.altissnono.BLEUnlock/` | Kun hvis dit eget script sender noget |

## 4. Hvad appen ikke gør

- Ingen analyse, telemetri, brugsstatistik, A/B-test, reklame-id eller fingeraftryk.
- Ingen nedbrudsrapporter sendt af appen. (macOS kan tilbyde at dele diagnostik med Apple; det er en systemindstilling under *Anonymitet og sikkerhed → Analyse og forbedringer*, uafhængig af denne app.)
- Ingen adgang til dine kontakter, kalender, fotos, placering, mikrofon, kamera eller filer.
- Ingen læsning af skærmindhold og ingen tilladelse til skærmoptagelse. Vinduestjekket læser kun ejerens navn og vinduernes størrelse.
- Ingen afsendelse af Bluetooth-enheders navne, identifikatorer eller signalværdier nogen steder hen.
- Der bliver aldrig bedt om konto, login, e-mailadresse eller telefonnummer.
- Ingen tredjepartsbiblioteker eller SDK’er (appen bruger kun Apples systemframeworks).

## 5. Netværksadgang

- Som standard **kontakter appen ingen server**.
- **Opdateringstjek (valgfrit):** Hvis du tillader det ved første start eller under *Indstillinger → Automatisk opdateringstjek*, sender appen højst én forespørgsel om dagen. Hvis du trykker på *Søg efter opdateringer*, udløser du selv én enkelt forespørgsel.
- Forespørgslen er `GET https://api.github.com/repos/Altissnono/BLEUnlock-LTS/releases/latest` med headerne `User-Agent: BLEUnlock-LTS` og `Accept: application/vnd.github+json`. Der sendes ingen cookie, intet kontotoken, intet versionsnummer, ingen enhedsoplysninger og ingen indstillinger.
- GitHub ser nødvendigvis din **IP-adresse** og tidspunktet for forespørgslen, som enhver webserver. Sessionen er midlertidig (ingen cookies, ingen diskcache), omdirigeringer afvises, svarets størrelse er begrænset, og kun versionstagets navn læses for at sammenligne versionsnumre.
- Hvis svaret er ugyldigt, eller værten ikke er `api.github.com`, ignoreres det.
- Links i Om-vinduet og menuen (*Privatlivspolitik*, *Hent*) åbnes kun i din browser, når du klikker. Din browser taler så med GitHub efter sine egne regler.
- Der er ingen anden netværksforbindelse i koden. CI lader buildet fejle, hvis en anden vært dukker op.

## 6. Tilladelser forklaret

- **Bluetooth:** nødvendig for at se din enheds signal. Mens menuen Enhed er åben, forbinder appen også kortvarigt til enheder i nærheden, hvis signal er stærkere end din indstilling for mindste signal, kun for at læse standardens “Enhedsoplysninger” (producent og model), så listen bliver læsbar. Intet gemmes eller sendes.
- **Tilgængelighed** (kun i tilstanden *Lås og lås op*): nødvendig for at indtaste din adgangskode på låseskærmen. Appen læser ikke, hvad der står på skærmen.
- **Underretninger:** valgfrie, så du får besked om låsning, oplåsning eller en opdatering.
- **Nøglering:** gemmer din adgangskode i tilstanden *Lås og lås op*. Emnet er markeret “kun denne enhed” og synkroniseres ikke.
- **Login-emne:** den valgfrie “Start ved login” bruger macOS’ standardtjeneste. *Slet alle data…* fjerner den.
- Systemfiler der læses: macOS’ Bluetooth-cache (`/Library/Preferences/com.apple.Bluetooth.plist`, `/Library/Bluetooth/*.db`), skrivebeskyttet, for at vise navne og adresser på listen.

## 7. Indstillingsnøgler (fuld oversigt)

Appen gemmer kun disse nøgler i `~/Library/Preferences/io.github.altissnono.BLEUnlock.plist`:

| Nøgler | Betydning |
|---|---|
| `mode` | Valgt tilstand: Lås og lås op, eller Kun lås |
| `device`, `device2` | Identifikatorer for den valgte enhed og den valgfrie anden enhed |
| `lockRSSI`, `unlockRSSI`, `thresholdRSSI`, `timeout`, `lockDelay`, `confirmDelay`, `maxUnlockAttempts`, `robustFilter`, `passiveMode` | Signaltærskler, forsinkelser, forsøgsgrænse, filter og søgetilstand |
| `wakeOnProximity`, `wakeWithoutUnlocking`, `pauseItunes`, `screensaver`, `sleepDisplay`, `lockOnSleep`, `lockOnBluetoothOff`, `verifyFrontWindow` | Adfærdsvalg, du kan slå til eller fra |
| `notifications`, `notifyOnUnlock`, `showRSSI`, `launchAtLogin` | Valg for underretninger og visning |
| `updateChecks`, `lastUpdateCheck` | Dit samtykke til opdateringstjek og datoen for det seneste tjek |

## 8. Hvor dine data er, og hvordan du sletter dem

1. **Alt på én gang:** menuen *Sikkerhed → Slet alle data…*. Den sletter adgangskoden i Nøglering, alle indstillinger og login-emnet og afslutter derefter appen.
2. **Kun adgangskoden:** menuen *Sikkerhed → Fjern gemt adgangskode*, eller skift til tilstanden *Kun lås* (adgangskoden slettes, når du har bekræftet).
3. **Manuelt:** slet `~/Library/Preferences/io.github.altissnono.BLEUnlock.plist` og Nøglering-emnet *BLEUnlock* i *Nøglering*, og læg appen i papirkurven.
4. **Diagnostiklog:** administreres af macOS og udløber automatisk. For at slette alle systemlogs nu, kør `sudo log erase --all` i Terminal.
5. **Dit eget `event`-script** i `~/Library/Application Scripts/io.github.altissnono.BLEUnlock/` er dit; appen opretter eller sletter aldrig dit script.

## 9. Opbevaring

- Indstillinger og Nøglering-emnet bliver, indtil du sletter dem (afsnit 8).
- Signalværdier og oplysninger om enheder i nærheden ligger i hukommelsen og kasseres, når appen afsluttes (en enhed på listen udløber efter mindst 30 sekunder uden observation).
- Vedligeholderen opbevarer intet, fordi intet modtages.

## 10. Tredjeparter og internationale overførsler

- **GitHub (GitHub, Inc., et amerikansk selskab i Microsoft):** hoster kildekoden og versionerne og besvarer det valgfrie opdateringstjek. Når du henter en version eller tillader opdateringstjekket, modtager GitHub din IP-adresse og behandler den efter egne vilkår og egen privatlivserklæring. Vedligeholderen har ingen kontrol over dette og modtager ikke disse data.
- Fordi GitHub er et amerikansk selskab, kan sådanne forespørgsler indebære en overførsel af din IP-adresse uden for EU/EØS. For helt at undgå det, lad opdateringstjekket være slået fra og byg appen fra kildekoden (afsnit 14).
- Der er ingen anden modtager: ingen analyseleverandør, intet reklamenetværk, ingen tjeneste til nedbrudsrapporter, ingen sky.

## 11. Retsgrundlag og dine rettigheder (GDPR)

- **Opdateringstjek:** dit samtykke (art. 6, stk. 1, litra a, i GDPR), som du når som helst kan trække tilbage under *Indstillinger → Automatisk opdateringstjek* eller ved aldrig at trykke på *Søg efter opdateringer*.
- **Lokal behandling på din Mac:** oplysningerne i afsnit 3 når aldrig vedligeholderen. Du har kontrollen og kan se eller slette dem (afsnit 8).
- **Dine rettigheder** (indsigt, berigtigelse, sletning, begrænsning, dataportabilitet, indsigelse, art. 15 til 21): vedligeholderen har ingen oplysninger om dig, så der er intet at anmode om hos vedligeholderen; brug værktøjerne i afsnit 8 på din egen enhed.
- **Klage:** du kan klage til din nationale databeskyttelsesmyndighed (for eksempel Datatilsynet i Danmark og Norge, IMY i Sverige, CNIL i Frankrig, BfDI i Tyskland, AEPD i Spanien).
- Dette er en beskrivelse i almindeligt sprog, ikke juridisk rådgivning. Hvis du bruger appen i en organisation, er du selv ansvarlig for din egen vurdering af overholdelse.

## 12. Sikkerhedsforanstaltninger

- Hardened Runtime, ingen tredjepartskode og, fra version 3.2.5, ingen fejlfindingsrettighed (kontrolleres ved hvert build; tidligere 3.x-versioner havde en ved en fejl).
- Adgangskoden findes kun i Nøglering, slettes fra hukommelsen efter indtastning, indtastes kun når låseskærmen er forrest, med forsøgsgrænse og bekræftelsesforsinkelse.
- Hærdet opdateringstjek (værtskontrol, ingen omdirigeringer, størrelsesgrænse, validering af tagnavn).
- Detaljer og kendte begrænsninger: [SECURITY_AUDIT.md](SECURITY_AUDIT.md).

## 13. Børn

- Appen er ikke rettet mod børn og indsamler ikke personoplysninger fra nogen.

## 14. Sådan kontrollerer du udsagnene selv

1. Læs kildekoden: den er lille (nogle få tusind linjer) og offentlig i [repositoryet](https://github.com/Altissnono/BLEUnlock-LTS).
2. Kør `scripts/security-check.sh`: det fejler, hvis en anden vært end github.com dukker op, hvis et sporings-SDK refereres, hvis automatisk netværksadgang ikke er valgfri, eller hvis privatlivsmanifestet erklærer sporing eller indsamlede data. Det kører ved hvert push (CI).
3. Undersøg den byggede app: `scripts/verify-build.sh /Applications/BLEUnlock.app` kontrollerer rettigheder og linkede biblioteker.
4. Overvåg netværket: med Little Snitch, LuLu eller `nettop -p <pid>` ser du ingen forbindelse, medmindre du udløser et opdateringstjek.
5. Byg den selv med Xcode fra kildekoden; ingen binær fra vedligeholderen er nødvendig.
6. Læs Apples privatlivsmanifest i appen (`PrivacyInfo.xcprivacy`): ingen sporing, ingen indsamlede datatyper.

## 15. Ændringer af denne politik

- Ændringer sker i dette repository; Git-historikken viser præcis, hvad der er ændret, og hvornår. Datoen øverst opdateres ved hver ændring.
- Hvis en fremtidig version tilføjer dataindsamling eller en netværksfunktion, beskrives den her før udgivelsen og bliver valgfri.

## 16. Kontakt

- Spørgsmål om denne politik: opret en issue på <https://github.com/Altissnono/BLEUnlock-LTS/issues>. Skriv **ikke** personoplysninger dér.
- Sprog: denne politik findes på engelsk, fransk, spansk, tysk, japansk, forenklet kinesisk, tyrkisk, svensk, dansk og norsk. Hvis oversættelserne afviger, gælder den engelske version.
