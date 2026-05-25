#!/usr/bin/env python3
"""Complete Anka setup after the app exists in App Store Connect."""

import json
import os
import sys
import time
import urllib.request
import urllib.error
import jwt

KEY_ID = "265D293FMJ"
ISSUER_ID = "043733eb-e8d3-4855-ad34-be06e1d3434e"
KEY_PATH = os.path.join(os.path.dirname(os.path.dirname(os.path.abspath(__file__))), ".auth_key.p8")
BASE_URL = "https://api.appstoreconnect.apple.com/v1"

APP_ID = "6772851997"
BUNDLE_IDS = {
    "anka": "P664G3FMGP",
    "watch": "7XB6RG223C",
    "widget": "Y4725D8QHU",
}


def token():
    with open(KEY_PATH, "rb") as f:
        k = f.read()
    now = int(time.time())
    return jwt.encode(
        {"iss": ISSUER_ID, "iat": now, "exp": now+20*60, "aud": "appstoreconnect-v1"},
        k, algorithm="ES256", headers={"kid": KEY_ID, "typ": "JWT"}
    )


def call(method, path, body=None, expect_ok=True):
    url = f"{BASE_URL}{path}"
    data = json.dumps(body).encode() if body is not None else None
    req = urllib.request.Request(url, data=data, method=method)
    req.add_header("Authorization", f"Bearer {token()}")
    req.add_header("Content-Type", "application/json")
    try:
        with urllib.request.urlopen(req) as r:
            raw = r.read().decode()
            return json.loads(raw) if raw else {}
    except urllib.error.HTTPError as e:
        txt = e.read().decode()
        if expect_ok:
            print(f"  ! HTTP {e.code} {method} {path}\n  {txt}", file=sys.stderr)
        raise


# -------- 1) App Group probe + assign --------

def probe_app_group():
    """Try to find an App Group via the bundle ID relationship; existence
    isn't directly queryable through ASC API in all cases."""
    try:
        resp = call("GET", f"/bundleIds/{BUNDLE_IDS['anka']}/appGroups")
        groups = resp.get("data", [])
        for g in groups:
            ident = g.get("attributes", {}).get("identifier", "")
            if ident == "group.com.birkanaksoy.anka":
                return g["id"]
        return None
    except urllib.error.HTTPError:
        return None


def assign_app_group(bundle_id, group_id):
    """Link an App Group to a bundle ID via the relationship endpoint."""
    payload = {"data": [{"type": "appGroups", "id": group_id}]}
    try:
        call("POST", f"/bundleIds/{bundle_id}/relationships/appGroups", payload, expect_ok=False)
        print(f"    ✓ linked App Group to {bundle_id}")
    except urllib.error.HTTPError as e:
        body = e.read().decode() if hasattr(e, 'read') else str(e)
        if "duplicate" in body.lower() or "already" in body.lower() or e.code == 409:
            print(f"    · App Group already linked to {bundle_id}")
        else:
            print(f"    ! {bundle_id}: HTTP {e.code} {body[:200]}")


# -------- 2) IAP --------

def list_iaps():
    return call("GET", f"/apps/{APP_ID}/inAppPurchasesV2")


def create_iap():
    """Create non-consumable Anka Premium IAP."""
    body = {
        "data": {
            "type": "inAppPurchases",
            "attributes": {
                "name": "Anka Premium",
                "productId": "com.birkanaksoy.anka.premium.lifetime",
                "inAppPurchaseType": "NON_CONSUMABLE",
                "reviewNote": "Unlocks all 5 mythological creatures and every evolution path.",
            },
            "relationships": {
                "app": {"data": {"type": "apps", "id": APP_ID}}
            }
        }
    }
    return call("POST", "/inAppPurchases", body)


# -------- Main --------

def main():
    print("== Step A: App Group ==")
    gid = probe_app_group()
    if gid:
        print(f"  · Found App Group on Anka bundle: {gid}")
        # Already linked. Try linking to Watch + Widget too.
        for name in ["watch", "widget"]:
            assign_app_group(BUNDLE_IDS[name], gid)
    else:
        print("  ! No App Group linked yet. Trying global appGroups list...")
        # Try the modern endpoint
        try:
            resp = call("GET", "/appGroups", expect_ok=False)
            print(f"    response: {resp}")
        except urllib.error.HTTPError as e:
            print(f"    /appGroups endpoint: HTTP {e.code}")
        print("\n  ⚠️  You must create App Group 'group.com.birkanaksoy.anka' manually:")
        print("     https://developer.apple.com/account/resources/identifiers/list/applicationGroup")

    print("\n== Step B: In-App Purchase ==")
    try:
        existing = list_iaps()
        found = None
        for i in existing.get("data", []):
            if i["attributes"]["productId"] == "com.birkanaksoy.anka.premium.lifetime":
                found = i
                break
        if found:
            print(f"  · IAP already exists: id={found['id']}")
        else:
            resp = create_iap()
            print(f"  ✓ Created IAP: id={resp['data']['id']}")
            print("    (Pricing must be set manually in App Store Connect → IAP → Anka Premium)")
    except urllib.error.HTTPError as e:
        pass  # already printed


if __name__ == "__main__":
    main()
