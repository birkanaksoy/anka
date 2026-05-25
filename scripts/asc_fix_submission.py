#!/usr/bin/env python3
"""Fix submission validation errors via App Store Connect API."""

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
        print(f"  ! HTTP {e.code} {method} {path}\n    {txt[:500]}", file=sys.stderr)
        raise


def fix_content_rights():
    """Declare app does not use third-party content."""
    print("== Content Rights Declaration ==")
    body = {
        "data": {
            "type": "apps",
            "id": APP_ID,
            "attributes": {
                "contentRightsDeclaration": "DOES_NOT_USE_THIRD_PARTY_CONTENT"
            }
        }
    }
    try:
        req("PATCH", f"/apps/{APP_ID}", body)
        print("  ✓ Declared: does NOT use third-party content")
    except urllib.error.HTTPError:
        pass


def fix_copyright():
    """Set copyright on App Store Version."""
    print("\n== Copyright ==")
    resp = req("GET", f"/apps/{APP_ID}/appStoreVersions?limit=5")
    for v in resp.get("data", []):
        if v["attributes"]["appStoreState"] in ("PREPARE_FOR_SUBMISSION", "DEVELOPER_REJECTED"):
            vid = v["id"]
            body = {
                "data": {
                    "type": "appStoreVersions",
                    "id": vid,
                    "attributes": {
                        "copyright": "© 2026 Birkan Aksoy"
                    }
                }
            }
            try:
                req("PATCH", f"/appStoreVersions/{vid}", body)
                print(f"  ✓ Set copyright on version {vid}")
                return
            except urllib.error.HTTPError:
                pass


def fix_age_rating():
    """Create or update age rating declaration — everything NONE → 4+."""
    print("\n== Age Rating Questionnaire ==")
    # Get the app info first
    ai_resp = req("GET", f"/apps/{APP_ID}/appInfos")
    app_info_id = None
    for ai in ai_resp.get("data", []):
        if ai["attributes"].get("state") in ("PREPARE_FOR_SUBMISSION", "DEVELOPER_REJECTED"):
            app_info_id = ai["id"]
            break
    if not app_info_id:
        app_info_id = ai_resp["data"][0]["id"]

    # Check if age rating declaration exists
    try:
        decl_resp = req("GET", f"/appInfos/{app_info_id}/ageRatingDeclaration")
        existing_id = decl_resp.get("data", {}).get("id") if decl_resp.get("data") else None
    except urllib.error.HTTPError:
        existing_id = None

    # All-NONE answers for "4+" rating
    none_attrs = {
        "alcoholTobaccoOrDrugUseOrReferences": "NONE",
        "contests": "NONE",
        "gamblingSimulated": "NONE",
        "medicalOrTreatmentInformation": "NONE",
        "profanityOrCrudeHumor": "NONE",
        "sexualContentGraphicAndNudity": "NONE",
        "sexualContentOrNudity": "NONE",
        "horrorOrFearThemes": "NONE",
        "matureOrSuggestiveThemes": "NONE",
        "unrestrictedWebAccess": False,
        "gambling": False,
        "violenceCartoonOrFantasy": "NONE",
        "violenceRealisticProlongedGraphicOrSadistic": "NONE",
        "violenceRealistic": "NONE",
    }

    if existing_id:
        body = {
            "data": {
                "type": "ageRatingDeclarations",
                "id": existing_id,
                "attributes": none_attrs
            }
        }
        try:
            req("PATCH", f"/ageRatingDeclarations/{existing_id}", body)
            print(f"  ✓ Updated existing age rating declaration to 4+")
            return
        except urllib.error.HTTPError:
            pass
    # Create new
    body = {
        "data": {
            "type": "ageRatingDeclarations",
            "attributes": none_attrs,
            "relationships": {
                "appInfo": {"data": {"type": "appInfos", "id": app_info_id}}
            }
        }
    }
    try:
        resp = req("POST", "/ageRatingDeclarations", body)
        print(f"  ✓ Created age rating declaration (4+)")
    except urllib.error.HTTPError:
        pass


if __name__ == "__main__":
    fix_content_rights()
    fix_copyright()
    fix_age_rating()
    print("\nDone. Remaining: screenshots (iPhone 6.5\" + Apple Watch)")
