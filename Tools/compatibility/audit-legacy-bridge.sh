#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
cd "$ROOT"

strict=0
if [[ "${1:-}" == "--strict" ]]; then
  strict=1
elif [[ $# -gt 0 ]]; then
  echo "usage: $0 [--strict]" >&2
  exit 2
fi

python3 - "$strict" <<'PY'
from pathlib import Path
import subprocess
import sys

strict = bool(int(sys.argv[1]))
pattern = r'InspectorElementProperty|titleAccessoryProperty|sectionBindingExtraProperties|makeInspectorElementProperty\(|makeBinding\(id:'
proc = subprocess.run(['rg', '-n', pattern, 'Sources', 'Tests', 'Example', '-g*.swift'], text=True, capture_output=True)
lines = proc.stdout.splitlines() if proc.stdout else []
non_compat = [line for line in lines if not line.startswith('Sources/Inspector/Compatibility/') and not line.startswith('Tests/InspectorTests/InspectorLegacyCompatibilityTests.swift')]
compat = [line for line in lines if line not in non_compat]
print('Non-compatibility legacy references:')
print('\n'.join(non_compat) if non_compat else '')
print('\nCompatibility-only legacy references:')
print('\n'.join(compat) if compat else '')
print('\nSummary:')
print(f'  non_compatibility_refs={len(non_compat)}')
print(f'  compatibility_refs={len(compat)}')
if strict and non_compat:
    sys.exit(1)
PY