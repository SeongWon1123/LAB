#!/usr/bin/env bash
set -euo pipefail

APP_ID="com.wellnessmaker.pocketmemorypet"
APP_NAME="Pocket Memory Pet"
PYTHON_BIN="${PYTHON_BIN:-python3}"

flutter create --platforms=android,ios --org com.wellnessmaker --project-name pocket_memory_pet .

patch_file() {
  local file="$1"
  local pattern="$2"
  local replacement="$3"
  "$PYTHON_BIN" - "$file" "$pattern" "$replacement" <<'PY'
from pathlib import Path
import re
import sys

path = Path(sys.argv[1])
pattern = sys.argv[2]
replacement = sys.argv[3]
text = path.read_text(encoding="utf-8")
next_text = re.sub(pattern, replacement, text)
if next_text != text:
    path.write_text(next_text, encoding="utf-8")
PY
}

if [[ -f android/app/build.gradle.kts ]]; then
  patch_file android/app/build.gradle.kts 'namespace = ".*"' "namespace = \"$APP_ID\""
  patch_file android/app/build.gradle.kts 'applicationId = ".*"' "applicationId = \"$APP_ID\""
  patch_file android/app/build.gradle.kts 'minSdk = flutter.minSdkVersion' 'minSdk = 23'
  "$PYTHON_BIN" - <<'PY'
from pathlib import Path

path = Path("android/app/build.gradle.kts")
text = path.read_text(encoding="utf-8")
if "isCoreLibraryDesugaringEnabled" not in text:
    text = text.replace(
        "compileOptions {\n",
        "compileOptions {\n        isCoreLibraryDesugaringEnabled = true\n",
        1,
    )
if "coreLibraryDesugaring(" not in text:
    text += '\n\ndependencies {\n    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.5")\n}\n'
path.write_text(text, encoding="utf-8")
PY
elif [[ -f android/app/build.gradle ]]; then
  patch_file android/app/build.gradle "namespace ['\"].*['\"]" "namespace '$APP_ID'"
  patch_file android/app/build.gradle "applicationId ['\"].*['\"]" "applicationId '$APP_ID'"
  patch_file android/app/build.gradle 'minSdkVersion flutter.minSdkVersion' 'minSdkVersion 23'
  "$PYTHON_BIN" - <<'PY'
from pathlib import Path

path = Path("android/app/build.gradle")
text = path.read_text(encoding="utf-8")
if "coreLibraryDesugaringEnabled" not in text:
    text = text.replace(
        "compileOptions {\n",
        "compileOptions {\n        coreLibraryDesugaringEnabled true\n",
        1,
    )
if "coreLibraryDesugaring " not in text:
    text += "\n\ndependencies {\n    coreLibraryDesugaring 'com.android.tools:desugar_jdk_libs:2.1.5'\n}\n"
path.write_text(text, encoding="utf-8")
PY
fi

"$PYTHON_BIN" - <<'PY'
from pathlib import Path

manifest = Path("android/app/src/main/AndroidManifest.xml")
if manifest.exists():
    text = manifest.read_text(encoding="utf-8")
    permission = '<uses-permission android:name="android.permission.POST_NOTIFICATIONS" />'
    if permission not in text:
        insert_at = text.find(">")
        text = text[:insert_at + 1] + "\n    " + permission + text[insert_at + 1:]
    manifest.write_text(text, encoding="utf-8")
PY

if [[ -d android/app/src/main ]]; then
  while IFS= read -r -d '' file; do
    patch_file "$file" '^package .*$' "package $APP_ID"
  done < <(find android/app/src/main -type f \( -name '*.kt' -o -name '*.java' \) -print0)
fi

if [[ -f ios/Runner.xcodeproj/project.pbxproj ]]; then
  patch_file ios/Runner.xcodeproj/project.pbxproj 'PRODUCT_BUNDLE_IDENTIFIER = [^;]+;' "PRODUCT_BUNDLE_IDENTIFIER = $APP_ID;"
  patch_file ios/Runner.xcodeproj/project.pbxproj 'PRODUCT_NAME = [^;]+;' "PRODUCT_NAME = \"$APP_NAME\";"
fi

"$PYTHON_BIN" - <<'PY'
from pathlib import Path
import plistlib

plist_path = Path("ios/Runner/Info.plist")
if plist_path.exists():
    with plist_path.open("rb") as fh:
        data = plistlib.load(fh)
    data["CFBundleDisplayName"] = "Pocket Memory Pet"
    data["CFBundleName"] = "Pocket Memory Pet"
    with plist_path.open("wb") as fh:
        plistlib.dump(data, fh)
PY

"$PYTHON_BIN" tool/generate_brand_assets.py --native
