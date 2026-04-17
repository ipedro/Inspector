# Inspector MCP Consumer Wrapper Template

Use [`run-inspector-mcp-template.sh`](./run-inspector-mcp-template.sh) as the cleanest way to register Inspector MCP for a consumer app.

## Why use the wrapper

It keeps client config short and pushes app-specific logic into the app repo:
- derive the Inspector package path from Xcode DerivedData
- fall back to a local Inspector package path when needed
- derive the bundle ID from build settings
- keep Codex and Claude registration to one short command

## Consumer app setup

1. Copy the template into the consumer app repo, for example:

```bash
cp ./Examples/MCP/run-inspector-mcp-template.sh /path/to/app/scripts/run-inspector-mcp.sh
chmod +x /path/to/app/scripts/run-inspector-mcp.sh
```

2. Edit:
- `XCODEPROJ`
- `SCHEME`
- optional `INSPECTOR_FALLBACK_PATH`

3. Make sure the app exposes the bridge:

```swift
var configuration = InspectorConfiguration.config(
    enableMCPBridge: true,
    snapshotExpiration: 300
)
configuration.snapshotMaxCount = 8
Inspector.setConfiguration(configuration)
Inspector.start()
```

## Register in Codex

```bash
codex mcp add my-app-inspector -- /absolute/path/to/app/scripts/run-inspector-mcp.sh
```

## Register in Claude Code

```bash
claude mcp add my-app-inspector -- /absolute/path/to/app/scripts/run-inspector-mcp.sh
```

## Dogfooding in this repo

This repo now includes a project-local `.mcp.json` that points to:

```text
./Examples/MCP/run-inspector-mcp.sh
```

So Claude can use the repo-local MCP config directly without absolute paths.

## Notes

- The current `InspectorMCPServer` CLI accepts `--xcodeproj`, not `--workspace`.
- If your app is workspace-driven, point the wrapper at the underlying `.xcodeproj` for now.
- The server is single-app/single-port in v1: one app at `127.0.0.1:49321` at a time.
