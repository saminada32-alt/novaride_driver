#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"

if [[ ! -f config/prod.json ]]; then
  echo "❌ Missing config/prod.json"
  exit 1
fi

flutter pub get
flutter build ipa \
  --release \
  --dart-define-from-file=config/prod.json

echo ""
echo "✅ IPA ready: build/ios/ipa/*.ipa"
