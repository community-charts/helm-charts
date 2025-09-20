# cloudflared

![cloudflared](https://raw.githubusercontent.com/cloudflare/color/refs/heads/master/static/thinking/logo.png)

A Helm chart for cloudflare tunnel

![Version: 2.2.0](https://img.shields.io/badge/Version-2.2.0-informational?style=flat-square) ![Type: application](https://img.shields.io/badge/Type-application-informational?style=flat-square) ![AppVersion: 2025.9.0](https://img.shields.io/badge/AppVersion-2025.9.0-informational?style=flat-square)

## Official Documentation

For detailed usage instructions, configuration options, and additional information about the `cloudflared` Helm chart, refer to the [official documentation](https://community-charts.github.io/docs/charts/cloudflared/usage).

## Get Helm Repository Info

```console
helm repo add community-charts https://community-charts.github.io/helm-charts
helm repo update
```

_See [`helm repo`](https://helm.sh/docs/helm/helm_repo/) for command documentation._

## Installing the Chart

> **Tip**: The creation of a Cloudflare account and the setup of a Cloudflared tunnel are prerequisites for using this chart. These steps are not included as part of the chart installation process and must be completed beforehand.

### Prerequisites

1. **Create a Cloudflare Account**
   If you do not yet have a Cloudflare account, please refer to [Cloudflare's official documentation](https://developers.cloudflare.com/fundamentals/setup/account/create-account/) to create one.

2. **Set Up a Cloudflared Tunnel**
   If you already have a Cloudflare account and have added your domain to it, follow the first three steps in [this guide](https://developers.cloudflare.com/cloudflare-one/connections/connect-networks/get-started/create-local-tunnel/) to create a Cloudflared tunnel using the CLI.

3. **Store Tunnel Files**
   After creating your Cloudflared tunnel via CLI, ensure the following files are stored in the `~/.cloudflared` directory under your home directory:
   - Your tunnel credentials JSON file.
   - Your tunnel certificate PEM file.

### Encoding and Configuring Tunnel Files

To configure the chart, encode the required tunnel files using the following commands and set their values accordingly:

1. **Encode the Tunnel Credentials JSON File**
   Use the following command to obtain the base64-encoded version of your tunnel credentials JSON file and set it in the `tunnelSecrets.base64EncodedConfigJsonFile` configuration:

   ```console
   base64 -b 0 -i ~/.cloudflared/*.json
   ```

   If the above command did not work due to OS differences, you can simply use the command below.

   ```console
   cat ~/.cloudflared/*.json | base64
   ```

2. **Encode the Tunnel Certificate PEM File**
   Use the following command to obtain the base64-encoded version of your tunnel certificate PEM file and set it in the `tunnelSecrets.base64EncodedPemFile` configuration:

   ```console
   base64 -b 0 -i ~/.cloudflared/cert.pem
   ```

   If the above command did not work due to OS differences, you can simply use the command below.

   ```console
   cat ~/.cloudflared/cert.pem | base64
   ```

3. **Set the Tunnel Name**
   Pass the name of your tunnel, as created earlier via the Cloudflared CLI, to the `tunnelConfig.name` configuration.

### Setting Credentials to Kubernetes Secrets and working with Existing Secrets

```console
cp ~/.cloudflared/*.json ./credentials.json
kubectl create secret generic config-json-file-secret -n cloudflare --from-file=credentials.json

kubectl create secret generic cert-pem-file-secret -n cloudflare --from-file=~/.cloudflared/cert.pem
```

And use the following configuration rather than base64 versions.

```yaml
tunnelSecrets:
  existingConfigJsonFileSecret:
    name: config-json-file-secret
  existingPemFileSecret:
    name: cert-pem-file-secret
```

### Configuring Ingress

The default ingress configuration is shown below. Replace the placeholder values with your domain and server settings. It is recommended to use a separate `values.yaml` file to manage this configuration.

```yaml
ingress:
  - hostname: example.com # or "*.example.com" (ensure a CNAME record for "*" is defined in your DNS)
    service: http://traefik.kube-system.svc.cluster.local:80

  - service: http_status:404
```

### Installing the Chart

Use the following `helm` command to install or upgrade the chart. Replace the placeholders with your specific values:

```console
helm upgrade --install -f values.yaml [RELEASE_NAME] community-charts/cloudflared -n [NAMESPACE] --create-namespace \
  --set=tunnelSecrets.base64EncodedConfigJsonFile=$(base64 -b 0 -i ~/.cloudflared/*.json) \
  --set=tunnelSecrets.base64EncodedPemFile=$(base64 -b 0 -i ~/.cloudflared/cert.pem) \
  --set=tunnelConfig.name=[TUNNEL_NAME]
```

_See [configuration](#configuration) below._

_See [helm install](https://helm.sh/docs/helm/helm_install/) for command documentation._

> **Tip**: Search all available chart versions using `helm search repo community-charts -l`. Please don't forget to run `helm repo update` before the command.

## Upgrading

This section outlines major updates and breaking changes for each version of the Helm Chart to help you transition smoothly between releases.

---

### Version-Specific Upgrade Notes

#### Upgrading to 2.x.x

##### Breaking Changes

- Your Kubernetes server must be at or later than version v1.21.

## Requirements

Kubernetes: `>=1.21.0-0`

## Uninstall Helm Chart

```console
helm uninstall [RELEASE_NAME]
```

This removes all the Kubernetes components associated with the chart and deletes the release.

_See [helm uninstall](https://helm.sh/docs/helm/helm_uninstall/) for command documentation._

## Upgrading Chart

```console
helm upgrade [RELEASE_NAME] community-charts/cloudflared
```

## Values

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| affinity | object | `{}` | For more information checkout: https://kubernetes.io/docs/concepts/scheduling-eviction/assign-pod-node/#affinity-and-anti-affinity |
| fullnameOverride | string | `""` |  |
| image | object | `{"pullPolicy":"IfNotPresent","repository":"cloudflare/cloudflared","tag":""}` | This sets the container image more information can be found here: https://kubernetes.io/docs/concepts/containers/images/ |
| image.pullPolicy | string | `"IfNotPresent"` | This sets the pull policy for images. |
| image.repository | string | `"cloudflare/cloudflared"` | The docker image repository to use |
| image.tag | string | `""` | Overrides the image tag whose default is the chart appVersion. |
| imagePullSecrets | list | `[]` | This is for the secretes for pulling an image from a private repository more information can be found here: https://kubernetes.io/docs/tasks/configure-pod-container/pull-image-private-registry/ |
| ingress | list | `[{"hostname":"example.com","service":"http://traefik.kube-system.svc.cluster.local:80"},{"service":"http_status:404"}]` | Cloudflare ingress rules. More information can be found here: https://developers.cloudflare.com/cloudflare-one/connections/connect-networks/configure-tunnels/local-management/configuration-file/#how-traffic-is-matched |
| nameOverride | string | `""` | This is to override the chart name. |
| nodeSelector | object | `{"kubernetes.io/os":"linux"}` | For more information checkout: https://kubernetes.io/docs/concepts/scheduling-eviction/assign-pod-node/#nodeselector |
| podAnnotations | object | `{}` | This is for setting Kubernetes Annotations to a Pod. For more information checkout: https://kubernetes.io/docs/concepts/overview/working-with-objects/annotations/ |
| podLabels | object | `{}` | This is for setting Kubernetes Labels to a Pod. For more information checkout: https://kubernetes.io/docs/concepts/overview/working-with-objects/labels/ |
| podSecurityContext | object | `{"fsGroup":65532,"fsGroupChangePolicy":"OnRootMismatch","sysctls":[{"name":"net.ipv4.ping_group_range","value":"0 2147483647"}]}` | This is for setting Security Context to a Pod. For more information checkout: https://kubernetes.io/docs/tasks/configure-pod-container/security-context/ |
| replica | object | `{"allNodes":true,"count":1}` | This will set the replicaset count more information can be found here: https://kubernetes.io/docs/concepts/workloads/controllers/replicaset/ |
| replica.allNodes | bool | `true` | This will use DaemonSet to deploy cloudflared to all nodes |
| replica.count | int | `1` | If previous flag disabled, this will use Deployment to deploy cloudflared only number of following count |
| resources | object | `{}` | This block is for setting up the resource management for the pod more information can be found here: https://kubernetes.io/docs/concepts/configuration/manage-resources-containers/ |
| securityContext | object | `{"allowPrivilegeEscalation":false,"capabilities":{"add":[],"drop":["ALL"]},"privileged":false,"readOnlyRootFilesystem":true,"runAsGroup":65532,"runAsNonRoot":true,"runAsUser":65532}` | This is for setting Security Context to a Container. For more information checkout: https://kubernetes.io/docs/tasks/configure-pod-container/security-context/ |
| serviceAccount | object | `{"annotations":{},"automount":true,"create":true,"name":""}` | This section builds out the service account more information can be found here: https://kubernetes.io/docs/concepts/security/service-accounts/ |
| serviceAccount.annotations | object | `{}` | Annotations to add to the service account |
| serviceAccount.automount | bool | `true` | Automatically mount a ServiceAccount's API credentials? |
| serviceAccount.create | bool | `true` | Specifies whether a service account should be created |
| serviceAccount.name | string | `""` | The name of the service account to use. If not set and create is true, a name is generated using the fullname template |
| terminationGracePeriodSeconds | int | `30` |  |
| tolerations | list | `[{"effect":"NoSchedule","operator":"Exists"}]` | For more information checkout: https://kubernetes.io/docs/concepts/scheduling-eviction/taint-and-toleration/ |
| tunnelConfig | object | `{"autoUpdateFrequency":"24h","connectTimeout":"30s","gracePeriod":"30s","logLevel":"info","metricsUpdateFrequency":"5s","name":"","noAutoUpdate":true,"protocol":"auto","retries":5,"transportLogLevel":"warn","warpRouting":false}` | Please find more configuration from https://developers.cloudflare.com/cloudflare-one/connections/connect-apps/configuration/arguments/ |
| tunnelConfig.name | string | `""` | cloudflared tunnel name |
| tunnelSecrets | object | `{"base64EncodedConfigJsonFile":"","base64EncodedPemFile":"","existingConfigJsonFileSecret":{"key":"credentials.json","name":""},"existingPemFileSecret":{"key":"cert.pem","name":""}}` | This is for setting up the cloudflared tunnel secrets. For more information checkout: https://developers.cloudflare.com/cloudflare-one/connections/connect-networks/do-more-with-tunnels/local-management/create-local-tunnel/ |
| tunnelSecrets.base64EncodedConfigJsonFile | string | `""` | This is for cloudflared tunnel configuration JSON file. |
| tunnelSecrets.base64EncodedPemFile | string | `""` | This is for cloudflared tunnel certificate PEM file. |
| tunnelSecrets.existingConfigJsonFileSecret | object | `{"key":"credentials.json","name":""}` | This is for setting up the existing secret for the cloudflared tunnel configuration JSON file. If not set, the base64EncodedConfigJsonFile will be used. |
| tunnelSecrets.existingConfigJsonFileSecret.key | string | `"credentials.json"` | This is the key of the configuration JSON file in the existing secret. |
| tunnelSecrets.existingConfigJsonFileSecret.name | string | `""` | This is the name of the existing secret. |
| tunnelSecrets.existingPemFileSecret | object | `{"key":"cert.pem","name":""}` | This is for setting up the existing secret for the cloudflared tunnel certificate PEM file. If not set, the base64EncodedPemFile will be used. |
| tunnelSecrets.existingPemFileSecret.key | string | `"cert.pem"` | This is the key of the certificate PEM file in the existing secret. |
| tunnelSecrets.existingPemFileSecret.name | string | `""` | This is the name of the existing secret. |
| updateStrategy.rollingUpdate.maxUnavailable | int | `1` |  |
| updateStrategy.type | string | `"RollingUpdate"` |  |

**Homepage:** <https://github.com/cloudflare/cloudflared>

## Source Code

* <https://github.com/community-charts/helm-charts>
* <https://github.com/cloudflare/cloudflared>

## Chart Development

Please install unittest helm plugin with `helm plugin install https://github.com/helm-unittest/helm-unittest.git` command and use following command to run helm unit tests.

```console
helm unittest --strict --file 'unittests/**/*.yaml' charts/cloudflared
```

## Maintainers

| Name | Email | Url |
| ---- | ------ | --- |
| burakince | <burak.ince@linux.org.tr> | <https://www.burakince.com> |
