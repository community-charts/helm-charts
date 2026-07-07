# Actualbudget Chart — CLAUDE.md

Chart-specific guidance for `charts/actualbudget`. The root `CLAUDE.md` covers general conventions; this file covers only what is non-obvious or specific to this chart.

## What This Chart Deploys

A single `Deployment` running the official `actualbudget/actual-server` image — a Node.js sync server that stores encrypted budget files and serves the Actual Budget web frontend. There are no subcharts, no init containers by default, and no HPA template.

The image is also published at `ghcr.io/actualbudget/actual` (same content, different registry).

## External Documentation

- Full config reference: https://actualbudget.org/docs/config/
- OAuth/OpenID config: https://actualbudget.org/docs/config/oauth-auth/
- Self-hosting guide: https://actualbudget.org/docs/self-hosting/docker/

## Data Directory Structure

The server writes to three paths that must survive pod restarts to retain data:

| Path | Env var | Contents |
|---|---|---|
| `/data` | `ACTUAL_DATA_DIR` | Root — the PVC mounts here |
| `/data/server-files` | `ACTUAL_SERVER_FILES` | `account.sqlite` (hashed password, session tokens, file registry) |
| `/data/user-files` | `ACTUAL_USER_FILES` | Encrypted budget files as binary blobs |

All three default to subdirectories under `/data`. Mounting the PVC at `/data` persists both subdirectories automatically — do not configure them to separate mount points unless you intend to split storage.

Persistence is **disabled by default** (`persistence.enabled: false`). Without it the pod uses ephemeral storage and all data is lost on restart. Always enable persistence for production.

**PVC creation condition:** `persistence.enabled: true` AND `persistence.existingClaim` is empty. When `existingClaim` is set the chart references that claim instead of creating one.

## Environment Variable Mapping

Every value in `values.yaml` maps to an env var that the `actual-server` process reads at startup:

| Env var | values.yaml field | Default |
|---|---|---|
| `ACTUAL_PORT` | `service.port` | `5006` |
| `ACTUAL_DATA_DIR` | `files.dataDirectory` | `/data` |
| `ACTUAL_SERVER_FILES` | `files.server` | `/data/server-files` |
| `ACTUAL_USER_FILES` | `files.user` | `/data/user-files` |
| `ACTUAL_UPLOAD_FILE_SYNC_SIZE_LIMIT_MB` | `upload.fileSizeSyncLimitMB` | `20` |
| `ACTUAL_UPLOAD_SYNC_ENCRYPTED_FILE_SYNC_SIZE_LIMIT_MB` | `upload.syncEncryptedFileSizeLimitMB` | `50` |
| `ACTUAL_UPLOAD_FILE_SIZE_LIMIT_MB` | `upload.fileSizeLimitMB` | `20` |
| `ACTUAL_LOGIN_METHOD` | `login.method` | `"password"` |
| `ACTUAL_ALLOWED_LOGIN_METHODS` | `login.allowedLoginMethods` (comma-joined) | `"password,header,openid"` |
| `NODE_TLS_REJECT_UNAUTHORIZED` | set to `"0"` when `login.skipSSLVerification: true` | unset |

**`extraEnvVars` key uppercasing:** Keys in the `extraEnvVars` map are automatically uppercased by the template (`{{ upper $key }}`). Use this for env vars that have no dedicated chart field, such as `ACTUAL_HOSTNAME`, `ACTUAL_TRUSTED_PROXIES`, and `ACTUAL_TRUSTED_AUTH_PROXIES`:

```yaml
extraEnvVars:
  actual_hostname: "::"
  actual_trusted_proxies: "10.0.0.0/8,172.16.0.0/12"
```

`ACTUAL_TRUSTED_PROXIES` and `ACTUAL_TRUSTED_AUTH_PROXIES` are not chart-level fields and must always be set via `extraEnvVars` when needed (e.g., behind an ingress controller).

## Authentication

Three mutually exclusive primary methods (`login.method`):

| Method | Description |
|---|---|
| `password` | Built-in server password (default) |
| `header` | Reads `x-actual-password` HTTP header from trusted proxies |
| `openid` | OpenID Connect / OAuth2 (requires app version ≥ 25.1.0) |

`login.allowedLoginMethods` is a list that controls which methods clients are permitted to use. It defaults to all three. The primary `login.method` should always be included in `allowedLoginMethods`.

### OpenID Connect Gate

The OpenID Secret (`*-openid-secret`) and the `envFrom` injection in the Deployment only render when **all four** conditions are true:

1. `ingress.enabled: true`
2. `login.method: "openid"`
3. `"openid"` is present in `login.allowedLoginMethods`
4. App version ≥ `25.1.0` — evaluated as `semverCompare ">=25.1.0"` against `image.tag` if set, otherwise `Chart.AppVersion`

If any condition fails, zero OIDC-related resources are created and the deployment has no `envFrom` block.

### OpenID Secret Contents

When the gate passes, `secret.yaml` creates `<release>-openid-secret` with these keys:

| Secret key | Source |
|---|---|
| `ACTUAL_MULTIUSER` | Always `"true"` |
| `ACTUAL_OPENID_ENFORCE` | `login.openid.enforce` (default `true`) |
| `ACTUAL_OPENID_PROVIDER_NAME` | `login.openid.providerName` (default `"OpenID Connect"`) |
| `ACTUAL_OPENID_CLIENT_ID` | `login.openid.clientId` — **only** when `existingSecret.name` is empty |
| `ACTUAL_OPENID_CLIENT_SECRET` | `login.openid.clientSecret` — **only** when `existingSecret.name` is empty |
| `ACTUAL_OPENID_SERVER_HOSTNAME` | Derived: `https://` + first ingress host when TLS is configured, `http://` otherwise |
| `ACTUAL_OPENID_DISCOVERY_URL` | `login.openid.discoveryUrl` (or legacy `dicovertUrl`) — when either is set |
| `ACTUAL_OPENID_AUTHORIZATION_ENDPOINT` | `login.openid.authorizationEndpoint` — when no discovery URL |
| `ACTUAL_OPENID_TOKEN_ENDPOINT` | `login.openid.tokenEndpoint` — when no discovery URL |
| `ACTUAL_OPENID_USERINFO_ENDPOINT` | `login.openid.userInfoEndpoint` — when no discovery URL |
| `ACTUAL_OPENID_AUTH_METHOD` | `login.openid.authMethod` (enum: `openid` / `oauth2`, default `openid`) |
| `ACTUAL_TOKEN_EXPIRATION` | `login.openid.tokenExpiration` (enum: `"never"` / `"openid-provider"` / numeric seconds, default `"never"`) |

### OpenID Discovery URL vs. Manual Endpoints

These two approaches are mutually exclusive in `secret.yaml`:

- **Discovery URL** (preferred): Set `login.openid.discoveryUrl`. The server fetches `/.well-known/openid-configuration` automatically.
- **Manual endpoints**: Leave `discoveryUrl` empty and set `authorizationEndpoint`, `tokenEndpoint`, and `userInfoEndpoint` individually.

### OpenID Existing Secret

When `login.openid.existingSecret.name` is set, `clientId` and `clientSecret` are **not** included in the chart-managed secret. Instead, the Deployment injects them as individual env vars via `secretKeyRef`:

```yaml
login:
  openid:
    existingSecret:
      name: my-oidc-secret
      clientIdKey: client-id       # → ACTUAL_OPENID_CLIENT_ID via secretKeyRef
      clientSecretKey: client-secret  # → ACTUAL_OPENID_CLIENT_SECRET via secretKeyRef
```

If `clientIdKey` or `clientSecretKey` is empty, that specific key is skipped from the `secretKeyRef` injection.

### Deprecated `dicovertUrl` Field

`login.openid.dicovertUrl` (note the typo) is a legacy alias for `discoveryUrl` kept for backward compatibility. `discoveryUrl` takes precedence when both are set. Do not use `dicovertUrl` in new configurations — it is marked `@deprecated` in `values.yaml`.

## Security Context

The container runs as UID/GID 1001 (non-root) with all Linux capabilities dropped and `readOnlyRootFilesystem: true`.

The only writable paths the server needs are:
- `/data` — provided by the PVC (or ephemeral storage when persistence is disabled)
- `/tmp` — provided by a built-in `emptyDir` volume always added by the Deployment template

The built-in `tmp` emptyDir is unconditional — it is always present regardless of `readOnlyRootFilesystem` setting. This was verified by running the actual-server image with `--read-only --tmpfs /tmp`, which starts cleanly (the server only writes to `/data` and `/tmp`).

The pod's `fsGroup: 1001` with `fsGroupChangePolicy: OnRootMismatch` ensures volume ownership is correct without re-chowning on every pod start.

## CI Install Testing — No `values-kind.yaml` or `.skip-kind-test`

This chart has neither a `values-kind.yaml` file nor a `.skip-kind-test` marker, and that is intentional.

The CI `ct install` step runs `helm install` against a kind cluster using default values when no `values-kind.yaml` is present. The actualbudget chart's defaults (`persistence.enabled: false`, `login.method: "password"`, single ClusterIP service) are sufficient for a smoke-test install with no extra overrides needed — the pod comes up healthy and the liveness probe passes without any additional configuration.

Do **not** add a `values-kind.yaml` unless the chart's default values stop working for CI (e.g., if persistence is ever enabled by default and requires a `storageClass`). Do **not** add `.skip-kind-test` unless the chart genuinely cannot be installed in a kind cluster at all.

## Values Documentation Conventions

Follow the same pattern as existing `# --` comments:

- Every field used in the README table needs its own `# --` comment on the line directly above the field.
- Do not use `|` in description text (it breaks the generated markdown table). Use `/` as the option separator.
- Nested object fields (e.g. `login.openid.existingSecret.*`) each need their own `# --` comment; a comment on the parent is not enough.
