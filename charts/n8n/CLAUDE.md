# n8n Chart — Claude Guidance

## External Documentation

Use `https://docs.n8n.io/llms.txt` as the entry point for official n8n documentation. That file lists all available pages — fetch individual pages from it for accurate, up-to-date details on configuration, environment variables, and features.

## Chart Architecture

### Operating Modes

The chart has two orthogonal mode axes that interact heavily:

**Task runner mode** (`taskRunners.mode`):
- `internal` — task runner runs inside the main n8n process (default)
- `external` — task runner runs as a sidecar container on the same pod. Exception: when `worker.mode: queue`, the main pod runs alone with no sidecar (the sidecar moves to worker pods instead).

**Worker mode** (`worker.mode`):
- `regular` — no separate worker pods; the main pod handles everything
- `queue` — separate worker pods are deployed (requires `db.type: postgresdb` + Redis). Workers each run their own task runner sidecar when `taskRunners.mode: external`.

### Pod Types

| Scenario | Template rendered |
|---|---|
| `main.count == 1` or `ReadWriteMany` or persistence off | `deployment.yaml` |
| `main.count > 1` + `ReadWriteOnce` + no `existingClaim` | `statefulset.yaml` (per-pod PVCs via `volumeClaimTemplates`) |
| `worker.mode: queue` + single worker or `ReadWriteMany` | `deployment-worker.yaml` |
| `worker.mode: queue` + multi-worker + `ReadWriteOnce` | `statefulset-worker.yaml` (per-pod PVCs) |

### Community Node Packages (`nodes.external.packages`)

Community packages are installed by an `npm-install` init container and need to be visible to the main n8n process at `/home/node/.n8n/nodes/node_modules/`.

**Volume routing logic** (helpers `n8n.main.coversCommunityNodes` / `n8n.worker.coversCommunityNodes` in `_helpers.tpl`):

- When `main.persistence.enabled: true` AND default `mountPath` (`/home/node/.n8n`) AND no `subPath`: the init container mounts the **main PVC** twice — at `/npmdata` (full root) and at `/nodesdata/nodes` with `subPath: nodes`. No separate `community-node-modules` volume is created. Packages persist automatically inside the main PVC.
- Otherwise: a dedicated `community-node-modules` volume is used (emptyDir by default, or a PVC when `nodes.external.persistence.enabled: true`).
- The same logic applies to worker pods using `worker.persistence`.

The `nodes.external.persistence` PVC is only created when the `community-node-modules` volume will actually be used (i.e., when neither the main nor the relevant worker persistence covers the path).

### npm Init Container

- Uses `--ignore-scripts` to prevent `postinstall` hooks (e.g. `only-allow pnpm`) from crashing on a fresh emptyDir.
- Sets `NPM_CONFIG_CACHE=/npmdata/.npm-cache` so the cache goes to a writable path, compatible with `readOnlyRootFilesystem: true`.
- The main container sets `NPM_CONFIG_CACHE=/home/node/.cache/npm` for the same reason.
- An `npm-home` emptyDir is mounted at `/home/node/.npm` in **both** the init container and the main n8n container. npm always initialises `~/.npm` for log files (`~/.npm/_logs/`) and temp operations regardless of `NPM_CONFIG_CACHE`. Without this mount, `npm pack` — called by n8n when installing community nodes through the UI or when `N8N_REINSTALL_MISSING_PACKAGES=true` — fails with `ENOENT: mkdir '/home/node/.npm'`. The init container's `npm install` happens to tolerate the missing directory, but `npm pack` does not.
- This volume must be present in `deployment.yaml`, `statefulset.yaml`, `deployment-worker.yaml`, and `statefulset-worker.yaml` — always in the unconditional `volumes:` block (never in `volumeClaimTemplates`).

### File Logging (`log.output: file`)

`log.file.location` must be an **absolute path inside a writable volume**. The default is `/home/node/.n8n/logs/n8n.log`, which lives inside the node-modules persistence volume (always writable, even as emptyDir). Do not use a relative path: npm resolves relative paths from the process CWD (`/home/node`), not the n8n data directory, so a relative path like `logs/n8n.log` would attempt `/home/node/logs/n8n.log` — outside any mounted volume and unwritable with `readOnlyRootFilesystem: true`.

### Python Packages (`nodes.python`)

Python packages are only relevant when `taskRunners.mode: external`. The `python-packages` volume uses `nodes.python.persistence` (same PVC/emptyDir toggle pattern as community packages).

## PVC Lifecycle Rules

Three non-obvious invariants govern how PVCs are created and must stay in sync across templates:

### Worker PVC condition must mirror `deployment-worker.yaml`

`pvc.yaml` creates the worker PVC only when `deployment-worker.yaml` renders AND persistence is needed. The condition **must** be kept in sync:

```
worker.persistence.enabled AND NOT existingClaim AND NOT forceToUseStatefulset
  AND ( (count==1 AND NOT autoscaling) OR accessMode==ReadWriteMany )
```

If `deployment-worker.yaml`'s render gate ever changes, update `pvc.yaml` to match. Divergence means pods reference a PVC that doesn't exist.

### `forceToUseStatefulset` guard in `pvc.yaml`

Any PVC created in `pvc.yaml` **must** include `(not .Values.X.forceToUseStatefulset)`. When `forceToUseStatefulset: true`, the StatefulSet's `volumeClaimTemplates` creates per-pod PVCs — if `pvc.yaml` also creates one (same logical name, different physical name), the shared PVC is orphaned and wastes storage.

### Community packages follow the python-packages pattern in StatefulSets

In `statefulset.yaml` and `statefulset-worker.yaml`, the `community-node-modules` volume uses the **same three-way split** as `python-packages`:

| Condition | Where the volume lives |
|---|---|
| `persistence.enabled: false` | `volumes:` as `emptyDir` |
| `persistence.existingClaim` set | `volumes:` as `persistentVolumeClaim` |
| `persistence.enabled: true` AND no `existingClaim` | `volumeClaimTemplates` (per-pod PVC) |

This means `volumes:` never holds a dynamically-provisioned PVC in StatefulSet context. Keep these two templates identical in structure for community packages and python packages.

## Environment Variable Injection Patterns

Three mechanisms exist for injecting env vars. Pick the right one for the test or template you are working on:

| Mechanism | When to use |
|---|---|
| `extraEnvVars` | Plain `string → string` pairs; rendered as `{ name: KEY, value: VALUE }` |
| `extraSecretNamesForEnvFrom` | Secret keys already match n8n env var names; entire secret is mounted via `envFrom: secretRef:` |
| `extraEnv` | Any `EnvVar` shape, including `valueFrom`; use when keys don't match env var names or you need selective injection |

All three fields exist on `main`, `worker`, `webhook`, and `webhook.mcp`. Each has a deprecated top-level fallback (same name) that resolves via `default .Values.<field> .Values.<block>.<field>` in the templates.

## Key Values Interactions

- `nodes.external.persistence` is only meaningful when `main.persistence` (and `worker.persistence` in queue mode) does **not** cover `/home/node/.n8n`. If main persistence is already enabled, community packages persist via the main PVC automatically.
- `main.forceToUseStatefulset: true` forces StatefulSet regardless of replica count.
- `worker.autoscaling.enabled: true` requires `ReadWriteMany` for any shared PVCs.

## Template Helpers to Know

| Helper | Purpose |
|---|---|
| `n8n.main.coversCommunityNodes` | True when main persistence covers `/home/node/.n8n/nodes` |
| `n8n.worker.coversCommunityNodes` | True when worker persistence covers `/home/node/.n8n/nodes` |
| `n8n-community.packages.fullname` | Community PVC name (respects `existingClaim`) |
| `n8n-python.packages.fullname` | Python PVC name (respects `existingClaim`) |
| `n8n.npmInstallScript` | Full npm install shell script for the init container |
| `n8n.taskRunners.uvInstallCommand` | uv pip install command for the task runner sidecar |
| `n8n.isCommunityPackage` | Returns `"true"` if a package (with or without `@version`/`@scope`) has a name starting with `n8n-nodes-`; used by `n8n.communityPackages` and `n8n.nonCommunityPackages` |
