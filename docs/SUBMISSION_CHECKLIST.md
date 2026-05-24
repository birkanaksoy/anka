# Anka — Submission Checklist

Pre-flight before tapping **Submit for Review** in App Store Connect.

## Code & Build
- [x] All targets compile with **Swift 6 strict concurrency** and no warnings
- [x] All unit tests pass (`xcodebuild test`)
- [x] iPhone app launches, onboarding works, Health prompt fires
- [x] Watch companion app launches, syncs pet from iPhone
- [x] Complications render in all 4 supported families
- [x] Notifications schedule (daily reminder + evolution celebration)
- [x] StoreKit paywall opens, "Restore Purchase" present
- [ ] Deep-link / Universal Links — **N/A for v0.1**
- [ ] Cold start under 2 seconds on iPhone 12 — **verify on device**
- [ ] Crash-free on TestFlight beta — **verify after upload**

## Assets
- [x] App icon 1024x1024 (PNG, no alpha, no transparency)
- [ ] Real creature illustrations (Sprint 8 — illustrator) — **PLACEHOLDER only**
- [ ] iPhone screenshots (6.7" required — at least 3): `scripts/capture_screenshots.sh`
- [ ] Apple Watch screenshots (Ultra + 45mm)
- [ ] Optional app preview video

## App Store Connect
- [ ] App ID `com.birkanaksoy.anka` registered with capabilities
- [ ] App ID `com.birkanaksoy.anka.watchkitapp` registered
- [ ] App ID `com.birkanaksoy.anka.watchkitapp.widget` registered
- [ ] App Group `group.com.birkanaksoy.anka` created and assigned
- [ ] App created in App Store Connect (name "Anka", SKU "anka-001")
- [ ] IAP `com.birkanaksoy.anka.premium.lifetime` ($6.99) created
- [ ] Age Rating questionnaire submitted (target: 4+)
- [ ] App Privacy: "Data Not Collected" declared
- [ ] Pricing & Availability: Free, all countries (or soft-launch subset)

## Metadata (from docs/APP_STORE_CONNECT.md)
- [ ] Name, Subtitle, Promotional Text, Description, Keywords
- [ ] Categories: Games (primary) + Health & Fitness (secondary)
- [ ] Support URL working (deploy `web/` to GitHub Pages)
- [ ] Privacy Policy URL working
- [ ] Copyright string filled

## Build Upload
- [ ] `ExportOptions.plist` has correct `teamID`
- [ ] `./scripts/archive.sh` runs cleanly
- [ ] IPA uploaded via Transporter or `./scripts/archive.sh upload`
- [ ] Build appears in App Store Connect (processing ~15–30 min)
- [ ] Build added to TestFlight Internal Testing
- [ ] Beta tested for 7+ days on real device

## App Review notes (from docs/APP_STORE_CONNECT.md)
- [ ] Demo flow explained
- [ ] No demo account (no login)
- [ ] HealthKit rationale clear

## Submit
- [ ] All sections show green checkmarks in App Store Connect
- [ ] Submit for Review
- [ ] Expect 24–72 hours for first response
