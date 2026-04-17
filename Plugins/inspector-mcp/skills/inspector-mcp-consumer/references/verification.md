# Verification

Use this after patching a consumer app.

## Minimum Checks

1. The consumer app still compiles for Simulator
2. The app still launches
3. `Inspector.setConfiguration(...)` happens before `Inspector.start()`
4. The configuration values are correct:
   - `enableMCPBridge = true`
   - `snapshotExpiration = 300`
   - `snapshotMaxCount = 8`

## Build Checks

Project:

```bash
xcodebuild build \
  -project /absolute/path/to/App.xcodeproj \
  -scheme AppScheme \
  -destination 'platform=iOS Simulator,name=iPhone 17 Pro,OS=26.4'
```

Workspace:

```bash
xcodebuild build \
  -workspace /absolute/path/to/App.xcworkspace \
  -scheme AppScheme \
  -destination 'platform=iOS Simulator,name=iPhone 17 Pro,OS=26.4'
```

## Launch Check

Once the app is wired, the next practical proof is to launch through the sibling `inspector-mcp` skill.

That confirms the app is not only compiled, but actually reachable by `InspectorMCPServer`.

## Common Failure Modes

### App compiles but MCP reports disabled

Likely causes:
- `enableMCPBridge` was not set to `true`
- configuration was set after `Inspector.start()`
- the wrong startup path was patched

### App compiles but MCP launch fails

Likely causes:
- wrong bundle ID
- wrong scheme
- wrong Inspector package path during server registration
- another app already occupies `127.0.0.1:49321`

### App has duplicate initialization

Symptoms:
- multiple `Inspector.start()` calls
- startup side effects repeated

Fix:
- patch the existing Inspector startup path instead of adding a new one
