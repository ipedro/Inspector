# Inspection Patterns

Use this when the server is already registered and the task is live UI inspection.

## Tool Order

Use tools in this order:
1. `query`
2. `resolve`
3. `list_actions` / `list_properties`
4. `snapshot`

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

Current model:
- one booted simulator
- one app on the fixed localhost port
- attach guard validates bundle identity
- v1: read-only (query, resolve, snapshot only)
- v2.1+: `inspect` adds write-side dispatch (presents Inspector UI)

If startup fails with an endpoint-occupied message, clear the conflicting app or simulator state first.

## Driving the Inspector UI

Call `inspect` to open the Inspector UI focused on a specific view. Typical recipe:

1. `query` → pick a handle
2. (optional) `resolve` to confirm the node is still the one you want
3. `inspect(handle)` → Inspector presents the element panel for that view

`inspect` semantics:
- Returns `{handle, presented:true}` as soon as the dispatch hits the main thread.
- Does NOT wait for the modal animation to finish; follow with `query`/`snapshot` if the next action depends on UI-settled state.
- Consecutive calls stack modals. Use Inspector's native back affordance to unwind.
- Stale handles → `staleHandle` error. Re-query before retrying.
- Non-UIView references → `unsupportedTarget`. Resolve to a concrete view first.

## Semantic tap (v2.3)

Use `tap` for the first write-side app interaction primitive:

1. `query` → find an exact handle for the control you want
2. (optional) `resolve` → confirm the handle is really the right control
3. `tap(handle)` → dispatch one supported control action

Request:

```json
{"handle":"HANDLE"}
```

Response:

```json
{"handle":"HANDLE","dispatched":true}
```

Important semantics:
- `tap` is **semantic activation of an exact-handle `UIControl`**
- it is **not** synthetic touch injection
- it does **not** hit-test coordinates
- it does **not** trigger gesture recognizers on plain `UIView`s
- it does **not** walk up to a parent button if you queried a child label/image

MVP success conditions:
- handle is live
- underlying object is exactly a visible, enabled `UIControl`
- the control is attached to a window
- the control exposes `.primaryActionTriggered` or `.touchUpInside`

Common failures:
- `staleHandle` → issue a fresh `query`
- `internalFailure` with a tappability message → the target is not a supported button-like control for MVP

Because mutation can immediately change the hierarchy, prefer a fresh `query` after successful taps before chaining the next action.

## Semantic actions (v2.5)

Use `list_actions` when you want to discover what semantic operations are currently available for a node.

Request:

```json
{"handle":"HANDLE"}
```

Response:

```json
{"handle":"HANDLE","expiresAt":"...","actions":[{"actionRef":"ACTION","title":"Inspect Attributes","kind":"inspect"}]}
```

Then invoke one with:

```json
{"actionRef":"ACTION"}
```

Current MVP action kinds:
- `inspect`
- `showHighlight`
- `hideHighlight`

Important semantics:
- action refs are ephemeral and snapshot-scoped
- after a successful `perform_action`, rediscover actions before the next operation
- actions reuse Inspector's existing semantic action model; this is not coordinate tapping or generic simulator orchestration

## Property mutation (v2.4)

Use this flow when you want to mutate supported Inspector-backed properties without presenting the Inspector UI:

1. `query` -> resolve the node you want
2. `list_properties(handle, panel)` -> inspect editable descriptors and collect a `propertyRef`
3. `set_property(propertyRef, typedValue)` -> apply exactly one typed mutation

Discovery request:

```json
{"handle":"HANDLE","panel":"attributes","includeReadOnly":false}
```

Mutation request examples:

```json
{"propertyRef":"PROP","boolValue":true}
```

```json
{"propertyRef":"PROP","numberValue":0.5}
```

```json
{"propertyRef":"PROP","stringValue":"Updated title"}
```

```json
{"propertyRef":"PROP","selectionIndex":2}
```

Important semantics:
- property discovery reuses the same Inspector property model the form panel uses
- `propertyRef` is ephemeral and snapshot-scoped
- after a successful `set_property`, rediscover properties before the next mutation
- only supported scalar/editor-like kinds are exposed in the MVP
- unsupported property kinds or wrong value-field combinations fail server-side
