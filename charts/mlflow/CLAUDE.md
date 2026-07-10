# MLflow Chart — CLAUDE.md

Chart-specific guidance for `charts/mlflow`. The root `CLAUDE.md` covers general conventions; this file covers only what is non-obvious or specific to this chart.

## What This Chart Deploys

A single MLflow tracking-server `Deployment` (image: `burakince/mlflow`, **not** the official `mlflow/mlflow` image) with optional:

- **Bitnami PostgreSQL** subchart (`postgresql.enabled`) or **Bitnami MySQL** subchart (`mysql.enabled`) for the backend store
- **External DB** via `backendStore.postgres/mysql/mssql.*` for databases managed outside the chart
- **Artifact storage** pointing at S3, Azure Blob Storage, or GCS
- **Basic auth** (`auth.enabled`) or **LDAP auth** (`ldapAuth.enabled`) or **OIDC auth** (`oidcAuth.enabled`) — all mutually exclusive, never more than one
- **OAuth2-proxy sidecar** (`oauth2Proxy.enabled`) — mutually exclusive with `oidcAuth`; cannot be combined with each other
- **Garbage collection CronJob** (`garbageCollection.enabled`) for periodic `mlflow gc`
- **Prometheus ServiceMonitor** when the `monitoring.coreos.com/v1` CRD is available
- **HPA** under strict conditions (see below)

## External Documentation

- MLflow tracking server configuration reference: https://mlflow.org/docs/latest/self-hosting/architecture/tracking-server.md
- MLflow basic auth configuration: https://mlflow.org/docs/latest/self-hosting/security/basic-http-auth.md
- MLflow custom auth plugins: https://mlflow.org/docs/latest/self-hosting/security/custom.md
- MLflow SSO approaches: https://mlflow.org/docs/latest/self-hosting/security/sso.md
- MLflow RBAC model: https://mlflow.org/docs/latest/self-hosting/security/role-based-access-control.md
- Full MLflow docs index: https://mlflow.org/docs/latest/llms.txt
- Custom image source and README: https://github.com/burakince/mlflow

## Image Details (`burakince/mlflow`)

The chart exclusively uses `burakince/mlflow` (not the upstream `mlflow/mlflow`). Key differences:

- Runs as non-root `mlflow` user (UID/GID 1001); Python venv at `/opt/venv`
- Two variants: Debian (default/latest) and Alpine (`-alpine` tag suffix)
- Bundled extras beyond vanilla MLflow: `psycopg2-binary`, `pymysql`, `pymssql`, `boto3`, `azure-storage-blob`, `google-cloud-storage`, `ldap3`, `mlflow-oidc-auth[cache]`, `prometheus-flask-exporter`, `pysftp`
- Exposes `/health` (returns `200 OK` once migrations finish and server is ready) and `/metrics` (Prometheus, enabled via `--expose-prometheus=/mlflow/metrics`)
- LDAP auth module lives at `mlflowstack.auth.ldap` — referenced as the `authorization_function` in the auth INI for LDAP mode

## Non-Obvious Architecture Decisions

### Auth Mechanism Overview

Four mutually exclusive auth mechanisms, all activated via `--app-name` on the `mlflow server` command:

| Mechanism | `--app-name` | How it works |
|---|---|---|
| `auth.enabled` | `basic-auth` (configurable) | MLflow built-in HTTP basic auth; stores users/permissions in SQLite or PostgreSQL |
| `ldapAuth.enabled` | `basic-auth` (hardcoded) | Same built-in plugin but delegates credential check to LDAP via `mlflowstack.auth.ldap` |
| `oidcAuth.enabled` | `oidc-auth` | `mlflow-oidc-auth` plugin (bundled in image); handles full OIDC flow inside MLflow |
| `oauth2Proxy.enabled` | *(none — MLflow runs unauthenticated)* | Sidecar proxy intercepts all traffic; MLflow itself is open on loopback |

`oauth2Proxy` can coexist with `auth` or `ldapAuth` in theory (proxy in front, MLflow auth behind) but is explicitly forbidden with `oidcAuth`.

Mutual exclusivity enforcement:

| Pair | Enforcement layer |
|---|---|
| `oidcAuth + oauth2Proxy`, `oidcAuth + auth`, `oidcAuth + ldapAuth` | Template-level `fail` guard in `deployment.yaml` |
| `auth + ldapAuth` | Two layers: `allOf[0] not` constraint in `values.schema.json` (catches it at schema validation time) **and** a `fail` guard in `deployment.yaml` (defense-in-depth for `--disable-openapi-validation`) |

Because the schema rejects `auth + ldapAuth` before the template renders, `failedTemplate` unit tests cannot exercise the template-level guard for that pair — `helm-unittest` validates values against the schema first.

### PostgreSQL Backend-Store URI Is Built Differently Than MySQL/MSSQL

PostgreSQL passes credentials via environment variables (`PGUSER`/`PGPASSWORD`) injected by Kubernetes — the connection URI in the server args ends with `://` (no embedded credentials):

```
--backend-store-uri=postgresql+psycopg2://
```

MySQL and MSSQL embed runtime env var references directly in the URI string:

```
--backend-store-uri=mysql+pymysql://$(MYSQL_USERNAME):$(MYSQL_PWD)@$(MYSQL_HOST):$(MYSQL_TCP_PORT)/$(MYSQL_DATABASE)
```

This means MySQL/MSSQL env vars must exist as container env entries so Kubernetes can expand `$(VAR)` — they come from `configmap.yaml` (`-env-configmap`). The same `$(VAR)` technique is used for `OIDC_USERS_DB_URI` when `oidcAuth.database.postgres.enabled`.

### MySQL Binary Logging Requirement

MLflow 3.12+ creates triggers during `mlflow db upgrade`. MySQL 8+/9+ with binary logging enabled (the default) requires `log_bin_trust_function_creators=ON` unless the MLflow user is `root`. When deploying against such a MySQL instance, the DB must be started with:

```
--log-bin-trust-function-creators=1
```

### Flask Server Secret Key (Pre-install Hook)

`flask_secret.yaml` creates a Secret with a random 32-char hex value using `mlflow.generateRandomHex` at install time via a `pre-install,pre-upgrade` hook with `before-hook-creation` delete policy. This persists the key across upgrades without storing it in `values.yaml`. Never delete this secret manually — it invalidates all existing sessions.

When `oidcAuth.enabled`, the chart injects this same secret as `SECRET_KEY` (the env var the OIDC plugin uses for Flask sessions). The upstream docs state explicitly that `SECRET_KEY` must remain stable across restarts and replicas; the shared hook secret ensures this automatically.

### Init Container Ordering

When a database is configured the init containers always run in this fixed order:

1. **dbchecker** — polls DB port using Fibonacci-backoff netcat (unbounded retries); runs only when `backendStore.databaseConnectionCheck: true`
2. **mlflow-db-migration** — runs `python /opt/mlflow/migrations.py` (wraps `mlflow db upgrade`); runs only when `backendStore.databaseMigration: true`
3. **ini-file-initializer** — writes `auth_result.ini` into an `emptyDir` shared with the main container; runs when `auth.enabled` or `ldapAuth.enabled`. Uses `sed` when `auth.enabled` (substitutes `$(ADMIN_USERNAME_PLACEHOLDER)` etc. from secrets); uses `cp` when only `ldapAuth.enabled` (no placeholders — the INI uses literal `fakeuser`/`fakepassword`, secrets are not needed)
4. **user-provided** `initContainers` — appended last

### Auth INI File Generation (basic auth and LDAP only)

The auth config is not rendered directly into a ConfigMap. Instead `auth_ini_configmap.yaml` contains a template, and the `ini-file-initializer` init container writes `auth_result.ini` into an `emptyDir` at runtime. The result is mounted read-only at `MLFLOW_AUTH_CONFIG_PATH`.

Two paths depending on which flag is active:

- `auth.enabled` → the ConfigMap contains literal placeholders (`$(ADMIN_USERNAME_PLACEHOLDER)` etc.); `sed` substitutes real values from secrets (admin credentials, DB password). App-name configurable via `auth.appName`; mounts at `auth.configPath/auth.configFile`.
- `ldapAuth.enabled` (without `auth.enabled`) → the ConfigMap uses literal `fakeuser`/`fakepassword` (LDAP itself handles credential validation — no placeholders needed); `cp` copies the file as-is, no secret env vars injected. App-name hardcoded to `basic-auth`; hardcoded path `/etc/mlflow/auth/ldap_basic_auth.ini`; authorization function `mlflowstack.auth.ldap:authenticate_request_basic_auth`.

`oidcAuth` does **not** use an INI file — it is configured entirely via environment variables injected directly in `deployment.yaml`.

### OIDC Auth (`oidcAuth`) Environment Variable Mapping

The `mlflow-oidc-auth` plugin reads all configuration from env vars (no INI file). Key mappings from values to env vars:

| `values.yaml` field | Env var | Notes |
|---|---|---|
| `oidcAuth.discoveryUrl` | `OIDC_DISCOVERY_URL` | OIDC provider `/.well-known/openid-configuration` URL |
| `oidcAuth.clientId` | `OIDC_CLIENT_ID` | Plain value |
| `oidcAuth.clientSecret` / `existingSecret` | `OIDC_CLIENT_SECRET` | From K8s secret via `secretKeyRef` |
| `oidcAuth.redirectUri` | `OIDC_REDIRECT_URI` | Optional; plugin auto-detects from request headers |
| `oidcAuth.scope` | `OIDC_SCOPE` | Comma-separated |
| `oidcAuth.groupsAttribute` | `OIDC_GROUPS_ATTRIBUTE` | JWT claim containing group memberships |
| `oidcAuth.groupName` | `OIDC_GROUP_NAME` | Joined with `,` |
| `oidcAuth.adminGroupName` | `OIDC_ADMIN_GROUP_NAME` | Joined with `,` |
| `oidcAuth.defaultPermission` | `DEFAULT_MLFLOW_PERMISSION` | `NO_PERMISSIONS` / `READ` / `EDIT` / `MANAGE` |
| `oidcAuth.sessionCookieSecure` | `SESSION_COOKIE_SECURE` | Set `false` only in local/dev |
| `oidcAuth.cache.redisUrl` | `CACHE_REDIS_URL` | Only when `cache.enabled: true` |
| `oidcAuth.database.postgres.*` | `OIDC_USERS_DB_URI` | Constructed via `$(OIDC_DB_USER):$(OIDC_DB_PASSWORD)` interpolation |
| `oidcAuth.trustedProxies` | `TRUSTED_PROXIES` | Joined with `,`; required behind an ingress for redirect URI detection |
| *(flask hook secret)* | `SECRET_KEY` | Injected from `<release>-flask-server-secret-key` secret; must be stable |

The OIDC user/permission DB (`OIDC_USERS_DB_URI`) is **separate** from the MLflow tracking DB — it stores OIDC-mapped users and their permissions, not experiment runs.

### oauth2-proxy Sidecar (`oauth2Proxy`)

When `oauth2Proxy.enabled`, a second container runs in the same pod:

```
Ingress → Service:4180 → oauth2-proxy sidecar → http://127.0.0.1:<containerPort>
```

The `mlflow.servicePort` helper in `_helpers.tpl` encodes this routing: it returns `oauth2Proxy.listenPort` when the sidecar is enabled, `service.port` otherwise. Both `ingress.yaml` and `service.yaml` use this helper so port routing is automatic.

Secret reference uses `mlflow.oauth2ProxySecretName` helper (`default` + `existingSecret.name`), the same pattern as `mlflow.oidcAuthSecretName`.

### MLflow Permission Model

Four permission levels apply to experiments, registered models, and other resources:

| Level | Capabilities |
|---|---|
| `NO_PERMISSIONS` | No access |
| `READ` | View only |
| `EDIT` | View and modify |
| `MANAGE` | Full control including permission delegation |

The default (when no per-resource permission is set) is controlled by:
- `auth.defaultPermission` for basic auth
- `oidcAuth.defaultPermission` (`DEFAULT_MLFLOW_PERMISSION` env var) for OIDC auth

### Security Middleware Auto-injection

MLflow 3.x uvicorn server includes security middleware for DNS rebinding, CORS, and clickjacking protection. The chart auto-injects two env vars into `configmap.yaml` via helper functions in `_helpers.tpl`:

| Env var | Helper | Source |
|---|---|---|
| `MLFLOW_SERVER_ALLOWED_HOSTS` | `mlflow.serverAllowedHosts` | Ingress hostnames + `serverAllowedHosts` list |
| `MLFLOW_SERVER_CORS_ALLOWED_ORIGINS` | `mlflow.corsAllowedOrigins` | Ingress origins (with scheme) + `corsAllowedOrigins` list |

Both helpers delegate the merge/dedup/wildcard step to a shared `mlflow.normalizeList` helper which:
1. Calls `uniq` to remove duplicates from the merged list
2. Returns `"*"` if the list contains a wildcard entry (collapsing everything else)
3. Returns `join "," $list` otherwise
4. Returns an empty string when the list is empty (suppressed by `with` in configmap)

Scheme detection for CORS: `https` when `ingress.tls` is non-empty, `http` otherwise.

**Important**: `serverAllowedHosts` and `corsAllowedOrigins` are **append-only** — their entries are merged with the ingress-derived entries, never replacing them. Users who need a full override should use `extraEnvVars.MLFLOW_SERVER_ALLOWED_HOSTS` / `extraEnvVars.MLFLOW_SERVER_CORS_ALLOWED_ORIGINS` (Kubernetes `env:` wins over `envFrom:` at runtime).

### MLflow Assistant API Restriction

The `/ajax-api/3.0/mlflow/assistant/config` endpoint is hardcoded localhost-only in `mlflow/server/assistant/api.py` via a `_require_localhost` dependency that checks `ip.is_loopback`. There is no env var to override this in current released MLflow. Through a Kubernetes ingress, every request arrives from the ingress controller's pod IP (never `127.0.0.1`), so this endpoint always returns 403. This is a known upstream limitation tracked in mlflow/mlflow#23883 — do not attempt to work around it at the chart level.

### HPA Creation Conditions

The HPA (`hpa.yaml`) is guarded by three simultaneous requirements:

1. `autoscaling.enabled: true`
2. A persistent backend store is configured — any of: `backendStore.postgres.enabled`, `backendStore.mysql.enabled`, `backendStore.mssql.enabled`, `postgresql.enabled` (Bitnami subchart), `mysql.enabled` (Bitnami subchart)
3. A persistent artifact store is configured (S3/Azure/GCS — not the default local `./mlruns`)
4. Additionally: if `auth.enabled`, it must use `auth.postgres` (not the default SQLite auth backend)

Scaling an MLflow server with in-memory SQLite or local artifact storage is unsafe because replicas would not share state. The template enforces this constraint rather than documenting it.

When using `oidcAuth` with HPA, ensure:
- `oidcAuth.cache.enabled: true` with a Redis URL — without this, each replica holds an independent in-memory token cache and sessions break on failover
- `oidcAuth.database.postgres.enabled: true` — SQLite for the OIDC user/permission DB is a single file that cannot be shared across replicas

### extraArgs vs extraFlags

- `extraArgs` is a `map[string]string` — keys are camelCase, values are strings. The template converts keys to kebab-case automatically: `{gunicornOpts: "--workers=4"}` → `--gunicorn-opts=--workers=4`
- `extraFlags` is a `string[]` of flag names (no `--` prefix, no value). Also kebab-case converted: `["serveArtifacts"]` → `--serve-artifacts`

### Server Log-Level Merging (uvicorn / gunicorn)

MLflow 3.x uses **uvicorn** by default (`--uvicorn-opts`). Gunicorn (`--gunicorn-opts`) is an opt-in legacy mode; waitress (`--waitress-opts`) is for Windows.

When `log.enabled: true`, the template injects `--log-level` via one of five paths:

- Neither `uvicornOpts` nor `gunicornOpts` in `extraArgs` → injects `--uvicorn-opts='--log-level=<level>'` (default)
- `uvicornOpts` present and already contains `--log-level` → replaces the existing value via `regexReplaceAll`
- `uvicornOpts` present without `--log-level` → prepends `--log-level=<level>` to the existing string
- `gunicornOpts` present and already contains `--log-level` → replaces the existing value via `regexReplaceAll`
- `gunicornOpts` present without `--log-level` → prepends `--log-level=<level>` to the existing string

Security middleware flags (`--allowed-hosts`, `--cors-allowed-origins`, `--disable-security-middleware`) are uvicorn-only and now naturally co-exist with the default uvicorn-opts injection.

Test cases for all paths exist in `unittests/deployment_test.yaml`.

### Proxied Artifact Storage Mode

When `artifactRoot.proxiedArtifactStorage: true`, the CLI flag switches from `--default-artifact-root` to `--artifacts-destination` and `--serve-artifacts` is also appended. The destination value comes from `artifactRoot.defaultArtifactsDestination`, not `artifactRoot.defaultArtifactRoot`. Cloud storage flags override the destination URI, but `--serve-artifacts` is still injected.

### Garbage Collection CronJob

`garbageCollection.enabled` creates `templates/gc-cronjob.yaml`, which periodically runs `mlflow gc` in the same image as the tracking server. It passes `--backend-store-uri` directly. When `artifactRoot.proxiedArtifactStorage` is enabled, it also injects a default `MLFLOW_TRACKING_URI` pointing at the in-cluster MLflow Service unless the user provides `extraEnvVars.MLFLOW_TRACKING_URI`.

The CronJob reuses the same backend-store URI helper, DB credential env helper, artifact-store env helper, and `envFrom` sources as the main container. This is important for S3 existing secrets, bundled MinIO credentials, Azure/GCS credentials from `-env-secret`, and user-provided `extraEnvVars` / `extraSecretNamesForEnvFrom`.

The template fails when enabled with the default in-memory SQLite backend (`backendStore.defaultSqlitePath: ":memory:"`) because each pod has an ephemeral database and garbage collection would silently do nothing useful. It does not hard-fail local artifact storage: users can mount persistent local storage with `garbageCollection.extraVolumes` / `extraVolumeMounts`, but remote artifact stores (S3/Azure/GCS) are the normal production path.

### LDAP CA Certificate

LDAP with a self-signed CA uses one of two paths (mutually exclusive):

- `ldapAuth.encodedTrustedCACertificate` — base64-encoded PEM value stored directly in `trusted_ca_cert_secret.yaml`
- `ldapAuth.externalSecretForTrustedCACertificate` — name of a pre-existing secret with key `ca.crt`

Both mount to `/certs/ca.crt` and set `LDAP_CA=/certs/ca.crt` in the main container.

### Helper Function Reference

`_helpers.tpl` provides these named helpers beyond the standard `name`/`fullname`/`labels` set:

| Helper | Purpose |
|---|---|
| `mlflow.containerImage` | Builds `repo:tag` or `repo:tag@digest` depending on `image.digest` |
| `mlflow.servicePort` | Returns `oauth2Proxy.listenPort` when sidecar is enabled, else `service.port` |
| `mlflow.oauth2ProxySecretName` | `<release>-oauth2-proxy` or `oauth2Proxy.existingSecret.name` |
| `mlflow.oidcAuthSecretName` | `<release>-oidc-auth-secret` or `oidcAuth.existingSecret.name` |
| `mlflow.oidcAuthDbSecretName` | `<release>-oidc-auth-db-secret` or `oidcAuth.database.postgres.existingSecret.name` |
| `mlflow.backendStoreUriArg` | Builds the `--backend-store-uri=...` argument shared by server and GC containers |
| `mlflow.backendStoreCredentialEnv` | Renders direct DB credential env entries for subcharts / existing database secrets |
| `mlflow.artifactStoreEnv` | Renders artifact-store credential env entries plus `extraEnvVars` |
| `mlflow.runtimeEnvFrom` | Renders common envFrom sources for configmap, env secret, Flask secret, and extra secrets |
| `mlflow.normalizeList` | Deduplicates a list and joins with `,`; collapses to `*` when wildcard present |
| `mlflow.serverAllowedHosts` | Builds `MLFLOW_SERVER_ALLOWED_HOSTS` value from ingress + `serverAllowedHosts` |
| `mlflow.corsAllowedOrigins` | Builds `MLFLOW_SERVER_CORS_ALLOWED_ORIGINS` value from ingress + `corsAllowedOrigins` |

### extraDeploy — Arbitrary Extra Resources

`extraDeploy` is a list of arbitrary Kubernetes objects rendered by `templates/extra-list.yaml` via `tpl (toYaml .) $`. Each item is emitted as a separate YAML document (with a `---` separator). Because `tpl` is used, Helm expressions are fully evaluated:

```yaml
extraDeploy:
  - apiVersion: v1
    kind: ConfigMap
    metadata:
      name: '{{ include "mlflow.fullname" . }}-extra'
    data:
      release: '{{ .Release.Name }}'
```

Single quotes around template expressions in YAML string values are required — without them the `{{` is parsed as part of the YAML scalar and may produce unexpected output.

The feature is intentionally minimal — no label injection, no name prefixing. Users have full control over every field.

### ConfigMap Checksum Annotation

The pod template carries `checksum/config: {{ include ".../configmap.yaml" . | sha256sum }}` so that any change to the `configmap.yaml` values (env vars) triggers a rolling restart automatically.

## Values Documentation Conventions

These rules go beyond the root `CLAUDE.md` and are specific to patterns already established in this chart:

**Every nested sub-field that should appear in the README table needs its own `# --` comment.** helm-docs only documents fields that carry a `# --` comment — a comment on the parent object alone is not enough. This bites nested `existingSecret.*`, `image.*`, and `provider.*` blocks in particular. Pattern from this chart:

```yaml
# -- Reference a pre-existing secret
existingSecret:
  # -- Name of the secret; leave empty to let the chart create one
  name: ""
  # -- Key that holds the client secret value
  clientSecretKey: "OIDC_CLIENT_SECRET"
```

**Do not use `|` in description text** — it breaks the generated markdown table (pipe is the column separator). Use `/` as the option delimiter:

```yaml
# -- Permission level: NO_PERMISSIONS / READ / EDIT / MANAGE  ← correct
# -- Permission level: NO_PERMISSIONS | READ | EDIT | MANAGE  ← breaks table
```

**Only one `# --` comment per field.** helm-docs only picks up the last `# --` block above a field. A descriptive `# --` comment followed by another `# --` (the real description) causes the first to be silently dropped — use a plain `#` line for inline notes:

```yaml
# This is just a code note (no --)
# -- This is the actual field description picked up by helm-docs
listenPort: 4180
```

**Two-line `# --` comments work, but keep them on one line when possible.** helm-docs joins continuation lines but the result can be hard to read in the source and easy to accidentally split:

```yaml
# -- Require HTTPS for cookies; set false only in dev (env: SESSION_COOKIE_SECURE)  ← prefer
# -- Require HTTPS for cookies; set false only in dev
# (env: SESSION_COOKIE_SECURE)  ← works but avoid
```

## Subcharts

| Subchart | Version | Condition | Notes |
|---|---|---|---|
| `postgresql` (Bitnami) | 18.7.5 | `postgresql.enabled` | Uses `bitnamilegacy/postgresql` image; sets `postgresql.auth.*` for DB/user/password creation |
| `mysql` (Bitnami) | 14.0.3 | `mysql.enabled` | Uses `bitnamilegacy/mysql` image; sets `mysql.auth.*` for DB/user/password creation |

Only one of `postgresql.enabled` / `mysql.enabled` should be true at a time. When both `backendStore.postgres.enabled` and `postgresql.enabled` are set, the subchart takes precedence for the connection string (the chart checks subchart flags first in the conditional chain).

## Unit Test Conventions

Test files are in `unittests/`. Each focuses on one configuration axis:

| File | What it covers |
|---|---|
| `deployment_test.yaml` | All deployment rendering: backends (postgres/mysql/mssql/s3/azure/gcs), auth, ldapAuth, oauth2Proxy, oidcAuth, extraEnvVars, HPA conditions, log level, init containers |
| `auth_admin_secret_test.yaml` | Basic auth admin secret (chart-managed vs existing secret) |
| `auth_ini_configmap_test.yaml` | INI configmap rendering for basic auth and ldapAuth |
| `auth_postgres_secret_test.yaml` | Auth Postgres credential secret |
| `configmap_test.yaml` | Env-configmap and migrations configmap; includes security middleware env var injection (`MLFLOW_SERVER_ALLOWED_HOSTS`, `MLFLOW_SERVER_CORS_ALLOWED_ORIGINS`) with append, dedup, and wildcard cases |
| `hpa_test.yaml` | HPA creation conditions |
| `ingress_test.yaml` | Ingress rendering and oauth2Proxy port routing |
| `oidc_auth_test.yaml` | oidcAuth env vars, secret references, Redis cache, Postgres DB URI |
| `oidc_auth_conflict_test.yaml` | Mutual exclusivity `fail` guards for oidcAuth (three `failedTemplate` tests). The `auth + ldapAuth` pair is enforced by `values.schema.json` (`allOf[0] not` constraint) before templates render, so no `failedTemplate` test is possible for that pair — the schema catches it first |
| `secret_test.yaml` | Env-secret (db credentials, S3/azure keys, ldap) and oauth2-proxy secret |
| `service_test.yaml` | Service port and type rendering |
| `serviceaccount_test.yaml` | ServiceAccount creation |
| `servicemonitor_test.yaml` | Prometheus ServiceMonitor rendering |
| `trusted_ca_cert_secret_test.yaml` | LDAP CA certificate secret |
| `extra_deploy_test.yaml` | `extraDeploy` rendering: empty list, single object, multiple objects, and `tpl` expression evaluation |
| `gc_cronjob_test.yaml` | Garbage collection CronJob rendering, backend URI variants, env inheritance, pod parity, volumes, resources |
| `gc_cronjob_fail_test.yaml` | Garbage collection `failedTemplate` guard for default in-memory SQLite |

Use `matchRegex` (not `equal`) when asserting a substring within a rendered multi-line arg or command string — the full strings include unrelated boilerplate that would make `equal` brittle.

`failedTemplate` tests must be in their own suite file that lists only the template containing the `fail` call — if `configmap.yaml` is also listed, helm-unittest checks it independently and fails when it renders cleanly.

## values-kind.yaml

Used exclusively by `ct install` in CI — do not rely on it for production-like testing. Enables:

- `log.level: debug`
- Bitnami PostgreSQL subchart (`postgresql.enabled: true`) with persistence disabled
- `backendStore.databaseMigration: true` — exercises the `mlflow-db-migration` init container
- `backendStore.databaseConnectionCheck: true` — exercises the `dbchecker` init container
- `garbageCollection.enabled: true` — exercises the garbage collection CronJob
- MinIO subchart (`minio.enabled: true`) with persistence disabled, plus `artifactRoot.s3.enabled: true` — exercises S3 artifact storage via the bundled MinIO instance
