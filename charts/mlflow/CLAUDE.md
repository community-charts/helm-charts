# MLflow Chart — CLAUDE.md

Chart-specific guidance for `charts/mlflow`. The root `CLAUDE.md` covers general conventions; this file covers only what is non-obvious or specific to this chart.

## What This Chart Deploys

A single MLflow tracking-server `Deployment` (image: `burakince/mlflow`, **not** the official `mlflow/mlflow` image) with optional:

- **Bitnami PostgreSQL** subchart (`postgresql.enabled`) or **Bitnami MySQL** subchart (`mysql.enabled`) for the backend store
- **External DB** via `backendStore.postgres/mysql/mssql.*` for databases managed outside the chart
- **Artifact storage** pointing at S3, Azure Blob Storage, or GCS
- **Basic auth** (`auth.enabled`) or **LDAP auth** (`ldapAuth.enabled`) or **OIDC auth** (`oidcAuth.enabled`) — all mutually exclusive, never more than one
- **OAuth2-proxy sidecar** (`oauth2Proxy.enabled`) — mutually exclusive with `oidcAuth`; cannot be combined with each other
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

`oauth2Proxy` can coexist with `auth` or `ldapAuth` in theory (proxy in front, MLflow auth behind) but is explicitly forbidden with `oidcAuth` — the chart enforces this with `fail` guards in `deployment.yaml`.

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

1. **dbchecker** — polls DB port using Fibonacci-backoff netcat (8 attempts max); runs only when `backendStore.databaseConnectionCheck: true`
2. **mlflow-db-migration** — runs `python /opt/mlflow/migrations.py` (wraps `mlflow db upgrade`); runs only when `backendStore.databaseMigration: true`
3. **ini-file-initializer** — `sed` substitution that writes `auth_result.ini` into an `emptyDir` shared with the main container; runs when `auth.enabled` or `ldapAuth.enabled`
4. **user-provided** `initContainers` — appended last

### Auth INI File Generation (basic auth and LDAP only)

The auth config is not rendered directly into a ConfigMap. Instead `auth_ini_configmap.yaml` contains a template with literal placeholders (`$(ADMIN_USERNAME_PLACEHOLDER)` etc.), and the `ini-file-initializer` init container runs `sed` to substitute real values from secrets at runtime. The result lands in an `emptyDir` volume mounted read-only into the main container at `MLFLOW_AUTH_CONFIG_PATH`.

- `auth.enabled` → uses `basic-auth` app-name (configurable via `auth.appName`), mounts at `auth.configPath/auth.configFile`
- `ldapAuth.enabled` → hardcoded app-name `basic-auth`, hardcoded path `/etc/mlflow/auth/ldap_basic_auth.ini`, authorization function set to `mlflowstack.auth.ldap:authenticate_request_basic_auth`

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

### HPA Creation Conditions

The HPA (`hpa.yaml`) is guarded by three simultaneous requirements:

1. `autoscaling.enabled: true`
2. A persistent backend store is configured (any DB — not the default SQLite in-memory store)
3. A persistent artifact store is configured (S3/Azure/GCS — not the default local `./mlruns`)
4. Additionally: if `auth.enabled`, it must use `auth.postgres` (not the default SQLite auth backend)

Scaling an MLflow server with in-memory SQLite or local artifact storage is unsafe because replicas would not share state. The template enforces this constraint rather than documenting it.

When using `oidcAuth` with HPA, ensure:
- `oidcAuth.cache.enabled: true` with a Redis URL — without this, each replica holds an independent in-memory token cache and sessions break on failover
- `oidcAuth.database.postgres.enabled: true` — SQLite for the OIDC user/permission DB is a single file that cannot be shared across replicas

### extraArgs vs extraFlags

- `extraArgs` is a `map[string]string` — keys are camelCase, values are strings. The template converts keys to kebab-case automatically: `{gunicornOpts: "--workers=4"}` → `--gunicorn-opts=--workers=4`
- `extraFlags` is a `string[]` of flag names (no `--` prefix, no value). Also kebab-case converted: `["serveArtifacts"]` → `--serve-artifacts`

### Gunicorn Log-Level Merging

When `log.enabled: true`, the template injects `--log-level` into gunicorn opts by one of three paths:

- No `gunicornOpts` in `extraArgs` → appends `--gunicorn-opts='--log-level=<level>'`
- `gunicornOpts` present and already contains `--log-level` → replaces the existing value via `regexReplaceAll`
- `gunicornOpts` present without `--log-level` → prepends `--log-level=<level>` to the existing string

Test cases for all three paths exist in `unittests/log_level_test.yaml`.

### Proxied Artifact Storage Mode

When `artifactRoot.proxiedArtifactStorage: true`, the CLI flag switches from `--default-artifact-root` to `--artifacts-destination` and `--serve-artifacts` is also appended. The destination value comes from `artifactRoot.defaultArtifactsDestination`, not `artifactRoot.defaultArtifactRoot`. Cloud storage flags override the destination URI, but `--serve-artifacts` is still injected.

### LDAP CA Certificate

LDAP with a self-signed CA uses one of two paths (mutually exclusive):

- `ldapAuth.encodedTrustedCACertificate` — base64-encoded PEM value stored directly in `trusted_ca_cert_secret.yaml`
- `ldapAuth.externalSecretForTrustedCACertificate` — name of a pre-existing secret with key `ca.crt`

Both mount to `/certs/ca.crt` and set `LDAP_CA=/certs/ca.crt` in the main container.

### Secret Name Helpers

`_helpers.tpl` provides three helpers that resolve to either a chart-managed or user-provided secret name using Helm's `default` function:

| Helper | Resolves to |
|---|---|
| `mlflow.oauth2ProxySecretName` | `<release>-oauth2-proxy` or `oauth2Proxy.existingSecret.name` |
| `mlflow.oidcAuthSecretName` | `<release>-oidc-auth-secret` or `oidcAuth.existingSecret.name` |
| `mlflow.oidcAuthDbSecretName` | `<release>-oidc-auth-db-secret` or `oidcAuth.database.postgres.existingSecret.name` |

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
| `deployment_test.yaml` | Core deployment defaults and general rendering |
| `postgres_test.yaml` | PostgreSQL backend (external and subchart) |
| `mysql_test.yaml` | MySQL backend |
| `mssql_test.yaml` | MSSQL backend |
| `s3_test.yaml` | S3 artifact store, IRSA |
| `azure_blob_test.yaml` | Azure Blob artifact store |
| `gcs_test.yaml` | GCS artifact store |
| `auth_test.yaml` | Basic auth, auth Postgres, existing secrets |
| `ldap_test.yaml` | LDAP auth, TLS modes, CA cert |
| `hpa_test.yaml` | HPA creation conditions |
| `log_level_test.yaml` | Log-level merging with gunicorn opts |
| `oidc_auth_test.yaml` | OIDC auth env vars, secret references, cache, DB URI |
| `oidc_auth_conflict_test.yaml` | Mutual exclusivity `fail` guards for oidcAuth |

Use `matchRegex` (not `equal`) when asserting a substring within a rendered multi-line arg or command string — the full strings include unrelated boilerplate that would make `equal` brittle.

`failedTemplate` tests must be in their own suite file that lists only the template containing the `fail` call — if `configmap.yaml` is also listed, helm-unittest checks it independently and fails when it renders cleanly.

## values-kind.yaml

Enables the Bitnami PostgreSQL subchart with no persistent storage (`postgresql.primary.persistence.enabled: false`) and sets `log.level: debug`. Used exclusively by `ct install` in CI — do not rely on it for production-like testing.
