# Consumer App Setup

Use this when Inspector is a dependency of another Xcode app instead of the current repo.

## Goal

Derive:
- the Inspector package path
- the app bundle identifier
- the MCP registration command

## Package Path

Preferred path discovery:

```bash
python3 "${CLAUDE_PLUGIN_ROOT}/skills/inspector-mcp/scripts/find_inspector_package.py" \
  --xcodeproj /absolute/path/to/App.xcodeproj \
  --scheme AppScheme
```

or:

```bash
python3 "${CLAUDE_PLUGIN_ROOT}/skills/inspector-mcp/scripts/find_inspector_package.py" \
  --workspace /absolute/path/to/App.xcworkspace \
  --scheme AppScheme
```

What it does:
- asks `xcodebuild -showBuildSettings` for `BUILD_DIR`
- derives the DerivedData root from `BUILD_DIR`
- looks for `SourcePackages/checkouts/Inspector/Package.swift`

Common outcomes:
- remote SwiftPM dependency: found under DerivedData
- local package reference: not found under DerivedData, use the local package repo path instead

Manual fallback:

```bash
find ~/Library/Developer/Xcode/DerivedData -path '*/SourcePackages/checkouts/Inspector/Package.swift'
```

## Bundle Identifier

Project:

```bash
xcodebuild -project /absolute/path/to/App.xcodeproj -scheme AppScheme -showBuildSettings \
  | awk -F ' = ' '$1 ~ /^[[:space:]]*PRODUCT_BUNDLE_IDENTIFIER$/ { print $2; exit }'
```

Workspace:

```bash
xcodebuild -workspace /absolute/path/to/App.xcworkspace -scheme AppScheme -showBuildSettings \
  | awk -F ' = ' '$1 ~ /^[[:space:]]*PRODUCT_BUNDLE_IDENTIFIER$/ { print $2; exit }'
```

## MCP Registration

Codex:

```bash
codex mcp add inspector -- \
  swift --package-path /absolute/path/to/Inspector run InspectorMCPServer launch \
  --xcodeproj /absolute/path/to/App.xcodeproj \
  --scheme AppScheme \
  --bundle-id com.example.app
```

Claude Code:

```bash
claude mcp add inspector -- \
  swift --package-path /absolute/path/to/Inspector run InspectorMCPServer launch \
  --xcodeproj /absolute/path/to/App.xcodeproj \
  --scheme AppScheme \
  --bundle-id com.example.app
```

## App Wiring Requirement

The app must enable the bridge before `Inspector.start()`.

Required pattern:

```swift
var configuration = InspectorConfiguration.config(
    enableMCPBridge: true,
    snapshotExpiration: 300
)
configuration.snapshotMaxCount = 8
Inspector.setConfiguration(configuration)
Inspector.start()
```

Without that, the server can start but the app will report the bridge as disabled.
