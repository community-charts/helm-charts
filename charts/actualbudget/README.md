# actualbudget

![actualbudget](https://actualbudget.org/img/actual.png)

A local-first personal finance app

![Version: 1.8.0](https://img.shields.io/badge/Version-1.8.0-informational?style=flat-square) ![Type: application](https://img.shields.io/badge/Type-application-informational?style=flat-square) ![AppVersion: 25.7.1](https://img.shields.io/badge/AppVersion-25.7.1-informational?style=flat-square)

## Official Documentation

For detailed usage instructions, configuration options, and additional information about the `actualbudget` Helm chart, refer to the [official documentation](https://community-charts.github.io/docs/charts/actualbudget/usage).

## Get Helm Repository Info

```console
helm repo add community-charts https://community-charts.github.io/helm-charts
helm repo update
```

_See [`helm repo`](https://helm.sh/docs/helm/helm_repo/) for command documentation._

## Installing the Chart

```console
helm install [RELEASE_NAME] community-charts/actualbudget
```

_See [configuration](#configuration) below._

_See [helm install](https://helm.sh/docs/helm/helm_install/) for command documentation._

> **Tip**: Search all available chart versions using `helm search repo community-charts -l`. Please don't forget to run `helm repo update` before the command.

## Full Example

This configuration mounts a PersistentVolumeClaim (`actualbudget-volume`) to `/data`, where server files (`/data/server-files`) and user files (`/data/user-files`) are stored. The `/data` folder persists across pod restarts, ensuring data retention.

```yaml
strategy:
  type: Recreate

files:
  server: /data/server-files
  user: /data/user-files

ingress:
  enabled: true
  hosts:
    - host: actualbudget.local
      paths:
        - path: /
          pathType: ImplementationSpecific

persistence:
  enabled: true
  existingClaim: actualbudget-volume
```

## Configuring OpenID Connect

The `actualbudget` Helm chart supports OpenID Connect (OIDC) for authentication with providers like Keycloak or Auth0. Please find full tested providers from [here](https://actualbudget.org/docs/config/oauth-auth/#tested-providers). Configure the `login.openid` settings in `values.yaml` or a `secrets.yaml` file to enable it. See the [Values](#values) table for all options, including `login.openid.tokenExpiration` (valid values: `"never"`, `"openid-provider"`, or seconds like `3600`).

### Example Configuration

To use OpenID with a Kubernetes Secret for sensitive data:

1. **Create a Secret**:

```bash
kubectl create secret generic actualbudget-openid-secret \
  --from-literal=clientId=actualbudget-client \
  --from-literal=clientSecret=your-client-secret
```

2. **Update `values.yaml`**:

```yaml
login:
  method: "openid"
  openid:
    enforce: true
    providerName: "Keycloak"
    discoveryUrl: "https://keycloak.example.com/auth/realms/my-realm/.well-known/openid-configuration"
    tokenExpiration: 3600
    existingSecret:
      name: "actualbudget-openid-secret"
      clientIdKey: "clientId"
      clientSecretKey: "clientSecret"
```

## Upgrading

This section provides information about significant updates and breaking changes in each version of the Helm Chart to facilitate a smooth upgrade process.

---

### Version-Specific Upgrade Notes

#### Upgrading to Version 1.5.x

##### Deprecation Notice

- The `login.openid.dicovertUrl` field has been deprecated.

##### Required Action

Please update your configuration to use the `login.openid.discoveryUrl` field in place of the deprecated one.

## Requirements

Kubernetes: `>=1.16.0-0`

## Uninstall Helm Chart

```console
helm uninstall [RELEASE_NAME]
```

This removes all the Kubernetes components associated with the chart and deletes the release.

_See [helm uninstall](https://helm.sh/docs/helm/helm_uninstall/) for command documentation._

## Upgrading Chart

```console
helm upgrade [RELEASE_NAME] community-charts/actualbudget
```

## Values

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| affinity | object | `{}` | For more information checkout: https://kubernetes.io/docs/concepts/scheduling-eviction/assign-pod-node/#affinity-and-anti-affinity |
| extraContainers | list | `[]` | Additional containers (sidecars) on the output Deployment definition. |
| extraEnvVars | object | `{}` | Extra environment variables. For more information checkout: https://actualbudget.org/docs/config/ |
| files.dataDirectory | string | `"/data"` | This is where the server stores the budget data files. For more information checkout: https://actualbudget.org/docs/config/#actual_data_dir |
| files.server | string | `"/data/server-files"` | The server will put an account.sqlite file in this directory, which will contain the (hashed) server password, a list of all the budget files the server knows about, and the active session token (along with anything else the server may want to store in the future). For more information checkout: https://actualbudget.org/docs/config/#serverfiles |
| files.user | string | `"/data/user-files"` | The server will put all the budget files in this directory as binary blobs. For more information checkout: https://actualbudget.org/docs/config/#userfiles |
| fullnameOverride | string | `""` |  |
| image.pullPolicy | string | `"IfNotPresent"` | This sets the pull policy for images. |
| image.repository | string | `"actualbudget/actual-server"` | The docker image repository to use |
| image.tag | string | `""` | Overrides the image tag whose default is the chart appVersion. |
| imagePullSecrets | list | `[]` | This is for the secretes for pulling an image from a private repository more information can be found here: https://kubernetes.io/docs/tasks/configure-pod-container/pull-image-private-registry/ |
| ingress | object | `{"annotations":{},"className":"","enabled":false,"hosts":[{"host":"actualbudget.local","paths":[{"path":"/","pathType":"ImplementationSpecific"}]}],"tls":[]}` | This block is for setting up the ingress for more information can be found here: https://kubernetes.io/docs/concepts/services-networking/ingress/ |
| initContainers | list | `[]` | Additional init containers on the output Deployment definition. |
| livenessProbe | object | `{"httpGet":{"path":"/","port":"http"}}` | This is to setup the liveness probe more information can be found here: https://kubernetes.io/docs/tasks/configure-pod-container/configure-liveness-readiness-startup-probes/ |
| login | object | `{"allowedLoginMethods":["password","header","openid"],"method":"password","openid":{"authMethod":"openid","authorizationEndpoint":"","clientId":"","clientSecret":"","dicovertUrl":"","discoveryUrl":"","enforce":true,"existingSecret":{"clientIdKey":"","clientSecretKey":"","name":""},"providerName":"OpenID Connect","tokenEndpoint":"","tokenExpiration":"never","userInfoEndpoint":""},"skipSSLVerification":false}` | This is for setting up the login for the server. For more information checkout: https://actualbudget.org/docs/config/#loginmethod |
| login.allowedLoginMethods | list | `["password","header","openid"]` | This is the allowed login methods. |
| login.method | string | `"password"` | This is the method to use for login. Possible values are "password" or "header" or "openid". |
| login.openid | object | `{"authMethod":"openid","authorizationEndpoint":"","clientId":"","clientSecret":"","dicovertUrl":"","discoveryUrl":"","enforce":true,"existingSecret":{"clientIdKey":"","clientSecretKey":"","name":""},"providerName":"OpenID Connect","tokenEndpoint":"","tokenExpiration":"never","userInfoEndpoint":""}` | This is for setting up the openid login. For more information checkout: https://actualbudget.org/docs/config/oauth-auth/ |
| login.openid.authMethod | string | `"openid"` | Tells the server whether it should use the OpenID (OIDC) or a more general OAuth2 flow. For more information checkout: https://actualbudget.org/docs/config/oauth-auth/#actual_openid_auth_method |
| login.openid.authorizationEndpoint | string | `""` | This is the authorization endpoint for the openid provider. For more information checkout: https://actualbudget.org/docs/config/oauth-auth/#actual_openid_authorization_endpoint |
| login.openid.clientId | string | `""` | This is the client id for the openid provider. If not set and existingSecret is set, the client id will be read from the existing secret. For more information checkout: https://actualbudget.org/docs/config/oauth-auth/#actual_openid_client_id |
| login.openid.clientSecret | string | `""` | This is the client secret for the openid provider. If not set and existingSecret is set, the client secret will be read from the existing secret. For more information checkout: https://actualbudget.org/docs/config/oauth-auth/#actual_openid_client_secret |
| login.openid.dicovertUrl | string | `""` | Deprecated: Please use discoveryUrl instead. This field will be removed in next major version. |
| login.openid.discoveryUrl | string | `""` | This is the discovery url for the openid provider. For more information checkout: https://actualbudget.org/docs/config/oauth-auth/#actual_openid_discovery_url |
| login.openid.enforce | bool | `true` | This is for setting the enforce for the openid login. For more information checkout: https://actualbudget.org/docs/config/oauth-auth/#actual_openid_enforce |
| login.openid.existingSecret | object | `{"clientIdKey":"","clientSecretKey":"","name":""}` | This is for setting up the existing secret for the openid provider. |
| login.openid.existingSecret.clientIdKey | string | `""` | This is the key of the client id in the existing secret. |
| login.openid.existingSecret.clientSecretKey | string | `""` | This is the key of the client secret in the existing secret. |
| login.openid.existingSecret.name | string | `""` | This is the name of the existing secret. |
| login.openid.providerName | string | `"OpenID Connect"` | This is the provider name for the openid provider. |
| login.openid.tokenEndpoint | string | `""` | This is the token endpoint for the openid provider. For more information checkout: https://actualbudget.org/docs/config/oauth-auth/#actual_openid_token_endpoint |
| login.openid.tokenExpiration | string | `"never"` | Controls how access tokens expire. For more information checkout: https://actualbudget.org/docs/config/oauth-auth/#actual_token_expiration |
| login.openid.userInfoEndpoint | string | `""` | This is the user info endpoint for the openid provider. For more information checkout: https://actualbudget.org/docs/config/oauth-auth/#actual_openid_userinfo_endpoint |
| login.skipSSLVerification | bool | `false` | This is for skipping the SSL verification for the login. |
| nameOverride | string | `""` | This is to override the chart name. |
| nodeSelector | object | `{}` | For more information checkout: https://kubernetes.io/docs/concepts/scheduling-eviction/assign-pod-node/#nodeselector |
| persistence | object | `{"accessModes":["ReadWriteOnce"],"annotations":{},"enabled":false,"existingClaim":"","size":"10Gi","storageClass":"","subPath":"","volumeMode":""}` | This is to setup the persistence for the pod more information can be found here: https://kubernetes.io/docs/concepts/storage/persistent-volumes/ |
| persistence.accessModes | list | `["ReadWriteOnce"]` | Actual Budget persistence access mode |
| persistence.annotations | object | `{}` | Actual Budget persistence annotations |
| persistence.enabled | bool | `false` | Enable persistence |
| persistence.existingClaim | string | `""` | Actual Budget persistence existing claim |
| persistence.size | string | `"10Gi"` | Actual Budget persistence size |
| persistence.storageClass | string | `""` | Actual Budget persistence storage class |
| persistence.subPath | string | `""` | Actual Budget persistence sub path |
| persistence.volumeMode | string | `""` | Actual Budget persistence volume mode |
| podAnnotations | object | `{}` | This is for setting Kubernetes Annotations to a Pod. For more information checkout: https://kubernetes.io/docs/concepts/overview/working-with-objects/annotations/ |
| podLabels | object | `{}` | This is for setting Kubernetes Labels to a Pod. For more information checkout: https://kubernetes.io/docs/concepts/overview/working-with-objects/labels/ |
| podSecurityContext | object | `{"fsGroup":1001,"fsGroupChangePolicy":"OnRootMismatch"}` | This is for setting Security Context to a Pod. For more information checkout: https://kubernetes.io/docs/tasks/configure-pod-container/security-context/ |
| readinessProbe | object | `{"httpGet":{"path":"/","port":"http"}}` | This is to setup the readiness probe more information can be found here: https://kubernetes.io/docs/tasks/configure-pod-container/configure-liveness-readiness-startup-probes/ |
| replicaCount | int | `1` | This will set the replicaset count more information can be found here: https://kubernetes.io/docs/concepts/workloads/controllers/replicaset/ |
| resources | object | `{}` | This block is for setting up the resource management for the pod more information can be found here: https://kubernetes.io/docs/concepts/configuration/manage-resources-containers/ |
| securityContext | object | `{"allowPrivilegeEscalation":false,"capabilities":{"drop":["ALL"]},"privileged":false,"readOnlyRootFilesystem":false,"runAsGroup":1001,"runAsNonRoot":true,"runAsUser":1001}` | This is for setting Security Context to a Container. For more information checkout: https://kubernetes.io/docs/tasks/configure-pod-container/security-context/ |
| service | object | `{"annotations":{},"name":"http","port":5006,"type":"ClusterIP"}` | This is for setting up a service more information can be found here: https://kubernetes.io/docs/concepts/services-networking/service/ |
| service.annotations | object | `{}` | Additional service annotations |
| service.name | string | `"http"` | Default Service name |
| service.port | int | `5006` | This sets the ports more information can be found here: https://kubernetes.io/docs/concepts/services-networking/service/#field-spec-ports |
| service.type | string | `"ClusterIP"` | This sets the service type more information can be found here: https://kubernetes.io/docs/concepts/services-networking/service/#publishing-services-service-types |
| serviceAccount | object | `{"annotations":{},"automount":true,"create":true,"name":""}` | This section builds out the service account more information can be found here: https://kubernetes.io/docs/concepts/security/service-accounts/ |
| serviceAccount.annotations | object | `{}` | Annotations to add to the service account |
| serviceAccount.automount | bool | `true` | Automatically mount a ServiceAccount's API credentials? |
| serviceAccount.create | bool | `true` | Specifies whether a service account should be created |
| serviceAccount.name | string | `""` | The name of the service account to use. If not set and create is true, a name is generated using the fullname template |
| strategy | object | `{"rollingUpdate":{"maxSurge":"100%","maxUnavailable":0},"type":"RollingUpdate"}` | This will set the deployment strategy more information can be found here: https://kubernetes.io/docs/concepts/workloads/controllers/deployment/#strategy |
| tolerations | list | `[]` | For more information checkout: https://kubernetes.io/docs/concepts/scheduling-eviction/taint-and-toleration/ |
| upload | object | `{"fileSizeLimitMB":20,"fileSizeSyncLimitMB":20,"syncEncryptedFileSizeLimitMB":50}` | This is for setting up the upload limits for the server. For more information checkout: https://github.com/actualbudget/actual/blob/f413fa03ae8f3bffc9c9c8b19885eb9f0f252acc/packages/sync-server/src/load-config.js#L83-L87 |
| upload.fileSizeLimitMB | int | `20` | This is the maximum size of a file that can be uploaded to the server in megabytes. |
| upload.fileSizeSyncLimitMB | int | `20` | This is the maximum size of a file that can be uploaded to the server in megabytes. |
| upload.syncEncryptedFileSizeLimitMB | int | `50` | This is the maximum size of an encrypted file that can be uploaded to the server in megabytes. |
| volumeMounts | list | `[]` | Additional volumeMounts on the output Deployment definition. |
| volumes | list | `[]` | Additional volumes on the output Deployment definition. |

**Homepage:** <https://actualbudget.org/>

## Source Code

* <https://github.com/community-charts/helm-charts>
* <https://github.com/actualbudget/actual>

## Chart Development

Please install unittest helm plugin with `helm plugin install https://github.com/helm-unittest/helm-unittest.git` command and use following command to run helm unit tests.

```console
helm unittest --strict --file 'unittests/**/*.yaml' charts/actualbudget
```

## Maintainers

| Name | Email | Url |
| ---- | ------ | --- |
| burakince | <burak.ince@linux.org.tr> | <https://www.burakince.com> |
