# n8n

![n8n](https://raw.githubusercontent.com/n8n-io/n8n-docs/refs/heads/main/docs/_images/n8n-docs-withWordmark.svg)

A Helm chart for fair-code workflow automation platform with native AI capabilities. Combine visual building with custom code, self-host or cloud, 400+ integrations.

![Version: 1.13.4](https://img.shields.io/badge/Version-1.13.4-informational?style=flat-square) ![Type: application](https://img.shields.io/badge/Type-application-informational?style=flat-square) ![AppVersion: 1.102.4](https://img.shields.io/badge/AppVersion-1.102.4-informational?style=flat-square)

## Official Documentation

For detailed usage instructions, configuration options, and additional information about the `n8n` Helm chart, refer to the [official documentation](https://community-charts.github.io/docs/charts/n8n/usage).

## Get Helm Repository Info

```console
helm repo add community-charts https://community-charts.github.io/helm-charts
helm repo update
```

_See [`helm repo`](https://helm.sh/docs/helm/helm_repo/) for command documentation._

## Installing the Chart

```console
helm install [RELEASE_NAME] community-charts/n8n
```

_See [configuration](#configuration) below._

_See [helm install](https://helm.sh/docs/helm/helm_install/) for command documentation._

> **Tip**: Search all available chart versions using `helm search repo community-charts -l`. Please don't forget to run `helm repo update` before the command.

## Full Example

```yaml
log:
  level: warn

db:
  type: postgresdb

externalPostgresql:
  host: "postgresql-instance1.ab012cdefghi.eu-central-1.rds.amazonaws.com"
  username: "n8nuser"
  password: "Pa33w0rd!"
  database: "n8n"

main:
  resources:
    requests:
      cpu: 100m
      memory: 128Mi
    limits:
      cpu: 512m
      memory: 512Mi

worker:
  mode: queue

  autoscaling:
    enabled: true

  waitMainNodeReady:
    enabled: true

  resources:
    requests:
      cpu: 1000m
      memory: 250Mi
    limits:
      cpu: 2000m
      memory: 2Gi

externalRedis:
  host: "redis-instance1.ab012cdefghi.eu-central-1.rds.amazonaws.com"
  username: "default"
  password: "Pa33w0rd!"

ingress:
  enabled: true
  hosts:
    - host: n8n.mydomain.com
      paths:
        - path: /
          pathType: Prefix

webhook:
  mode: queue

  url: "https://webhook.mydomain.com"

  autoscaling:
    enabled: true

  waitMainNodeReady:
    enabled: true

  resources:
    requests:
      cpu: 100m
      memory: 128Mi
    limits:
      cpu: 512m
      memory: 512Mi
```

## Basic Deployment with Ingress

```yaml
ingress:
  enabled: true
  hosts:
    - host: n8n.mydomain.com
      paths:
        - path: /
          pathType: ImplementationSpecific
```

## Deployment with Bitnami's PostgreSQL

```yaml
db:
  type: postgresdb

postgresql:
  enabled: true
 
  primary:
    persistence:
      existingClaim: "my-n8n-claim"
```

## Deployment with External PostgreSQL

```yaml
db:
  type: postgresdb

externalPostgresql:
  host: "postgresql-instance1.ab012cdefghi.eu-central-1.rds.amazonaws.com"
  username: "n8nuser"
  password: "Pa33w0rd!"
  database: "n8n"
```

## Deployment with External PostgreSQL and Exist Secret on Kubernetes

```yaml
db:
  type: postgresdb

externalPostgresql:
  host: "postgresql-instance1.ab012cdefghi.eu-central-1.rds.amazonaws.com"
  username: "n8nuser"
  database: "n8n"

  existingSecret: "my-k8s-secret-contains-postgres-password-key-and-credential"
```

## Queue Mode with Bitnami's Redis

> **Tip**: Queue mode doesn't work with default SQLite mode

```yaml
db:
  type: postgresdb

externalPostgresql:
  host: "postgresql-instance1.ab012cdefghi.eu-central-1.rds.amazonaws.com"
  username: "n8nuser"
  password: "Pa33w0rd!"
  database: "n8n"

worker:
  mode: queue

redis:
  enabled: true
```

## Queue Mode with External Redis

> **Tip**: Queue mode doesn't work with default SQLite mode

```yaml
db:
  type: postgresdb

externalPostgresql:
  host: "postgresql-instance1.ab012cdefghi.eu-central-1.rds.amazonaws.com"
  username: "n8nuser"
  password: "Pa33w0rd!"
  database: "n8n"

worker:
  mode: queue

externalRedis:
  host: "redis-instance1.ab012cdefghi.eu-central-1.rds.amazonaws.com"
  username: "default"
  password: "Pa33w0rd!"
```

## Queue Mode with External Redis and Exist Secret on Kubernetes

> **Tip**: Queue mode doesn't work with default SQLite mode

```yaml
db:
  type: postgresdb

externalPostgresql:
  host: "postgresql-instance1.ab012cdefghi.eu-central-1.rds.amazonaws.com"
  username: "n8nuser"
  database: "n8n"

  existingSecret: "my-k8s-secret-contains-postgres-password-key-and-credential"

worker:
  mode: queue

externalRedis:
  host: "redis-instance1.ab012cdefghi.eu-central-1.rds.amazonaws.com"
  username: "default"

  existingSecret: "my-k8s-secret-contains-redis-password-key-and-credential"
```

## Webhook Node Deployment

> **Tip**: Webhook needs PostgreSQL backend and Redis based queue mode.

```yaml
db:
  type: postgresdb

externalPostgresql:
  host: "postgresql-instance1.ab012cdefghi.eu-central-1.rds.amazonaws.com"
  username: "n8nuser"
  password: "Pa33w0rd!"
  database: "n8n"

worker:
  mode: queue

externalRedis:
  host: "redis-instance1.ab012cdefghi.eu-central-1.rds.amazonaws.com"
  username: "default"
  password: "Pa33w0rd!"

ingress:
  enabled: true
  hosts:
    - host: n8n.mydomain.com
      paths:
        - path: /
          pathType: Prefix

webhook:
  mode: queue

  url: "https://webhook.mydomain.com"
```

## External Task Runner Example

Please find more detail about external task runners from [here](https://docs.n8n.io/hosting/securing/hardening-task-runners/).

```yaml
taskRunners:
  mode: external
```

## Autoscaling Configuration

> **Note:** The `autoscaling` and `allNodes` options cannot be enabled simultaneously.

### Deploying Worker and Webhook Pods on All Nodes

To deploy worker or webhook pods on all Kubernetes nodes, set the `allNodes` flag to `true`: 

```yaml
db:
  type: postgresdb

worker:
  mode: queue
  allNodes: true

webhook:
  mode: queue
  allNodes: true
```

### Enabling Autoscaling

To enable autoscaling, set the `enabled` field under `autoscaling` to `true`:

```yaml
db:
  type: postgresdb

worker:
  mode: queue
  autoscaling:
    enabled: true

webhook:
  mode: queue
  autoscaling:
    enabled: true
```

Ensure that you configure either `allNodes` or `autoscaling` based on your deployment requirements.

## StatefulSet and Deployment Selection (Persistence & Scaling)

> **Note:** You do **not** need to set `forceToUseStatefulset` in most cases. The chart will automatically select StatefulSet or Deployment based on your persistence and replica settings.

- **StatefulSet** is used automatically if:
  - `persistence.enabled: true`
  - More than one replica (`count > 1` and `autoscaling.enabled: false`)
  - `persistence.accessMode: ReadWriteOnce`
  - No `existingClaim` is set

- **Deployment** is used if:
  - `persistence.enabled: false`
  - Only one replica (`count: 1` and no autoscaling)
  - `persistence.accessMode: ReadWriteMany`
  - `existingClaim` is set

- You can **force** StatefulSet with `forceToUseStatefulset: true` (default is `false`).

**Examples:**

### Main Node Examples

```yaml
# Automatic StatefulSet (multiple replicas, ReadWriteOnce)
main:
  count: 3  # Multiple replicas
  persistence:
    enabled: true
    accessMode: ReadWriteOnce
    volumeName: "n8n-main-data"
    mountPath: "/home/node/.n8n"
    size: 10Gi
# Result: StatefulSet with 3 replicas
```

```yaml
# Automatic Deployment (multiple replicas, ReadWriteMany)
main:
  count: 3  # Multiple replicas
  persistence:
    enabled: true
    accessMode: ReadWriteMany
    volumeName: "n8n-main-data"
    mountPath: "/home/node/.n8n"
    size: 10Gi
# Result: Deployment with 3 replicas
```

```yaml
# Automatic Deployment (single replica)
main:
  count: 1  # Single replica
  persistence:
    enabled: true
    accessMode: ReadWriteOnce
    volumeName: "n8n-main-data"
    mountPath: "/home/node/.n8n"
    size: 10Gi
# Result: Deployment with 1 replica
```

```yaml
# Manual override (force StatefulSet)
main:
  forceToUseStatefulset: true
  persistence:
    enabled: true
    volumeName: "n8n-main-data"
    mountPath: "/home/node/.n8n"
    size: 10Gi
# Result: StatefulSet regardless of other settings
```

### Worker Node Examples

```yaml
# Automatic StatefulSet (multiple replicas, ReadWriteOnce)
worker:
  mode: queue
  count: 3  # Multiple replicas
  persistence:
    enabled: true
    accessMode: ReadWriteOnce
    volumeName: "n8n-worker-data"
    mountPath: "/home/node/.n8n"
    size: 5Gi
# Result: StatefulSet with 3 replicas
```

```yaml
# Autoscaling with Deployment (ReadWriteMany)
worker:
  mode: queue
  autoscaling:
    enabled: true
    minReplicas: 2
    maxReplicas: 10
  persistence:
    enabled: true
    accessMode: ReadWriteMany  # Required for autoscaling
    volumeName: "n8n-worker-data"
    mountPath: "/home/node/.n8n"
    size: 5Gi
# Result: Deployment with autoscaling enabled
```

```yaml
# Manual scaling with StatefulSet
worker:
  mode: queue
  forceToUseStatefulset: true
  count: 3  # Fixed number of replicas
  persistence:
    enabled: true
    accessMode: ReadWriteOnce
    volumeName: "n8n-worker-data"
    mountPath: "/home/node/.n8n"
    size: 5Gi
  # Note: autoscaling.enabled should be false or omitted
# Result: StatefulSet with 3 replicas, no autoscaling
```

```yaml
# ❌ INVALID CONFIGURATION - Will fail schema validation
worker:
  mode: queue
  autoscaling:
    enabled: true  # ❌ Cannot enable autoscaling
  persistence:
    enabled: true
    accessMode: ReadWriteOnce  # ❌ With ReadWriteOnce persistence
# Result: Schema validation error
```

### Persistence Use Cases

**When to use persistence:**
- **Main node**: Store n8n data, workflows, and configuration persistently
- **Worker nodes**: Store npm packages and node modules for faster startup
- **Development**: Keep workflows and data across pod restarts
- **Production**: Ensure data persistence and faster npm package loading

**Storage considerations:**
- **ReadWriteOnce**: Use for single-node deployments or when you need StatefulSets
- **ReadWriteMany**: Use for multi-node deployments with autoscaling
- **Storage classes**: Choose based on your cluster's available storage options
- **Size**: Consider your data growth and npm package requirements

> **⚠️ Warning**: Using `ReadWriteMany` access mode with multiple nodes can create a volume bottleneck and significantly decrease performance. Consider using `ReadWriteOnce` with StatefulSets for better performance in high-traffic scenarios, or use external storage solutions (S3, NFS) for shared data.

> **⚠️ Autoscaling Limitations**:
> - **StatefulSets and Autoscaling**: StatefulSets do not work with Horizontal Pod Autoscaler (HPA). If you enable `worker.forceToUseStatefulset: true`, autoscaling will be disabled automatically.
> - **Persistence and Autoscaling**: When using `worker.persistence.enabled: true` with `worker.persistence.accessMode: ReadWriteOnce`, autoscaling cannot be enabled. This is because ReadWriteOnce volumes can only be mounted by one pod at a time, which conflicts with HPA's ability to scale pods dynamically.
> - **Webhook pods only support Deployments and can always use autoscaling.**

## Host Aliases Configuration

The chart supports Kubernetes hostAliases for all node types (main, worker, and webhook). This allows you to add custom hostname-to-IP mappings to the pods' `/etc/hosts` file.

### Host Aliases Configuration

```yaml
main:
  hostAliases:
    - ip: "127.0.0.1"
      hostnames:
        - "foo.local"
        - "bar.local"
    - ip: "10.1.2.3"
      hostnames:
        - "foo.remote"
        - "bar.remote"

worker:
  hostAliases:
    - ip: "192.168.1.100"
      hostnames:
        - "internal-api.local"

webhook:
  hostAliases:
    - ip: "10.0.0.50"
      hostnames:
        - "webhook-service.local"
```

For more information about hostAliases, see the [Kubernetes documentation](https://kubernetes.io/docs/tasks/network/customize-hosts-file-for-pods/#adding-additional-entries-with-hostaliases).

## Main Node Ready status Waiter

Running `main` nodes, `worker` nodes, and `webhooks` nodes at sametime sometimes creates migration error because multiple containers trying to apply same migration to the database. If we enable `wait-for-main` init container, only main node will apply database migrations and after nodes will start after starting to get ready status from the main node.

### Enabling `wait-for-main` for Worker Nodes and Webhook Nodes

If you set `N8N_PROTOCOL` environment variable to your main node, if will read the value and set the corrrect schema for you.

```yaml
worker:
  waitMainNodeReady:
    enabled: true

webhook:
  waitMainNodeReady:
    enabled: true
```

You can also overwrite the automatically defined values with you desired settings.

```yaml
worker:
  waitMainNodeReady:
    enabled: true
    overwriteSchema: "https"
    overwriteUrl: "n8n.n8n.svc.cluster.local:5678"
    healthCheckPath: "/healthz"
    additionalParameters:
      - "--no-check-certificate"

webhook:
  waitMainNodeReady:
    enabled: true
    overwriteSchema: "https"
    overwriteUrl: "n8n.n8n.svc.cluster.local:5678"
    healthCheckPath: "/healthz"
    additionalParameters:
      - "--no-check-certificate"
```

## Enabling Support for Node.js Core and External/Private NPM Packages

Easily incorporate Node.js core packages, public NPM packages, or private NPM packages from your registry into your n8n Code blocks with this Helm chart. Below, we guide you through enabling and configuring these options.

### Using Node.js Core Packages

To enable Node.js core packages, set the `nodes.builtin.enabled` flag to `true`. This allows access to all built-in Node.js modules.

```yaml
nodes:
  builtin:
    enabled: true
```

If you prefer to enable only specific core modules, list them in `nodes.builtin.modules`. Here's an example:

```yaml
nodes:
  builtin:
    enabled: true
    modules:
      - crypto
      - fs
      - http
      - https
      - querystring
      - url
```

### Installing External NPM Packages

To install packages from the public NPM registry, add them to the `nodes.external.packages` list. You can specify versions or omit them to use the latest available version.

```yaml
nodes:
  external:
    packages:
      - "moment@2.29.4"
      - "lodash@4.17.21"
      - "date-fns"
```

#### Supporting Scoped NPM Packages (e.g., @scoped/package)

Our Helm chart supports installing NPM packages, including scoped packages (those starting with `@`, such as `@stdlib/math`). However, the Node.js Task Runner may encounter issues when processing internal package definitions that include scoped package names. To address this, we've implemented a convenient workaround: enabling the `nodes.external.allowAll` option allows all external package definitions, including scoped packages, to be processed seamlessly.

Here's an example configuration to install both regular and scoped packages:

```yaml
nodes:
  external:
    allowAll: true
    packages:
      - "moment@2.29.4"
      - "lodash@4.17.21"
      - "date-fns"
      - "@stdlib/math@0.3.3"
```

### Installing Community Node Packages

To install packages from the public NPM registry, add them to the `nodes.external.packages` list. Community Node package names must start with `n8n-nodes-`. You can specify versions or omit them to use the latest available version.

```yaml
nodes:
  external:
    packages:
      - "n8n-nodes-python@0.1.4"
      - "n8n-nodes-chatwoot@0.1.40"
```

##### How It Works

By setting `nodes.external.allowAll` to `true`, the chart bypasses the Node.js Task Runner's limitations for scoped packages, ensuring smooth installation of all listed packages. You can include both scoped (e.g., `@stdlib/math`) and non-scoped packages in the `nodes.external.packages` list, with or without specific versions.

### Using Private NPM Packages

For packages hosted in a private NPM registry, configure access by providing a valid `.npmrc` file. You can either reference an existing Kubernetes secret containing the `.npmrc` content or define custom `.npmrc` content directly in the chart values.

#### Option 1: Using a Secret for `.npmrc`

If your `.npmrc` file is stored in a Kubernetes secret, specify the secret details as shown below:

```yaml
nodes:
  external:
    packages:
      - "my-private-package"

npmRegistry:
  enabled: true
  url: "https://internal.npm.registry.mycompany.com"
  secretName: "npmrc-secret"
  secretKey: "npmrc"
```

#### Option 2: Providing Custom `.npmrc` Content

Alternatively, you can define the `.npmrc` content directly in the chart values. This is useful for registries like GitHub Packages that require authentication tokens:

```yaml
nodes:
  external:
    packages:
      - "@myGithubOrg/my-private-package"

npmRegistry:
  enabled: true
  url: "https://npm.pkg.github.com"
  customNpmrc: |
    @myGithubOrg:registry=https://npm.pkg.github.com
    //npm.pkg.github.com/:_authToken=ghp_MyGithubClassicToken
```

## Service Monitor Examples

The n8n Helm chart supports optional integration with Prometheus via `ServiceMonitor` and `PodMonitor` resources, compatible with the Prometheus Operator (API version `monitoring.coreos.com/v1`). These resources allow Prometheus to scrape metrics from n8n services and worker pods. This section provides examples to help you enable and configure monitoring.

### Prerequisites

* The Prometheus Operator must be installed in your cluster.
* Your Prometheus instance must be configured to discover `ServiceMonitor` and `PodMonitor` resources (e.g., via a matching `release` label).

### Enabling the ServiceMonitor

To enable monitoring, set `serviceMonitor.enabled` to `true` in your `values.yaml` file or via a Helm override. By default, the `ServiceMonitor` is disabled (`false`).

#### Basic Example

Enable the `ServiceMonitor` with default settings:

```yaml
serviceMonitor:
  enabled: true
```

This deploys a `ServiceMonitor` in the same namespace as the chart (e.g., `n8n`), scraping the n8n service's `/metrics` endpoint every 30 seconds with a 10-second timeout. The default label `release: prometheus` is applied, which should match your Prometheus instance's service monitor selector.

#### Custom Namespace and Interval

Deploy the `ServiceMonitor` in a specific namespace (e.g., `monitoring`) with a custom scrape interval:

```yaml
serviceMonitor:
  enabled: true
  namespace: monitoring
  interval: 1m
```

This scrapes metrics every minute from the n8n service in the release namespace (e.g., `n8n`), with the `ServiceMonitor` itself residing in the `monitoring` namespace.

#### Relabeling Metrics

Add custom metric relabeling to drop unwanted labels:

```yaml
serviceMonitor:
  enabled: true
  labels:
    release: my-prometheus
  metricRelabelings:
    - regex: prometheus_replica
      action: labeldrop
```

This deploys a `ServiceMonitor` with a custom `release: my-prometheus` label and drops the `prometheus_replica` label from scraped metrics.

### Enabling the PodMonitor (Worker Mode)

If using a PostgreSQL database (`db.type: postgresdb`) and queue mode (`worker.mode: queue`), a `PodMonitor` is available to scrape metrics from n8n worker pods.

#### Worker Monitoring Example

Enable both `ServiceMonitor` and `PodMonitor` for a full setup:

```yaml
db:
  type: postgresdb

externalPostgresql:
  host: "postgresql-instance1.ab012cdefghi.eu-central-1.rds.amazonaws.com"
  username: "n8nuser"
  password: "Pa33w0rd!"
  database: "n8n"

worker:
  mode: queue

externalRedis:
  host: "redis-instance1.ab012cdefghi.eu-central-1.rds.amazonaws.com"
  username: "default"
  password: "Pa33w0rd!"

serviceMonitor:
  enabled: true
  interval: 15s
  timeout: 5s
```

This scrapes the main n8n service and worker pods every 15 seconds with a 5-second timeout. The `PodMonitor` targets worker pods with the label `role: worker`.

### Troubleshooting

* Ensure the `release` label matches your Prometheus configuration (see [Prometheus Operator docs](https://github.com/prometheus-operator/prometheus-operator/blob/main/Documentation/platform/troubleshooting.md#troubleshooting-servicemonitor-changes)).
* Verify RBAC permissions for the Prometheus service account (e.g., system:serviceaccount:monitoring:prometheus-k8s) to list/watch Pods, Services, and Endpoints. You can use something similar as the following command.

```bash
kubectl auth can-i list pods --namespace n8n --as=system:serviceaccount:monitoring:prometheus-k8s
kubectl auth can-i list services --namespace n8n --as=system:serviceaccount:monitoring:prometheus-k8s
kubectl auth can-i list endpoints --namespace n8n --as=system:serviceaccount:monitoring:prometheus-k8s

kubectl auth can-i watch pods --namespace n8n --as=system:serviceaccount:monitoring:prometheus-k8s
kubectl auth can-i watch services --namespace n8n --as=system:serviceaccount:monitoring:prometheus-k8s
kubectl auth can-i watch endpoints --namespace n8n --as=system:serviceaccount:monitoring:prometheus-k8s
```

## Enterprise License Configuration

The chart now supports enterprise license configuration. To enable and configure it, update the `values.yaml` file:

```yaml
license:
  enabled: true
  activationKey: "your-activation-key"
```

If you have an existing secret for the activation key with `N8N_LICENSE_ACTIVATION_KEY` secret key, configure it as follows:

```yaml
license:
  enabled: true
  existingActivationKeySecret: "your-existing-secret"
```

## S3 Binary Storage Configuration

The chart now supports storing binary data in S3-compatible external storage. To enable and configure it, update the `values.yaml` file:

```yaml
binaryData:
  availableModes:
    - s3
  mode: "s3"
  s3:
    host: "s3.us-east-1.amazonaws.com"
    bucketName: "your-bucket-name"
    bucketRegion: "us-east-1"
    accessKey: "your-access-key"
    accessSecret: "your-secret-access-key"
```

If you have an existing secret for the s3 access key and access secret with `access-key-id` and `secret-access-key` seret key names respectively, configure it as follows:

```yaml
binaryData:
  availableModes:
    - s3
  mode: "s3"
  s3:
    host: "s3.us-east-1.amazonaws.com"
    bucketName: "your-bucket-name"
    bucketRegion: "us-east-1"
    existingSecret: "your-existing-secret"
```

## Upgrading

This section outlines major updates and breaking changes for each version of the Helm Chart to help you transition smoothly between releases.

---

###  Version-Specific Upgrade Notes

#### Upgrading to Version 1.13.1

##### Action Required

Pleae do not use 1.13.0 chart. It contains selector labels breaking changes. Please consider to upgrade 1.13.1 or higher hotfix version directly.

#### Upgrading to Version 1.11.x

##### Deprecation Notices

- The top-level field `affinity` is deprecated.

##### Action Required

Please consider using the corresponding fields in the `main`, `worker` and `webhook` blocks instead. The deprecated field will be removed in the next major release.

#### Upgrading to Version 1.7.x

##### Deprecation Notices

- The top-level fields `livenessProbe`, and `readinessProbe` are deprecated.

##### Action Required

Please consider using the corresponding fields in the `main`, `worker` and `webhook` blocks instead. The deprecated fields will be removed in the next major release.
The Worker and Webhook nodes no longer include a default init container to wait for the main node to become ready. If this behavior is required, please enable it explicitly by setting `worker.waitMainNodeReady.enabled` and `webhook.waitMainNodeReady.enabled` to `true`.

#### Upgrading to Version 1.3.1

##### Deprecation Notices

* **Secret Name Change**: The secret `RELEASE_NAME-encryption-key-secret` is deprecated. Starting with this release, the chart now uses `RELEASE_NAME-encryption-key-secret-v2` to manage the `N8N_ENCRYPTION_KEY`. This change ensures compatibility with Helm's resource ownership model and resolves previous upgrade issues.

##### Actions Required

* **Verify the Upgrade**: After successfully upgrading to version 1.3.1, confirm that your `n8n` deployment is using the new secret (`RELEASE_NAME-encryption-key-secret-v2`). The old secret (`RELEASE_NAME-encryption-key-secret`) is preserved in the namespace and will not be automatically deleted.
* **Optional Cleanup**: If the old secret is no longer needed, you may manually remove it from your namespace using the following command:
bash

```bash
kubectl delete secret RELEASE_NAME-encryption-key-secret -n YOUR_NAMESPACE
```

Replace `RELEASE_NAME` and `YOUR_NAMESPACE` with your specific release name and namespace.

#### Upgrading to Version 1.2.x

##### Deprecation Notices

- The top-level fields `extraEnvVars`, `extraSecretNamesForEnvFrom`, `resources`, `volumes` and `volumeMounts` are deprecated.

##### Action Required

Please consider using the corresponding fields in the `main`, `worker` and `webhook` blocks instead. The deprecated fields will be removed in the next major release.

#### Upgrading to Version 1.x.x

##### Breaking Changes

- The `diagnostics.externalTaskRunnersSentryDsn` setting has been relocated to `sentry.externalTaskRunnersDsn`.

##### Action Required

If you previously configured `diagnostics.externalTaskRunnersSentryDsn`, update your configuration to use `sentry.externalTaskRunnersDsn`. Ensure that any associated flags are enabled as needed.

## Requirements

Kubernetes: `>=1.23.0-0`

| Repository | Name | Version |
|------------|------|---------|
| https://charts.bitnami.com/bitnami | postgresql | 16.7.19 |
| https://charts.bitnami.com/bitnami | redis | 21.2.12 |
| https://charts.min.io/ | minio | 5.4.0 |

## Uninstall Helm Chart

```console
helm uninstall [RELEASE_NAME]
```

This removes all the Kubernetes components associated with the chart and deletes the release.

_See [helm uninstall](https://helm.sh/docs/helm/helm_uninstall/) for command documentation._

## Upgrading Chart

```console
helm upgrade [RELEASE_NAME] community-charts/n8n
```

## Values

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| affinity | object | `{}` | DEPRECATED: Use main, worker, and webhook blocks volumes fields instead. This field will be removed in a future release. |
| api.enabled | bool | `true` | Whether to enable the Public API |
| api.path | string | `"api"` | Path segment for the Public API |
| api.swagger | object | `{"enabled":true}` | Whether to enable the Swagger UI for the Public API |
| binaryData | object | `{"availableModes":[],"localStoragePath":"","mode":"default","s3":{"accessKey":"","accessSecret":"","bucketName":"","bucketRegion":"us-east-1","existingSecret":"","host":""}}` | Configuration for binary data storage |
| binaryData.availableModes | list | `[]` | Available modes of binary data storage. If not set, the default mode will be used. For more information, see https://docs.n8n.io/hosting/configuration/environment-variables/binary-data/ |
| binaryData.localStoragePath | string | `""` | Path for binary data storage in "filesystem" mode. If not set, the default path will be used. For more information, see https://docs.n8n.io/hosting/configuration/environment-variables/binary-data/ |
| binaryData.mode | string | `"default"` | The default binary data mode. default keeps binary data in memory. Set to filesystem to use the filesystem, or s3 to AWS S3. Note that binary data pruning operates on the active binary data mode. For example, if your instance stored data in S3, and you later switched to filesystem mode, n8n only prunes binary data in the filesystem. This may change in future. Valid values are 'default' | 'filesystem' | 's3'. For more information, see https://docs.n8n.io/hosting/configuration/environment-variables/binary-data/ |
| binaryData.s3 | object | `{"accessKey":"","accessSecret":"","bucketName":"","bucketRegion":"us-east-1","existingSecret":"","host":""}` | S3-compatible external storage configurations. For more information, see https://docs.n8n.io/hosting/configuration/environment-variables/external-data-storage/ |
| binaryData.s3.accessKey | string | `""` | Access key in S3-compatible external storage |
| binaryData.s3.accessSecret | string | `""` | Access secret in S3-compatible external storage. |
| binaryData.s3.bucketName | string | `""` | Name of the n8n bucket in S3-compatible external storage. |
| binaryData.s3.bucketRegion | string | `"us-east-1"` | Region of the n8n bucket in S3-compatible external storage. For example, us-east-1 |
| binaryData.s3.existingSecret | string | `""` | This is for setting up the s3 file storage existing secret. Must contain access-key-id and secret-access-key keys. |
| binaryData.s3.host | string | `""` | Host of the n8n bucket in S3-compatible external storage. For example, s3.us-east-1.amazonaws.com |
| db | object | `{"logging":{"enabled":false,"maxQueryExecutionTime":0,"options":"error"},"sqlite":{"database":"database.sqlite","poolSize":0,"vacuum":false},"tablePrefix":"","type":"sqlite"}` | n8n database configurations |
| db.logging.enabled | bool | `false` | Whether database logging is enabled. |
| db.logging.maxQueryExecutionTime | int | `0` | Only queries that exceed this time (ms) will be logged. Set `0` to disable. |
| db.logging.options | string | `"error"` | Database logging level. Requires `maxQueryExecutionTime` to be higher than `0`. Valid values 'query' | 'error' | 'schema' | 'warn' | 'info' | 'log' | 'all' |
| db.sqlite.database | string | `"database.sqlite"` | SQLite database file name |
| db.sqlite.poolSize | int | `0` | SQLite database pool size. Set to `0` to disable pooling. |
| db.sqlite.vacuum | bool | `false` | Runs VACUUM operation on startup to rebuild the database. Reduces file size and optimizes indexes. This is a long running blocking operation and increases start-up time. |
| db.tablePrefix | string | `""` | Prefix to use for table names. |
| db.type | string | `"sqlite"` | Type of database to use. Valid values 'sqlite' | 'postgresdb' |
| defaultLocale | string | `"en"` | A locale identifier, compatible with the Accept-Language header. n8n doesn't support regional identifiers, such as de-AT. |
| diagnostics.backendConfig | string | `"1zPn7YoGC3ZXE9zLeTKLuQCB4F6;https://telemetry.n8n.io"` | Diagnostics config for backend. |
| diagnostics.enabled | bool | `false` | Whether diagnostics are enabled. |
| diagnostics.frontendConfig | string | `"1zPn9bgWPzlQc0p8Gj1uiK6DOTn;https://telemetry.n8n.io"` | Diagnostics config for frontend. |
| diagnostics.postHog.apiHost | string | `"https://ph.n8n.io"` | API host for PostHog. |
| diagnostics.postHog.apiKey | string | `"phc_4URIAm1uYfJO7j8kWSe0J8lc8IqnstRLS7Jx8NcakHo"` | API key for PostHog. |
| dnsConfig | object | `{}` | For more information checkout: https://kubernetes.io/docs/concepts/services-networking/dns-pod-service/#pod-dns-config |
| dnsPolicy | string | `""` | For more information checkout: https://kubernetes.io/docs/concepts/services-networking/dns-pod-service/#pod-s-dns-policy |
| encryptionKey | string | `""` | If you install n8n first time, you can keep this empty and it will be auto generated and never change again. If you already have a encryption key generated before, please use it here. |
| existingEncryptionKeySecret | string | `""` | The name of an existing secret with encryption key. The secret must contain a key with the name N8N_ENCRYPTION_KEY. |
| externalPostgresql | object | `{"database":"n8n","existingSecret":"","host":"","password":"","port":5432,"username":"postgres"}` | External PostgreSQL parameters |
| externalPostgresql.database | string | `"n8n"` | The name of the external PostgreSQL database. For more information: https://docs.n8n.io/hosting/configuration/supported-databases-settings/#required-permissions |
| externalPostgresql.existingSecret | string | `""` | The name of an existing secret with PostgreSQL (must contain key `postgres-password`) and credentials. When it's set, the `externalPostgresql.password` parameter is ignored |
| externalPostgresql.host | string | `""` | External PostgreSQL server host |
| externalPostgresql.password | string | `""` | External PostgreSQL password |
| externalPostgresql.port | int | `5432` | External PostgreSQL server port |
| externalPostgresql.username | string | `"postgres"` | External PostgreSQL username |
| externalRedis | object | `{"existingSecret":"","host":"","password":"","port":6379,"username":""}` | External Redis parameters |
| externalRedis.existingSecret | string | `""` | The name of an existing secret with Redis (must contain key `redis-password`) and Sentinel credentials. When it's set, the `externalRedis.password` parameter is ignored |
| externalRedis.host | string | `""` | External Redis server host |
| externalRedis.password | string | `""` | External Redis password |
| externalRedis.port | int | `6379` | External Redis server port |
| externalRedis.username | string | `""` | External Redis username |
| extraEnvVars | object | `{}` | DEPRECATED: Use main, worker, and webhook blocks extraEnvVars fields instead. This field will be removed in a future release. |
| extraSecretNamesForEnvFrom | list | `[]` | DEPRECATED: Use main, worker, and webhook blocks extraSecretNamesForEnvFrom fields instead. This field will be removed in a future release. |
| fullnameOverride | string | `""` |  |
| gracefulShutdownTimeout | int | `30` | graceful shutdown timeout in seconds |
| image | object | `{"pullPolicy":"IfNotPresent","repository":"n8nio/n8n","tag":""}` | This sets the container image more information can be found here: https://kubernetes.io/docs/concepts/containers/images/ |
| image.pullPolicy | string | `"IfNotPresent"` | This sets the pull policy for images. |
| image.tag | string | `""` | Overrides the image tag whose default is the chart appVersion. |
| imagePullSecrets | list | `[]` | This is for the secretes for pulling an image from a private repository more information can be found here: https://kubernetes.io/docs/tasks/configure-pod-container/pull-image-private-registry/ |
| ingress | object | `{"annotations":{},"className":"","enabled":false,"hosts":[{"host":"n8n.local","paths":[{"path":"/","pathType":"Prefix"}]}],"tls":[]}` | This block is for setting up the ingress for more information can be found here: https://kubernetes.io/docs/concepts/services-networking/ingress/ |
| license | object | `{"activationKey":"","autoNenew":{"enabled":true,"offsetInHours":72},"enabled":false,"existingActivationKeySecret":"","serverUrl":"http://license.n8n.io/v1","tenantId":1}` | n8n enterprise license configurations |
| license.activationKey | string | `""` | Activation key to initialize license. Not applicable if the n8n instance was already activated. For more information please refer to the following link: https://docs.n8n.io/enterprise-key/ |
| license.autoNenew | object | `{"enabled":true,"offsetInHours":72}` | The auto new license configuration |
| license.autoNenew.enabled | bool | `true` | Enables (true) or disables (false) autorenewal for licenses. If disabled, you need to manually renew the license every 10 days by navigating to Settings > Usage and plan, and pressing F5. Failure to renew the license will disable Enterprise features. |
| license.autoNenew.offsetInHours | int | `72` | Time in hours before expiry a license should automatically renew. |
| license.enabled | bool | `false` | Whether to enable the enterprise license |
| license.existingActivationKeySecret | string | `""` | The name of an existing secret with license activation key. The secret must contain a key with the name N8N_LICENSE_ACTIVATION_KEY. |
| license.serverUrl | string | `"http://license.n8n.io/v1"` | Server URL to retrieve license. |
| license.tenantId | int | `1` | Tenant ID associated with the license. Only set this variable if explicitly instructed by n8n. |
| livenessProbe | object | `{}` | DEPRECATED: Use main, worker, and webhook blocks livenessProbe field instead. This field will be removed in a future release. |
| log | object | `{"file":{"location":"logs/n8n.log","maxcount":"100","maxsize":16},"level":"info","output":["console"],"scopes":[]}` | n8n log configurations |
| log.file.location | string | `"logs/n8n.log"` | Location of the log files inside `~/.n8n`. Only for `file` log output. |
| log.file.maxcount | string | `"100"` | Max number of log files to keep, or max number of days to keep logs for. Once the limit is reached, the oldest log files will be rotated out. If using days, append a `d` suffix. Only for `file` log output. |
| log.file.maxsize | int | `16` | The maximum size (in MB) for each log file. By default, n8n uses 16 MB. |
| log.level | string | `"info"` | The log output level. The available options are (from lowest to highest level) are error, warn, info, and debug. The default value is info. You can learn more about these options [here](https://docs.n8n.io/hosting/logging-monitoring/logging/#log-levels). |
| log.output | list | `["console"]` | Where to output logs to. Options are: `console` or `file` or both. |
| log.scopes | list | `[]` | Scopes to filter logs by. Nothing is filtered by default. Supported log scopes: concurrency, external-secrets, license, multi-main-setup, pubsub, redis, scaling, waiting-executions |
| main | object | `{"affinity":{},"count":1,"extraContainers":[],"extraEnvVars":{},"extraSecretNamesForEnvFrom":[],"forceToUseStatefulset":false,"hostAliases":[],"initContainers":[],"livenessProbe":{"httpGet":{"path":"/healthz","port":"http"}},"pdb":{"enabled":true,"maxUnavailable":null,"minAvailable":1},"persistence":{"accessMode":"ReadWriteOnce","annotations":{"helm.sh/resource-policy":"keep"},"enabled":false,"existingClaim":"","labels":{},"mountPath":"/home/node/.n8n","size":"8Gi","storageClass":"","subPath":"","volumeName":""},"readinessProbe":{"httpGet":{"path":"/healthz/readiness","port":"http"}},"resources":{},"runtimeClassName":"","volumeMounts":[],"volumes":[]}` | Main node configurations |
| main.affinity | object | `{}` | Main node affinity. For more information checkout: https://kubernetes.io/docs/concepts/scheduling-eviction/assign-pod-node/#affinity-and-anti-affinity |
| main.count | int | `1` | Number of main nodes. Only enterprise license users can have one leader main node and mutiple follower main nodes. |
| main.extraContainers | list | `[]` | Additional containers for the main pod |
| main.extraEnvVars | object | `{}` | Extra environment variables |
| main.extraSecretNamesForEnvFrom | list | `[]` | Extra secrets for environment variables |
| main.forceToUseStatefulset | bool | `false` | Force to use statefulset for the main pod. If true, the main pod will be created as a statefulset. |
| main.hostAliases | list | `[]` | Host aliases for the main pod. For more information checkout: https://kubernetes.io/docs/tasks/network/customize-hosts-file-for-pods/#adding-additional-entries-with-hostaliases |
| main.initContainers | list | `[]` | Additional init containers for the main pod |
| main.livenessProbe | object | `{"httpGet":{"path":"/healthz","port":"http"}}` | This is to setup the liveness probe for the main pod more information can be found here: https://kubernetes.io/docs/tasks/configure-pod-container/configure-liveness-readiness-startup-probes/ |
| main.pdb | object | `{"enabled":true,"maxUnavailable":null,"minAvailable":1}` | Whether to enable the PodDisruptionBudget for the main pod. |
| main.pdb.enabled | bool | `true` | Whether to enable the PodDisruptionBudget |
| main.pdb.maxUnavailable | string | `nil` | Maximum number of unavailable replicas |
| main.pdb.minAvailable | int | `1` | Minimum number of available replicas |
| main.persistence | object | `{"accessMode":"ReadWriteOnce","annotations":{"helm.sh/resource-policy":"keep"},"enabled":false,"existingClaim":"","labels":{},"mountPath":"/home/node/.n8n","size":"8Gi","storageClass":"","subPath":"","volumeName":""}` | Persistence configuration for the main pod |
| main.persistence.accessMode | string | `"ReadWriteOnce"` | Access mode for persistence |
| main.persistence.annotations | object | `{"helm.sh/resource-policy":"keep"}` | Annotations for persistence |
| main.persistence.enabled | bool | `false` | Whether to enable persistence |
| main.persistence.existingClaim | string | `""` | Existing claim to use for persistence |
| main.persistence.labels | object | `{}` | Labels for persistence |
| main.persistence.mountPath | string | `"/home/node/.n8n"` | Mount path for persistence |
| main.persistence.size | string | `"8Gi"` | Size for persistence |
| main.persistence.storageClass | string | `""` | Storage class for persistence |
| main.persistence.subPath | string | `""` | Sub path for persistence |
| main.persistence.volumeName | string | `""` | Name of the volume to use for persistence |
| main.readinessProbe | object | `{"httpGet":{"path":"/healthz/readiness","port":"http"}}` | This is to setup the readiness probe for the main pod more information can be found here: https://kubernetes.io/docs/tasks/configure-pod-container/configure-liveness-readiness-startup-probes/ |
| main.resources | object | `{}` | This block is for setting up the resource management for the main pod more information can be found here: https://kubernetes.io/docs/concepts/configuration/manage-resources-containers/ |
| main.runtimeClassName | string | `""` | Runtime class name for the main pod. For more information checkout: https://kubernetes.io/docs/concepts/containers/runtime-class/ |
| main.volumeMounts | list | `[]` | Additional volumeMounts on the output Deployment definition. |
| main.volumes | list | `[]` | Additional volumes on the output Deployment definition. |
| minio | object | `{"buckets":[{"name":"n8n-bucket","policy":"none","purge":false,"versioning":false}],"consoleIngress":{"enabled":false,"hosts":["minio-console.mydomain.com"],"path":"/"},"deploymentUpdate":{"type":"Recreate"},"drivesPerNode":1,"enabled":false,"ingress":{"enabled":true,"hosts":["minio.mydomain.com"],"path":"/"},"mode":"standalone","persistence":{"accessMode":"ReadWriteOnce","annotations":{},"enabled":true,"existingClaim":"","size":"40Gi","storageClass":"","subPath":"","volumeName":""},"policies":[{"name":"n8n-policy","statements":[{"actions":["s3:AbortMultipartUpload","s3:GetObject","s3:DeleteObject","s3:PutObject","s3:ListMultipartUploadParts"],"resources":["arn:aws:s3:::n8n-bucket/*"]},{"actions":["s3:GetBucketLocation","s3:ListBucket","s3:ListBucketMultipartUploads"],"resources":["arn:aws:s3:::n8n-bucket"]}]}],"pools":1,"replicas":1,"resources":{"requests":{"memory":"1Gi"}},"rootPassword":"","rootUser":"","statefulSetUpdate":{"updateStrategy":"Recreate"},"users":[{"accessKey":"n8n-user","policy":"n8n-policy","secretKey":"Change_Me"}]}` | Minio configuration |
| minio.buckets | list | `[{"name":"n8n-bucket","policy":"none","purge":false,"versioning":false}]` | Minio buckets |
| minio.buckets[0] | object | `{"name":"n8n-bucket","policy":"none","purge":false,"versioning":false}` | n8n bucket |
| minio.buckets[0].policy | string | `"none"` | Policy to be set on the bucket [none|download|upload|public] |
| minio.consoleIngress | object | `{"enabled":false,"hosts":["minio-console.mydomain.com"],"path":"/"}` | Minio console ingress |
| minio.consoleIngress.enabled | bool | `false` | Enable ingress |
| minio.consoleIngress.hosts | list | `["minio-console.mydomain.com"]` | Ingress hosts |
| minio.consoleIngress.path | string | `"/"` | Ingress path |
| minio.deploymentUpdate | object | `{"type":"Recreate"}` | Minio deployment update strategy |
| minio.drivesPerNode | int | `1` | Number of drives attached to a node |
| minio.enabled | bool | `false` | Enable minio |
| minio.ingress | object | `{"enabled":true,"hosts":["minio.mydomain.com"],"path":"/"}` | Minio ingress. n8n will use this ingress to access Minio. It's required when binaryData.mode has s3. |
| minio.ingress.enabled | bool | `true` | Enable ingress |
| minio.ingress.hosts | list | `["minio.mydomain.com"]` | Ingress hosts |
| minio.ingress.path | string | `"/"` | Ingress path |
| minio.mode | string | `"standalone"` | Minio mode |
| minio.persistence | object | `{"accessMode":"ReadWriteOnce","annotations":{},"enabled":true,"existingClaim":"","size":"40Gi","storageClass":"","subPath":"","volumeName":""}` | Minio persistence |
| minio.persistence.accessMode | string | `"ReadWriteOnce"` | Minio persistence access mode |
| minio.persistence.annotations | object | `{}` | Minio persistence annotations |
| minio.persistence.enabled | bool | `true` | Enable persistence |
| minio.persistence.existingClaim | string | `""` | Minio persistence existing claim |
| minio.persistence.size | string | `"40Gi"` | Minio persistence size |
| minio.persistence.storageClass | string | `""` | Minio persistence storage class |
| minio.persistence.subPath | string | `""` | Minio persistence sub path |
| minio.persistence.volumeName | string | `""` | Minio persistence volume name |
| minio.policies | list | `[{"name":"n8n-policy","statements":[{"actions":["s3:AbortMultipartUpload","s3:GetObject","s3:DeleteObject","s3:PutObject","s3:ListMultipartUploadParts"],"resources":["arn:aws:s3:::n8n-bucket/*"]},{"actions":["s3:GetBucketLocation","s3:ListBucket","s3:ListBucketMultipartUploads"],"resources":["arn:aws:s3:::n8n-bucket"]}]}]` | Minio policies |
| minio.policies[0] | object | `{"name":"n8n-policy","statements":[{"actions":["s3:AbortMultipartUpload","s3:GetObject","s3:DeleteObject","s3:PutObject","s3:ListMultipartUploadParts"],"resources":["arn:aws:s3:::n8n-bucket/*"]},{"actions":["s3:GetBucketLocation","s3:ListBucket","s3:ListBucketMultipartUploads"],"resources":["arn:aws:s3:::n8n-bucket"]}]}` | n8n policy |
| minio.policies[0].statements[0] | object | `{"actions":["s3:AbortMultipartUpload","s3:GetObject","s3:DeleteObject","s3:PutObject","s3:ListMultipartUploadParts"],"resources":["arn:aws:s3:::n8n-bucket/*"]}` | n8n policy statements |
| minio.pools | int | `1` | Number of expanded MinIO clusters |
| minio.replicas | int | `1` | Number of MinIO containers running |
| minio.resources | object | `{"requests":{"memory":"1Gi"}}` | Minio resources |
| minio.resources.requests | object | `{"memory":"1Gi"}` | Minio requests |
| minio.resources.requests.memory | string | `"1Gi"` | Minio requests memory |
| minio.rootPassword | string | `""` | Minio root password. Length should be at least 8 characters. |
| minio.rootUser | string | `""` | Minio root user. Length should be at least 3 characters. |
| minio.statefulSetUpdate | object | `{"updateStrategy":"Recreate"}` | Minio statefulset update strategy |
| minio.users | list | `[{"accessKey":"n8n-user","policy":"n8n-policy","secretKey":"Change_Me"}]` | Minio users |
| minio.users[0] | object | `{"accessKey":"n8n-user","policy":"n8n-policy","secretKey":"Change_Me"}` | n8n user |
| minio.users[0].policy | string | `"n8n-policy"` | n8n user policy |
| minio.users[0].secretKey | string | `"Change_Me"` | n8n user secret key |
| nameOverride | string | `""` | This is to override the chart name. |
| nodeSelector | object | `{}` | For more information checkout: https://kubernetes.io/docs/concepts/scheduling-eviction/assign-pod-node/#nodeselector |
| nodes | object | `{"builtin":{"enabled":false,"modules":[]},"external":{"allowAll":false,"packages":[],"reinstallMissingPackages":false},"initContainer":{"image":{"pullPolicy":"IfNotPresent","repository":"node","tag":"20-alpine"},"resources":{}}}` | Node configurations for built-in and external npm packages |
| nodes.builtin | object | `{"enabled":false,"modules":[]}` | Enable built-in node functions (e.g., HTTP Request, Code Node, etc.) |
| nodes.builtin.enabled | bool | `false` | Enable built-in modules for the Code node |
| nodes.builtin.modules | list | `[]` | List of built-in Node.js modules to allow in the Code node (e.g., crypto, fs). Use '*' to allow all. |
| nodes.external | object | `{"allowAll":false,"packages":[],"reinstallMissingPackages":false}` | External npm packages to install and allow in the Code node |
| nodes.external.allowAll | bool | `false` | Allow all external npm packages |
| nodes.external.packages | list | `[]` | List of npm package names and versions (e.g., "package-name@1.0.0") |
| nodes.external.reinstallMissingPackages | bool | `false` | Whether to reinstall missing packages. For more information, see https://docs.n8n.io/integrations/community-nodes/troubleshooting/#error-missing-packages |
| nodes.initContainer | object | `{"image":{"pullPolicy":"IfNotPresent","repository":"node","tag":"20-alpine"},"resources":{}}` | Image for the init container to install npm packages |
| nodes.initContainer.image | object | `{"pullPolicy":"IfNotPresent","repository":"node","tag":"20-alpine"}` | Image for the init container to install npm packages |
| nodes.initContainer.image.pullPolicy | string | `"IfNotPresent"` | Pull policy for the init container to install npm packages |
| nodes.initContainer.image.repository | string | `"node"` | Repository for the init container to install npm packages |
| nodes.initContainer.image.tag | string | `"20-alpine"` | Tag for the init container to install npm packages |
| nodes.initContainer.resources | object | `{}` | Resources for the init container |
| npmRegistry | object | `{"customNpmrc":"","enabled":false,"secretKey":"npmrc","secretName":"","url":""}` | Configuration for private npm registry |
| npmRegistry.customNpmrc | string | `""` | Custom .npmrc content (optional, overrides secret if provided) |
| npmRegistry.enabled | bool | `false` | Enable private npm registry |
| npmRegistry.secretKey | string | `"npmrc"` | Key in the secret for the .npmrc content or auth token |
| npmRegistry.secretName | string | `""` | Name of the Kubernetes secret containing npm registry credentials |
| npmRegistry.url | string | `""` | URL of the private npm registry (e.g., https://registry.npmjs.org/) |
| podAnnotations | object | `{}` | This is for setting Kubernetes Annotations to a Pod. For more information checkout: https://kubernetes.io/docs/concepts/overview/working-with-objects/annotations/ |
| podLabels | object | `{}` | This is for setting Kubernetes Labels to a Pod. For more information checkout: https://kubernetes.io/docs/concepts/overview/working-with-objects/labels/ |
| podSecurityContext | object | `{"fsGroup":1000,"fsGroupChangePolicy":"OnRootMismatch"}` | This is for setting Security Context to a Pod. For more information checkout: https://kubernetes.io/docs/tasks/configure-pod-container/security-context/ |
| postgresql | object | `{"architecture":"standalone","auth":{"database":"n8n","password":"","username":""},"enabled":false,"primary":{"persistence":{"enabled":true,"existingClaim":""},"service":{"ports":{"postgresql":5432}}}}` | Bitnami PostgreSQL configuration |
| postgresql.auth.database | string | `"n8n"` | The name of the PostgreSQL database. For more information: https://docs.n8n.io/hosting/configuration/supported-databases-settings/#required-permissions |
| postgresql.enabled | bool | `false` | Enable postgresql |
| readinessProbe | object | `{}` | DEPRECATED: Use main, worker, and webhook blocks readinessProbe field instead. This field will be removed in a future release. |
| redis | object | `{"architecture":"standalone","enabled":false,"master":{"persistence":{"enabled":false}}}` | Bitnami Redis configuration |
| redis.enabled | bool | `false` | Enable redis |
| resources | object | `{}` | DEPRECATED: Use main, worker, and webhook blocks resources fields instead. This field will be removed in a future release. |
| securityContext | object | `{"allowPrivilegeEscalation":false,"capabilities":{"drop":["ALL"]},"privileged":false,"readOnlyRootFilesystem":false,"runAsGroup":1000,"runAsNonRoot":true,"runAsUser":1000}` | This is for setting Security Context to a Container. For more information checkout: https://kubernetes.io/docs/tasks/configure-pod-container/security-context/ |
| sentry.backendDsn | string | `""` | Sentry DSN for backend. |
| sentry.enabled | bool | `false` | Whether sentry is enabled. |
| sentry.externalTaskRunnersDsn | string | `""` | Sentry DSN for external task runners. |
| sentry.frontendDsn | string | `""` | Sentry DSN for frontend. |
| service | object | `{"annotations":{},"enabled":true,"labels":{},"name":"http","port":5678,"type":"ClusterIP"}` | This is for setting up a service more information can be found here: https://kubernetes.io/docs/concepts/services-networking/service/ |
| service.annotations | object | `{}` | Additional service annotations |
| service.enabled | bool | `true` | Whether to enable the service |
| service.labels | object | `{}` | Additional service labels |
| service.name | string | `"http"` | Default Service name |
| service.port | int | `5678` | This sets the ports more information can be found here: https://kubernetes.io/docs/concepts/services-networking/service/#field-spec-ports |
| service.type | string | `"ClusterIP"` | This sets the service type more information can be found here: https://kubernetes.io/docs/concepts/services-networking/service/#publishing-services-service-types |
| serviceAccount | object | `{"annotations":{},"automount":true,"create":true,"name":""}` | This section builds out the service account more information can be found here: https://kubernetes.io/docs/concepts/security/service-accounts/ |
| serviceAccount.annotations | object | `{}` | Annotations to add to the service account |
| serviceAccount.automount | bool | `true` | Automatically mount a ServiceAccount's API credentials? |
| serviceAccount.create | bool | `true` | Specifies whether a service account should be created |
| serviceAccount.name | string | `""` | The name of the service account to use. If not set and create is true, a name is generated using the fullname template |
| serviceMonitor | object | `{"enabled":false,"include":{"apiEndpoints":false,"apiMethodLabel":false,"apiPathLabel":false,"apiStatusCodeLabel":false,"cacheMetrics":false,"credentialTypeLabel":false,"defaultMetrics":true,"messageEventBusMetrics":false,"nodeTypeLabel":false,"queueMetrics":false,"workflowIdLabel":false},"interval":"30s","labels":{"release":"prometheus"},"metricRelabelings":[],"metricsPrefix":"n8n_","namespace":"","targetLabels":[],"timeout":"10s"}` | The service monitor configuration. Please refer to the following link for more information: https://github.com/prometheus-operator/prometheus-operator/blob/main/Documentation/api-reference/api.md |
| serviceMonitor.enabled | bool | `false` | When set true then use a ServiceMonitor to configure scraping |
| serviceMonitor.include | object | `{"apiEndpoints":false,"apiMethodLabel":false,"apiPathLabel":false,"apiStatusCodeLabel":false,"cacheMetrics":false,"credentialTypeLabel":false,"defaultMetrics":true,"messageEventBusMetrics":false,"nodeTypeLabel":false,"queueMetrics":false,"workflowIdLabel":false}` | Whether to include metrics |
| serviceMonitor.include.apiEndpoints | bool | `false` | Whether to include api endpoints |
| serviceMonitor.include.apiMethodLabel | bool | `false` | Whether to include api method label |
| serviceMonitor.include.apiPathLabel | bool | `false` | Whether to include api path label |
| serviceMonitor.include.apiStatusCodeLabel | bool | `false` | Whether to include api status code label |
| serviceMonitor.include.cacheMetrics | bool | `false` | Whether to include cache metrics |
| serviceMonitor.include.credentialTypeLabel | bool | `false` | Whether to include credential type label |
| serviceMonitor.include.defaultMetrics | bool | `true` | Whether to include default metrics |
| serviceMonitor.include.messageEventBusMetrics | bool | `false` | Whether to include message event bus metrics |
| serviceMonitor.include.nodeTypeLabel | bool | `false` | Whether to include node type label |
| serviceMonitor.include.queueMetrics | bool | `false` | Whether to include queue metrics |
| serviceMonitor.include.workflowIdLabel | bool | `false` | Whether to include workflow id label |
| serviceMonitor.interval | string | `"30s"` | Set how frequently Prometheus should scrape |
| serviceMonitor.labels | object | `{"release":"prometheus"}` | Set labels for the ServiceMonitor, use this to define your scrape label for Prometheus Operator |
| serviceMonitor.labels.release | string | `"prometheus"` | default `kube prometheus stack` helm chart serviceMonitor selector label Mostly it's your prometheus helm release name. Please find more information from here: https://github.com/prometheus-operator/prometheus-operator/blob/main/Documentation/platform/troubleshooting.md#troubleshooting-servicemonitor-changes |
| serviceMonitor.metricRelabelings | list | `[]` | Set of rules to relabel your exist metric labels |
| serviceMonitor.metricsPrefix | string | `"n8n_"` | The prefix for the metrics |
| serviceMonitor.namespace | string | `""` | Set the namespace the ServiceMonitor should be deployed. If empty, the ServiceMonitor will be deployed in the same namespace as the n8n chart. |
| serviceMonitor.targetLabels | list | `[]` | Set of labels to transfer on the Kubernetes Service onto the target. |
| serviceMonitor.timeout | string | `"10s"` | Set timeout for scrape |
| strategy | object | `{"rollingUpdate":{"maxSurge":"25%","maxUnavailable":"25%"},"type":"RollingUpdate"}` | This will set the deployment strategy more information can be found here: https://kubernetes.io/docs/concepts/workloads/controllers/deployment/#strategy |
| taskRunners | object | `{"broker":{"address":"127.0.0.1","port":5679},"external":{"autoShutdownTimeout":15,"mainNodeAuthToken":"","nodeOptions":["--max-semi-space-size=16","--max-old-space-size=300"],"port":5680,"resources":{"limits":{"cpu":"2000m","memory":"512Mi"},"requests":{"cpu":"100m","memory":"32Mi"}},"workerNodeAuthToken":""},"maxConcurrency":5,"mode":"internal","taskHeartbeatInterval":30,"taskTimeout":60}` | Task runners mode. Please follow the documentation for more information: https://docs.n8n.io/hosting/configuration/task-runners/ |
| taskRunners.broker | object | `{"address":"127.0.0.1","port":5679}` | The address for the broker of the external task runner |
| taskRunners.broker.address | string | `"127.0.0.1"` | The address for the broker of the external task runner |
| taskRunners.broker.port | int | `5679` | The port for the broker of the external task runner |
| taskRunners.external | object | `{"autoShutdownTimeout":15,"mainNodeAuthToken":"","nodeOptions":["--max-semi-space-size=16","--max-old-space-size=300"],"port":5680,"resources":{"limits":{"cpu":"2000m","memory":"512Mi"},"requests":{"cpu":"100m","memory":"32Mi"}},"workerNodeAuthToken":""}` | The configuration for the external task runner |
| taskRunners.external.autoShutdownTimeout | int | `15` | The auto shutdown timeout for the external task runner in seconds |
| taskRunners.external.mainNodeAuthToken | string | `""` | The auth token for the main node |
| taskRunners.external.nodeOptions | list | `["--max-semi-space-size=16","--max-old-space-size=300"]` | The node options for the external task runner |
| taskRunners.external.port | int | `5680` | The port for the external task runner |
| taskRunners.external.resources | object | `{"limits":{"cpu":"2000m","memory":"512Mi"},"requests":{"cpu":"100m","memory":"32Mi"}}` | The resources for the external task runner |
| taskRunners.external.resources.limits | object | `{"cpu":"2000m","memory":"512Mi"}` | The limits for the external task runner |
| taskRunners.external.resources.limits.cpu | string | `"2000m"` | The CPU limit for the external task runner |
| taskRunners.external.resources.limits.memory | string | `"512Mi"` | The memory limit for the external task runner |
| taskRunners.external.resources.requests | object | `{"cpu":"100m","memory":"32Mi"}` | The resources requests for the external task runner |
| taskRunners.external.resources.requests.cpu | string | `"100m"` | The CPU request for the external task runner |
| taskRunners.external.resources.requests.memory | string | `"32Mi"` | The memory request for the external task runner |
| taskRunners.external.workerNodeAuthToken | string | `""` | The auth token for the worker node |
| taskRunners.maxConcurrency | int | `5` | The maximum concurrency for the task |
| taskRunners.mode | string | `"internal"` | Use `internal` to use internal task runner, or use `external` to have external sidecar task runner. For more information please follow the documentation: https://docs.n8n.io/hosting/configuration/task-runners/#task-runner-modes |
| taskRunners.taskHeartbeatInterval | int | `30` | The heartbeat interval for the task in seconds |
| taskRunners.taskTimeout | int | `60` | The timeout for the task in seconds |
| timezone | string | `"Europe/Berlin"` | For instance, the Schedule node uses it to know at what time the workflow should start. Find you timezone from here: https://momentjs.com/timezone/ |
| tolerations | list | `[]` | For more information checkout: https://kubernetes.io/docs/concepts/scheduling-eviction/taint-and-toleration/ |
| versionNotifications.enabled | bool | `false` | Whether to request notifications about new n8n versions |
| versionNotifications.endpoint | string | `"https://api.n8n.io/api/versions/"` | Endpoint to retrieve n8n version information from |
| versionNotifications.infoUrl | string | `"https://docs.n8n.io/hosting/installation/updating/"` | URL for versions panel to page instructing user on how to update n8n instance |
| volumeMounts | list | `[]` | DEPRECATED: Use main, worker, and webhook blocks volumeMounts fields instead. This field will be removed in a future release. |
| volumes | list | `[]` | DEPRECATED: Use main, worker, and webhook blocks volumes fields instead. This field will be removed in a future release. |
| webhook | object | `{"affinity":{},"allNodes":false,"autoscaling":{"behavior":{},"enabled":false,"maxReplicas":10,"metrics":[{"resource":{"name":"cpu","target":{"averageUtilization":80,"type":"Utilization"}},"type":"Resource"}],"minReplicas":2},"count":2,"extraContainers":[],"extraEnvVars":{},"extraSecretNamesForEnvFrom":[],"hostAliases":[],"initContainers":[],"livenessProbe":{"httpGet":{"path":"/healthz","port":"http"}},"mcp":{"affinity":{},"enabled":true,"extraContainers":[],"extraEnvVars":{},"extraSecretNamesForEnvFrom":[],"hostAliases":[],"initContainers":[],"livenessProbe":{"httpGet":{"path":"/healthz","port":"http"}},"readinessProbe":{"httpGet":{"path":"/healthz/readiness","port":"http"}},"resources":{},"startupProbe":{"exec":{"command":["/bin/sh","-c","ps aux | grep '[n]8n'"]},"failureThreshold":30,"initialDelaySeconds":10,"periodSeconds":5},"volumeMounts":[],"volumes":[]},"mode":"regular","pdb":{"enabled":true,"maxUnavailable":null,"minAvailable":1},"readinessProbe":{"httpGet":{"path":"/healthz/readiness","port":"http"}},"resources":{},"runtimeClassName":"","startupProbe":{"exec":{"command":["/bin/sh","-c","ps aux | grep '[n]8n'"]},"failureThreshold":30,"initialDelaySeconds":10,"periodSeconds":5},"url":"","volumeMounts":[],"volumes":[],"waitMainNodeReady":{"additionalParameters":[],"enabled":false,"healthCheckPath":"/healthz","overwriteSchema":"","overwriteUrl":""}}` | Webhook node configurations |
| webhook.affinity | object | `{}` | Webhook node affinity. For more information checkout: https://kubernetes.io/docs/concepts/scheduling-eviction/assign-pod-node/#affinity-and-anti-affinity |
| webhook.allNodes | bool | `false` | If true, all k8s nodes will deploy exatly one webhook pod |
| webhook.autoscaling | object | `{"behavior":{},"enabled":false,"maxReplicas":10,"metrics":[{"resource":{"name":"cpu","target":{"averageUtilization":80,"type":"Utilization"}},"type":"Resource"}],"minReplicas":2}` | If true, the number of webhooks will be automatically scaled based on default metrics. On default, it will scale based on CPU. Scale by requests can be done by setting a custom metric. For more information can be found here: https://kubernetes.io/docs/tasks/run-application/horizontal-pod-autoscale-walkthrough/ |
| webhook.autoscaling.behavior | object | `{}` | The behavior of the autoscaler. |
| webhook.autoscaling.enabled | bool | `false` | Whether autoscaling is enabled. |
| webhook.autoscaling.maxReplicas | int | `10` | The maximum number of replicas. |
| webhook.autoscaling.metrics | list | `[{"resource":{"name":"cpu","target":{"averageUtilization":80,"type":"Utilization"}},"type":"Resource"}]` | The metrics to use for autoscaling. |
| webhook.autoscaling.minReplicas | int | `2` | The minimum number of replicas. |
| webhook.count | int | `2` | Static number of webhooks. If allNodes or autoscaling is enabled, this value will be ignored. |
| webhook.extraContainers | list | `[]` | Additional containers for the webhook pod |
| webhook.extraEnvVars | object | `{}` | Extra environment variables |
| webhook.extraSecretNamesForEnvFrom | list | `[]` | Extra secrets for environment variables |
| webhook.hostAliases | list | `[]` | Host aliases for the webhook pod. For more information checkout: https://kubernetes.io/docs/tasks/network/customize-hosts-file-for-pods/#adding-additional-entries-with-hostaliases |
| webhook.initContainers | list | `[]` | Additional init containers for the webhook pod |
| webhook.livenessProbe | object | `{"httpGet":{"path":"/healthz","port":"http"}}` | This is to setup the liveness probe for the webhook pod more information can be found here: https://kubernetes.io/docs/tasks/configure-pod-container/configure-liveness-readiness-startup-probes/ |
| webhook.mcp | object | `{"affinity":{},"enabled":true,"extraContainers":[],"extraEnvVars":{},"extraSecretNamesForEnvFrom":[],"hostAliases":[],"initContainers":[],"livenessProbe":{"httpGet":{"path":"/healthz","port":"http"}},"readinessProbe":{"httpGet":{"path":"/healthz/readiness","port":"http"}},"resources":{},"startupProbe":{"exec":{"command":["/bin/sh","-c","ps aux | grep '[n]8n'"]},"failureThreshold":30,"initialDelaySeconds":10,"periodSeconds":5},"volumeMounts":[],"volumes":[]}` | MCP webhook configuration. This is only used when the webhook mode is set to `queue` and the database type is set to `postgresdb`. |
| webhook.mcp.affinity | object | `{}` | Webhook node affinity for the mcp webhook pod. For more information checkout: https://kubernetes.io/docs/concepts/scheduling-eviction/assign-pod-node/#affinity-and-anti-affinity |
| webhook.mcp.enabled | bool | `true` | Whether to enable MCP webhook |
| webhook.mcp.extraContainers | list | `[]` | Additional containers for the mcp webhook pod |
| webhook.mcp.extraEnvVars | object | `{}` | Extra environment variables for the mcp webhook pod |
| webhook.mcp.extraSecretNamesForEnvFrom | list | `[]` | Extra secrets for environment variables for the mcp webhook pod |
| webhook.mcp.hostAliases | list | `[]` | Host aliases for the mcp webhook pod. For more information checkout: https://kubernetes.io/docs/tasks/network/customize-hosts-file-for-pods/#adding-additional-entries-with-hostaliases |
| webhook.mcp.initContainers | list | `[]` | Additional init containers for the mcp webhook pod |
| webhook.mcp.livenessProbe | object | `{"httpGet":{"path":"/healthz","port":"http"}}` | This is to setup the liveness probe for the mcp webhook pod more information can be found here: https://kubernetes.io/docs/tasks/configure-pod-container/configure-liveness-readiness-startup-probes/ |
| webhook.mcp.readinessProbe | object | `{"httpGet":{"path":"/healthz/readiness","port":"http"}}` | This is to setup the readiness probe for the mcp webhook pod more information can be found here: https://kubernetes.io/docs/tasks/configure-pod-container/configure-liveness-readiness-startup-probes/ |
| webhook.mcp.resources | object | `{}` | This block is for setting up the resource management for the mcp webhook pod more information can be found here: https://kubernetes.io/docs/concepts/configuration/manage-resources-containers/ |
| webhook.mcp.startupProbe | object | `{"exec":{"command":["/bin/sh","-c","ps aux | grep '[n]8n'"]},"failureThreshold":30,"initialDelaySeconds":10,"periodSeconds":5}` | This is to setup the startup probe for the mcp webhook pod more information can be found here: https://kubernetes.io/docs/tasks/configure-pod-container/configure-liveness-readiness-startup-probes/ |
| webhook.mcp.volumeMounts | list | `[]` | Additional volumeMounts on the output Deployment definition for the mcp webhook pod |
| webhook.mcp.volumes | list | `[]` | Additional volumes on the output Deployment definition for the mcp webhook pod |
| webhook.mode | string | `"regular"` | Use `regular` to use main node as webhook node, or use `queue` to have webhook nodes |
| webhook.pdb | object | `{"enabled":true,"maxUnavailable":null,"minAvailable":1}` | Whether to enable the PodDisruptionBudget for the webhook pod |
| webhook.pdb.enabled | bool | `true` | Whether to enable the PodDisruptionBudget |
| webhook.pdb.maxUnavailable | string | `nil` | Maximum number of unavailable replicas |
| webhook.pdb.minAvailable | int | `1` | Minimum number of available replicas |
| webhook.readinessProbe | object | `{"httpGet":{"path":"/healthz/readiness","port":"http"}}` | This is to setup the readiness probe for the webhook pod more information can be found here: https://kubernetes.io/docs/tasks/configure-pod-container/configure-liveness-readiness-startup-probes/ |
| webhook.resources | object | `{}` | This block is for setting up the resource management for the webhook pod more information can be found here: https://kubernetes.io/docs/concepts/configuration/manage-resources-containers/ |
| webhook.runtimeClassName | string | `""` | Runtime class name for the webhook pod. For more information checkout: https://kubernetes.io/docs/concepts/containers/runtime-class/ |
| webhook.startupProbe | object | `{"exec":{"command":["/bin/sh","-c","ps aux | grep '[n]8n'"]},"failureThreshold":30,"initialDelaySeconds":10,"periodSeconds":5}` | This is to setup the startup probe for the webhook pod more information can be found here: https://kubernetes.io/docs/tasks/configure-pod-container/configure-liveness-readiness-startup-probes/ |
| webhook.url | string | `""` | Webhook url together with http or https schema |
| webhook.volumeMounts | list | `[]` | Additional volumeMounts on the output Deployment definition. |
| webhook.volumes | list | `[]` | Additional volumes on the output Deployment definition. |
| webhook.waitMainNodeReady | object | `{"additionalParameters":[],"enabled":false,"healthCheckPath":"/healthz","overwriteSchema":"","overwriteUrl":""}` | This is to setup the wait for the webhook node to be ready. |
| webhook.waitMainNodeReady.enabled | bool | `false` | Whether to enable the wait for the webhook node to be ready. |
| webhook.waitMainNodeReady.healthCheckPath | string | `"/healthz"` | The health check path to use for request to the main node. |
| webhook.waitMainNodeReady.overwriteSchema | string | `""` | The schema to use for request to the main node. On default, it will use identify the schema from the main N8N_PROTOCOL environment variable or use http. |
| webhook.waitMainNodeReady.overwriteUrl | string | `""` | The URL to use for request to the main node. On default, it will use service name and port. |
| worker | object | `{"affinity":{},"allNodes":false,"autoscaling":{"behavior":{},"enabled":false,"maxReplicas":10,"metrics":[{"resource":{"name":"memory","target":{"averageUtilization":80,"type":"Utilization"}},"type":"Resource"},{"resource":{"name":"cpu","target":{"averageUtilization":80,"type":"Utilization"}},"type":"Resource"}],"minReplicas":2},"concurrency":10,"count":2,"extraContainers":[],"extraEnvVars":{},"extraSecretNamesForEnvFrom":[],"forceToUseStatefulset":false,"hostAliases":[],"initContainers":[],"livenessProbe":{"httpGet":{"path":"/healthz","port":"http"}},"mode":"regular","pdb":{"enabled":true,"maxUnavailable":null,"minAvailable":1},"persistence":{"accessMode":"ReadWriteOnce","annotations":{"helm.sh/resource-policy":"keep"},"enabled":false,"existingClaim":"","labels":{},"mountPath":"/home/node/.n8n","size":"8Gi","storageClass":"","subPath":"","volumeName":""},"readinessProbe":{"httpGet":{"path":"/healthz/readiness","port":"http"}},"resources":{},"runtimeClassName":"","startupProbe":{"exec":{"command":["/bin/sh","-c","ps aux | grep '[n]8n'"]},"failureThreshold":30,"initialDelaySeconds":10,"periodSeconds":5},"volumeMounts":[],"volumes":[],"waitMainNodeReady":{"additionalParameters":[],"enabled":false,"healthCheckPath":"/healthz","overwriteSchema":"","overwriteUrl":""}}` | Worker node configurations |
| worker.affinity | object | `{}` | Worker node affinity. For more information checkout: https://kubernetes.io/docs/concepts/scheduling-eviction/assign-pod-node/#affinity-and-anti-affinity |
| worker.allNodes | bool | `false` | If true, all k8s nodes will deploy exatly one worker pod |
| worker.autoscaling | object | `{"behavior":{},"enabled":false,"maxReplicas":10,"metrics":[{"resource":{"name":"memory","target":{"averageUtilization":80,"type":"Utilization"}},"type":"Resource"},{"resource":{"name":"cpu","target":{"averageUtilization":80,"type":"Utilization"}},"type":"Resource"}],"minReplicas":2}` | If true, the number of workers will be automatically scaled based on default metrics. On default, it will scale based on CPU and memory. For more information can be found here: https://kubernetes.io/docs/concepts/workloads/autoscaling/ |
| worker.autoscaling.behavior | object | `{}` | The behavior of the autoscaler. |
| worker.autoscaling.enabled | bool | `false` | Whether autoscaling is enabled. |
| worker.autoscaling.maxReplicas | int | `10` | The maximum number of replicas. |
| worker.autoscaling.metrics | list | `[{"resource":{"name":"memory","target":{"averageUtilization":80,"type":"Utilization"}},"type":"Resource"},{"resource":{"name":"cpu","target":{"averageUtilization":80,"type":"Utilization"}},"type":"Resource"}]` | The metrics to use for autoscaling. |
| worker.autoscaling.minReplicas | int | `2` | The minimum number of replicas. |
| worker.concurrency | int | `10` | number of concurrency for each worker |
| worker.count | int | `2` | Static number of workers. If allNodes or autoscaling is enabled, this value will be ignored. |
| worker.extraContainers | list | `[]` | Additional containers for the worker pod |
| worker.extraEnvVars | object | `{}` | Extra environment variables |
| worker.extraSecretNamesForEnvFrom | list | `[]` | Extra secrets for environment variables |
| worker.forceToUseStatefulset | bool | `false` | Force to use statefulset for the worker pod. If true, the worker pod will be created as a statefulset. |
| worker.hostAliases | list | `[]` | Host aliases for the worker pod. For more information checkout: https://kubernetes.io/docs/tasks/network/customize-hosts-file-for-pods/#adding-additional-entries-with-hostaliases |
| worker.initContainers | list | `[]` | Additional init containers for the worker pod |
| worker.livenessProbe | object | `{"httpGet":{"path":"/healthz","port":"http"}}` | This is to setup the liveness probe for the worker pod more information can be found here: https://kubernetes.io/docs/tasks/configure-pod-container/configure-liveness-readiness-startup-probes/ |
| worker.mode | string | `"regular"` | Use `regular` to use main node as executer, or use `queue` to have worker nodes |
| worker.pdb | object | `{"enabled":true,"maxUnavailable":null,"minAvailable":1}` | Whether to enable the PodDisruptionBudget for the worker pod |
| worker.pdb.enabled | bool | `true` | Whether to enable the PodDisruptionBudget |
| worker.pdb.maxUnavailable | string | `nil` | Maximum number of unavailable replicas |
| worker.pdb.minAvailable | int | `1` | Minimum number of available replicas |
| worker.persistence | object | `{"accessMode":"ReadWriteOnce","annotations":{"helm.sh/resource-policy":"keep"},"enabled":false,"existingClaim":"","labels":{},"mountPath":"/home/node/.n8n","size":"8Gi","storageClass":"","subPath":"","volumeName":""}` | Persistence configuration for the worker pod |
| worker.persistence.accessMode | string | `"ReadWriteOnce"` | Access mode for persistence |
| worker.persistence.annotations | object | `{"helm.sh/resource-policy":"keep"}` | Annotations for persistence |
| worker.persistence.enabled | bool | `false` | Whether to enable persistence |
| worker.persistence.existingClaim | string | `""` | Existing claim to use for persistence |
| worker.persistence.labels | object | `{}` | Labels for persistence |
| worker.persistence.mountPath | string | `"/home/node/.n8n"` | Mount path for persistence |
| worker.persistence.size | string | `"8Gi"` | Size for persistence |
| worker.persistence.storageClass | string | `""` | Storage class for persistence |
| worker.persistence.subPath | string | `""` | Sub path for persistence |
| worker.persistence.volumeName | string | `""` | Name of the volume to use for persistence |
| worker.readinessProbe | object | `{"httpGet":{"path":"/healthz/readiness","port":"http"}}` | This is to setup the readiness probe for the worker pod more information can be found here: https://kubernetes.io/docs/tasks/configure-pod-container/configure-liveness-readiness-startup-probes/ |
| worker.resources | object | `{}` | This block is for setting up the resource management for the worker pod more information can be found here: https://kubernetes.io/docs/concepts/configuration/manage-resources-containers/ |
| worker.runtimeClassName | string | `""` | Runtime class name for the worker pod. For more information checkout: https://kubernetes.io/docs/concepts/containers/runtime-class/ |
| worker.startupProbe | object | `{"exec":{"command":["/bin/sh","-c","ps aux | grep '[n]8n'"]},"failureThreshold":30,"initialDelaySeconds":10,"periodSeconds":5}` | This is to setup the startup probe for the worker pod more information can be found here: https://kubernetes.io/docs/tasks/configure-pod-container/configure-liveness-readiness-startup-probes/ |
| worker.volumeMounts | list | `[]` | Additional volumeMounts on the output Deployment definition. |
| worker.volumes | list | `[]` | Additional volumes on the output Deployment definition. |
| worker.waitMainNodeReady | object | `{"additionalParameters":[],"enabled":false,"healthCheckPath":"/healthz","overwriteSchema":"","overwriteUrl":""}` | This is to setup the wait for the main node to be ready. |
| worker.waitMainNodeReady.enabled | bool | `false` | Whether to enable the wait for the main node to be ready. |
| worker.waitMainNodeReady.healthCheckPath | string | `"/healthz"` | The health check path to use for request to the main node. |
| worker.waitMainNodeReady.overwriteSchema | string | `""` | The schema to use for request to the main node. On default, it will use identify the schema from the main N8N_PROTOCOL environment variable or use http. |
| worker.waitMainNodeReady.overwriteUrl | string | `""` | The URL to use for request to the main node. On default, it will use service name and port. |
| workflowHistory | object | `{"enabled":true,"pruneTime":336}` | The workflow history configuration |
| workflowHistory.enabled | bool | `true` | Whether to save workflow history versions |
| workflowHistory.pruneTime | int | `336` | Time (in hours) to keep workflow history versions for. To disable it, use -1 as a value |

**Homepage:** <https://n8n.io>

## Source Code

* <https://github.com/community-charts/helm-charts>
* <https://github.com/n8n-io/n8n>

## Chart Development

Please install unittest helm plugin with `helm plugin install https://github.com/helm-unittest/helm-unittest.git` command and use following command to run helm unit tests.

```console
helm unittest --strict --file 'unittests/**/*.yaml' charts/n8n
```

## Maintainers

| Name | Email | Url |
| ---- | ------ | --- |
| burakince | <burak.ince@linux.org.tr> | <https://www.burakince.com> |
