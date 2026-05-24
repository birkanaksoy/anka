#!/bin/bash
# Capture App Store screenshots from the iPhone simulator.
#
# Apple requires at minimum 3 screenshots per device class. Recommended set:
#   1. Hero (Companion tab with creature visible)
#   2. Onboarding species picker
#   3. Today's Health card
#   4. Lore / Album
#   5. Paywall
#
# Apple Watch screenshots are captured separately when the watch simulator
# is paired.

set -e

OUTDIR="screenshots"
mkdir -p "$OUTDIR"

DEVICE="iPhone 17 Pro Max"

echo "Booting $DEVICE..."
xcrun simctl boot "$DEVICE" 2>/dev/null || true
open -a Simulator

echo "Press ENTER once the app shows the screen you want to capture..."

for n in 1 2 3 4 5; do
    read -p "Capture frame $n (or Ctrl-C to stop): "
    xcrun simctl io "$DEVICE" screenshot "$OUTDIR/anka-iphone-$n.png"
    echo "  saved $OUTDIR/anka-iphone-$n.png"
done

echo "Done. Move PNGs into App Store Connect → Screenshots."
