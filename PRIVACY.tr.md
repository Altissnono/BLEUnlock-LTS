# 🇪🇺 BLEUnlock LTS Gizlilik Politikası

[English](PRIVACY.md) | [Français](PRIVACY.fr.md) | [Español](PRIVACY.es.md) | [Deutsch](PRIVACY.de.md) | [日本語](PRIVACY.ja.md) | [简体中文](PRIVACY.zh-Hans.md) | [Türkçe](PRIVACY.tr.md) | [Svenska](PRIVACY.sv.md) | [Dansk](PRIVACY.da.md) | [Norsk](PRIVACY.nb.md)

*Son güncelleme: 25.11.2026. BLEUnlock LTS 3.x için geçerlidir.*

> Bu belge yazılımın ne yaptığını anlatır. Bir şeffaflık beyanıdır; hukuki danışmanlık veya hukuki sertifika değildir.

## 1. Özet

- BLEUnlock LTS tamamen Mac’inizde çalışır. Hesap, analiz, reklam, izleme veya çökme raporu yoktur.
- Bakımcı uygulama için herhangi bir sunucu işletmez ve uygulamadan kişisel veri almaz, saklamaz ya da işlemez.
- Tek ağ özelliği güncelleme denetimidir. **İsteğe bağlıdır** ve `api.github.com` adresine bir HTTPS isteği gönderir; bu adres IP adresinizi görebilir (ayrıntılar 5. bölümde).
- Mac oturum parolanız yalnızca *Kilitle ve Kilidi Aç* modunu seçerseniz, macOS Anahtar Zinciri’nde ve yalnızca bu cihazda saklanır. *Yalnızca Kilitle* modu parolayı hiçbir zaman istemez ve saklamaz.
- Uygulamanın sakladığı her şeyi tek tıkla silebilirsiniz: *Güvenlik → Tüm Verileri Sil…*.

## 2. Sorumlu kim

- Bakımcı: **Altissnono** GitHub hesabı ([profil](https://github.com/Altissnono), depo [BLEUnlock-LTS](https://github.com/Altissnono/BLEUnlock-LTS)). Özgün proje Takeshi Sone’a aittir (MIT lisansı).
- Uygulama bakımcıya kişisel veri göndermediği için bakımcı, verileriniz bakımından ne veri sorumlusu ne de veri işleyendir. Aşağıda anlatılan veriler kendi Mac’inizde sizin denetiminizde kalır.
- Dahil olan tek üçüncü taraf GitHub’dır (10. bölüm) ve yalnızca güncelleme denetimine izin verirseniz ya da bir sürüm indirirseniz.

## 3. Uygulamanın işlediği veriler

Bu tablodaki her şey yerel olarak Mac’inizde işlenir. Hiçbiri bakımcıya veya herhangi bir sunucuya gönderilmez.

| Veri | Amaç | Nerede durur | Mac’inizden çıkar mı? |
|---|---|---|---|
| Seçtiğiniz Bluetooth cihazlarının tanımlayıcısı (CoreBluetooth UUID) ve sinyal gücü (RSSI) | Cihazınızın yakında olup olmadığını anlayıp kilitlemek veya kilidi açmak | Tanımlayıcı uygulama ayarlarında; sinyal değerleri yalnızca bellekte | Hayır |
| Yakındaki Bluetooth cihazlarının adı, üreticisi, modeli ve sinyal gücü, **yalnızca Aygıt menüsü açıkken** | Cihazınızı seçebilmeniz için listeyi göstermek | Yalnızca bellekte; en az 30 saniye görülmezse ve uygulama kapanınca atılır | Hayır |
| Mac oturum parolanız (yalnızca *Kilitle ve Kilidi Aç* modunda) | Kilit ekranına yazmak | macOS Anahtar Zinciri, hizmet = uygulamanın paket tanımlayıcısı, “yalnızca bu cihaz” (iCloud ile eşitlenmez) | Hayır |
| Ayarlar (eşikler, gecikmeler, seçenekler) | Yapılandırma | Uygulamanın tercih dosyası (7. bölüm) | Hayır |
| Tanılama: sinyal değerleri, zamanlayıcılar, kilitleme kararları (ad, tanımlayıcı veya parola yok) | Sorun giderme | Mac’inizdeki macOS birleşik günlüğü, macOS tarafından otomatik döndürülür | Hayır |
| Son güncelleme denetiminin tarihi | Denetimleri günde bir ile sınırlamak | Uygulamanın tercih dosyası | Hayır |
| En öndeki pencerenin sahibinin adı ve boyutu (içerik veya başlık yok) | Parola yazılmadan önce kilit ekranının önde olduğundan emin olmak | Saklanmaz | Hayır |
| Etkinleştirdiğiniz bildirimler (kilitleme, kilit açma, güncelleme) | Sizi bilgilendirmek | Yerel macOS bildirimleri | Hayır |
| Kendi yazdığınız isteğe bağlı `event` betiği | Kendi otomasyonunuz | `~/Library/Application Scripts/io.github.altissnono.BLEUnlock/` | Yalnızca kendi betiğiniz bir şey gönderirse |

## 4. Uygulamanın yapmadıkları

- Analiz, telemetri, kullanım istatistiği, A/B testi, reklam tanımlayıcısı veya parmak izi çıkarma yoktur.
- Uygulama çökme raporu göndermez. (macOS, tanılama verilerini Apple ile paylaşmayı önerebilir; bu, *Gizlilik ve Güvenlik → Analiz ve İyileştirmeler* altındaki bir sistem ayarıdır ve bu uygulamadan bağımsızdır.)
- Kişilerinize, takviminize, fotoğraflarınıza, konumunuza, mikrofonunuza, kameranıza veya dosyalarınıza erişmez.
- Ekran içeriğini okumaz ve Ekran Kaydı izni gerektirmez. Pencere denetimi yalnızca pencerelerin sahip adını ve boyutunu okur.
- Bluetooth cihazlarının adlarını, tanımlayıcılarını veya sinyal değerlerini hiçbir yere göndermez.
- Hiçbir zaman hesap, oturum açma, e-posta adresi veya telefon numarası istenmez.
- Üçüncü taraf kitaplık veya SDK yoktur (uygulama yalnızca Apple sistem çerçevelerini kullanır).

## 5. Ağ erişimi

- Varsayılan olarak uygulama **hiçbir sunucuyla iletişim kurmaz**.
- **Güncelleme denetimi (isteğe bağlı):** İlk açılışta veya *Seçenekler → Otomatik Güncelleme Denetimi* içinde izin verirseniz uygulama günde en fazla bir istek yapar. *Güncellemeleri Denetle*’ye basarsanız tek bir isteği kendiniz başlatırsınız.
- İstek `GET https://api.github.com/repos/Altissnono/BLEUnlock-LTS/releases/latest` biçimindedir ve `User-Agent: BLEUnlock-LTS` ile `Accept: application/vnd.github+json` başlıklarını taşır. Çerez, hesap jetonu, sürüm numarası, cihaz bilgisi veya ayar gönderilmez.
- GitHub, her web sunucusu gibi **IP adresinizi** ve isteğin zamanını görmek zorundadır. Oturum geçicidir (çerez yok, disk önbelleği yok), yönlendirmeler reddedilir, yanıt boyutu sınırlıdır ve sürüm numaralarını karşılaştırmak için yalnızca sürüm etiketinin adı okunur.
- Yanıt geçersizse veya sunucu `api.github.com` değilse yok sayılır.
- Hakkında penceresindeki ve menüdeki bağlantılar (*Gizlilik Politikası*, *İndir*) yalnızca siz tıkladığınızda tarayıcınızda açılır. Tarayıcınız bundan sonra GitHub ile kendi kurallarına göre konuşur.
- Kodda başka hiçbir ağ bağlantısı yoktur. Başka bir sunucu görünürse CI derlemeyi başarısız kılar.

## 6. İzinlerin açıklaması

- **Bluetooth:** Cihazınızın sinyalini görmek için gerekir. Aygıt menüsü açıkken uygulama, sinyali en düşük sinyal ayarınızdan güçlü olan yakın cihazlara da kısa süre bağlanır; yalnızca liste okunabilsin diye standart “Aygıt Bilgisi”ni (üretici ve model) okur. Hiçbir şey saklanmaz veya gönderilmez.
- **Erişilebilirlik** (yalnızca *Kilitle ve Kilidi Aç* modunda): Parolanızı kilit ekranına yazmak için gerekir. Uygulama ekranda ne olduğunu okumaz.
- **Bildirimler:** İsteğe bağlı; kilitleme, kilit açma veya güncelleme olduğunda sizi bilgilendirir.
- **Anahtar Zinciri:** *Kilitle ve Kilidi Aç* modunda parolanızı saklar. Öğe “yalnızca bu cihaz” olarak işaretlidir ve eşitlenmez.
- **Oturum açma öğesi:** İsteğe bağlı “Oturum Açınca Başlat” standart macOS hizmetini kullanır. *Tüm Verileri Sil…* bunu kaldırır.
- Okunan sistem dosyaları: macOS’un Bluetooth önbelleği (`/Library/Preferences/com.apple.Bluetooth.plist`, `/Library/Bluetooth/*.db`), yalnızca okuma amaçlı, listede ad ve adresleri göstermek için.

## 7. Tercih anahtarları (tam envanter)

Uygulama `~/Library/Preferences/io.github.altissnono.BLEUnlock.plist` içinde yalnızca şu anahtarları saklar:

| Anahtarlar | Anlamı |
|---|---|
| `mode` | Seçilen mod: Kilitle ve Kilidi Aç veya Yalnızca Kilitle |
| `device`, `device2` | Seçilen cihazın ve isteğe bağlı ikinci cihazın tanımlayıcıları |
| `lockRSSI`, `unlockRSSI`, `thresholdRSSI`, `timeout`, `lockDelay`, `confirmDelay`, `maxUnlockAttempts`, `robustFilter`, `passiveMode` | Sinyal eşikleri, gecikmeler, deneme sınırı, filtre ve tarama modu |
| `wakeOnProximity`, `wakeWithoutUnlocking`, `pauseItunes`, `screensaver`, `sleepDisplay`, `lockOnSleep`, `lockOnBluetoothOff`, `verifyFrontWindow` | Açıp kapatabileceğiniz davranış seçenekleri |
| `notifications`, `notifyOnUnlock`, `showRSSI`, `launchAtLogin` | Bildirim ve görüntü seçenekleri |
| `updateChecks`, `lastUpdateCheck` | Güncelleme denetimi onayınız ve son denetimin tarihi |

## 8. Verileriniz nerede ve nasıl silinir

1. **Hepsi bir arada:** *Güvenlik → Tüm Verileri Sil…* menüsü. Anahtar Zinciri’ndeki parolayı, tüm tercihleri ve oturum açma öğesini siler, sonra uygulamadan çıkar.
2. **Yalnızca parola:** *Güvenlik → Kayıtlı Parolayı Sil* menüsü veya *Yalnızca Kilitle* moduna geçin (onayınızdan sonra parola silinir).
3. **Elle:** `~/Library/Preferences/io.github.altissnono.BLEUnlock.plist` dosyasını ve *Anahtar Zinciri Erişimi*’ndeki *BLEUnlock* adlı öğeyi silin, ardından uygulamayı Çöp Sepeti’ne taşıyın.
4. **Tanılama günlüğü:** macOS tarafından yönetilir ve otomatik olarak süresi dolar. Tüm sistem günlüklerini şimdi silmek için Terminal’de `sudo log erase --all` çalıştırın.
5. **Kendi `event` betiğiniz** `~/Library/Application Scripts/io.github.altissnono.BLEUnlock/` içindedir ve size aittir; uygulama betiğinizi hiçbir zaman oluşturmaz veya silmez.

## 9. Saklama süresi

- Tercihler ve Anahtar Zinciri öğesi siz silene kadar kalır (8. bölüm).
- Sinyal değerleri ve yakındaki cihaz bilgileri bellekte durur ve uygulama kapanınca atılır (listedeki bir cihazın süresi en az 30 saniye görülmezse dolar).
- Bakımcı hiçbir şey almadığı için hiçbir şey saklamaz.

## 10. Üçüncü taraflar ve uluslararası aktarımlar

- **GitHub (GitHub, Inc., Microsoft’a ait ABD şirketi):** Kaynak kodu ve sürümleri barındırır ve isteğe bağlı güncelleme denetimini yanıtlar. Bir sürüm indirdiğinizde veya güncelleme denetimine izin verdiğinizde GitHub IP adresinizi alır ve kendi koşulları ile gizlilik beyanına göre işler. Bakımcının bunun üzerinde denetimi yoktur ve bu verileri almaz.
- GitHub bir ABD şirketi olduğundan bu istekler IP adresinizin AB/AEA dışına aktarılmasını içerebilir. Bunu tamamen önlemek için güncelleme denetimini kapalı tutun ve uygulamayı kaynak koddan derleyin (14. bölüm).
- Başka alıcı yoktur: analiz sağlayıcısı, reklam ağı, çökme raporu hizmeti veya bulut yoktur.

## 11. Hukuki dayanak ve haklarınız (GDPR)

- **Güncelleme denetimi:** Onayınız (GDPR md. 6/1-a). *Seçenekler → Otomatik Güncelleme Denetimi*’nden ya da *Güncellemeleri Denetle*’ye hiç basmayarak istediğiniz zaman geri alabilirsiniz.
- **Mac’inizde yerel işleme:** 3. bölümdeki veriler bakımcıya asla ulaşmaz. Denetim sizdedir; bunları inceleyebilir veya silebilirsiniz (8. bölüm).
- **Haklarınız** (erişim, düzeltme, silme, kısıtlama, taşınabilirlik, itiraz; md. 15 ila 21): Bakımcının sizinle ilgili hiçbir verisi yoktur, dolayısıyla ondan talep edilecek bir şey yoktur; kendi cihazınızda 8. bölümdeki araçları kullanın.
- **Şikâyet:** Ulusal veri koruma otoritenize şikâyette bulunabilirsiniz (örneğin Fransa’da CNIL, Almanya’da BfDI, İspanya’da AEPD, Danimarka ve Norveç’te Datatilsynet, İsveç’te IMY; Türkiye’de KVKK).
- Bu, sade bir dille yapılmış bir açıklamadır, hukuki danışmanlık değildir. Uygulamayı bir kurumda kullanırsanız kendi uyum değerlendirmenizden siz sorumlusunuz.

## 12. Güvenlik önlemleri

- Hardened Runtime, üçüncü taraf kod yok ve 3.2.5 sürümünden itibaren hata ayıklayıcı yetkisi yok (her derlemede denetlenir; önceki 3.x sürümleri bunu yanlışlıkla taşıyordu).
- Parola yalnızca Anahtar Zinciri’nde, yazıldıktan sonra bellekten silinir, yalnızca kilit ekranı önde olduğunda yazılır; deneme sınırı ve onay gecikmesi vardır.
- Güçlendirilmiş güncelleme denetimi (sunucu denetimi, yönlendirme yok, boyut sınırı, etiket adı doğrulaması).
- Ayrıntılar ve bilinen sınırlar: [SECURITY_AUDIT.md](SECURITY_AUDIT.md).

## 13. Çocuklar

- Uygulama çocuklara yönelik değildir ve kimseden kişisel veri toplamaz.

## 14. Bu beyanları kendiniz nasıl doğrularsınız

1. Kaynak kodu okuyun: küçüktür (birkaç bin satır) ve [depoda](https://github.com/Altissnono/BLEUnlock-LTS) herkese açıktır.
2. `scripts/security-check.sh` çalıştırın: github.com dışında bir sunucu görünürse, izleme SDK’sı anılırsa, otomatik ağ erişimi isteğe bağlı değilse veya gizlilik bildirimi izleme ya da toplanan veri bildirirse başarısız olur. Her push’ta çalışır (CI).
3. Derlenmiş uygulamayı inceleyin: `scripts/verify-build.sh /Applications/BLEUnlock.app` yetkileri ve bağlı kitaplıkları denetler.
4. Ağı izleyin: Little Snitch, LuLu veya `nettop -p <pid>` ile, güncelleme denetimi başlatmadıkça hiçbir bağlantı görmezsiniz.
5. Xcode ile kaynak koddan kendiniz derleyin; bakımcının ikili dosyasına gerek yoktur.
6. Uygulamadaki Apple gizlilik bildirimini okuyun (`PrivacyInfo.xcprivacy`): izleme yok, toplanan veri türü yok.

## 15. Bu politikadaki değişiklikler

- Değişiklikler bu depoda yapılır; Git geçmişi tam olarak neyin ne zaman değiştiğini gösterir. Üstteki tarih her değişiklikte güncellenir.
- Gelecekteki bir sürüm veri toplama veya ağ özelliği eklerse, yayımlanmadan önce burada açıklanır ve isteğe bağlı olur.

## 16. İletişim

- Bu politika hakkında sorular: <https://github.com/Altissnono/BLEUnlock-LTS/issues> adresinde bir konu açın. Orada kişisel veri **paylaşmayın**.
- Diller: Bu politika İngilizce, Fransızca, İspanyolca, Almanca, Japonca, Basitleştirilmiş Çince, Türkçe, İsveççe, Danca ve Norveççe sunulur. Çeviriler arasında fark olursa İngilizce sürüm geçerlidir.
