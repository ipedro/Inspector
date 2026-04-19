#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
cd "$ROOT"

python3 - <<'PY'
from pathlib import Path
import subprocess
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
PY
