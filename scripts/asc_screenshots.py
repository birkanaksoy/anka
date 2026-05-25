#!/usr/bin/env python3
"""Upload screenshots to App Store Connect.

Apple's flow:
1. Find or create appScreenshotSet for the given display type
2. POST appScreenshot reservation (returns upload URL + headers)
3. PUT bytes to that URL with the provided headers
4. PATCH appScreenshot to commit (sourceFileChecksum)
"""

import hashlib
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

# Get the prepare-for-submission version
def tok():
    with open(KEY_PATH, "rb") as f: k = f.read()
    now = int(time.time())
    return jwt.encode(
        {"iss": ISSUER_ID, "iat": now, "exp": now+1200, "aud": "appstoreconnect-v1"},
        k, algorithm="ES256", headers={"kid": KEY_ID, "typ": "JWT"}
    )


def call(method, url, body=None, headers=None, raw_data=None):
    is_full = url.startswith("http")
    full = url if is_full else f"{BASE_URL}{url}"
    if raw_data is not None:
        data = raw_data
    else:
        data = json.dumps(body).encode() if body is not None else None
    r = urllib.request.Request(full, data=data, method=method)
    if not is_full or headers is None:
        r.add_header("Authorization", f"Bearer {tok()}")
        r.add_header("Content-Type", "application/json")
    if headers:
        for h in headers:
            r.add_header(h["name"], h["value"])
    try:
        with urllib.request.urlopen(r) as resp:
            txt = resp.read().decode() if not is_full else resp.read()
            if is_full: return txt
            return json.loads(txt) if txt else {}
    except urllib.error.HTTPError as e:
        body_txt = e.read().decode(errors='replace')
        print(f"HTTP {e.code} {method} {url}\n  {body_txt[:600]}", file=sys.stderr)
        raise


def get_version_id():
    resp = call("GET", f"/apps/{APP_ID}/appStoreVersions?limit=5")
    for v in resp.get("data", []):
        if v["attributes"]["appStoreState"] in ("PREPARE_FOR_SUBMISSION", "DEVELOPER_REJECTED", "READY_FOR_REVIEW"):
            return v["id"]
    return resp["data"][0]["id"] if resp.get("data") else None


def get_or_create_set(version_id, display_type, localization_id=None):
    """Find or create an AppScreenshotSet for a given screenshotDisplayType."""
    # Get appStoreVersionLocalization
    if localization_id is None:
        locs = call("GET", f"/appStoreVersions/{version_id}/appStoreVersionLocalizations")
        localization_id = locs["data"][0]["id"]

    # List existing sets
    sets = call("GET", f"/appStoreVersionLocalizations/{localization_id}/appScreenshotSets")
    for s in sets.get("data", []):
        if s["attributes"]["screenshotDisplayType"] == display_type:
            return s["id"]
    # Create new
    body = {
        "data": {
            "type": "appScreenshotSets",
            "attributes": {"screenshotDisplayType": display_type},
            "relationships": {
                "appStoreVersionLocalization": {
                    "data": {"type": "appStoreVersionLocalizations", "id": localization_id}
                }
            }
        }
    }
    resp = call("POST", "/appScreenshotSets", body)
    return resp["data"]["id"]


def upload(set_id, file_path, file_name):
    file_size = os.path.getsize(file_path)
    with open(file_path, "rb") as f:
        file_bytes = f.read()

    # Step 1: reserve
    reserve_body = {
        "data": {
            "type": "appScreenshots",
            "attributes": {
                "fileName": file_name,
                "fileSize": file_size
            },
            "relationships": {
                "appScreenshotSet": {
                    "data": {"type": "appScreenshotSets", "id": set_id}
                }
            }
        }
    }
    res = call("POST", "/appScreenshots", reserve_body)
    sid = res["data"]["id"]
    operations = res["data"]["attributes"]["uploadOperations"]

    # Step 2: upload each part (usually 1)
    for op in operations:
        url = op["url"]
        method = op["method"]
        headers = op.get("requestHeaders", [])
        offset = op.get("offset", 0)
        length = op.get("length", file_size)
        chunk = file_bytes[offset:offset+length]
        call(method, url, raw_data=chunk, headers=headers)

    # Step 3: commit
    md5 = hashlib.md5(file_bytes).hexdigest()
    commit = {
        "data": {
            "type": "appScreenshots",
            "id": sid,
            "attributes": {
                "uploaded": True,
                "sourceFileChecksum": md5
            }
        }
    }
    call("PATCH", f"/appScreenshots/{sid}", commit)
    print(f"    ✓ {file_name}")
    return sid


def delete_existing(set_id):
    """Delete all existing screenshots in the set to allow replacement."""
    sets = call("GET", f"/appScreenshotSets/{set_id}/appScreenshots")
    for s in sets.get("data", []):
        try:
            call("DELETE", f"/appScreenshots/{s['id']}")
        except urllib.error.HTTPError:
            pass


if __name__ == "__main__":
    version_id = get_version_id()
    if not version_id:
        print("No version found")
        sys.exit(1)
    print(f"Version: {version_id}")

    # Get localization
    locs = call("GET", f"/appStoreVersions/{version_id}/appStoreVersionLocalizations")
    loc_id = locs["data"][0]["id"]

    # iPhone 6.7" (Pro Max class) — covers 6.5" + 6.7" requirements
    print("\n== iPhone 6.7\" (Pro Max) screenshots ==")
    iphone_set = get_or_create_set(version_id, "APP_IPHONE_67", localization_id=loc_id)
    print(f"  set: {iphone_set}")
    delete_existing(iphone_set)
    for fname in ["01-welcome.png", "02-dashboard.png", "03-anka-evolved.png"]:
        path = f"/Users/birkanaksoy/oyun009/screenshots/{fname}"
        if os.path.exists(path):
            upload(iphone_set, path, fname)

    # Apple Watch Series 10 / Ultra — modern Watch size
    print("\n== Apple Watch screenshots ==")
    try:
        watch_set = get_or_create_set(version_id, "APP_WATCH_ULTRA", localization_id=loc_id)
    except urllib.error.HTTPError:
        watch_set = get_or_create_set(version_id, "APP_WATCH_SERIES_10", localization_id=loc_id)
    print(f"  set: {watch_set}")
    delete_existing(watch_set)
    path = "/Users/birkanaksoy/oyun009/screenshots/04-watch-pet.png"
    if os.path.exists(path):
        upload(watch_set, path, "04-watch-pet.png")

    print("\nDone.")
