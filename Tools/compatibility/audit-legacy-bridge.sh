#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
cd "$ROOT"

strict=0
json=0
for arg in "$@"; do
  case "$arg" in
    --strict) strict=1 ;;
    --json) json=1 ;;
    *) echo "usage: $0 [--strict] [--json]" >&2; exit 2 ;;
  esac
done

python3 - "$strict" "$json" <<'PY'
import json
import subprocess
import sys
from collections import Counter

strict = bool(int(sys.argv[1]))
json_mode = bool(int(sys.argv[2]))
pattern = r'InspectorElementProperty|titleAccessoryProperty|sectionBindingExtraProperties|makeInspectorElementProperty\(|makeBinding\(id:'
proc = subprocess.run(['rg', '-n', pattern, 'Sources', 'Tests', 'Example', '-g*.swift'], text=True, capture_output=True)
lines = proc.stdout.splitlines() if proc.stdout else []
non_compat = [line for line in lines if not line.startswith('Sources/Inspector/Compatibility/') and not line.startswith('Tests/InspectorTests/InspectorLegacyCompatibilityTests.swift')]
compat = [line for line in lines if line not in non_compat]
compat_by_file = Counter(line.split(':', 1)[0] for line in compat)
non_compat_by_file = Counter(line.split(':', 1)[0] for line in non_compat)
summary = {
    'non_compatibility_refs': len(non_compat),
    'compatibility_refs': len(compat),
    'strict': strict,
    'non_compatibility_lines': non_compat,
    'compatibility_lines': compat,
    'non_compatibility_by_file': dict(non_compat_by_file),
    'compatibility_by_file': dict(compat_by_file),
}
if json_mode:
    print(json.dumps(summary, indent=2, sort_keys=True))
else:
    print('Non-compatibility legacy references:')
    print('\n'.join(non_compat) if non_compat else '')
    print('\nCompatibility-only legacy references:')
    print('\n'.join(compat) if compat else '')
    print('\nSummary:')
    print(f"  non_compatibility_refs={len(non_compat)}")
    print(f"  compatibility_refs={len(compat)}")
    if compat_by_file:
        print('  compatibility_by_file:')
        for path, count in sorted(compat_by_file.items(), key=lambda item: (-item[1], item[0])):
            print(f'    {count:>3} {path}')
if strict and non_compat:
    sys.exit(1)
PY
