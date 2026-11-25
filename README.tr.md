# 🇪🇺 BLEUnlock LTS

[English](README.md) | [Français](README.fr.md) | [Español](README.es.md) | [Deutsch](README.de.md) | [日本語](README.ja.md) | [简体中文](README.zh-Hans.md) | [Türkçe](README.tr.md) | [Svenska](README.sv.md) | [Dansk](README.da.md) | [Norsk](README.nb.md)

![CI](https://github.com/Altissnono/BLEUnlock-LTS/actions/workflows/test.yml/badge.svg)
[![Latest release](https://img.shields.io/github/v/release/Altissnono/BLEUnlock-LTS?display_name=tag&cacheSeconds=300)](https://github.com/Altissnono/BLEUnlock-LTS/releases/latest)
![GDPR friendly](https://img.shields.io/badge/%F0%9F%87%AA%F0%9F%87%BA-GDPR--friendly-003399?labelColor=FFCC00) ![No telemetry](https://img.shields.io/badge/telemetry-none-brightgreen) ![Languages](https://img.shields.io/badge/languages-10-informational)

BLEUnlock, iPhone’unuzun, Apple Watch’unuzun veya herhangi bir Bluetooth Low Energy cihazının yakınlığına göre Mac’inizi kilitleyen ve kilidini açan küçük bir menü çubuğu aracıdır.

## Özellikler

- iPhone uygulaması gerekmez: iPhone, Apple Watch veya sabit adresli herhangi bir BLE cihazıyla çalışır.
- Cihazınız uzaklaşınca Mac’i kilitler, geri gelince kilidini açar.
- İki mod: **Kilitle ve Kilidi Aç** veya **Yalnızca Kilitle** (parola saklanmaz, Erişilebilirlik izni gerekmez).
- Kalibrasyon asistanı, ikinci cihaz (Watch ve iPhone), sağlam sinyal filtresi.
- İsteğe bağlı: yaklaşınca uyandırma, medyayı duraklatma, uyku veya kapak kapanınca kilitleme, Bluetooth kapanınca kilitleme.
- 10 dilde kullanılabilir.

## 🇪🇺 Gizlilik ve GDPR

- Hesap, analiz, reklam veya çökme raporu yoktur. Her şey Mac’inizde kalır.
- Güncelleme denetimi isteğe bağlıdır: `api.github.com` adresine tek bir HTTPS isteği gönderilir ve IP adresiniz GitHub tarafından görülür.
- Tek tıkla silme: Güvenlik → Tüm Verileri Sil…
- Parola (yalnızca kilit açma modunda) macOS Anahtar Zinciri’nde, yalnızca bu cihazda saklanır.
- Üçüncü taraf bağımlılık yok, Hardened Runtime açık, güvenlik mantığı için birim testleri var.

> Bu, uygulamanın teknik davranışının açıklamasıdır, hukuki bir sertifika değildir. Ayrıntılar: [PRIVACY.md](PRIVACY.md).

## Gereksinimler

- Bluetooth Low Energy destekleyen bir Mac
- macOS 12 (Monterey) veya üzeri
- iPhone, Apple Watch veya sabit adresli başka bir BLE cihazı

## Kurulum

[Releases](https://github.com/Altissnono/BLEUnlock-LTS/releases) sayfasından zip dosyasını indirin, açın ve uygulamayı Uygulamalar klasörüne taşıyın.

> Uygulama noterlenmemiştir: ilk açılışta sağ tıklayıp **Aç**’ı seçin (veya `xattr -dr com.apple.quarantine /Applications/BLEUnlock.app` çalıştırın). Zip dosyasını `SHA256SUMS.txt` ile veya doğrulama kaydıyla kontrol edin: `gh attestation verify BLEUnlock-<version>.zip --repo Altissnono/BLEUnlock-LTS`.

## Başlarken

1. Uygulamayı açın (menü çubuğundaki kilit simgesi) ve ilk açılışta bir mod seçin.
2. Bluetooth’a ve bildirimlere izin verin. Erişilebilirliğe yalnızca **Kilitle ve Kilidi Aç** modunu seçerseniz izin verin.
3. Menü → **Aygıt**: iPhone’unuzu veya Apple Watch’unuzu Mac’e yaklaştırın. Listenin en üstüne çıkar, onu seçin.
4. Menü → **Yakınlık** → **Sinyali Kalibre Et…**: iki adımı izleyin (yakında 12 sn, uzakta 12 sn).
5. İsteğe bağlı: Watch ve iPhone’u birlikte izlemek için **İkinci Cihaz**.
6. Deneyin: uzaklaşın, Mac kilitleme gecikmesinden sonra kilitlenir.

## Bilmekte fayda var

- Bluetooth sinyali dalgalıdır (bir Apple Watch iki okuma arasında 25 ile 30 dB oynayabilir). Eşikleri “yakın” ve “uzak” değerlerden en az 10 dB uzak tutun. 5 sn’den kısa sinyal zaman aşımı yanlış kilitlemelere yol açabilir.
- Yakınlıkla kilit açma, uygun donanıma sahip biri tarafından taklit edilebilir. Hassas ortamlarda **Yalnızca Kilitle** modunu seçin.

## Daha fazlası

- Tam belge (İngilizce): [README.md](README.md)
- Gizlilik politikası: [PRIVACY.md](PRIVACY.md)
- Güvenlik denetimi: [SECURITY_AUDIT.md](SECURITY_AUDIT.md)

---

MIT lisansı. Özgün proje: [Takeshi Sone](https://github.com/ts1/BLEUnlock). Bakımını [Altissnono](https://github.com/Altissnono) yapıyor.
