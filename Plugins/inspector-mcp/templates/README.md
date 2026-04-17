# Inspector MCP — Templates

Drop-in templates for consumer apps that want to expose the Inspector MCP bridge to Codex or Claude Code.

## What's here

- [`run-inspector-mcp-template.sh`](./run-inspector-mcp-template.sh) — shell wrapper that locates the Inspector package, derives the bundle id, and launches `InspectorMCPServer` with the right arguments.
- [`codex-inspector-mcp.json`](./codex-inspector-mcp.json) — minimal Codex MCP config pointing straight at `swift run InspectorMCPServer` when you do not want a wrapper script.

## Why use the wrapper script

It keeps client config short and pushes app-specific logic into the app repo:
- derive the Inspector package path from Xcode DerivedData
- fall back to a local Inspector package path when needed
- derive the bundle id from build settings
- keep Codex and Claude registration to one short command

## Consumer app setup

1. Copy the template into the consumer app repo:

   ```bash
   cp run-inspector-mcp-template.sh /path/to/app/scripts/run-inspector-mcp.sh
   chmod +x /path/to/app/scripts/run-inspector-mcp.sh
   ```

2. Edit in the copied file:
   - `XCODEPROJ` (or uncomment `WORKSPACE`)
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

   See the sibling `inspector-mcp-consumer` skill for the full consumer-side patching workflow.

4. Register the wrapper:

   ```bash
   # Codex
   codex mcp add my-app-inspector -- /absolute/path/to/app/scripts/run-inspector-mcp.sh

   # Claude Code
   claude mcp add my-app-inspector -- /absolute/path/to/app/scripts/run-inspector-mcp.sh
   ```

## Helper discovery

The template resolves `find_inspector_package.py` in this order:
1. `${INSPECTOR_HELPER}` if set explicitly
2. `${CLAUDE_PLUGIN_ROOT}/skills/inspector-mcp/scripts/find_inspector_package.py` (Claude Code with the inspector-mcp plugin enabled)
3. `${CODEX_HOME:-$HOME/.codex}/skills/inspector-mcp/scripts/find_inspector_package.py` (Codex install)

If none are available the script exits with a clear error.

## Dogfooding in the Inspector repo

The Inspector repo itself uses `Tools/mcp/run-inspector-mcp.sh` (not this template) for its own dogfooding, registered via the repo-local `.mcp.json`. That wrapper is hardcoded to the bundled `Example` app; use this template for real consumer apps instead.

## Notes

- The current `InspectorMCPServer` CLI accepts `--xcodeproj`, not `--workspace`.
- If your app is workspace-driven, point the wrapper at the underlying `.xcodeproj` for now.
- The server is single-app/single-port in v1: one app at `127.0.0.1:49321` at a time.
