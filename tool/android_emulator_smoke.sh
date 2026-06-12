#!/usr/bin/env bash
set -euo pipefail

package_id="${ANDROID_EMULATOR_PACKAGE_ID:-com.wellnessmaker.pocketmemorypet}"
apk="${ANDROID_EMULATOR_APK:-build/app/outputs/flutter-apk/app-debug.apk}"
smoke_log="${ANDROID_EMULATOR_SMOKE_LOG:-build/qa/android-emulator-smoke.txt}"
screenshot="${ANDROID_EMULATOR_SCREENSHOT_DEVICE:-/sdcard/pocket-memory-pet-smoke.png}"
pulled_screenshot="${ANDROID_EMULATOR_SCREENSHOT_LOCAL:-build/qa/android-emulator-smoke.png}"

mkdir -p build/qa

launch_result="failed"
launch_output=""
pid=""
installed_path=""

cleanup() {
  local code=$?
  {
    echo "workflow=Native Build"
    echo "job=android"
    echo "run_number=${GITHUB_RUN_NUMBER:-unknown}"
    echo "run_id=${GITHUB_RUN_ID:-unknown}"
    echo "commit=${GITHUB_SHA:-unknown}"
    echo "branch=${GITHUB_REF_NAME:-unknown}"
    echo "generated_utc=$(date -u +%Y-%m-%dT%H:%M:%SZ)"
    echo "emulator_api_level=30"
    echo "emulator_profile=pixel_2"
    echo "package_id=$package_id"
    echo "apk_path=$apk"
    echo "installed_path=$installed_path"
    echo "launch_result=$launch_result"
    echo "process_id=$pid"
    echo "launch_output=$(printf '%s' "$launch_output" | tr '\n' ' ')"
    if [ -f "$pulled_screenshot" ]; then
      echo "screenshot=android-emulator-smoke.png"
      echo "screenshot_size_bytes=$(stat -c%s "$pulled_screenshot")"
      echo "screenshot_sha256=$(sha256sum "$pulled_screenshot" | awk '{print $1}')"
    fi
  } > "$smoke_log"

  {
    echo "ANDROID_EMULATOR_LAUNCH_RESULT=$launch_result"
    echo "ANDROID_EMULATOR_PACKAGE=$package_id"
  } >> "$GITHUB_ENV"

  exit "$code"
}
trap cleanup EXIT

if [ ! -f "$apk" ]; then
  echo "Android debug APK does not exist: $apk"
  exit 1
fi

adb devices
adb install -r "$apk"

installed_path="$(adb shell pm path "$package_id" | tr -d '\r' || true)"
if [ -z "$installed_path" ]; then
  echo "Package was not installed: $package_id"
  exit 1
fi

launch_output="$(adb shell monkey -p "$package_id" -c android.intent.category.LAUNCHER 1 2>&1 | tr -d '\r')"
sleep 8

pid="$(adb shell pidof "$package_id" | tr -d '\r' || true)"
if [ -z "$pid" ]; then
  adb logcat -d -t 250 > build/qa/android-emulator-logcat.txt || true
  echo "Android app process was not running after launch."
  exit 1
fi

adb shell screencap -p "$screenshot" || true
adb pull "$screenshot" "$pulled_screenshot" || true
launch_result="passed"
