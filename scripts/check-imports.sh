#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/.."
echo "=== Driver flutter analyze ==="
flutter analyze
echo "OK: driver analyze passed"
