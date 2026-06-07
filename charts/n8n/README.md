# n8n

![n8n](https://raw.githubusercontent.com/n8n-io/n8n-docs/refs/heads/main/docs/_images/n8n-docs-withWordmark.svg)

A Helm chart for fair-code workflow automation platform with native AI capabilities. Combine visual building with custom code, self-host or cloud, 400+ integrations.

![Version: 1.21.0](https://img.shields.io/badge/Version-1.21.0-informational?style=flat-square) ![Type: application](https://img.shields.io/badge/Type-application-informational?style=flat-square) ![AppVersion: 2.23.4](https://img.shields.io/badge/AppVersion-2.23.4-informational?style=flat-square)

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

> **Tip**:
> n8n now listens on IPv6 addresses by [default](https://docs.n8n.io/hosting/configuration/environment-variables/deployment/) (`N8N_LISTEN_ADDRESS="::"`) due to the gradual deprecation of IPv4.
> If your Kubernetes cluster only supports IPv4, be sure to set `N8N_LISTEN_ADDRESS=0.0.0.0`.
> This will help avoid potential issues with readiness and liveness probes failing.

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
  existingSecretPasswordKey: "my-postgres-password-key"
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
  existingUsernameKey: "my-redis-username-key"
  existingPasswordKey: "my-redis-password-key"
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

## Extra Manifests

The chart supports deploying arbitrary Kubernetes resources alongside n8n using `extraManifests` and `extraTemplateManifests`. Standard chart labels (`helm.sh/chart`, `app.kubernetes.io/*`) are automatically merged into each manifest's `metadata.labels`.

### `extraManifests` — Static Manifests

Accepts a list of Kubernetes resource **objects** or raw **YAML strings**. No Helm templating is evaluated.

#### Object format

```yaml
extraManifests:
  - apiVersion: postgresql.cnpg.io/v1
    kind: Cluster
    metadata:
      name: postgresql
    spec:
      instances: 1
      enablePDB: false
      storage:
        storageClass: csi-disk
        size: 5Gi
  - apiVersion: v1
    kind: ConfigMap
    metadata:
      name: my-extra-config
    data:
      key: value
```

#### String format (supports multi-document YAML with `---`)

```yaml
extraManifests:
  - |
    apiVersion: v1
    kind: ConfigMap
    metadata:
      name: my-string-config
    data:
      key: value
```

### `extraTemplateManifests` — Manifests with Helm Templating

Each item must be a YAML **string** (use `|` block scalar). Helm template functions are evaluated, giving access to `.Release`, `.Values`, `.Chart`, etc.

```yaml
extraTemplateManifests:
  - |
    apiVersion: v1
    kind: ConfigMap
    metadata:
      name: release-info
      namespace: 