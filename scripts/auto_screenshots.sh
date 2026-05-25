#!/bin/bash
# Automated capture of 5 App Store screenshots from the iPhone simulator.
#
# Uses xcrun simctl to drive the app and take screenshots. The app must
# accept a launch argument `--screenshot-stage=<n>` to deterministically
# show each screen; if not, falls back to manual prompts.

set -euo pipefail

DEVICE="${DEVICE:-iPhone 17 Pro Max}"
BUNDLE="com.birkanaksoy.anka"
OUTDIR="screenshots"
mkdir -p "$OUTDIR"

ensure_device() {
    xcrun simctl boot "$DEVICE" 2>/dev/null || true
    open -a Simulator
    sleep 2
}

snap() {
    local n="$1"
    local label="$2"
    local out="$OUTDIR/anka-$n-$label.png"
    xcrun simctl io "$DEVICE" screenshot "$out"
    echo "  ✓ $out"
}

# Reset app state for repeatable screenshots.
xcrun simctl terminate "$DEVICE" "$BUNDLE" 2>/dev/null || true
xcrun simctl uninstall "$DEVICE" "$BUNDLE" 2>/dev/null || true

APP_PATH=$(find ~/Library/Developer/Xcode/DerivedData/Anka-* -name "Anka.app" -path "*Debug-iphonesimulator*" | head -1)
xcrun simctl install "$DEVICE" "$APP_PATH"
ensure_device

# 1) Welcome screen
xcrun simctl launch "$DEVICE" "$BUNDLE"
sleep 2.5
snap 1 welcome

# Tap "Begin" — but coordinates depend on device. We'll just give the user
# a prompt to advance through screens by hand for the remaining shots.
echo
echo "Now tap through the app on the Simulator. Press ENTER between screens."

read -p "Show species picker, then press ENTER... "
snap 2 species

read -p "Pick Anka, tap Continue, type a name, tap Hatch the Egg, then press ENTER... "
snap 3 dashboard

read -p "Open the Lore tab, then press ENTER... "
snap 4 lore

read -p "Open Settings → tap Unlock Anka Premium, then press ENTER... "
snap 5 paywall

echo
echo "Done. Screenshots in $OUTDIR/"
ls -la "$OUTDIR"
