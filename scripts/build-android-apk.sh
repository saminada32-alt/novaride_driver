#!/usr/bin/env bash
# Build release APK for family testing (avoids Kotlin daemon issues on macOS).
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"

CONFIG="${1:-config/prod.json}"

# Kotlin 2.x + Flutter Gradle plugin: in-process avoids "Could not connect to Kotlin compile daemon"
export GRADLE_OPTS="${GRADLE_OPTS:-} -Dkotlin.compiler.execution.strategy=in-process -Dkotlin.daemon.enabled=false"

MAPS_KEY=""
if command -v python3 >/dev/null 2>&1; then
  MAPS_KEY="$(python3 -c "import json; print(json.load(open('$CONFIG')).get('GOOGLE_MAPS_API_KEY',''))" 2>/dev/null || true)"
fi
if [[ -n "$MAPS_KEY" ]]; then
  PROPS="$ROOT/android/gradle.properties"
  if grep -q '^GOOGLE_MAPS_API_KEY=' "$PROPS" 2>/dev/null; then
    sed -i '' "s/^GOOGLE_MAPS_API_KEY=.*/GOOGLE_MAPS_API_KEY=$MAPS_KEY/" "$PROPS"
  else
    echo "GOOGLE_MAPS_API_KEY=$MAPS_KEY" >> "$PROPS"
  fi
  echo "▶ Google Maps API key injected into android/gradle.properties"
fi

echo "▶ Building APK ($CONFIG)..."
flutter pub get

if ! flutter build apk --release --dart-define-from-file="$CONFIG"; then
  echo "▶ First build failed — clearing stale Kotlin daemon and retrying..."
  rm -rf "${HOME}/.kotlin/daemon" 2>/dev/null || true
  sleep 3
  flutter build apk --release --dart-define-from-file="$CONFIG"
fi

APK="build/app/outputs/flutter-apk/app-release.apk"
if [[ -f "$APK" ]]; then
  cp "$APK" "${HOME}/Desktop/NovaRide-Driver.apk"
  echo ""
  echo "✅ Done:"
  echo "   $ROOT/$APK"
  echo "   ${HOME}/Desktop/NovaRide-Driver.apk"
else
  echo "❌ APK not found — check errors above."
  exit 1
fi
