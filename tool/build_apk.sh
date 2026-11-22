#!/usr/bin/env bash
# Builds the merchant APK with push notifications configured from android/app/google-services.json
# (Firebase console → Project settings → Your apps → Android app com.taxipay.taxipay_merchant).
#
#   tool/build_apk.sh http://192.168.1.7:8080            # debug APK
#   tool/build_apk.sh http://192.168.1.7:8080 --release   # any extra flutter build args
set -euo pipefail
cd "$(dirname "$0")/.."

API_BASE_URL="${1:-http://10.0.2.2:8080}"
shift || true
MODE="--debug"
[[ " $* " == *" --release "* || " $* " == *" --profile "* ]] && MODE=""

GS=android/app/google-services.json
DEFINES=(--dart-define=API_BASE_URL="$API_BASE_URL")
if [[ -f "$GS" ]]; then
  # Read the Android client of this package from google-services.json.
  read -r API_KEY APP_ID SENDER_ID PROJECT_ID < <(python3 - "$GS" <<'PY'
import json, sys
gs = json.load(open(sys.argv[1]))
pkg = "com.taxipay.taxipay_merchant"
client = next((c for c in gs["client"] if c["client_info"]["android_client_info"]["package_name"] == pkg), gs["client"][0])
print(client["api_key"][0]["current_key"], client["client_info"]["mobilesdk_app_id"],
      gs["project_info"]["project_number"], gs["project_info"]["project_id"])
PY
  )
  DEFINES+=(--dart-define=FIREBASE_API_KEY="$API_KEY" --dart-define=FIREBASE_APP_ID="$APP_ID"
            --dart-define=FIREBASE_SENDER_ID="$SENDER_ID" --dart-define=FIREBASE_PROJECT_ID="$PROJECT_ID")
  echo "Push notifications: Firebase project $PROJECT_ID"
else
  echo "No $GS — building without push notifications (live updates still work while the app is open)."
fi

flutter build apk $MODE "${DEFINES[@]}" "$@"
