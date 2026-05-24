# Anka — A Wrist Companion

Apple Watch + iPhone hibrit oyun. Anadolu mitolojisinden yaratıklar HealthKit verisiyle evrilir.

## Geliştirme

```bash
xcodegen generate
open Anka.xcodeproj
```

## Dokümanlar

- [GDD + Teknik Mimari](docs/ANKA_GDD.md)

## Gereksinimler

- Xcode 16+
- iOS 17.0+ / watchOS 10.0+
- Apple Developer hesabı

## Release

```bash
./scripts/archive.sh           # archive + export
./scripts/archive.sh upload    # ... and upload to App Store Connect
```

See [Submission Checklist](docs/SUBMISSION_CHECKLIST.md) and
[App Store Connect Setup](docs/APP_STORE_CONNECT.md).
