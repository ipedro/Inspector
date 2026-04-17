#!/usr/bin/env bash
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
XCODEPROJ="${REPO_ROOT}/Example/Example.xcodeproj"
SCHEME="Example"
CODEX_HOME_DIR="${CODEX_HOME:-$HOME/.codex}"
INSPECTOR_HELPER="${CODEX_HOME_DIR}/skills/inspector-mcp/scripts/find_inspector_package.py"

# In this repo the Example app uses a local package reference, so the fallback
# is the repo root. If a DerivedData checkout exists, prefer that.
INSPECTOR_FALLBACK_PATH="${REPO_ROOT}"

find_inspector_path() {
  python3 "${INSPECTOR_HELPER}" \
    --xcodeproj "${XCODEPROJ}" \
    --scheme "${SCHEME}" \
    2>/dev/null || true
}

derive_bundle_id() {
  xcodebuild -project "${XCODEPROJ}" -scheme "${SCHEME}" -destination 'generic/platform=iOS Simulator' -showBuildSettings \
    | awk -F ' = ' '$1 ~ /^[[:space:]]*PRODUCT_BUNDLE_IDENTIFIER$/ { print $2; exit }'
}

main() {
  INSPECTOR_PATH="$(find_inspector_path)"
  if [[ -z "${INSPECTOR_PATH}" ]]; then
    INSPECTOR_PATH="${INSPECTOR_FALLBACK_PATH}"
  fi

  BUNDLE_ID="$(derive_bundle_id)"
  if [[ -z "${BUNDLE_ID}" ]]; then
    echo "Could not derive PRODUCT_BUNDLE_IDENTIFIER for scheme ${SCHEME}." >&2
    exit 1
  fi

  exec swift run --package-path "${INSPECTOR_PATH}" InspectorMCPServer launch \
    --xcodeproj "${XCODEPROJ}" \
    --scheme "${SCHEME}" \
    --bundle-id "${BUNDLE_ID}"
}

main "$@"
