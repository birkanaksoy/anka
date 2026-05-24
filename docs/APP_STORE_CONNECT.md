# App Store Connect — Setup Checklist

Adım adım talimatlar. Süre: ~1-2 saat ilk seferinde.

## 1. Developer Portal (developer.apple.com)

### a) App ID kaydet
**Certificates, IDs & Profiles → Identifiers → "+"**

- Description: `Anka`
- Bundle ID: Explicit → `com.birkanaksoy.anka`
- Capabilities seç:
  - ✅ App Groups (Configure: `group.com.birkanaksoy.anka`)
  - ✅ HealthKit
  - ✅ Push Notifications
  - ✅ Background Modes

### b) Watch App ID kaydet
Aynı yerden ikinci bir ID:
- Bundle ID: `com.birkanaksoy.anka.watchkitapp`
- Capabilities:
  - ✅ App Groups (aynı group)
  - ✅ HealthKit

### c) Widget Extension ID
- Bundle ID: `com.birkanaksoy.anka.watchkitapp.widget`
- Capabilities:
  - ✅ App Groups

### d) App Group oluştur
**Identifiers → App Groups → "+"**
- Identifier: `group.com.birkanaksoy.anka`
- Description: `Anka shared`

## 2. App Store Connect (appstoreconnect.apple.com)

### My Apps → "+" → New App

| Alan | Değer |
|---|---|
| Platform | iOS (Watch otomatik gelir) |
| Name | `Anka` |
| Primary language | English (U.S.) |
| Bundle ID | `com.birkanaksoy.anka` |
| SKU | `anka-001` |

### App Information

| Alan | Değer |
|---|---|
| Subtitle | `A Wrist Companion of Myth` |
| Primary category | Games |
| Secondary category | Health & Fitness |
| Content Rights | "Does your app contain..." — No |

### Age Rating
Apple'ın sorularına şöyle cevap ver:
- Cartoon or Fantasy Violence: None
- Realistic Violence: None
- Sexual Content: None
- Profanity: None
- Drugs/Alcohol: None
- Gambling: None
- Horror/Fear: None
- Medical/Treatment: None
- Web Access: No
- User Generated Content: No
- Result: **4+**

### Pricing & Availability

- Price: Free (paywall in-app)
- All countries

### In-App Purchases → "+"

| Alan | Değer |
|---|---|
| Type | Non-Consumable |
| Reference Name | Anka Premium Lifetime |
| Product ID | `com.birkanaksoy.anka.premium.lifetime` |
| Pricing | $6.99 (Tier 7) |
| Display Name | Anka Premium |
| Description | Unlock all 5 mythological creatures and every evolution path. One purchase, lifetime, no ads. |

### App Privacy

**Data Collection: NO**
- "Does your app collect any data..." → **No**
- "Health & Fitness" sorusu: HealthKit verisi sadece cihazda, paylaşılmıyor → seçenek **Not Collected**

### URLs

| Alan | Değer |
|---|---|
| Marketing URL | `https://birkanaksoy.github.io/anka/` (opsiyonel) |
| Support URL | `https://birkanaksoy.github.io/anka/support.html` (zorunlu) |
| Privacy Policy URL | `https://birkanaksoy.github.io/anka/privacy.html` (zorunlu) |

> ⚠️ Bu URL'leri çalışır hale getirmek için web/ klasörünü GitHub Pages'e
> push etmen gerekir. README.md'de talimatlar var.

## 3. Version Information (App Store sayfası)

### Promotional Text (170 char)
```
Hatch a creature from Anatolian myth on your wrist. Your steps, heartbeats, and sleep shape who it becomes. Five companions. Five paths.
```

### Description (4000 char)
```
ANKA — A Wrist Companion Born of Myth

Hatch a mythological creature on your wrist. Your daily steps, heartbeats, stand hours, sleep and workouts shape what it becomes. Every choice in your day pushes your Anka toward a different evolution.

FIVE COMPANIONS FROM ANATOLIAN MYTH
• Anka — the immortal firebird, burns to ash and rises again
• Şahmaran — the serpent queen, keeper of secrets beneath the earth
• Hodağ — guardian of the dark forest, seen only by night walkers
• Karakoncolos — spirit of long winter nights
• Pirebatak — the swift helper, friend of children's tales

FIVE PATHS TO EVOLVE
• Wanderer — for those who walk far
• Warrior — for those whose heart climbs high
• Sage — for those who stand patient through the day
• Dreamer — for those who sleep deeply
• Master — for those whose workouts are sacred

WATCH-FIRST DESIGN
• Live complications across every accessory family
• Digital Crown to pet your companion
• Haptic responses calibrated for the wrist
• Always-On Display friendly

PURE PREMIUM
One purchase. Forever.
No ads. No subscriptions. No upsells.
A companion you actually own.

PRIVACY FIRST
Your health data never leaves your device. We have no servers. We have no analytics about you. Anka is a quiet, personal thing.

Crafted by an independent developer for everyone who wants a small, beautiful, mythic companion on their wrist.
```

### Keywords (100 char total, comma-separated)
```
tamagotchi,virtual pet,watch,companion,health,fitness,steps,mythology,idle,pet,evolve,anatolian
```

### What's New (first release)
```
First flight! Hatch your wrist companion and choose its path.
```

## 4. Build Upload

```bash
# In project root
xcodebuild -project Anka.xcodeproj -scheme Anka -configuration Release \
  -archivePath build/Anka.xcarchive archive

xcodebuild -exportArchive -archivePath build/Anka.xcarchive \
  -exportPath build/Anka \
  -exportOptionsPlist ExportOptions.plist
```

Veya Xcode UI: **Product → Archive → Distribute App → App Store Connect**.

Build ~15-30 dakika processing'de bekler. Sonra TestFlight'ta görünür.

## 5. App Review Notes (Submit ederken)

```
Hello Reviewer,

Anka is a wrist companion game that uses HealthKit to drive a mythological
creature's growth. Health data is read on-device only and never sent
anywhere — see Privacy Policy for details.

To exercise the app:
1. Open the iPhone app
2. Grant Health permission when prompted
3. Tap "Begin", choose a creature (Anka is unlocked for free; others
   require the in-app purchase)
4. Name the creature and tap "Hatch the Egg"
5. The Companion tab shows today's Health summary and the creature's
   current stage / evolution path
6. The Apple Watch app mirrors the same companion

If you don't see Health data, the simulator has no health samples by
default — please use a paired iPhone + Watch with sample data, or add
samples via Health → Browse → "+".

In-app purchase: Anka Premium ($6.99) unlocks the remaining 4 creatures
and all evolution paths. There are no subscriptions and no other IAPs.

Thank you!
— Birkan
```

## 6. Demo Account
Not needed — Anka has no login.

## 7. Submission

When all sections are green:
**App Store → Submit for Review**

Typical review time: 24-72 hours.
