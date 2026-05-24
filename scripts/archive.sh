#!/bin/bash
# Archive Anka for App Store distribution.
#
# Usage:
#   ./scripts/archive.sh                   # archive + export to build/Anka/
#   ./scripts/archive.sh upload            # ... then upload to App Store Connect
#
# Prerequisites:
#   - Apple Developer account active ($99/yr)
#   - Team ID set in ExportOptions.plist
#   - Bundle IDs registered in developer.apple.com
#   - Signed in to Xcode (Settings → Accounts)

set -euo pipefail

PROJECT="Anka.xcodeproj"
SCHEME="Anka"
ARCHIVE_PATH="build/Anka.xcarchive"
EXPORT_PATH="build/Anka"
EXPORT_OPTIONS="ExportOptions.plist"

# 0) Regenerate the Xcode project from project.yml.
echo "==> Regenerating Xcode project"
xcodegen generate

# 1) Bump the build number to a fresh timestamp so every upload is unique.
BUILD_NUMBER=$(date +%Y%m%d%H%M)
echo "==> Setting CURRENT_PROJECT_VERSION to $BUILD_NUMBER"
agvtool new-version -all "$BUILD_NUMBER" >/dev/null

# 2) Clean previous output.
rm -rf "$ARCHIVE_PATH" "$EXPORT_PATH"

# 3) Archive (Release configuration).
echo "==> Archiving"
xcodebuild \
    -project "$PROJECT" \
    -scheme "$SCHEME" \
    -configuration Release \
    -destination 'generic/platform=iOS' \
    -archivePath "$ARCHIVE_PATH" \
    archive | xcbeautify 2>/dev/null || \
xcodebuild \
    -project "$PROJECT" \
    -scheme "$SCHEME" \
    -configuration Release \
    -destination 'generic/platform=iOS' \
    -archivePath "$ARCHIVE_PATH" \
    archive

# 4) Export the IPA.
echo "==> Exporting IPA"
xcodebuild -exportArchive \
    -archivePath "$ARCHIVE_PATH" \
    -exportPath "$EXPORT_PATH" \
    -exportOptionsPlist "$EXPORT_OPTIONS"

IPA=$(ls "$EXPORT_PATH"/*.ipa | head -1)
echo "==> IPA ready: $IPA"

# 5) Optional upload.
if [[ "${1:-}" == "upload" ]]; then
    if [[ -z "${APP_STORE_API_KEY_ID:-}" || -z "${APP_STORE_API_ISSUER:-}" ]]; then
        echo "Set APP_STORE_API_KEY_ID and APP_STORE_API_ISSUER environment vars."
        echo "Or upload manually via Transporter.app: open $IPA"
        exit 1
    fi
    echo "==> Uploading via altool"
    xcrun altool --upload-app \
        --type ios \
        --file "$IPA" \
        --apiKey "$APP_STORE_API_KEY_ID" \
        --apiIssuer "$APP_STORE_API_ISSUER"
fi

echo
echo "Next steps:"
echo "  1. Open Transporter.app and drag $IPA into it (if not auto-uploaded)"
echo "  2. Wait ~15–30 min for App Store Connect processing"
echo "  3. Add the build to TestFlight (Internal Testing)"
echo "  4. Once happy: submit for App Review"
