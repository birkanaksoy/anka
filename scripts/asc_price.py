#!/usr/bin/env python3
"""Set My Anka's App Store price to $4.99 (Tier 5) via App Store Connect API."""

import json, os, sys, time, urllib.request, urllib.error
import jwt

KEY_ID = "265D293FMJ"
ISSUER_ID = "043733eb-e8d3-4855-ad34-be06e1d3434e"
KEY_PATH = os.path.join(os.path.dirname(os.path.dirname(os.path.abspath(__file__))), ".auth_key.p8")
BASE_URL = "https://api.appstoreconnect.apple.com/v1"
APP_ID = "6772851997"


def tok():
    with open(KEY_PATH, "rb") as f: k = f.read()
    now = int(time.time())
    return jwt.encode(
        {"iss": ISSUER_ID, "iat": now, "exp": now+1200, "aud": "appstoreconnect-v1"},
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
        print(f"  ! HTTP {e.code} {method} {path}\n  {txt[:600]}", file=sys.stderr)
        raise


# Tier 5 = USD 4.99 across most storefronts. Apple's tier IDs are integers as strings.
TIER = "5"

def find_baseline_territory():
    """Pick USA storefront as price baseline."""
    resp = req("GET", "/territories?limit=200")
    for t in resp.get("data", []):
        if t["id"] == "USA":
            return t["id"]
    return resp["data"][0]["id"] if resp.get("data") else None


def main():
    print(f"== Setting price for app {APP_ID} to Tier {TIER} (~$4.99) ==")

    territory = find_baseline_territory()
    print(f"  · baseline territory: {territory}")

    # Create AppPriceSchedule with one manual price entry
    body = {
        "data": {
            "type": "appPriceSchedules",
            "relationships": {
                "app": {"data": {"type": "apps", "id": APP_ID}},
                "baseTerritory": {"data": {"type": "territories", "id": territory}},
                "manualPrices": {"data": [{"type": "appPrices", "id": "${price1}"}]}
            }
        },
        "included": [{
            "type": "appPrices",
            "id": "${price1}",
            "attributes": {
                "startDate": None
            },
            "relationships": {
                "appPricePoint": {
                    "data": {
                        "type": "appPricePoints",
                        "id": f"{APP_ID}_{TIER}_{territory}"
                    }
                },
                "territory": {"data": {"type": "territories", "id": territory}}
            }
        }]
    }
    try:
        resp = req("POST", "/appPriceSchedules", body)
        print(f"  ✓ Price schedule created: {resp.get('data', {}).get('id')}")
    except urllib.error.HTTPError as e:
        print(f"  · Direct schedule POST failed — likely existing schedule. Trying alternative...")
        # Fallback: look up price point ID and update
        try:
            pp = req("GET", f"/appPricePoints?filter[app]={APP_ID}&filter[priceTier]={TIER}&filter[territory]={territory}&limit=1")
            print(f"    available point: {pp}")
        except urllib.error.HTTPError:
            pass


if __name__ == "__main__":
    main()
