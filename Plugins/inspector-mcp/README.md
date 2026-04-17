# Inspector MCP — Claude Code Plugin

Skills and helpers for driving the Inspector MCP bridge from Claude Code.

## Versions

- **v2.1 (2026-04-17)** — Adds `inspect` tool. Open the Inspector UI focused on a handle. Additive, no breaking changes.
- **v2 (2026-04-17)** — snapshot returns `pngPath` (disk file) instead of `pngBase64`. Requires restarting MCP clients after upgrading Inspector. See `docs/superpowers/specs/2026-04-17-snapshot-disk-path-design.md`.
- **v1** — initial release.

## What's in it

- **`inspector-mcp` skill** — register `InspectorMCPServer` for a consumer Xcode project, then use `query` / `resolve` / `snapshot` on the live UIKit hierarchy. Includes `scripts/find_inspector_package.py` to locate the Inspector Swift package under DerivedData.
- **`inspector-mcp-consumer` skill** — patch a consumer iOS app so it exposes the bridge: pick the right lifecycle entry point, set `enableMCPBridge = true` with `snapshotExpiration = 300` / `snapshotMaxCount = 8` before `Inspector.start()`.
- **`templates/`** — drop-in shell wrapper and Codex MCP config for consumer apps. See [`templates/README.md`](templates/README.md).

Both skills reference `${CLAUDE_PLUGIN_ROOT}` so paths stay portable across machines.

## Install (local dev)

From the Claude Code prompt:

```
/install-local-plugin /Users/pedro/Developer/Inspector/Plugins/inspector-mcp
```

That symlinks this directory into the Claude Code plugin cache so skill auto-discovery picks it up. Restart the Claude Code session after installing.

## Use

Claude Code activates each skill by description match. Typical triggers:

- "set up Inspector MCP for this app" → `inspector-mcp-consumer`
- "inspect the live hierarchy of the Simulator app" → `inspector-mcp`

## MCP server registration

This plugin ships skills plus templates, not the MCP server itself. Registration stays per-app since it needs an Xcode project, scheme, and bundle id. Options:

- In the Inspector repo (dogfooding): the project-local `.mcp.json` already points at `Tools/mcp/run-inspector-mcp.sh`.
- In another consumer app: follow step 4 of the `inspector-mcp` skill, or copy [`templates/run-inspector-mcp-template.sh`](templates/run-inspector-mcp-template.sh) into the consumer and register a per-app wrapper.

## Layout

```
Plugins/inspector-mcp/
├── plugin.json
├── README.md
├── skills/
│   ├── inspector-mcp/
│   │   ├── SKILL.md
│   │   ├── references/
│   │   │   ├── consumer-app-setup.md
│   │   │   └── inspection-patterns.md
│   │   └── scripts/
│   │       └── find_inspector_package.py
│   └── inspector-mcp-consumer/
│       ├── SKILL.md
│       └── references/
│           ├── entry-points.md
│           └── verification.md
└── templates/
    ├── README.md
    ├── codex-inspector-mcp.json
    └── run-inspector-mcp-template.sh
```
