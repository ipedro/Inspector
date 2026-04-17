# Inspection Patterns

Use this when the server is already registered and the task is live UI inspection.

## Tool Order

Use tools in this order:
1. `query`
2. `resolve`
3. `snapshot`

Reason:
- `query` finds candidates and returns handles
- `resolve` confirms which handle is the right one
- `snapshot` is more expensive and should be last

## Good Query Strategy

Start with the most specific predicate available.

Best first choices:
- `accessibilityIdentifierEquals`
- `classNameContains`
- `displayNameContains`
- `elementNameContains`
- `nodeKind`

Examples:

```json
{"accessibilityIdentifierEquals":"Content Stack View"}
```

```json
{"nodeKind":"view","classNameContains":"UIButton"}
```

```json
{"displayNameContains":"Login"}
```

Avoid broad empty queries unless you are mapping an unfamiliar screen.

## Resolve Before Snapshot

After `query`, inspect the returned node fields:
- `className`
- `displayName`
- `elementName`
- `accessibilityIdentifier`
- `frame`
- `depth`
- `childCount`

If there are multiple candidates, `resolve` the one that looks right before snapshotting.

## Snapshot Usage

Snapshot request:

```json
{"handle":"HANDLE","afterScreenUpdates":true}
```

Response shape (v2):

```json
{"handle":"HANDLE","mimeType":"image/png","pngPath":"/absolute/host/path/inspector-snapshots/<uuid>.png","size":{"width":402,"height":874},"deviceScale":3,"createdAt":"2026-04-17T13:03:29Z"}
```

Rules:
- `afterScreenUpdates` is required; use `true` unless you have a concrete reason not to.
- `pngPath` is an absolute host filesystem path. Read it directly — do not try to decode base64.
- Paths are ephemeral (live under the simulator sandbox `tmp/`). Consume immediately; do not cache across simulator resets or reinstalls.

## Stale Handle Recovery

If you get:
- `staleHandle`

Do this:
1. issue a fresh `query`
2. take the new handle
3. continue with `resolve` or `snapshot`

Do not:
- keep retrying the old handle
- assume the host will remap it for you

## Runtime Constraints

Current v1 model:
- read-only
- one booted simulator
- one app on the fixed localhost port
- attach guard validates bundle identity

If startup fails with an endpoint-occupied message, clear the conflicting app or simulator state first.
