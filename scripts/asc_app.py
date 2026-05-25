#!/usr/bin/env python3
"""Create the Anka app in App Store Connect and link App Group."""

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


def make_token():
    with open(KEY_PATH, "rb") as f:
        key = f.read()
    now = int(time.time())
    return jwt.encode(
        {"iss": ISSUER_ID, "iat": now, "exp": now + 20*60, "aud": "appstoreconnect-v1"},
        key, algorithm="ES256", headers={"kid": KEY_ID, "typ": "JWT"}
    )


def call(method, path, body=None):
    url = f"{BASE_URL}{path}"
    data = json.dumps(body).encode() if body is not None else None
    req = urllib.request.Request(url, data=data, method=method)
    req.add_header("Authorization", f"Bearer {make_token()}")
    req.add_header("Content-Type", "application/json")
    try:
        with urllib.request.urlopen(req) as r:
            raw = r.read().decode()
            return json.loads(raw) if raw else {}
    except urllib.error.HTTPError as e:
        body_txt = e.read().decode()
        raise RuntimeError(f"HTTP {e.code} {method} {path}\n{body_txt}") from e


# ---- App Groups ----

def list_app_groups():
    return call("GET", "/appGroups")


def create_app_group(identifier, name):
    payload = {
        "data": {
            "type": "appGroups",
            "attributes": {
                "identifier": identifier,
                "name": name
            }
        }
    }
    return call("POST", "/appGroups", payload)


def link_app_group(bundle_id, app_group_id):
    """Assign an App Group to a bundle ID via the capability."""
    payload = {
        "data": [{"type": "appGroups", "id": app_group_id}]
    }
    return call("POST", f"/bundleIds/{bundle_id}/relationships/appGroups", payload)


# ---- App ----

def create_app(name, bundle_id, sku, primary_locale="en-US"):
    payload = {
        "data": {
            "type": "apps",
            "attributes": {
                "name": name,
                "primaryLocale": primary_locale,
                "bundleId": bundle_id,
                "sku": sku
            }
        }
    }
    return call("POST", "/apps", payload)


# ---- Main ----

if __name__ == "__main__":
    print("== Step 1: App Group ==")
    try:
        groups = list_app_groups()
        existing = None
        for g in groups.get("data", []):
            if g["attributes"]["identifier"] == "group.com.birkanaksoy.anka":
                existing = g
                break
        if existing:
            print(f"  · App Group already exists: {existing['id']}")
            group_id = existing["id"]
        else:
            resp = create_app_group("group.com.birkanaksoy.anka", "Anka shared")
            group_id = resp["data"]["id"]
            print(f"  ✓ Created App Group: {group_id}")
    except RuntimeError as e:
        print(f"  ! App Group creation: {e}", file=sys.stderr)
        group_id = None

    if group_id:
        for bid_name, bid_value in [
            ("Anka", "P664G3FMGP"),
            ("Watch", "7XB6RG223C"),
            ("Widget", "Y4725D8QHU"),
        ]:
            print(f"\n→ Linking App Group to {bid_name} ({bid_value})")
            try:
                link_app_group(bid_value, group_id)
                print("  ✓ linked")
            except RuntimeError as e:
                if "duplicate" in str(e).lower() or "already" in str(e).lower():
                    print("  · already linked")
                else:
                    print(f"  ! {e}")

    print("\n== Step 2: Create app in App Store Connect ==")
    try:
        resp = create_app("Anka", "com.birkanaksoy.anka", "anka-001")
        print(f"  ✓ Created app: {resp['data']['id']}")
    except RuntimeError as e:
        print(f"  ! {e}")
