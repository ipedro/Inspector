---
name: inspector-mcp
description: Use when an agent needs to inspect a live iOS app through the Inspector MCP bridge, register or troubleshoot InspectorMCPServer for a consumer Xcode project, or query, resolve, and snapshot the live UIKit hierarchy on Simulator. Especially useful when Inspector is a SwiftPM dependency of another app and the Inspector package path must be derived from Xcode DerivedData instead of assumed from the current repo.
---

# Inspector MCP

## Overview

Use this skill to set up and use the Inspector MCP bridge against a running iOS Simulator app. Prefer this when the task is live UI inspection, not static source reading.

## Workflow

### 1. Find the Inspector package path first

Do not assume Inspector lives in the current repo. In consumer apps it is often checked out under Xcode DerivedData.

Use the bundled helper first:

```bash
python3 "${CLAUDE_PLUGIN_ROOT}/skills/inspector-mcp/scripts/find_inspector_package.py" \
  --xcodeproj /absolute/path/to/App.xcodeproj \
  --scheme AppScheme
```

Or for workspaces:

```bash
python3 "${CLAUDE_PLUGIN_ROOT}/skills/inspector-mcp/scripts/find_inspector_package.py" \
  --workspace /absolute/path/to/App.xcworkspace \
  --scheme AppScheme
```

If that fails:
- Check whether the app uses a local package reference instead of a DerivedData checkout.
- If you already know the Inspector repo path, use that as `--package-path`.
- Read [consumer-app-setup.md](references/consumer-app-setup.md) for the fallback flow.

### 2. Derive the app launch inputs

You need:
- Xcode project or workspace path
- scheme
- bundle identifier

Bundle identifier pattern:

```bash
xcodebuild -project /absolute/path/to/App.xcodeproj -scheme AppScheme -showBuildSettings \
  | awk -F ' = ' '$1 ~ /^[[:space:]]*PRODUCT_BUNDLE_IDENTIFIER$/ { print $2; exit }'
```

Use `-workspace` instead of `-project` when appropriate.

### 3. Confirm the app enables the bridge

The app must opt in before `Inspector.start()`.

Minimum pattern:

```swift
var configuration = InspectorConfiguration.config(
    enableMCPBridge: true,
    snapshotExpiration: 300
)
configuration.snapshotMaxCount = 8
Inspector.setConfiguration(configuration)
Inspector.start()
```

If the app does not enable the bridge, MCP setup is blocked. For full consumer-side wiring, use the sibling `inspector-mcp-consumer` skill.

### 4. Register the MCP server in the client

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

If you are inside the Inspector repo itself, you can also point the client at:
- `<Inspector repo>/Examples/MCP/run-inspector-mcp.sh`
- or use the example config at `<Inspector repo>/Examples/MCP/codex-inspector-mcp.json` (replace the `cwd` placeholder).

### 5. Use the tools effectively

Tool order matters:
1. `query`
2. `resolve`
3. `snapshot`

Start narrow. Prefer:
- `accessibilityIdentifierEquals`
- `classNameContains`
- `displayNameContains`
- `elementNameContains`
- `nodeKind`

Good first query:

```json
{"accessibilityIdentifierEquals":"Content Stack View"}
```

Avoid broad snapshots first. First get a stable handle with `query`, confirm the node with `resolve`, then call `snapshot`.

### 6. Reading snapshot results (v2)

Snapshot request:

```json
{"handle":"HANDLE","afterScreenUpdates":true}
```

Response:

```json
{"handle":"HANDLE","mimeType":"image/png","pngPath":"/Users/you/Library/Developer/CoreSimulator/…/tmp/inspector-snapshots/<uuid>.png","size":{"width":402,"height":874},"deviceScale":3,"createdAt":"2026-04-17T13:03:29Z"}
```

After receiving the response, read the PNG with your file-reading tool (Claude Code: `Read pngPath`). Do not base64-decode — the bytes live on disk, not inline.

### 7. Handle stale handles correctly

There is no host-side auto-recovery.

If you get `staleHandle`:
- issue a fresh `query`
- take the new handle
- re-run `resolve` or `snapshot`

Do not retry the stale handle repeatedly.

### 8. Respect runtime constraints

Current v1 constraints:
- read-only only
- exactly one booted simulator
- fixed localhost endpoint `127.0.0.1:49321`
- single app on that port at a time
- launcher rejects attach if the process on the port does not match the requested bundle id

If startup says the endpoint is occupied by the wrong app:
- shut down the simulator or other app
- relaunch with the intended target

## Verification

If you are working in the Inspector repo, prefer:

```bash
xcodebuild test \
  -project <Inspector repo>/Example/Example.xcodeproj \
  -scheme Example \
  -destination 'platform=iOS Simulator,name=iPhone 17 Pro,OS=26.4' \
  -only-testing:InspectorTests/InspectorMCPTransportTests
```

For direct package verification of the iOS target:

```bash
SDK=$(xcrun --sdk iphonesimulator --show-sdk-path)
swift build --target Inspector --sdk "$SDK" --triple arm64-apple-ios26.4-simulator
```

For the host executable:

```bash
swift build --product InspectorMCPServer
```

## References

Read these only when needed:
- [consumer-app-setup.md](references/consumer-app-setup.md) for deriving the package path from DerivedData and wiring Codex/Claude
- [inspection-patterns.md](references/inspection-patterns.md) for effective query/resolve/snapshot usage and stale-handle recovery

## Breaking changes

- **v2 (2026-04-17)** — The `snapshot` tool response no longer carries `pngBase64`. It now returns `pngPath` (absolute host path) and `createdAt`; `scale` was renamed to `deviceScale`. Restart your MCP clients (Codex, Claude Code) after upgrading Inspector — in-flight sessions keep the old schema until reconnected.
