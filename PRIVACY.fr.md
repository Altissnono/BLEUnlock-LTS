# 🇪🇺 Politique de confidentialité de BLEUnlock LTS

[English](PRIVACY.md) | [Français](PRIVACY.fr.md) | [Español](PRIVACY.es.md) | [Deutsch](PRIVACY.de.md) | [日本語](PRIVACY.ja.md) | [简体中文](PRIVACY.zh-Hans.md) | [Türkçe](PRIVACY.tr.md) | [Svenska](PRIVACY.sv.md) | [Dansk](PRIVACY.da.md) | [Norsk](PRIVACY.nb.md)

*Dernière mise à jour : 25/11/2026. S'applique à BLEUnlock LTS 3.x.*

> Ce document décrit ce que fait le logiciel. C'est une déclaration de transparence, pas un avis juridique ni une certification.

## 1. Résumé

- BLEUnlock LTS fonctionne entièrement sur votre Mac. Aucun compte, aucune analyse d'usage, aucune publicité, aucun suivi, aucun rapport de plantage.
- Le mainteneur n'exploite aucun serveur pour l'app et ne reçoit, ne stocke ni ne traite aucune donnée personnelle issue de celle-ci.
- La seule fonction réseau est la recherche de mise à jour. Elle est **facultative** et envoie une requête HTTPS à `api.github.com`, qui peut voir votre adresse IP (détails en section 5).
- Le mot de passe de session de votre Mac n'est stocké que si vous choisissez le mode *Verrouiller et déverrouiller*, dans le Trousseau macOS, sur cet appareil uniquement. Le mode *Verrouiller seulement* ne le demande ni ne le stocke jamais.
- Vous pouvez tout effacer en un clic : *Sécurité → Effacer toutes les données…*.

## 2. Qui est responsable

- Mainteneur : le compte GitHub **Altissnono** ([profil](https://github.com/Altissnono), dépôt [BLEUnlock-LTS](https://github.com/Altissnono/BLEUnlock-LTS)). Projet d'origine de Takeshi Sone (licence MIT).
- L'app n'envoyant aucune donnée personnelle au mainteneur, celui-ci n'agit ni comme responsable de traitement ni comme sous-traitant pour vos données. Les données décrites ci-dessous restent sous votre contrôle, sur votre Mac.
- Le seul tiers concerné est GitHub (section 10), et seulement si vous activez la recherche de mise à jour ou téléchargez une version.

## 3. Ce que l'app traite

Tout ce tableau est traité localement sur votre Mac. Rien n'est envoyé au mainteneur ni à un serveur.

| Donnée | Finalité | Où elle se trouve | Quitte votre Mac ? |
|---|---|---|---|
| Identifiant (UUID CoreBluetooth) du ou des appareils Bluetooth choisis, et puissance du signal (RSSI) | Savoir si votre appareil est proche, pour verrouiller ou déverrouiller | Identifiant dans les réglages de l'app ; valeurs du signal en mémoire uniquement | Non |
| Nom, fabricant, modèle et signal des appareils Bluetooth proches, **uniquement quand le menu Appareil est ouvert** | Afficher la liste pour choisir votre appareil | En mémoire uniquement, oubliés après au moins 30 secondes sans détection et à la fermeture de l'app | Non |
| Mot de passe de session du Mac (mode *Verrouiller et déverrouiller* seulement) | Le saisir sur l'écran de verrouillage | Trousseau macOS, service = identifiant de l'app, « cet appareil uniquement » (non synchronisé avec iCloud) | Non |
| Réglages (seuils, délais, options) | Configuration | Fichier de préférences de l'app (section 7) | Non |
| Diagnostic : valeurs de signal, minuteries, décisions de verrouillage (ni noms, ni identifiants, ni mot de passe) | Dépannage | Journal unifié de macOS sur votre Mac, effacé automatiquement par macOS | Non |
| Date de la dernière recherche de mise à jour | Limiter les recherches à une par jour | Fichier de préférences de l'app | Non |
| Nom du propriétaire et taille de la fenêtre au premier plan (ni contenu, ni titres) | Vérifier que l'écran de verrouillage est devant avant de saisir le mot de passe | Non conservés | Non |
| Notifications activées (verrouillage, déverrouillage, mise à jour) | Vous informer | Notifications locales de macOS | Non |
| Script facultatif `event` que vous écrivez vous-même | Votre propre automatisation | `~/Library/Application Scripts/io.github.altissnono.BLEUnlock/` | Seulement si votre propre script envoie quelque chose |

## 4. Ce que l'app ne fait pas

- Aucune analyse d'usage, télémétrie, statistique, test A/B, identifiant publicitaire ni empreinte numérique.
- Aucun rapport de plantage envoyé par l'app. (macOS peut proposer de partager des diagnostics avec Apple : c'est un réglage système, sous *Confidentialité et sécurité → Analyse et améliorations*, indépendant de cette app.)
- Aucun accès à vos contacts, calendrier, photos, position, micro, caméra ou fichiers.
- Aucune lecture du contenu de l'écran et aucune autorisation d'enregistrement de l'écran. La vérification de fenêtre ne lit que le nom du propriétaire et la taille des fenêtres.
- Aucun envoi de noms, identifiants ou valeurs de signal d'appareils Bluetooth, nulle part.
- Aucun compte, identifiant de connexion, adresse e-mail ou numéro de téléphone n'est jamais demandé.
- Aucune bibliothèque ni SDK tiers (l'app n'utilise que les frameworks système d'Apple).

## 5. Accès réseau

- Par défaut, l'app **ne contacte aucun serveur**.
- **Recherche de mise à jour (facultative) :** si vous l'autorisez au premier lancement ou dans *Options → Recherche automatique de mises à jour*, l'app fait au plus une requête par jour. Si vous cliquez sur *Rechercher des mises à jour*, vous déclenchez vous-même une seule requête.
- La requête est `GET https://api.github.com/repos/Altissnono/BLEUnlock-LTS/releases/latest`, avec les en-têtes `User-Agent: BLEUnlock-LTS` et `Accept: application/vnd.github+json`. Aucun cookie, jeton de compte, numéro de version, information sur l'appareil ni réglage n'est envoyé.
- GitHub voit nécessairement votre **adresse IP** et l'heure de la requête, comme tout serveur web. La session est éphémère (pas de cookie, pas de cache disque), les redirections sont refusées, la taille de la réponse est plafonnée et seul le nom de la version est lu pour comparer les numéros.
- Si la réponse est invalide ou si l'hôte diffère de `api.github.com`, elle est ignorée.
- Les liens de la fenêtre À propos et du menu (*Politique de confidentialité*, *Télécharger*) s'ouvrent dans votre navigateur uniquement quand vous cliquez. Votre navigateur dialogue alors avec GitHub selon ses propres règles.
- Il n'existe aucune autre connexion réseau dans le code. La CI fait échouer la compilation si un autre hôte apparaît.

## 6. Autorisations expliquées

- **Bluetooth :** nécessaire pour voir le signal de votre appareil. Tant que le menu Appareil est ouvert, l'app se connecte aussi brièvement aux appareils proches dont le signal dépasse votre réglage de signal minimal, uniquement pour lire les « Informations sur l'appareil » standard (fabricant et modèle) afin que la liste soit lisible. Rien n'est conservé ni envoyé.
- **Accessibilité** (mode *Verrouiller et déverrouiller* seulement) : nécessaire pour saisir votre mot de passe sur l'écran de verrouillage. L'app ne lit pas ce qui est affiché à l'écran.
- **Notifications :** facultatives, pour vous indiquer un verrouillage, un déverrouillage ou une mise à jour.
- **Trousseau :** stocke votre mot de passe en mode *Verrouiller et déverrouiller*. L'élément est marqué « cet appareil uniquement » et n'est pas synchronisé.
- **Ouverture de session :** l'option « Ouvrir au démarrage de session » utilise le service standard de macOS. *Effacer toutes les données…* la retire.
- Fichiers système lus : le cache Bluetooth de macOS (`/Library/Preferences/com.apple.Bluetooth.plist`, `/Library/Bluetooth/*.db`), en lecture seule, pour afficher noms et adresses dans la liste.

## 7. Clés de préférences (inventaire complet)

L'app ne stocke que ces clés dans `~/Library/Preferences/io.github.altissnono.BLEUnlock.plist` :

| Clés | Signification |
|---|---|
| `mode` | Mode choisi : Verrouiller et déverrouiller, ou Verrouiller seulement |
| `device`, `device2` | Identifiants de l'appareil choisi et du second appareil facultatif |
| `lockRSSI`, `unlockRSSI`, `thresholdRSSI`, `timeout`, `lockDelay`, `confirmDelay`, `maxUnlockAttempts`, `robustFilter`, `passiveMode` | Seuils de signal, délais, limite de tentatives, filtre et mode d'écoute |
| `wakeOnProximity`, `wakeWithoutUnlocking`, `pauseItunes`, `screensaver`, `sleepDisplay`, `lockOnSleep`, `lockOnBluetoothOff`, `verifyFrontWindow` | Options de comportement que vous activez ou non |
| `notifications`, `notifyOnUnlock`, `showRSSI`, `launchAtLogin` | Options de notification et d'affichage |
| `updateChecks`, `lastUpdateCheck` | Votre consentement à la recherche de mise à jour et la date de la dernière recherche |

## 8. Où sont vos données et comment les supprimer

1. **Tout d'un coup :** menu *Sécurité → Effacer toutes les données…*. Cela supprime le mot de passe du Trousseau, toutes les préférences et l'élément d'ouverture de session, puis quitte l'app.
2. **Le mot de passe seulement :** menu *Sécurité → Supprimer le mot de passe enregistré*, ou passez en mode *Verrouiller seulement* (le mot de passe est supprimé après votre confirmation).
3. **Manuellement :** supprimez `~/Library/Preferences/io.github.altissnono.BLEUnlock.plist` et l'élément du Trousseau nommé *BLEUnlock* dans *Accès au trousseau*, puis mettez l'app à la corbeille.
4. **Journal de diagnostic :** il est géré par macOS et expire automatiquement. Pour effacer tous les journaux système maintenant, exécutez `sudo log erase --all` dans le Terminal.
5. **Votre script `event`** dans `~/Library/Application Scripts/io.github.altissnono.BLEUnlock/` vous appartient ; l'app ne crée ni ne supprime jamais votre script.

## 9. Conservation

- Les préférences et l'élément du Trousseau restent jusqu'à ce que vous les supprimiez (section 8).
- Les valeurs de signal et les informations sur les appareils proches vivent en mémoire et sont oubliées à la fermeture de l'app (un appareil listé expire après au moins 30 secondes sans détection).
- Le mainteneur ne conserve rien, puisqu'il ne reçoit rien.

## 10. Tiers et transferts internationaux

- **GitHub (GitHub, Inc., société américaine du groupe Microsoft) :** héberge le code source et les versions et répond à la recherche de mise à jour facultative. Quand vous téléchargez une version ou autorisez la recherche de mise à jour, GitHub reçoit votre adresse IP et la traite selon ses propres conditions et sa déclaration de confidentialité. Le mainteneur n'a aucun contrôle là-dessus et ne reçoit aucune de ces données.
- GitHub étant une société américaine, ces requêtes peuvent impliquer un transfert de votre adresse IP hors de l'UE/EEE. Pour l'éviter totalement, laissez la recherche de mise à jour désactivée et compilez l'app depuis le code source (section 14).
- Il n'existe aucun autre destinataire : ni outil d'analyse, ni réseau publicitaire, ni service de rapports de plantage, ni cloud.

## 11. Base légale et vos droits (RGPD)

- **Recherche de mise à jour :** votre consentement (art. 6.1.a du RGPD), que vous pouvez retirer à tout moment dans *Options → Recherche automatique de mises à jour* ou en ne cliquant jamais sur *Rechercher des mises à jour*.
- **Traitement local sur votre Mac :** les données de la section 3 n'atteignent jamais le mainteneur. Vous les contrôlez et pouvez les consulter ou les supprimer (section 8).
- **Vos droits** (accès, rectification, effacement, limitation, portabilité, opposition, art. 15 à 21) : le mainteneur ne détient aucune donnée vous concernant, il n'y a donc rien à lui demander ; utilisez les outils de la section 8 sur votre appareil.
- **Réclamation :** vous pouvez saisir votre autorité nationale de protection des données (par exemple la CNIL en France, le BfDI en Allemagne, l'AEPD en Espagne, la Datatilsynet au Danemark et en Norvège, l'IMY en Suède).
- Ceci est une description en langage clair, pas un avis juridique. Si vous déployez l'app dans une organisation, vous restez responsable de votre propre analyse de conformité.

## 12. Mesures de sécurité

- Hardened Runtime, aucun code tiers et, à partir de la version 3.2.5, aucun droit de débogage (vérifié à chaque compilation ; les versions 3.x antérieures en portaient un par erreur).
- Mot de passe uniquement dans le Trousseau, effacé de la mémoire après saisie, saisi seulement quand l'écran de verrouillage est devant, avec limite de tentatives et délai de confirmation.
- Recherche de mise à jour renforcée (vérification de l'hôte, pas de redirection, taille plafonnée, validation du nom de version).
- Détails et limites connues : [SECURITY_AUDIT.md](SECURITY_AUDIT.md).

## 13. Enfants

- L'app ne s'adresse pas aux enfants et ne collecte de données personnelles de personne.

## 14. Comment vérifier ces affirmations vous-même

1. Lisez le code source : il est court (quelques milliers de lignes) et public dans le [dépôt](https://github.com/Altissnono/BLEUnlock-LTS).
2. Lancez `scripts/security-check.sh` : il échoue si un hôte autre que github.com apparaît, si un SDK de suivi est référencé, si l'accès réseau automatique n'est pas facultatif ou si le manifeste de confidentialité déclare du suivi ou des données collectées. Il s'exécute à chaque push (CI).
3. Inspectez l'app compilée : `scripts/verify-build.sh /Applications/BLEUnlock.app` vérifie les droits et les bibliothèques liées.
4. Surveillez le réseau : avec Little Snitch, LuLu ou `nettop -p <pid>`, vous ne verrez aucune connexion tant que vous ne déclenchez pas une recherche de mise à jour.
5. Compilez-la vous-même avec Xcode depuis le code source ; aucun binaire du mainteneur n'est nécessaire.
6. Lisez le manifeste de confidentialité d'Apple inclus dans l'app (`PrivacyInfo.xcprivacy`) : aucun suivi, aucun type de donnée collectée.

## 15. Modifications de cette politique

- Les modifications se font dans ce dépôt ; l'historique Git montre exactement ce qui a changé et quand. La date en haut est mise à jour à chaque changement.
- Si une version future ajoute une collecte de données ou une fonction réseau, elle sera décrite ici avant la publication et sera facultative.

## 16. Contact

- Questions sur cette politique : ouvrez un ticket sur <https://github.com/Altissnono/BLEUnlock-LTS/issues>. N'y publiez **pas** de données personnelles.
- Langues : cette politique est disponible en anglais, français, espagnol, allemand, japonais, chinois simplifié, turc, suédois, danois et norvégien. En cas de divergence, la version anglaise prévaut.
