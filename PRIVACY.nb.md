# 🇪🇺 Personvernerklæring for BLEUnlock LTS

[English](PRIVACY.md) | [Français](PRIVACY.fr.md) | [Español](PRIVACY.es.md) | [Deutsch](PRIVACY.de.md) | [日本語](PRIVACY.ja.md) | [简体中文](PRIVACY.zh-Hans.md) | [Türkçe](PRIVACY.tr.md) | [Svenska](PRIVACY.sv.md) | [Dansk](PRIVACY.da.md) | [Norsk](PRIVACY.nb.md)

*Sist oppdatert: 25.11.2026. Gjelder for BLEUnlock LTS 3.x.*

> Dette dokumentet beskriver hva programvaren gjør. Det er en åpenhetserklæring, ikke juridisk rådgivning eller en juridisk sertifisering.

## 1. Sammendrag

- BLEUnlock LTS kjører helt og holdent på Macen din. Ingen kontoer, ingen analyse, ingen reklame, ingen sporing og ingen krasjrapporter.
- Vedlikeholderen driver ingen server for appen og mottar, lagrer eller behandler ikke personopplysninger fra den.
- Den eneste nettverksfunksjonen er oppdateringssjekken. Den er **valgfri** og sender én HTTPS-forespørsel til `api.github.com`, som kan se IP-adressen din (detaljer i avsnitt 5).
- Innloggingspassordet til Macen lagres bare hvis du velger modusen *Lås og lås opp*, i macOS Nøkkelring og bare på denne enheten. Modusen *Bare lås* ber aldri om og lagrer aldri passordet.
- Du kan slette alt appen lagrer med ett klikk: *Sikkerhet → Slett alle data…*.

## 2. Hvem som er ansvarlig

- Vedlikeholder: GitHub-kontoen **Altissnono** ([profil](https://github.com/Altissnono), repository [BLEUnlock-LTS](https://github.com/Altissnono/BLEUnlock-LTS)). Opprinnelig prosjekt av Takeshi Sone (MIT-lisens).
- Fordi appen ikke sender personopplysninger til vedlikeholderen, er vedlikeholderen verken behandlingsansvarlig eller databehandler for opplysningene dine. Opplysningene beskrevet nedenfor blir under din kontroll på din egen Mac.
- Den eneste tredjeparten som er involvert er GitHub (avsnitt 10), og bare hvis du tillater oppdateringssjekken eller laster ned en versjon.

## 3. Hva appen behandler

Alt i denne tabellen behandles lokalt på Macen din. Ingenting av det sendes til vedlikeholderen eller noen server.

| Opplysning | Formål | Hvor den finnes | Forlater den Macen? |
|---|---|---|---|
| Identifikator (CoreBluetooth-UUID) for Bluetooth-enhetene du velger, og signalstyrken deres (RSSI) | Avgjøre om enheten din er nær, for å låse eller låse opp | Identifikatoren i appens innstillinger; signalverdier bare i minnet | Nei |
| Navn, produsent, modell og signalstyrke for Bluetooth-enheter i nærheten, **bare mens menyen Enhet er åpen** | Vise listen slik at du kan velge enheten din | Bare i minnet, forkastes etter minst 30 sekunder uten observasjon og når appen avsluttes | Nei |
| Innloggingspassordet til Macen (bare i modusen *Lås og lås opp*) | Skrive det inn på låseskjermen | macOS Nøkkelring, tjeneste = appens bundle-identifikator, «bare denne enheten» (synkroniseres ikke med iCloud) | Nei |
| Innstillinger (terskler, forsinkelser, valg) | Konfigurasjon | Appens innstillingsfil (avsnitt 7) | Nei |
| Diagnostikk: signalverdier, tidtakere, låsebeslutninger (ingen navn, ingen identifikatorer, ikke passordet) | Feilsøking | macOS’ samlede logg på Macen din, roteres automatisk av macOS | Nei |
| Dato for siste oppdateringssjekk | Begrense sjekkene til én per dag | Appens innstillingsfil | Nei |
| Eiernavn og størrelse på det fremste vinduet (ikke innhold, ikke titler) | Sikre at låseskjermen er fremst før passordet skrives | Lagres ikke | Nei |
| Varsler du har slått på (låsing, opplåsing, oppdatering) | Informere deg | Lokale macOS-varsler | Nei |
| Valgfritt skript `event` som du skriver selv | Din egen automatisering | `~/Library/Application Scripts/io.github.altissnono.BLEUnlock/` | Bare hvis ditt eget skript sender noe |

## 4. Hva appen ikke gjør

- Ingen analyse, telemetri, bruksstatistikk, A/B-testing, reklame-ID eller fingeravtrykk.
- Ingen krasjrapporter sendt av appen. (macOS kan tilby å dele diagnostikk med Apple; det er en systeminnstilling under *Personvern og sikkerhet → Analyse og forbedringer*, uavhengig av denne appen.)
- Ingen tilgang til kontakter, kalender, bilder, posisjon, mikrofon, kamera eller filer.
- Ingen lesing av skjerminnhold og ingen tillatelse til skjermopptak. Vindussjekken leser bare eiernavn og størrelse på vinduer.
- Ingen sending av Bluetooth-enheters navn, identifikatorer eller signalverdier noe sted.
- Det blir aldri bedt om konto, innlogging, e-postadresse eller telefonnummer.
- Ingen tredjepartsbiblioteker eller SDK-er (appen bruker bare Apples systemrammeverk).

## 5. Nettverkstilgang

- Som standard **kontakter appen ingen server**.
- **Oppdateringssjekk (valgfri):** Hvis du tillater den ved første oppstart eller under *Valg → Automatisk oppdateringssjekk*, sender appen høyst én forespørsel per dag. Hvis du trykker på *Se etter oppdateringer*, utløser du selv én enkelt forespørsel.
- Forespørselen er `GET https://api.github.com/repos/Altissnono/BLEUnlock-LTS/releases/latest` med hodene `User-Agent: BLEUnlock-LTS` og `Accept: application/vnd.github+json`. Ingen informasjonskapsel, ingen kontotoken, ikke versjonsnummer, ingen enhetsinformasjon og ingen innstillinger sendes.
- GitHub ser nødvendigvis **IP-adressen** din og tidspunktet for forespørselen, som enhver nettserver. Økten er midlertidig (ingen informasjonskapsler, ingen diskbuffer), omdirigeringer avvises, størrelsen på svaret er begrenset, og bare navnet på versjonstaggen leses for å sammenligne versjonsnumre.
- Hvis svaret er ugyldig, eller verten ikke er `api.github.com`, ignoreres det.
- Lenker i Om-vinduet og menyen (*Personvernerklæring*, *Last ned*) åpnes i nettleseren din bare når du klikker. Nettleseren din snakker da med GitHub etter sine egne regler.
- Det finnes ingen annen nettverksforbindelse i koden. CI lar bygget feile hvis en annen vert dukker opp.

## 6. Tillatelser forklart

- **Bluetooth:** nødvendig for å se signalet fra enheten din. Mens menyen Enhet er åpen kobler appen seg også kort til enheter i nærheten med sterkere signal enn innstillingen for minste signal, bare for å lese standardens «Enhetsinformasjon» (produsent og modell) slik at listen blir lesbar. Ingenting lagres eller sendes.
- **Tilgjengelighet** (bare i modusen *Lås og lås opp*): nødvendig for å skrive passordet ditt på låseskjermen. Appen leser ikke hva som vises på skjermen.
- **Varsler:** valgfrie, for å si fra om låsing, opplåsing eller en oppdatering.
- **Nøkkelring:** lagrer passordet ditt i modusen *Lås og lås opp*. Elementet er merket «bare denne enheten» og synkroniseres ikke.
- **Påloggingselement:** det valgfrie «Start ved innlogging» bruker macOS’ standardtjeneste. *Slett alle data…* fjerner det.
- Systemfiler som leses: macOS’ Bluetooth-buffer (`/Library/Preferences/com.apple.Bluetooth.plist`, `/Library/Bluetooth/*.db`), skrivebeskyttet, for å vise navn og adresser i listen.

## 7. Innstillingsnøkler (full oversikt)

Appen lagrer bare disse nøklene i `~/Library/Preferences/io.github.altissnono.BLEUnlock.plist`:

| Nøkler | Betydning |
|---|---|
| `mode` | Valgt modus: Lås og lås opp, eller Bare lås |
| `device`, `device2` | Identifikatorer for valgt enhet og den valgfrie andre enheten |
| `lockRSSI`, `unlockRSSI`, `thresholdRSSI`, `timeout`, `lockDelay`, `confirmDelay`, `maxUnlockAttempts`, `robustFilter`, `passiveMode` | Signalterskler, forsinkelser, forsøksgrense, filter og søkemodus |
| `wakeOnProximity`, `wakeWithoutUnlocking`, `pauseItunes`, `screensaver`, `sleepDisplay`, `lockOnSleep`, `lockOnBluetoothOff`, `verifyFrontWindow` | Atferdsvalg du kan slå på eller av |
| `notifications`, `notifyOnUnlock`, `showRSSI`, `launchAtLogin` | Valg for varsler og visning |
| `updateChecks`, `lastUpdateCheck` | Samtykket ditt til oppdateringssjekk og datoen for siste sjekk |

## 8. Hvor dataene dine er, og hvordan du sletter dem

1. **Alt på en gang:** menyen *Sikkerhet → Slett alle data…*. Den sletter passordet i Nøkkelringen, alle innstillinger og påloggingselementet, og avslutter deretter appen.
2. **Bare passordet:** menyen *Sikkerhet → Fjern lagret passord*, eller bytt til modusen *Bare lås* (passordet slettes etter at du har bekreftet).
3. **Manuelt:** slett `~/Library/Preferences/io.github.altissnono.BLEUnlock.plist` og Nøkkelring-elementet *BLEUnlock* i *Nøkkelringtilgang*, og legg appen i papirkurven.
4. **Diagnostikklogg:** styres av macOS og utløper automatisk. For å slette alle systemlogger nå, kjør `sudo log erase --all` i Terminal.
5. **Ditt eget `event`-skript** i `~/Library/Application Scripts/io.github.altissnono.BLEUnlock/` er ditt; appen oppretter eller sletter aldri skriptet ditt.

## 9. Lagringstid

- Innstillinger og Nøkkelring-elementet blir værende til du sletter dem (avsnitt 8).
- Signalverdier og informasjon om enheter i nærheten ligger i minnet og forkastes når appen avsluttes (en enhet i listen utløper etter minst 30 sekunder uten observasjon).
- Vedlikeholderen lagrer ingenting, fordi ingenting mottas.

## 10. Tredjeparter og internasjonale overføringer

- **GitHub (GitHub, Inc., et amerikansk selskap i Microsoft):** er vert for kildekoden og versjonene og svarer på den valgfrie oppdateringssjekken. Når du laster ned en versjon eller tillater oppdateringssjekken, mottar GitHub IP-adressen din og behandler den etter egne vilkår og egen personvernerklæring. Vedlikeholderen har ingen kontroll over dette og mottar ikke disse dataene.
- Fordi GitHub er et amerikansk selskap, kan slike forespørsler innebære en overføring av IP-adressen din utenfor EU/EØS. For å unngå det helt, la oppdateringssjekken være av og bygg appen fra kildekoden (avsnitt 14).
- Det finnes ingen andre mottakere: ingen analyseleverandør, ingen reklamenettverk, ingen tjeneste for krasjrapporter, ingen sky.

## 11. Rettslig grunnlag og rettighetene dine (GDPR)

- **Oppdateringssjekk:** samtykket ditt (art. 6 nr. 1 bokstav a i GDPR), som du når som helst kan trekke tilbake under *Valg → Automatisk oppdateringssjekk* eller ved aldri å trykke på *Se etter oppdateringer*.
- **Lokal behandling på Macen din:** opplysningene i avsnitt 3 når aldri vedlikeholderen. Du har kontrollen og kan se eller slette dem (avsnitt 8).
- **Rettighetene dine** (innsyn, retting, sletting, begrensning, dataportabilitet, innsigelse, art. 15 til 21): vedlikeholderen har ingen opplysninger om deg, så det er ingenting å be om hos vedlikeholderen; bruk verktøyene i avsnitt 8 på din egen enhet.
- **Klage:** du kan klage til din nasjonale personvernmyndighet (for eksempel Datatilsynet i Norge og Danmark, IMY i Sverige, CNIL i Frankrike, BfDI i Tyskland, AEPD i Spania).
- Dette er en beskrivelse i klart språk, ikke juridisk rådgivning. Hvis du bruker appen i en organisasjon, er du selv ansvarlig for din egen vurdering av etterlevelse.

## 12. Sikkerhetstiltak

- Hardened Runtime, ingen tredjepartskode og, fra versjon 3.2.5, ingen feilsøkingsrettighet (kontrolleres ved hvert bygg; tidligere 3.x-versjoner hadde en ved en feil).
- Passordet finnes bare i Nøkkelringen, slettes fra minnet etter inntasting, skrives bare når låseskjermen er fremst, med forsøksgrense og bekreftelsesforsinkelse.
- Herdet oppdateringssjekk (vertskontroll, ingen omdirigeringer, størrelsesgrense, validering av tagnavn).
- Detaljer og kjente begrensninger: [SECURITY_AUDIT.md](SECURITY_AUDIT.md).

## 13. Barn

- Appen er ikke rettet mot barn og samler ikke inn personopplysninger fra noen.

## 14. Slik kontrollerer du påstandene selv

1. Les kildekoden: den er liten (noen få tusen linjer) og offentlig i [repositoryet](https://github.com/Altissnono/BLEUnlock-LTS).
2. Kjør `scripts/security-check.sh`: det feiler hvis en annen vert enn github.com dukker opp, hvis et sporings-SDK refereres, hvis automatisk nettverkstilgang ikke er valgfri, eller hvis personvernmanifestet erklærer sporing eller innsamlede data. Det kjøres ved hver push (CI).
3. Undersøk den bygde appen: `scripts/verify-build.sh /Applications/BLEUnlock.app` kontrollerer rettigheter og lenkede biblioteker.
4. Overvåk nettverket: med Little Snitch, LuLu eller `nettop -p <pid>` ser du ingen forbindelse med mindre du utløser en oppdateringssjekk.
5. Bygg den selv med Xcode fra kildekoden; ingen binærfil fra vedlikeholderen er nødvendig.
6. Les Apples personvernmanifest i appen (`PrivacyInfo.xcprivacy`): ingen sporing, ingen innsamlede datatyper.

## 15. Endringer i denne erklæringen

- Endringer gjøres i dette repositoryet; Git-historikken viser nøyaktig hva som er endret og når. Datoen øverst oppdateres ved hver endring.
- Hvis en fremtidig versjon legger til datainnsamling eller en nettverksfunksjon, beskrives den her før lansering og blir valgfri.

## 16. Kontakt

- Spørsmål om denne erklæringen: opprett en issue på <https://github.com/Altissnono/BLEUnlock-LTS/issues>. Ikke publiser personopplysninger der.
- Språk: denne erklæringen finnes på engelsk, fransk, spansk, tysk, japansk, forenklet kinesisk, tyrkisk, svensk, dansk og norsk. Hvis oversettelsene avviker, gjelder den engelske versjonen.
