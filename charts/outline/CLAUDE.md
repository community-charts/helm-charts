# Outline Chart — Architecture Notes

Official hosting documentation: https://docs.getoutline.com/s/hosting/

## Runtime Environment

- Image: `outlinewiki/outline`, runs as user `nodejs` (UID 1001), workdir `/opt/outline`
- Entry point: `node build/server/index.js`
- `readOnlyRootFilesystem: true` — only `/tmp` needs a writable emptyDir volume. File uploads go to `/var/lib/outline/data` only when `fileStorage.mode: local` with persistence enabled, so the `data` PVC mount is conditional on that path.

## Redis URL Duality

Outline accepts two Redis URL formats:

- **Plain:** `redis://host:port` — used when the built-in redis subchart has auth disabled (`redis.enabled=true` AND `redis.auth.enabled=false`). The chart sets `REDIS_URL` directly in the env block.
- **Advanced:** `ioredis://<base64-JSON>` — required when auth is enabled or when using an external Redis with credentials. `files/entrypoint.sh` constructs this from `REDIS_HOST`, `REDIS_PORT`, `REDIS_USERNAME`, `REDIS_PASSWORD` environment variables and exports `REDIS_URL` before starting the server.

The deployment command is conditionally overridden to `["/bin/bash", "/entrypoint.sh"]` for any case that is NOT (built-in redis + auth disabled). See `templates/deployment.yaml:60-62`.

## OIDC Auth Provider Mutual Exclusivity

Outline uses a single set of `OIDC_*` env vars regardless of which OIDC-compatible provider is chosen. The chart maps these providers through the same variables:

- **gitea** → `OIDC_*` with gitea-specific endpoints
- **gitlab** → `OIDC_*` with gitlab-specific endpoints
- **auth0** → `OIDC_*` with auth0-specific endpoints
- **keycloak** → `OIDC_*` with keycloak realm endpoints (also adds `OIDC_LOGOUT_URI`)
- **oidc** → `OIDC_*` with manually specified endpoints

These five are implemented as `if / else if / else if / else if / else if` in `templates/secret.yaml:135-192` — enabling more than one will silently use whichever comes first in the chain. Only **one** may be enabled per deployment.

The other auth providers (slack, google, azure, github, discord, saml) are independent and may be combined freely.

## Auto-Generated SECRET_KEY and UTILS_SECRET

`templates/secret.yaml:32-56` uses `helm.sh/hook: pre-install` combined with a `lookup` call to prevent regeneration on `helm upgrade`:

```yaml
{{- if not (lookup "v1" "Secret" .Release.Namespace $secretName) }}
```

The secret is only created if it does not already exist. This means:
- First install: random 64-char hex values are generated and stored.
- Subsequent upgrades: the existing secret is left untouched.
- Override: set `secretKey` / `utilsSecret` in values or point to an external secret via `secretKeyExternalSecret` / `utilsSecretExternalSecret`.

## URL Resolution

The `URL` env var is resolved in priority order (`templates/deployment.yaml:96-107`):

1. `values.url` if explicitly set
2. First ingress host (HTTP or HTTPS based on TLS presence) when `ingress.enabled=true`
3. Fallback: `http://<fullname>:<port>` using the internal service name

## File Storage

Two modes controlled by `fileStorage.mode`:

- **`local`** (default): Files stored in `FILE_STORAGE_LOCAL_ROOT_DIR` (default `/var/lib/outline/data`). A PVC is mounted at that path only when `fileStorage.local.persistence.enabled=true`. Without persistence, local storage is ephemeral — acceptable for dev but data is lost on pod restart.
- **`s3`**: Files stored in an S3-compatible bucket. Credentials sourced from the built-in MinIO subchart (when enabled) or from `fileStorage.s3.*` values. When MinIO is enabled with no users configured (`minio.users: []`), the chart auto-creates an `<fullname>-minio` secret and reads `rootUser`/`rootPassword` from it.

## Subcharts

Three optional subcharts: `redis` (Bitnami), `postgresql` (Bitnami), `minio` (MinIO). All three are stored as `.tgz` archives in `charts/`, which causes Trivy's Helm renderer to fail with 0 detections — this is expected behavior and does not indicate the chart is insecure.

## Secret Architecture

`templates/secret.yaml` creates up to 7 Kubernetes Secrets:

| Secret | Condition | Contents |
|---|---|---|
| `<fullname>-postgresql` | `!postgresql.enabled && !externalPostgresql.existingSecret` | `postgres-password` |
| `<fullname>-redis` | `!redis.enabled && !externalRedis.existingSecret` | `redis-username`, `redis-password` |
| `<fullname>-auto-generated-secret` | `secretKeyExternalSecret.name == "" && utilsSecretExternalSecret.name == ""` | `secret-key`, `utils-secret` |
| `<fullname>-s3-secret` | `fileStorage.mode == s3 && !fileStorage.s3.existingSecret` | S3 credentials |
| `<fullname>-auth-secret` | Always | Auth provider env vars (`SLACK_*`, `GOOGLE_*`, `OIDC_*`, etc.) |
| `<fullname>-smtp-secret` | Always | `SMTP_HOST`, `SMTP_PORT`, `SMTP_FROM_EMAIL`, `SMTP_REPLY_EMAIL`, etc. |
| `<fullname>-integrations-secret` | Always | Integration env vars (iframely, openAI, gotenberg, sentry, slack, dropbox, linear, notion) |

The auth, smtp, and integrations secrets are always created (even when empty) because the deployment unconditionally references them via `envFrom`.

## KubeLinter Annotation

The deployment carries a `read-secret-from-env-var` suppression at the object level:

```yaml
metadata:
  annotations:
    ignore-check.kube-linter.io/read-secret-from-env-var: "Outline reads secrets via environment variables; the application does not support file-based secret loading"
```

This is intentional — Outline does not support reading secrets from mounted files.

## Database Connection

PostgreSQL connection is constructed from individual `PG*` env vars then assembled into `DATABASE_URL`:

```
postgres://$(PGUSER):$(PGPASSWORD)@$(PGHOST):$(PGPORT)/$(PGDATABASE)
```

This allows Kubernetes to resolve `secretKeyRef` for `PGPASSWORD` before the composite value is expanded at runtime.
