# Anka — A Wrist Companion

**Versiyon:** 0.1 (MVP planlama)
**Tarih:** 2026-05-25
**Platform:** iOS 17+ (iPhone) + watchOS 10+ (Apple Watch)
**Hedef pazar:** Global (TR + ABD + AB öncelik)
**Geliştirme süresi:** 12 hafta (MVP)

---

## 1. Yüksek Konsept

> Bileğinde yaşayan, Anadolu mitolojisinin yaratıklarından evrilen küçük bir canlı.
> Adımların, kalp atışın, uykun ve egzersizin onu büyütür. Hangi yaşam tarzına sahipsen,
> Anka'n o yöne evrilir. Her oyuncu farklı bir yolculuk yaşar.

**Pitch:** "Tamagotchi meets Apple HealthKit, painted in Anatolian myth. Premium, no ads, no IAP."

**Tek satır USP:** Rakiplerin step→heart'ta sıkıştığı yerde, 5 HealthKit kaynağıyla 5 farklı evrim yolu sunan, Anadolu mitolojisinden ilham alan premium bir companion.

---

## 2. Hedef Kitle

- **Birincil:** 22-40 yaş, Apple Watch sahibi, sağlık/fitness ilgisi var
- **İkincil:** Tamagotchi nostaljisi olan 30+, mitoloji/fantasy ilgisi olan tüm yaşlar
- **Cinsiyet:** %50-50 dengeli (kawaii değil → erkek de kaçmaz)
- **Coğrafya:** TR (yerel tema avantajı) + ABD/AB/JP (exotic appeal)
- **Davranış:** Günde 5-15 kere Watch'a bakar, fitness uygulaması kullanır

---

## 3. Core Gameplay Loop

### Mikro-loop (5-15 saniye / etkileşim)
1. Watch'a bakarsın → complication'da Anka görünür (durumu: aç/mutlu/uykuda/evrim eşiği)
2. Tap → mini watchOS view → Anka'yla 1-2 hızlı etkileşim (besle, okşa, uyut)
3. Haptic feedback (Anka'nın "mırlama"sı)
4. Geri kapanır

### Mezo-loop (gün içi)
- Sabah: Anka uyanır (uyku verisi → form'una etki eder)
- Gün boyu: adımların, ayakta durduğun saatler → enerjisi
- Workout: ekstra besleme + özel "burst" form
- Akşam: günü özetler (iPhone'da)

### Makro-loop (haftalar)
- 5 farklı yaratık başlangıç türü
- Her biri 4-5 evrim aşaması
- Hangi HealthKit kaynağı baskın → hangi evrim yolunu izler
- "True ending" bir yaratığın tüm evrim yollarını gezmek (replay)

---

## 4. 5 Evrim Yolu Mantığı (Core Mekanik)

| HealthKit Kaynağı | Evrim Yönü | Tema |
|---|---|---|
| **Step Count** baskın | Yolcu / Gezgin | Uzun yürüyüş ruhu (Anka uçar) |
| **Heart Rate Zone** (egzersiz) | Savaşçı / Atılgan | Karakoncolos kalın derili (atak) |
| **Stand Hours** | Bilge / Sabırlı | Şahmaran (yer yüzü bilgesi) |
| **Sleep Hours/Quality** | Rüya / Mistik | Hodağ (gece-orman ruhu) |
| **Workout Minutes** | Usta / Yetkin | Pirebatak (hızlı ve atik) |

### Algoritma (basitleştirilmiş)
- Her gün sonu: 5 puanlık kaynak skoru hesaplanır (relative weighted)
- 7 gün rolling average → "dominant trait" belirlenir
- Trait'e göre evrim eşiğinde yaratık yön seçer
- Her trait'in görsel formu farklı

### Replayability
- 1. yaratığı evrimledikten sonra "yumurta" sıfırlanır (yeni başlangıç)
- Albümde her yaratığın geçirdiği formlar arşivlenir
- "Trait Master" — tüm 5 evrim yolunu tamamla → özel rozet

---

## 5. 5 Başlangıç Yaratığı (MVP)

| Yaratık | Mitoloji | Görsel teması |
|---|---|---|
| **Anka** | Pers/Türk Phoenix | Ateş kuşu, kanatlı, kırmızı-altın |
| **Şahmaran** | Anadolu yılan-kız | Yeşil, bilge, taç motifi |
| **Hodağ** | Anadolu efsanevi | Karanlık orman yaratığı, mor-mavi |
| **Karakoncolos** | Kış efsanesi | Buz, gri-beyaz tüylü |
| **Pirebatak** | Türk mitolojisi yardımcı ruh | Toprak rengi, çevik |

Her yaratık 5 form geçer: **Yumurta → Yavru → Genç → Erişkin → Evrimleşmiş (5 farklı son form)**

**Toplam görsel:** 5 yaratık × 4 ortak form + 5 unique son form = ~25 illustration (MVP)

---

## 6. Apple Watch Feature Entegrasyonu

### Complications (KRITIK — App Store öne çıkma kaynağı)
- **Corner** — Anka silüeti + günlük progress halkası
- **Circular Small** — Anka avatar + mutluluk %'si
- **Modular Large** — Anka + bugün önerilen aktivite
- **Inline** — "Anka aç" / "Anka mutlu" gibi anlık mesaj
- Always-On uyumlu (düşük renk doygunluğu varyantı)

### HealthKit
- Read permissions: steps, heart rate, stand hours, sleep, workouts
- Background fetch (kullanıcı izniyle) — gün sonu hesaplama
- Asla yazma izni istemiyoruz (privacy puanı)

### Digital Crown
- Anka'yı okşa: Crown çevirisi → hafif haptic + Anka tepkisi
- iPhone yoksa Watch'ta tek başına çalışır

### Haptic Engine
- "Açım" → kısa double-tap haptic
- "Evrim eşiği" → uzun ascending pattern
- "Uyandım" → soft single tap
- Her yaratık kendi haptic imzasına sahip

### Notifications (Nomi'nin patladığı yer — biz doğru yapacağız)
- Push notification + UNNotificationCategoryIdentifier
- "Anka aç" → action: "Beslemek için aç"
- Critical timing: gece bildirim göndermez (DoNotDisturb saygılı)
- Asla spam yapmaz — günde max 2 bildirim

### iPhone Companion (gerçek companion, yan-app değil)
- **Hatıra Albümü** — geçmiş yaratıkların formları, evrim yolu
- **Lore Library** — her yaratık için Anadolu mitolojisinden bilgi kartları
- **İstatistikler** — hangi HealthKit kaynağında ne kadar büyüdün
- **Customization** — Anka'nın arka plan, isim
- **Mağaza** (gelecek) — cosmetic skin packs

---

## 7. Monetizasyon

### Faz 1 — Launch
- **Tek seferlik $6.99 premium** (StoreKit 2)
- 14 gün ücretsiz deneme — sadece "Anka" yaratığı + 1 form
- Ödedikten sonra: tüm 5 yaratık + 5 evrim yolu + tüm complications + Hatıra Albümü

### Faz 2 — 3-6 ay sonra (opsiyonel)
- **Skin packs** ($1.99 her biri):
  - Mevsim teması (kış/yaz Anka)
  - Çini motif
  - Modern minimalist
- Sezon etkinlikleri (Nevruz, Hıdırellez vb.)

### LTV varsayımı
- Hedef: 100K satış 1. yıl × $6.99 = **$490K** (Apple komisyon sonrası ~$340K)
- Stretch: 300K satış → **$1.5M+ gross**

---

## 8. Retention Mekanikleri

- **Daily streak** — günde 1 kez giriş → "Anka mutlu"
- **Evrim eşiği** — her 7-14 gün bir form değişimi → dopamine reward
- **Lore unlocks** — her form aşaması yeni mitoloji kartı açar
- **Hatıra Albümü** — geçmiş Anka'ları görmek → nostaljik bağ
- **Mevsim olayları** — Nevruz, Halloween vb. özel formlar
- **Sosyal paylaşım** — "Anka'm bugün evrimleşti" → iPhone'da paylaşılır PNG

---

## 9. Teknik Mimari

### Stack
- **iOS:** SwiftUI, iOS 17+
- **watchOS:** SwiftUI, watchOS 10+
- **Dil:** Swift 6 (strict concurrency)
- **Persistence:** SwiftData (modern, Codable)
- **Health:** HealthKit
- **Sync:** WatchConnectivity (iPhone ↔ Watch)
- **IAP:** StoreKit 2
- **Analytics:** Firebase Analytics + Crashlytics
- **Backend:** YOK (offline-first); CloudKit (iCloud sync için kullanıcı opt-in)

### Modül Yapısı

```
Anka/
├── iPhone/                # iOS target
│   ├── App/
│   ├── Features/
│   │   ├── Album/         # Hatıra Albümü
│   │   ├── Lore/          # Mitoloji bilgi kartları
│   │   ├── Stats/         # HealthKit grafikleri
│   │   ├── Onboarding/
│   │   └── Settings/
│   └── Resources/
├── Watch/                 # watchOS target
│   ├── App/
│   ├── Features/
│   │   ├── PetView/       # Ana Anka görünümü
│   │   ├── Feed/          # Hızlı besleme aksiyonları
│   │   └── Status/        # Bugün özet
│   ├── Complications/
│   └── Resources/
├── Shared/                # Swift package — iki target da kullanır
│   ├── Models/
│   │   ├── Pet.swift
│   │   ├── Evolution.swift
│   │   └── HealthSnapshot.swift
│   ├── Services/
│   │   ├── HealthKitService.swift
│   │   ├── EvolutionEngine.swift
│   │   ├── PetStore.swift          # SwiftData
│   │   ├── ConnectivityService.swift
│   │   └── HapticService.swift
│   └── Assets/
│       └── Creatures/    # Vector + raster
└── Tests/
    ├── EvolutionEngineTests/
    └── HealthSnapshotTests/
```

### Veri akışı

```
HealthKit (iPhone)
    ↓ daily snapshot
PetStore (SwiftData, App Group shared)
    ↕ WatchConnectivity
Watch UI + Complications
```

- App Group: `group.com.birkanaksoy.anka` → iPhone + Watch + Extension paylaşır
- SwiftData store her iki targette aynı dosyaya yazar (App Group container)
- EvolutionEngine deterministik — aynı snapshot → aynı sonuç (test'lenebilir)

### Privacy
- HealthKit veri **asla** cihazdan çıkmaz
- Firebase Analytics → sadece event isimleri (örn. "pet_evolved"), kişisel veri yok
- Crashlytics → user_id yok
- App Tracking Transparency uygulanır

---

## 10. 12 Haftalık Sprint Planı

| Hafta | Hedef |
|---|---|
| 1 | Xcodegen setup, iPhone + Watch target + Shared package, ilk build |
| 2 | HealthKit izin akışı + okuma servisi, Pet model + SwiftData |
| 3 | Evolution engine + deterministik algoritma + birim test |
| 4 | Watch ana ekran (PetView) + temel animasyon |
| 5 | Watch ↔ iPhone WatchConnectivity sync |
| 6 | Complications (5 stil) |
| 7 | iPhone Hatıra Albümü + Lore Library |
| 8 | İlk 2 yaratık (Anka + Şahmaran) full görsel + 5 form |
| 9 | Kalan 3 yaratık + bildirimler |
| 10 | StoreKit 2 premium IAP, paywall, deneme akışı |
| 11 | TestFlight beta, polish, bug fix |
| 12 | ASO + screenshots + soft launch (TR + 2 küçük ülke) |

---

## 11. Başarı Metrikleri (12 ay)

| Metrik | Hedef | Stretch |
|---|---|---|
| Total satış | 50K | 200K |
| Konversiyon (deneme → ödeme) | 8% | 15% |
| D1 retention | 60% | 75% |
| D7 retention | 35% | 50% |
| D30 retention | 20% | 35% |
| App Store rating | 4.5+ | 4.8+ |
| Featured | TR + 1 ülke | Apple Today / Editor's Choice |

---

## 12. Risk ve Mitigation

| Risk | Mitigation |
|---|---|
| Görsel bütçesi (illustrator) | Tek freelance ile başla, ileride senior artist |
| HealthKit permission reddi | Onboarding'de net değer önerisi, "neden istiyoruz" anlatımı |
| watchOS bug'ları (Nomi vakası) | Manuel test + birim test + TestFlight 2 hafta |
| App Store reddi (HealthKit) | Apple'ın HealthKit guidelines'ına sıkı uyum |
| Türk teması fazla niche | Global marketing'de "mythology" kelimesi kullan, Anadolu özelinde özel |
| Tek geliştirici burnout | Sprint disiplin, 80 saat/hafta'dan kaç, polish 2. faza |

---

## 13. App Store Stratejisi

### Metadata
- **Subtitle:** "A Wrist Companion from Myth"
- **Keywords:** anka, tamagotchi, watch pet, healthkit, virtual pet, mythology, companion, idle, fitness pet
- **Primary category:** Games → Casual
- **Secondary:** Health & Fitness (önemli — featured şansı artar)

### Screenshots (sıra)
1. Anka — Watch complication (hero shot)
2. iPhone hatıra albümü
3. Evrim animasyonu
4. Lore card
5. "5 farklı yol" anlatımı

### Launch ülkeleri (soft launch)
1. Türkiye (yerel tema avantajı)
2. Filipinler veya Endonezya (test küçük market)
3. Pozitif veri sonrası global

---

## 14. Sonraki Adım

**Görev #4:** MVP scaffolding. Xcodegen ile iPhone + Watch + Shared package. İlk build, hafta 1 hedefi gerçek olacak.
