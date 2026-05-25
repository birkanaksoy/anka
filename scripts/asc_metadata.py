#!/usr/bin/env python3
"""Fill My Anka's App Store metadata via API."""

import json, os, sys, time, urllib.request, urllib.error
import jwt

KEY_ID = "265D293FMJ"
ISSUER_ID = "043733eb-e8d3-4855-ad34-be06e1d3434e"
KEY_PATH = os.path.join(os.path.dirname(os.path.dirname(os.path.abspath(__file__))), ".auth_key.p8")
BASE_URL = "https://api.appstoreconnect.apple.com/v1"
APP_ID = "6772851997"


def tok():
    with open(KEY_PATH, "rb") as f:
        k = f.read()
    now = int(time.time())
    return jwt.encode(
        {"iss": ISSUER_ID, "iat": now, "exp": now + 20*60, "aud": "appstoreconnect-v1"},
        k, algorithm="ES256", headers={"kid": KEY_ID, "typ": "JWT"}
    )


def req(method, path, body=None):
    url = f"{BASE_URL}{path}"
    data = json.dumps(body).encode() if body is not None else None
    r = urllib.request.Request(url, data=data, method=method)
    r.add_header("Authorization", f"Bearer {tok()}")
    r.add_header("Content-Type", "application/json")
    try:
        with urllib.request.urlopen(r) as resp:
            txt = resp.read().decode()
            return json.loads(txt) if txt else {}
    except urllib.error.HTTPError as e:
        txt = e.read().decode()
        print(f"  ! {method} {path}\n    HTTP {e.code}: {txt[:400]}", file=sys.stderr)
        raise


SUBTITLE = "A Wrist Companion of Myth"
DESCRIPTION = """A WRIST COMPANION BORN OF MYTH

Hatch a mythological creature on your wrist. Your daily steps, heartbeats, stand hours, sleep and workouts shape what it becomes. Every choice in your day pushes your Anka toward a different evolution.

FIVE COMPANIONS FROM ANATOLIAN MYTH
• Anka — the immortal firebird that burns to ash and rises again
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
Your health data never leaves your device. We have no servers. We have no analytics about you. My Anka is a quiet, personal thing.

Crafted by an independent developer for everyone who wants a small, beautiful, mythic companion on their wrist."""

KEYWORDS = "tamagotchi,virtual pet,watch,companion,health,fitness,steps,mythology,idle,pet,evolve"
PROMO = "Hatch a creature from Anatolian myth on your wrist. Your steps, heartbeats, and sleep shape who it becomes. Five companions. Five paths."
SUPPORT_URL = "https://birkanaksoy.github.io/anka/support.html"
MARKETING_URL = "https://birkanaksoy.github.io/anka/"
PRIVACY_URL = "https://birkanaksoy.github.io/anka/privacy.html"


# ---------- AppInfo (categories, content rights, age rating) ----------

def get_app_info():
    resp = req("GET", f"/apps/{APP_ID}/appInfos")
    for ai in resp.get("data", []):
        state = ai["attributes"].get("state", "")
        # We want the editable one: PREPARE_FOR_SUBMISSION (or any non-READY_FOR_DISTRIBUTION)
        if state != "READY_FOR_DISTRIBUTION":
            return ai
    return resp["data"][0] if resp.get("data") else None


def list_categories():
    resp = req("GET", "/appCategories?limit=200")
    cats = {c["id"]: c for c in resp.get("data", [])}
    return cats


def find_category(cats, key):
    return cats.get(key) and cats[key]


def update_app_info_categories(app_info_id, primary_id, secondary_id):
    payload = {
        "data": {
            "type": "appInfos",
            "id": app_info_id,
            "relationships": {
                "primaryCategory": {
                    "data": {"type": "appCategories", "id": primary_id}
                },
                "secondaryCategory": {
                    "data": {"type": "appCategories", "id": secondary_id}
                }
            }
        }
    }
    return req("PATCH", f"/appInfos/{app_info_id}", payload)


# ---------- AppInfoLocalization ----------

def get_app_info_localization(app_info_id, locale="en-US"):
    resp = req("GET", f"/appInfos/{app_info_id}/appInfoLocalizations")
    for l in resp.get("data", []):
        if l["attributes"]["locale"] == locale:
            return l
    return None


def update_app_info_localization(loc_id):
    payload = {
        "data": {
            "type": "appInfoLocalizations",
            "id": loc_id,
            "attributes": {
                "name": "My Anka",
                "subtitle": SUBTITLE,
                "privacyPolicyUrl": PRIVACY_URL,
            }
        }
    }
    return req("PATCH", f"/appInfoLocalizations/{loc_id}", payload)


# ---------- AppStoreVersion + Localization ----------

def get_or_create_version():
    resp = req("GET", f"/apps/{APP_ID}/appStoreVersions?limit=10")
    for v in resp.get("data", []):
        state = v["attributes"]["appStoreState"]
        if state == "PREPARE_FOR_SUBMISSION":
            return v
    # Create new
    payload = {
        "data": {
            "type": "appStoreVersions",
            "attributes": {
                "platform": "IOS",
                "versionString": "1.0.0",
                "copyright": "© 2026 Birkan Aksoy",
                "releaseType": "MANUAL"
            },
            "relationships": {
                "app": {"data": {"type": "apps", "id": APP_ID}}
            }
        }
    }
    resp = req("POST", "/appStoreVersions", payload)
    return resp["data"]


def get_version_localization(version_id, locale="en-US"):
    resp = req("GET", f"/appStoreVersions/{version_id}/appStoreVersionLocalizations")
    for l in resp.get("data", []):
        if l["attributes"]["locale"] == locale:
            return l
    return None


def update_version_localization(loc_id):
    payload = {
        "data": {
            "type": "appStoreVersionLocalizations",
            "id": loc_id,
            "attributes": {
                "description": DESCRIPTION,
                "keywords": KEYWORDS,
                "marketingUrl": MARKETING_URL,
                "supportUrl": SUPPORT_URL,
                "promotionalText": PROMO,
            }
        }
    }
    return req("PATCH", f"/appStoreVersionLocalizations/{loc_id}", payload)


# ---------- Main ----------

def main():
    print("== App Info (categories + privacy URL) ==")
    ai = get_app_info()
    if not ai:
        print("  ! No app info found"); return
    ai_id = ai["id"]
    print(f"  · app info id: {ai_id} (state: {ai['attributes'].get('state')})")

    cats = list_categories()
    games_id = "GAMES"  # category enum-style IDs
    health_id = "HEALTH_AND_FITNESS"
    # The actual primary cat IDs are like "GAMES" — confirmed via API responses.
    if games_id in cats and health_id in cats:
        try:
            update_app_info_categories(ai_id, games_id, health_id)
            print("  ✓ categories: Games (primary) + Health & Fitness (secondary)")
        except urllib.error.HTTPError:
            pass
    else:
        print(f"  · category IDs not found, available: {list(cats.keys())[:10]}...")

    loc = get_app_info_localization(ai_id)
    if loc:
        try:
            update_app_info_localization(loc["id"])
            print(f"  ✓ subtitle + privacy URL set for {loc['attributes']['locale']}")
        except urllib.error.HTTPError:
            pass

    print("\n== App Store Version (description, keywords, URLs) ==")
    v = get_or_create_version()
    v_id = v["id"]
    print(f"  · version id: {v_id} (version: {v['attributes'].get('versionString')})")

    vloc = get_version_localization(v_id)
    if vloc:
        try:
            update_version_localization(vloc["id"])
            print(f"  ✓ description/keywords/URLs set for {vloc['attributes']['locale']}")
        except urllib.error.HTTPError:
            pass

    print("\nDone. App Store sayfasını ASC'de açıp kontrol edebilirsin.")


if __name__ == "__main__":
    main()
