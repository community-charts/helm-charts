# MLflow Chart — CLAUDE.md

Chart-specific guidance for `charts/mlflow`. The root `CLAUDE.md` covers general conventions; this file covers only what is non-obvious or specific to this chart.

## What This Chart Deploys

A single MLflow tracking-server `Deployment` (image: `burakince/mlflow`, **not** the official `mlflow/mlflow` image) with optional:

- **Bitnami PostgreSQL** subchart (`postgresql.enabled`) or **Bitnami MySQL** subchart (`mysql.enabled`) for the backend store
- **External DB** via `backendStore.postgres/mysql/mssql.*` for databases managed outside the chart
- **Artifact storage** pointing at S3, Azure Blob Storage, or GCS
- **Basic auth** (SQLite or PostgreSQL-backed) or **LDAP auth** — mutually exclusive, never both
- **Prometheus ServiceMonitor** when the `monitoring.coreos.com/v1` CRD is available
- **HPA** under strict conditions (see below)

## External Documentation

MLflow server configuration reference: https://mlflow.org/docs/latest/tracking/server.html

The custom image adds extra Python dependencies (psycopg2, pymysql, pyodbc, boto3, azure-storage-blob, google-cloud-storage, mlflowstack). Check the upstream repo for the exact package list: https://github.com/burakince/mlflow

## Non-Obvious Architecture Decisions

### PostgreSQL Backend-Store URI Is Built Differently Than MySQL/MSSQL

PostgreSQL passes credentials via environment variables (`PGUSER`/`PGPASSWORD`) injected by Kubernetes — the connection URI in the server args ends with `://` (no embedded credentials):

```
--backend-store-uri=postgresql+psycopg2://
```

MySQL and MSSQL embed runtime env var references directly in the URI string:

```
--backend-store-uri=mysql+pymysql://$(MYSQL_USERNAME):$(MYSQL_PWD)@$(MYSQL_HOST):$(MYSQL_TCP_PORT)/$(MYSQL_DATABASE)
```

This means MySQL/MSSQL env vars must exist as container env entries so the shell can expand `$(VAR)` — they come from `configmap.yaml` (`-env-configmap`).

### Flask Server Secret Key (Pre-install Hook)

`flask_secret.yaml` creates a Secret with a random 32-char hex value using `mlflow.generateRandomHex` at install time via a `pre-install,pre-upgrade` hook with `before-hook-creation` delete policy. This persists the key across upgrades without storing it in `values.yaml`. Never delete this secret manually without understanding the consequence (all existing sessions will be invalidated).

### Init Container Ordering

When a database is configured the init containers always run in this fixed order:

1. **dbchecker** — polls DB port using Fibonacci-backoff netcat (8 attempts max); runs only when `backendStore.databaseConnectionCheck: true`
2. **mlflow-db-migration** — runs `python /opt/mlflow/migrations.py` (wraps `mlflow db upgrade`); runs only when `backendStore.databaseMigration: true`
3. **ini-file-initializer** — `sed` substitution that writes `auth_result.ini` into an `emptyDir` shared with the main container; runs when `auth.enabled` or `ldapAuth.enabled`
4. **user-provided** `initContainers` — appended last

### Auth INI File Generation

The auth config is not rendered directly into a ConfigMap. Instead `auth_ini_configmap.yaml` contains a template with literal placeholders (`$(ADMIN_USERNAME_PLACEHOLDER)` etc.), and the `ini-file-initializer` init container runs `sed` to substitute real values from secrets at runtime. The result lands in an `emptyDir` volume mounted read-only into the main container at `MLFLOW_AUTH_CONFIG_PATH`.

- `auth.enabled` → uses `basic-auth` app-name (configurable via `auth.appName`), mounts at `auth.configPath/auth.configFile`
- `ldapAuth.enabled` → hard-coded app-name `basic-auth`, hard-coded path `/etc/mlflow/auth/ldap_basic_auth.ini`

### HPA Creation Conditions

The HPA (`hpa.yaml`) is guarded by three simultaneous requirements:

1. `autoscaling.enabled: true`
2. A persistent backend store is configured (any DB — not the default SQLite in-memory store)
3. A persistent artifact store is configured (S3/Azure/GCS — not the default local `./mlruns`)
4. Additionally: if `auth.enabled`, it must use `auth.postgres` (not the default SQLite auth backend)

Scaling an MLflow server with in-memory SQLite or local artifact storage is unsafe because replicas would not share state. The template enforces this constraint rather than documenting it.

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

### ConfigMap Checksum Annotation

The pod template carries `checksum/config: {{ include ".../configmap.yaml" . | sha256sum }}` so that any change to the `configmap.yaml` values (env vars) triggers a rolling restart automatically.

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

Use `matchRegex` (not `equal`) when asserting a substring within a rendered multi-line arg or command string — the full strings include unrelated boilerplate that would make `equal` brittle.

## values-kind.yaml

Enables the Bitnami PostgreSQL subchart with no persistent storage (`postgresql.primary.persistence.enabled: false`) and sets `log.level: debug`. Used exclusively by `ct install` in CI — do not rely on it for production-like testing.
