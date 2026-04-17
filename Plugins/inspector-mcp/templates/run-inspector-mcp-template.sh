#!/usr/bin/env bash
set -euo pipefail

# Copy this script into a consumer app repo and edit the variables below.
# Then register the script itself as the MCP command in Codex or Claude.

APP_ROOT="$(cd "$(dirname "$0")/.." && pwd)"

# Choose exactly one:
XCODEPROJ="${APP_ROOT}/MyApp.xcodeproj"
# WORKSPACE="${APP_ROOT}/MyApp.xcworkspace"

SCHEME="MyApp"

# Optional fallback when Inspector is a local package reference instead of
# a DerivedData checkout. Leave empty to require DerivedData discovery.
INSPECTOR_FALLBACK_PATH=""

# Locate the Inspector package helper. When this script is invoked by Claude
# Code with the inspector-mcp plugin enabled, ${CLAUDE_PLUGIN_ROOT} points at
# the plugin directory. Fall back to a Codex-installed copy, or set
# INSPECTOR_HELPER explicitly before invoking this script.
if [[ -z "${INSPECTOR_HELPER:-}" ]]; then
  PLUGIN_HELPER="${CLAUDE_PLUGIN_ROOT:-}/skills/inspector-mcp/scripts/find_inspector_package.py"
  CODEX_HELPER="${CODEX_HOME:-$HOME/.codex}/skills/inspector-mcp/scripts/find_inspector_package.py"

  if [[ -n "${CLAUDE_PLUGIN_ROOT:-}" && -f "${PLUGIN_HELPER}" ]]; then
    INSPECTOR_HELPER="${PLUGIN_HELPER}"
  elif [[ -f "${CODEX_HELPER}" ]]; then
    INSPECTOR_HELPER="${CODEX_HELPER}"
  else
    echo "Could not locate find_inspector_package.py. Install the inspector-mcp plugin or set INSPECTOR_HELPER." >&2
    exit 5
  fi
fi

find_inspector_path() {
  if [[ -n "${XCODEPROJ:-}" ]]; then
    python3 "${INSPECTOR_HELPER}" \
      --xcodeproj "${XCODEPROJ}" \
      --scheme "${SCHEME}" \
      2>/dev/null || true
  else
    python3 "${INSPECTOR_HELPER}" \
      --workspace "${WORKSPACE}" \
      --scheme "${SCHEME}" \
      2>/dev/null || true
  fi
}

derive_bundle_id() {
  if [[ -n "${XCODEPROJ:-}" ]]; then
    xcodebuild -project "${XCODEPROJ}" -scheme "${SCHEME}" -destination 'generic/platform=iOS Simulator' -showBuildSettings
  else
    xcodebuild -workspace "${WORKSPACE}" -scheme "${SCHEME}" -destination 'generic/platform=iOS Simulator' -showBuildSettings
  fi | awk -F ' = ' '$1 ~ /^[[:space:]]*PRODUCT_BUNDLE_IDENTIFIER$/ { print $2; exit }'
}

main() {
  if [[ -n "${XCODEPROJ:-}" && -n "${WORKSPACE:-}" ]]; then
    echo "Set only one of XCODEPROJ or WORKSPACE" >&2
    exit 1
  fi

  if [[ -z "${XCODEPROJ:-}" && -z "${WORKSPACE:-}" ]]; then
    echo "Set one of XCODEPROJ or WORKSPACE" >&2
    exit 1
  fi

  INSPECTOR_PATH="$(find_inspector_path)"
  if [[ -z "${INSPECTOR_PATH}" ]]; then
    if [[ -n "${INSPECTOR_FALLBACK_PATH}" ]]; then
      INSPECTOR_PATH="${INSPECTOR_FALLBACK_PATH}"
    else
      echo "Could not find Inspector in DerivedData and no INSPECTOR_FALLBACK_PATH was set." >&2
      exit 2
    fi
  fi

  BUNDLE_ID="$(derive_bundle_id)"
  if [[ -z "${BUNDLE_ID}" ]]; then
    echo "Could not derive PRODUCT_BUNDLE_IDENTIFIER for scheme ${SCHEME}." >&2
    exit 3
  fi

  if [[ -n "${XCODEPROJ:-}" ]]; then
    exec swift run --package-path "${INSPECTOR_PATH}" InspectorMCPServer launch \
      --xcodeproj "${XCODEPROJ}" \
      --scheme "${SCHEME}" \
      --bundle-id "${BUNDLE_ID}"
  else
    echo "InspectorMCPServer currently expects --xcodeproj. If your app uses only a workspace," >&2
    echo "either point XCODEPROJ at the underlying project or extend the server CLI first." >&2
    exit 4
  fi
}

main "$@"
