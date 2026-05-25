#!/usr/bin/env python3
"""
Minimal App Store Connect API client.

Usage:
    ./scripts/asc.py apps             # list all apps
    ./scripts/asc.py bundles          # list bundle IDs registered in Developer Portal
    ./scripts/asc.py iaps <appId>     # list IAPs for app
    ./scripts/asc.py status           # quick health check
"""

import json
import os
import sys
import time
import urllib.request
import jwt

KEY_ID = "265D293FMJ"
ISSUER_ID = "043733eb-e8d3-4855-ad34-be06e1d3434e"
KEY_PATH = os.path.join(os.path.dirname(os.path.dirname(os.path.abspath(__file__))), ".auth_key.p8")
BASE_URL = "https://api.appstoreconnect.apple.com/v1"


def make_token() -> str:
    with open(KEY_PATH, "rb") as f:
        private_key = f.read()
    now = int(time.time())
    payload = {
        "iss": ISSUER_ID,
        "iat": now,
        "exp": now + 20 * 60,  # 20 min
        "aud": "appstoreconnect-v1",
    }
    headers = {"kid": KEY_ID, "typ": "JWT"}
    return jwt.encode(payload, private_key, algorithm="ES256", headers=headers)


def call(path: str) -> dict:
    token = make_token()
    url = f"{BASE_URL}{path}"
    req = urllib.request.Request(url, headers={"Authorization": f"Bearer {token}"})
    try:
        with urllib.request.urlopen(req) as resp:
            return json.loads(resp.read().decode())
    except urllib.error.HTTPError as e:
        body = e.read().decode()
        print(f"HTTP {e.code}: {body}", file=sys.stderr)
        sys.exit(1)


def cmd_apps():
    data = call("/apps?limit=200")
    apps = data.get("data", [])
    if not apps:
        print("(no apps registered in App Store Connect)")
        return
    for a in apps:
        attrs = a["attributes"]
        print(f"  · {attrs.get('name', '?')}  [{attrs.get('bundleId', '?')}]  id={a['id']}")


def cmd_bundles():
    data = call("/bundleIds?limit=200")
    items = data.get("data", [])
    if not items:
        print("(no bundle IDs registered in Developer Portal)")
        return
    for b in items:
        attrs = b["attributes"]
        print(f"  · {attrs.get('identifier', '?')}  ({attrs.get('platform', '?')})  name={attrs.get('name', '?')}")


def cmd_iaps(app_id: str):
    data = call(f"/apps/{app_id}/inAppPurchasesV2?limit=50")
    items = data.get("data", [])
    if not items:
        print("(no IAPs)")
        return
    for i in items:
        attrs = i["attributes"]
        print(f"  · {attrs.get('name', '?')}  [{attrs.get('productId', '?')}]  state={attrs.get('state', '?')}")


def cmd_status():
    print("== App Store Connect status ==")
    print("\nApps in App Store Connect:")
    cmd_apps()
    print("\nBundle IDs in Developer Portal:")
    cmd_bundles()


if __name__ == "__main__":
    cmd = sys.argv[1] if len(sys.argv) > 1 else "status"
    if cmd == "apps":
        cmd_apps()
    elif cmd == "bundles":
        cmd_bundles()
    elif cmd == "iaps":
        cmd_iaps(sys.argv[2])
    elif cmd == "status":
        cmd_status()
    else:
        print(__doc__)
        sys.exit(1)
