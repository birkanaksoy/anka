# Anka — Project Status

_Last updated: 2026-05-25_

## Where the project stands

**Code: 100% complete for v1.0 MVP.** All 15 planned sprints either done or
deferred to user-driven steps (illustrator, account setup, submission).

```
✅ Sprint 1  — MVP scaffolding (iPhone + Watch + Shared package)
✅ Sprint 2  — HealthKit real queries
✅ Sprint 3  — Daily snapshot pipeline + Background refresh
✅ Sprint 4  — iPhone ↔ Watch sync (WatchConnectivity + App Group)
✅ Sprint 5  — Watch polish (breathing animation, Crown, haptic)
✅ Sprint 6  — Complications (4 accessory families)
✅ Sprint 7  — Notifications (daily reminder + evolution celebration)
⏸️  Sprint 8  — Creature illustrations (PLACEHOLDER, awaiting illustrator)
✅ Sprint 9  — Accessibility + dark mode declared
✅ Sprint 10 — StoreKit 2 + Paywall ($6.99 lifetime)
✅ Sprint 11 — Legal docs (Privacy Policy, Terms, Support)
✅ Sprint 12 — App Store Connect setup instructions
✅ Sprint 13 — App icon placeholder + asset catalog + screenshot script
✅ Sprint 14 — Archive + export scripts + submission checklist
🔄 Sprint 15 — Submission day guide (ready when user is)
```

## Architecture summary

```
Anka/
├── iPhone/          (iOS 17+ app)
├── Watch/           (watchOS 10+ app)
├── Widget/          (WatchOS Widget extension — complications)
├── Shared/          (Swift package: models, services, evolution engine)
├── Tests/           (XCTest, 9/9 passing)
├── scripts/         (generate_icon.swift, capture_screenshots.sh, archive.sh)
├── docs/            (GDD, tech architecture, AppStore docs, checklists)
└── web/             (Privacy / Terms / Support — for GitHub Pages)
```

- 9/9 unit tests pass on every build
- Build clean under Swift 6 strict concurrency
- Single non-consumable IAP, App Group sharing, WatchConnectivity, HealthKit
- Privacy-first: no servers, no analytics, no tracking

## What's still on the user

These can't be done from code:

1. **Hire an illustrator** for 25 creature illustrations + final app icon.
   Budget $200-1000 on Fiverr/Upwork. ~3-4 weeks.
2. **Deploy `web/` to GitHub Pages.** ~30 minutes.
3. **App Store Connect setup** (App IDs, IAP, metadata).
   ~2 hours, walk through `docs/APP_STORE_CONNECT.md`.
4. **TestFlight beta** ~7-14 days with real testers.
5. **Submit for Review.** Walk through `docs/SUBMISSION_GUIDE.md`.

## Estimated time to App Store

- If illustrator delivers in 3 weeks: **~5-6 weeks from today**
- With placeholder icon and emojis: **~2 weeks** (but likely rejected)

## First-year revenue targets

| Scenario | Sales | Gross @ $6.99 |
|---|---|---|
| Worst | 10K | $70K |
| Realistic | 50K | $350K |
| Stretch | 200K | $1.4M |

Apple takes 15-30%, so net is ~70-85% of gross.

## Tech debt to handle in v1.1+

- Replace UserDefaults PetStore with SwiftData (richer querying)
- Add SwiftData CloudKit sync (user opt-in)
- iPhone widget (Home Screen, Lock Screen)
- Real-time HealthKit observer instead of pipeline-only refresh
- Snapshot tests for Watch UI
- Localization framework (TR + ES + DE + JA)
