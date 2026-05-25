#!/usr/bin/env python3
"""Create Anka bundle IDs and capabilities via App Store Connect API."""

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


def make_token() -> str:
    with open(KEY_PATH, "rb") as f:
        private_key = f.read()
    now = int(time.time())
    payload = {
        "iss": ISSUER_ID,
        "iat": now,
        "exp": now + 20 * 60,
        "aud": "appstoreconnect-v1",
    }
    headers = {"kid": KEY_ID, "typ": "JWT"}
    return jwt.encode(payload, private_key, algorithm="ES256", headers=headers)


def request(method: str, path: str, body=None):
    token = make_token()
    url = f"{BASE_URL}{path}"
    data = json.dumps(body).encode() if body is not None else None
    req = urllib.request.Request(url, data=data, method=method)
    req.add_header("Authorization", f"Bearer {token}")
    req.add_header("Content-Type", "application/json")
    try:
        with urllib.request.urlopen(req) as resp:
            raw = resp.read().decode()
            return json.loads(raw) if raw else {}
    except urllib.error.HTTPError as e:
        body_txt = e.read().decode()
        print(f"HTTP {e.code} {method} {path}\n{body_txt}\n", file=sys.stderr)
        raise


def create_bundle_id(identifier: str, name: str, platform: str = "IOS"):
    payload = {
        "data": {
            "type": "bundleIds",
            "attributes": {
                "identifier": identifier,
                "name": name,
                "platform": platform,
                "seedId": "879968V3XN",
            }
        }
    }
    try:
        resp = request("POST", "/bundleIds", payload)
        bid = resp["data"]["id"]
        print(f"  ✓ created {identifier} (id={bid})")
        return bid
    except urllib.error.HTTPError as e:
        if e.code == 409:
            # Already exists — fetch the existing one
            resp = request("GET", f"/bundleIds?filter[identifier]={identifier}&limit=1")
            if resp["data"]:
                bid = resp["data"][0]["id"]
                print(f"  · {identifier} already exists (id={bid})")
                return bid
        raise


def find_bundle_id(identifier: str):
    resp = request("GET", f"/bundleIds?filter[identifier]={identifier}&limit=1")
    if resp["data"]:
        return resp["data"][0]["id"]
    return None


def list_capabilities(bundle_id: str):
    resp = request("GET", f"/bundleIds/{bundle_id}/bundleIdCapabilities")
    enabled = {c["attributes"]["capabilityType"] for c in resp.get("data", [])}
    return enabled


def enable_capability(bundle_id: str, capability_type: str, settings=None):
    body = {
        "data": {
            "type": "bundleIdCapabilities",
            "attributes": {
                "capabilityType": capability_type,
            },
            "relationships": {
                "bundleId": {
                    "data": {"type": "bundleIds", "id": bundle_id}
                }
            }
        }
    }
    if settings:
        body["data"]["attributes"]["settings"] = settings
    try:
        request("POST", "/bundleIdCapabilities", body)
        print(f"    ✓ enabled {capability_type}")
    except urllib.error.HTTPError as e:
        if e.code == 409 or "already" in str(e):
            print(f"    · {capability_type} already enabled")
        else:
            raise


def ensure(identifier: str, name: str, capabilities: list):
    print(f"\n→ {identifier} ({name})")
    bid = create_bundle_id(identifier, name)
    existing = list_capabilities(bid)
    for cap in capabilities:
        if cap in existing:
            print(f"    · {cap} already enabled")
        else:
            enable_capability(bid, cap)


if __name__ == "__main__":
    print("== Registering Anka bundle IDs and capabilities ==")

    # 1) iPhone app
    ensure(
        "com.birkanaksoy.anka",
        "Anka",
        ["APP_GROUPS", "HEALTHKIT"]
    )

    # 2) Watch app
    ensure(
        "com.birkanaksoy.anka.watchkitapp",
        "Anka Watch",
        ["APP_GROUPS", "HEALTHKIT"]
    )

    # 3) Widget extension
    ensure(
        "com.birkanaksoy.anka.watchkitapp.widget",
        "Anka Widget",
        ["APP_GROUPS"]
    )

    print("\nDone.")
