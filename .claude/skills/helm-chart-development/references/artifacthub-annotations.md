# ArtifactHub Annotations Reference

All supported `artifacthub.io/` annotations for Helm charts (used in `Chart.yaml`):

| Annotation | Format | Description |
|---|---|---|
| `artifacthub.io/alternativeName` | string | Alternate package name for improved search ranking (e.g. `postgres` for `postgresql`) |
| `artifacthub.io/category` | string | Package category: `ai-machine-learning`, `database`, `integration-delivery`, `monitoring-logging`, `networking`, `security`, `storage`, `streaming-messaging`, or `skip-prediction` |
| `artifacthub.io/changes` | YAML string | Changelog for the release. Each entry has `kind` (`added`, `changed`, `deprecated`, `removed`, `fixed`, `security`) and `description`. Optional `links` list with `name`/`url`. |
| `artifacthub.io/containsSecurityUpdates` | `"true"`/`"false"` | Flags releases that contain security patches |
| `artifacthub.io/crds` | YAML string | Lists CRDs provided by the chart. Each entry: `kind`, `version`, `name`, `displayName`, `description` |
| `artifacthub.io/crdsExamples` | YAML string | Example Kubernetes manifests for each CRD |
| `artifacthub.io/images` | YAML string | Container images used by the chart. Each entry: `name`, `image`, optional `platforms`, optional `whitelisted` |
| `artifacthub.io/license` | string | SPDX license identifier (e.g. `MIT`, `Apache-2.0`) |
| `artifacthub.io/links` | YAML string | Named resource links. Each entry: `name`, `url`. Name `support` has special meaning on ArtifactHub. |
| `artifacthub.io/maintainers` | YAML string | Maintainer display info. Each entry: `name`, `email` |
| `artifacthub.io/operator` | `"true"`/`"false"` | Marks the chart as a Kubernetes operator |
| `artifacthub.io/operatorCapabilities` | string | Operator capability level: `Basic Install`, `Seamless Upgrades`, `Full Lifecycle`, `Deep Insights`, `Auto Pilot` |
| `artifacthub.io/prerelease` | `"true"`/`"false"` | Marks this version as a pre-release |
| `artifacthub.io/recommendations` | YAML string | Related packages. Each entry: `url` pointing to an ArtifactHub package page |
| `artifacthub.io/screenshots` | YAML string | Visual documentation. Each entry: `title`, `url` |
| `artifacthub.io/signKey` | YAML string | Chart signing info. Fields: `fingerprint`, `url` (public key location) |

## changes annotation format

```yaml
artifacthub.io/changes: |
  - kind: added
    description: Support for custom annotations on all resources
    links:
      - name: PR
        url: https://github.com/org/repo/pull/42
  - kind: fixed
    description: Health check path now respects staticPrefix value
  - kind: security
    description: Bumped base image to address CVE-2024-1234
```

Valid `kind` values: `added`, `changed`, `deprecated`, `removed`, `fixed`, `security`

## images annotation format

```yaml
artifacthub.io/images: |
  - name: myapp
    image: myorg/myapp:2.3.1
    platforms:
      - linux/amd64
      - linux/arm64
  - name: init-container
    image: busybox:1.36
    whitelisted: true
```

## crds annotation format

```yaml
artifacthub.io/crds: |
  - kind: MyResource
    version: v1alpha1
    name: myresources.example.com
    displayName: My Resource
    description: Manages MyResource instances
artifacthub.io/crdsExamples: |
  - apiVersion: example.com/v1alpha1
    kind: MyResource
    metadata:
      name: example
    spec:
      replicas: 1
```
