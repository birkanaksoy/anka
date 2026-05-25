# Anka — Submission Day Guide

Sıralı, atlanmayacak adımlar. Tahmini süre: **3-5 saat aktif iş** + Apple inceleme (24-72 saat).

---

## Hazırlık (submission gününden önce)

1. **Illustrator işi bitti mi?**
   25 yaratık görseli + final app icon teslim alındı, `Assets.xcassets` içine yerleştirildi.
   _Placeholder ile de submit edebilirsin ama Apple "needs more visual polish" diye reject edebilir._

2. **TestFlight 7+ gün canlı.** Min 5 internal tester, kritik crash sıfır.

3. **GitHub Pages yayında.**
   `https://birkanaksoy.github.io/anka/privacy.html` ve `support.html` URL'leri tarayıcıda açılıyor.

---

## Submission günü adımları

### 1) Build'i yükle (~30 dk)

```bash
./scripts/archive.sh upload
```

veya manuel:
```bash
./scripts/archive.sh
open build/Anka/*.ipa   # Transporter.app açılır, "Deliver" tıkla
```

App Store Connect → My Apps → Anka → TestFlight'ta **15-30 dk içinde** build görünür.

### 2) TestFlight Internal Testing'e ekle

App Store Connect → TestFlight → Internal Testing:
- Build'i seç
- Beta App Review'a gerek yok (Internal = kendi takımına dağıt)
- Cihaza yükle, son bir akışı dene

### 3) App Store sayfasını doldur

[APP_STORE_CONNECT.md](APP_STORE_CONNECT.md) açık, sırasıyla:

- App Information → kategoriler ✓
- Pricing & Availability → Free, ülkeler
- App Privacy → "Data Not Collected"
- Age Rating → 4+
- IAP → Anka Premium $6.99 onayda
- **Screenshots** (yeni build için):
  ```bash
  ./scripts/capture_screenshots.sh
  ```
  En az 3 iPhone 6.7" + 2 Apple Watch screenshot yükle.
- App icon otomatik build'den gelir
- Description, Keywords, Promotional Text, What's New (kopyala-yapıştır)
- **Privacy Policy URL** ve **Support URL** alanları dolu
- App Review notes: HealthKit gerekçesi (APP_STORE_CONNECT.md'de hazır)

### 4) Build'i version'a bağla

App Store Connect → App Store → Version 1.0 → "Build" → upload ettiğin build'i seç.

### 5) Soft launch ülkeleri seç (önerilen)

Tüm ülkeler yerine **küçük başla**:
- Türkiye (yerel tema avantajı)
- Filipinler (küçük pazar, ucuz CPI)
- Endonezya (büyüyen smartwatch pazarı)

Trafik temizse 1-2 hafta sonra global'e aç.

### 6) Submit For Review

Tüm bölümlerde yeşil tik → sağ üstte **Submit for Review**.
- "Manually release this version" işaretle (onaylanınca senin onayına kalsın)
- Submit

---

## İlk 72 saat

| Saat | Beklenen |
|---|---|
| 0-2h | "Waiting for Review" |
| 2-48h | "In Review" |
| 48-72h | "Approved" veya "Rejected" |

**Reject gelirse panik etme** — ilk submission %40 reject olur. Yaygın sebepler:
- HealthKit metadata yetersiz → APP_STORE_CONNECT.md'deki Review Notes daha detaylı yaz
- Privacy Policy URL boş açılıyor → GitHub Pages'i kontrol et
- IAP test edilmedi → sandbox test hesabı oluştur

Apple'a Resolution Center'dan kibarca cevap ver, fix gönder, tekrar submit. Genelde 2. submission 24h içinde onaylanır.

---

## Approved sonrası

1. **Release** (manuel mod seçtiysen) — "Release This Version"
2. Apple ~12-24h içinde tüm App Store'larda canlı eder
3. İlk 24h trafik patlamaz — sosyal medya post + Product Hunt + r/AppleWatch + Reddit hazırlamış ol
4. Daily downloads + crash rate'i App Store Connect'ten izle

---

## Soft launch metrik hedefleri (ilk 30 gün)

| Metrik | Min | İyi | Mükemmel |
|---|---|---|---|
| İndirme | 1K | 10K | 50K+ |
| D1 retention | %30 | %50 | %70 |
| Crash-free | %99 | %99.5 | %99.9 |
| Rating | 4.0 | 4.5 | 4.7+ |
| Premium conversion | %2 | %5 | %10+ |

Bu metrikler "Phase 2"yi belirler: skin pack IAP, yeni yaratık, lokalizasyon, vb.

---

## Sonraki adım (post-launch)

- v1.1: Skin pack IAP'leri ($1.99) — 2-3 mevsim/tema
- v1.2: Yeni yaratık (mevsim eventi — Karakoncolos kışın gelir)
- v1.3: iCloud sync (kullanıcı opt-in)
- v2.0: Lokalizasyon (TR + ES + DE + JA)

Hepsi pazar verisine göre öncelenir.
