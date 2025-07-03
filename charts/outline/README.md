# outline

![outline](https://avatars.githubusercontent.com/u/1765001?s=200&v=4)

A Helm chart for the fastest knowledge base for growing teams. Beautiful, realtime collaborative, feature packed, and markdown compatible.

![Version: 0.4.0](https://img.shields.io/badge/Version-0.4.0-informational?style=flat-square) ![Type: application](https://img.shields.io/badge/Type-application-informational?style=flat-square) ![AppVersion: 0.84.0](https://img.shields.io/badge/AppVersion-0.84.0-informational?style=flat-square)

## Official Documentation

For detailed usage instructions, configuration options, and additional information about the `outline` Helm chart, refer to the [official documentation](https://community-charts.github.io/docs/charts/outline/usage).

## Get Helm Repository Info

```console
helm repo add community-charts https://community-charts.github.io/helm-charts
helm repo update
```

_See [`helm repo`](https://helm.sh/docs/helm/helm_repo/) for command documentation._

## Installing the Chart

```console
helm install [RELEASE_NAME] community-charts/outline
```

_See [configuration](#configuration) below._

_See [helm install](https://helm.sh/docs/helm/helm_install/) for command documentation._

> **Tip**: Search all available chart versions using `helm search repo community-charts -l`. Please don't forget to run `helm repo update` before the command.

## Full Example

If you prefer to use self-signed certificate, please install `cert-manager` and `selfsigned-issuer` in your cluster. You can install cert-manager with following command:

```console
helm install cert-manager jetstack/cert-manager --namespace cert-manager --create-namespace --version v1.17.0 --set crds.enabled=true
```

Please find more information about cert-manager [here](https://cert-manager.io/docs/installation/).

And you can create selfsigned-issuer with following command:

```console
echo "apiVersion: cert-manager.io/v1
kind: Issuer
metadata:
  name: selfsigned-issuer
spec:
  selfSigned: {}" | kubectl apply -f -
```

Please find more information about selfsigned-issuer [here](https://cert-manager.io/docs/configuration/selfsigned/).

Now you can use the following values.yaml file to install the chart. Please don't forget to import selfsigned certificate to your computer and change trust level of the certificate. Or you can use a valid certificate from your certificate authority.

```yaml
strategy:
  type: Recreate

auth:
  gitea:
    enabled: true
    clientId: "123456ab-d789-12ef-g345-f6789ab12cd3"
    clientSecret: "gto_a1b2c3d4e5f6g7h8i9j0k1l2m3n4o5p6q7r8s9t0u1v2w3x4y5z6"
    baseUrl: "https://gitea.example.com"

ingress:
  enabled: true
  annotations:
    cert-manager.io/cluster-issuer: "selfsigned-issuer"
  hosts:
    - host: "outline.example.com"
      paths:
        - path: /
          pathType: ImplementationSpecific
  tls:
    - secretName: "outline-selfsigned-cert-tls"
      hosts:
        - "outline.example.com"

web:
  forceHttps: false
  skipSSLVerification: true

externalRedis:
  host: "redis.example.com"
  existingSecret: "external-redis-secret"

externalPostgresql:
  host: "postgresql.example.com"
  database: "outline"
  existingSecret: "external-postgresql-secret"

fileStorage:
  mode: "local"

  local:
    persistence:
      enabled: true
      storageClass: "longhorn-static"

resources:
  requests:
    cpu: "1000m"
    memory: "512Mi"
  limits:
    cpu: "2000m"
    memory: "2Gi"
```

## Authentication Methods

Outline supports multiple authentication methods. Here are examples for each:

### Google Auth

This is for setting up the Google authentication. More information about google can be found here: https://docs.getoutline.com/s/hosting/doc/google-hOuvtCmTqQ

```yaml
auth:
  google:
    enabled: true
    clientId: "your-client-id"
    clientSecret: "your-client-secret"
```

### Azure Auth

This is for setting up the Azure authentication. More information about azure can be found here: https://docs.getoutline.com/s/hosting/doc/microsoft-entra-UVz6jsIOcv

```yaml
auth:
  azure:
    enabled: true
    clientId: "your-client-id"
    clientSecret: "your-client-secret"
    resourceAppId: "optional-resource-app-id"  # Optional
    tenantId: "optional-tenant-id"  # Optional
```

### OIDC Auth

This is for setting up the OIDC authentication. More information about oidc can be found here: https://docs.getoutline.com/s/hosting/doc/oidc-8CPBm6uC0I

```yaml
auth:
  oidc:
    enabled: true
    clientId: "your-client-id"
    clientSecret: "your-client-secret"
    authUri: "https://your-auth-server/auth"
    tokenUri: "https://your-auth-server/token"
    userInfoUri: "https://your-auth-server/userinfo"
    usernameClaim: "preferred_username"
    displayName: "OpenID Connect"
    scopes:
      - openid
      - profile
      - email
```

### Slack Auth

This is for setting up the Slack authentication. More information about slack can be found here: https://docs.getoutline.com/s/hosting/doc/slack-sgMujR8J9J

```yaml
auth:
  slack:
    enabled: true
    clientId: "your-client-id"
    clientSecret: "your-client-secret"
```

### GitHub Auth

This is for setting up the GitHub authentication. More information about github can be found here: https://docs.getoutline.com/s/hosting/doc/github-GchT3NNxI9

```yaml
auth:
  github:
    enabled: true
    clientId: "your-client-id"
    clientSecret: "your-client-secret"
    appName: "your-app-name"  # Optional
    appId: "your-app-id"  # Optional
    appPrivateKey: "your-private-key"  # Optional
```

### GitLab Auth

This is for setting up the GitLab authentication. More information about gitlab can be found here: https://docs.gitlab.com/ee/integration/oauth_provider.html

```yaml
auth:
  gitlab:
    enabled: true
    clientId: "your-client-id"
    clientSecret: "your-client-secret"
    baseUrl: "https://gitlab.com"  # Optional, for self-hosted instances
```

### Gitea Auth

This is for setting up the Gitea authentication. More information about gitea can be found here: https://docs.gitea.com/development/oauth2-provider#endpoints

```yaml
auth:
  gitea:
    enabled: true
    clientId: "your-client-id"
    clientSecret: "your-client-secret"
    baseUrl: "https://gitea.com"  # Optional, for self-hosted instances
```

### Keycloak Auth

This is for setting up the Keycloak authentication. More information about keycloak can be found here: https://www.keycloak.org/docs/latest/server_admin/index.html#_oauth2-service-provider-configuration

```yaml
auth:
  keycloak:
    enabled: true
    clientId: "your-client-id"
    clientSecret: "your-client-secret"
    realm: "your-realm"
```

### Discord Auth

This is for setting up the Discord authentication. More information about discord can be found here: https://docs.getoutline.com/s/hosting/doc/discord-g4JdWFFub6

```yaml
auth:
  discord:
    enabled: true
    clientId: "your-client-id"
    clientSecret: "your-client-secret"
    serverId: "your-server-id"
    serverRoles: []
```

### Auth0 Auth

This is for setting up the Auth0 authentication. More information about auth0 can be found here: https://auth0.com/docs/get-started/applications/configure-applications-with-oidc-discovery

```yaml
auth:
  auth0:
    enabled: true
    clientId: "your-client-id"
    clientSecret: "your-client-secret"
    baseUrl: "https://your-auth0-server"
```

## Storage Configuration

### Local File Storage

```yaml
fileStorage:
  mode: local
  local:
    rootDir: /var/lib/outline/data
    persistence:
      enabled: true
      size: 8Gi
```

### S3 Compatible Storage

```yaml
fileStorage:
  mode: s3

  s3:
    bucket: outline
    region: us-east-1
    baseUrl: "https://your-s3-compatible-endpoint"
    accessKeyId: "your-access-key"
    secretAccessKey: "your-secret-key"
    forcePathStyle: true
    acl: private
```

### Using MinIO

```yaml
fileStorage:
  mode: s3

minio:
  enabled: true
  rootUser: admin
  rootPassword: strongpassword

  persistence:
    enabled: true
    size: 40Gi
```

## Database Configuration

### Using Built-in PostgreSQL

```yaml
postgresql:
  enabled: true

  auth:
    username: outline
    password: strongpassword
    database: outline

  primary:
    persistence:
      enabled: true
```

### Using External PostgreSQL

```yaml
postgresql:
  enabled: false

externalPostgresql:
  host: "your-postgresql-host"
  port: 5432
  database: outline
  username: outline
  password: strongpassword
  # Or use existing secret:
  existingSecret: "your-secret-name"
```

## Redis Configuration

### Using Built-in Redis

```yaml
redis:
  enabled: true
  architecture: standalone
  master:
    persistence:
      enabled: true
```

### Using External Redis

```yaml
redis:
  enabled: false

externalRedis:
  host: "your-redis-host"
  port: 6379
  username: "default"
  password: "your-password"
  # Or use existing secret:
  existingSecret: "your-secret-name"
```

## SMTP Configuration

```yaml
smtp:
  host: "smtp.example.com"
  port: 587
  username: "your-username"
  password: "your-password"
  fromEmail: "outline@example.com"
  replyEmail: "no-reply@example.com"
  secure: true
```

## Ingress Configuration

```yaml
ingress:
  enabled: true
  className: nginx
  annotations:
    kubernetes.io/ingress.class: nginx
    cert-manager.io/cluster-issuer: letsencrypt-prod

  hosts:
    - host: outline.example.com
      paths:
        - path: /
          pathType: ImplementationSpecific

  tls:
    - secretName: outline-tls
      hosts:
        - outline.example.com
```

## Resource Management

```yaml
resources:
  requests:
    cpu: 1000m
    memory: 512Mi
  limits:
    cpu: 2000m
    memory: 2Gi
```

## Health Checks

```yaml
livenessProbe:
  httpGet:
    path: /_health
    port: http
  initialDelaySeconds: 10
  periodSeconds: 30
  timeoutSeconds: 3
  failureThreshold: 5

readinessProbe:
  httpGet:
    path: /_health
    port: http
  initialDelaySeconds: 10
  periodSeconds: 30
  timeoutSeconds: 3
  failureThreshold: 5
```

## Requirements

Kubernetes: `>=1.23.0-0`

| Repository | Name | Version |
|------------|------|---------|
| https://charts.bitnami.com/bitnami | postgresql | 16.7.2 |
| https://charts.bitnami.com/bitnami | redis | 21.0.2 |
| https://charts.min.io/ | minio | 5.4.0 |

## Uninstall Helm Chart

```console
helm uninstall [RELEASE_NAME]
```

This removes all the Kubernetes components associated with the chart and deletes the release.

_See [helm uninstall](https://helm.sh/docs/helm/helm_uninstall/) for command documentation._

## Upgrading Chart

```console
helm upgrade [RELEASE_NAME] community-charts/outline
```

## Values

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| affinity | object | `{}` | For more information checkout: https://kubernetes.io/docs/concepts/scheduling-eviction/assign-pod-node/#affinity-and-anti-affinity |
| auth | object | `{"auth0":{"baseUrl":"","clientId":"","clientSecret":"","displayName":"Auth0 Connect","enabled":false,"existingSecret":{"clientSecretKey":"client-secret","name":""},"scopes":["openid","profile","email"],"usernameClaim":"name"},"azure":{"clientId":"","clientSecret":"","enabled":false,"existingSecret":{"clientSecretKey":"client-secret","name":""},"resourceAppId":"","tenantId":""},"discord":{"clientId":"","clientSecret":"","enabled":false,"existingSecret":{"clientSecretKey":"client-secret","name":""},"serverId":"","serverRoles":[]},"gitea":{"baseUrl":"","clientId":"","clientSecret":"","displayName":"Gitea Connect","enabled":false,"existingSecret":{"clientSecretKey":"client-secret","name":""},"scopes":["openid","profile","email"],"usernameClaim":"preferred_username"},"github":{"appId":"","appName":"","appPrivateKey":"","clientId":"","clientSecret":"","enabled":false,"existingSecret":{"appPrivateKeyKey":"app-private-key","clientSecretKey":"client-secret","name":""}},"gitlab":{"baseUrl":"","clientId":"","clientSecret":"","displayName":"GitLab Connect","enabled":false,"existingSecret":{"clientSecretKey":"client-secret","name":""},"scopes":["openid","profile","email"],"usernameClaim":"preferred_username"},"google":{"clientId":"","clientSecret":"","enabled":false,"existingSecret":{"clientSecretKey":"client-secret","name":""}},"keycloak":{"baseUrl":"","clientId":"","clientSecret":"","displayName":"Keycloak Connect","enabled":false,"existingSecret":{"clientSecretKey":"client-secret","name":""},"realmName":"","scopes":["openid","profile","email"],"usernameClaim":"preferred_username"},"oidc":{"authUri":"","clientId":"","clientSecret":"","displayName":"OpenID Connect","enabled":false,"existingSecret":{"clientSecretKey":"client-secret","name":""},"logoutUri":"","scopes":["openid","profile","email"],"tokenUri":"","userInfoUri":"","usernameClaim":"preferred_username"},"saml":{"cert":"","enabled":false,"existingSecret":{"certKey":"cert","name":""},"ssoEndpoint":""},"slack":{"clientId":"","clientSecret":"","enabled":false,"existingSecret":{"clientSecretKey":"client-secret","name":""}}}` | This is for setting up the auth. |
| auth.auth0 | object | `{"baseUrl":"","clientId":"","clientSecret":"","displayName":"Auth0 Connect","enabled":false,"existingSecret":{"clientSecretKey":"client-secret","name":""},"scopes":["openid","profile","email"],"usernameClaim":"name"}` | This is for setting up the auth0. More information about auth0 can be found here: https://auth0.com/docs/get-started/applications/configure-applications-with-oidc-discovery |
| auth.auth0.baseUrl | string | `""` | This is for setting up the auth0 base url. |
| auth.auth0.clientId | string | `""` | This is for setting up the auth0 client id. |
| auth.auth0.clientSecret | string | `""` | This is for setting up the auth0 client secret. |
| auth.auth0.displayName | string | `"Auth0 Connect"` | This is for setting up the auth0 display name. |
| auth.auth0.enabled | bool | `false` | This is for setting up the auth0 enabled. |
| auth.auth0.existingSecret | object | `{"clientSecretKey":"client-secret","name":""}` | This is for setting up the auth0 existing secret. If it's set, clientSecret will be ignored. |
| auth.auth0.existingSecret.clientSecretKey | string | `"client-secret"` | This is for setting up the auth0 secret key. |
| auth.auth0.existingSecret.name | string | `""` | This is for setting up the auth0 existing secret name. |
| auth.auth0.scopes | list | `["openid","profile","email"]` | This is for setting up the auth0 scopes. |
| auth.auth0.usernameClaim | string | `"name"` | This is for setting up the auth0 username claim. |
| auth.azure | object | `{"clientId":"","clientSecret":"","enabled":false,"existingSecret":{"clientSecretKey":"client-secret","name":""},"resourceAppId":"","tenantId":""}` | This is for setting up the azure. More information about azure can be found here: https://docs.getoutline.com/s/hosting/doc/microsoft-entra-UVz6jsIOcv |
| auth.azure.clientId | string | `""` | This is for setting up the azure client id. |
| auth.azure.clientSecret | string | `""` | This is for setting up the azure client secret. |
| auth.azure.enabled | bool | `false` | This is for setting up the azure enabled. |
| auth.azure.existingSecret | object | `{"clientSecretKey":"client-secret","name":""}` | This is for setting up the azure existing secret. If it's set, clientSecret will be ignored. |
| auth.azure.existingSecret.clientSecretKey | string | `"client-secret"` | This is for setting up the azure secret key. |
| auth.azure.existingSecret.name | string | `""` | This is for setting up the azure existing secret name. |
| auth.azure.resourceAppId | string | `""` | This is for setting up the azure resource app id. This is optional. |
| auth.azure.tenantId | string | `""` | This is for setting up the azure tenant id. This is optional. |
| auth.discord | object | `{"clientId":"","clientSecret":"","enabled":false,"existingSecret":{"clientSecretKey":"client-secret","name":""},"serverId":"","serverRoles":[]}` | This is for setting up the discord. More information about discord can be found here: https://docs.getoutline.com/s/hosting/doc/discord-g4JdWFFub6 |
| auth.discord.clientId | string | `""` | This is for setting up the discord client id. |
| auth.discord.clientSecret | string | `""` | This is for setting up the discord client secret. |
| auth.discord.enabled | bool | `false` | This is for setting up the discord enabled. |
| auth.discord.existingSecret | object | `{"clientSecretKey":"client-secret","name":""}` | This is for setting up the discord existing secret. If it's set, clientSecret will be ignored. |
| auth.discord.existingSecret.clientSecretKey | string | `"client-secret"` | This is for setting up the discord secret key. |
| auth.discord.existingSecret.name | string | `""` | This is for setting up the discord existing secret name. |
| auth.discord.serverId | string | `""` | This is for setting up the discord server id. |
| auth.discord.serverRoles | list | `[]` | This is for setting up the discord server roles. |
| auth.gitea | object | `{"baseUrl":"","clientId":"","clientSecret":"","displayName":"Gitea Connect","enabled":false,"existingSecret":{"clientSecretKey":"client-secret","name":""},"scopes":["openid","profile","email"],"usernameClaim":"preferred_username"}` | This is for setting up the gitea. More information about gitea can be found here: https://docs.gitea.com/development/oauth2-provider#endpoints |
| auth.gitea.baseUrl | string | `""` | This is for setting up the gitea base url. |
| auth.gitea.clientId | string | `""` | This is for setting up the gitea client id. |
| auth.gitea.clientSecret | string | `""` | This is for setting up the gitea client secret. |
| auth.gitea.displayName | string | `"Gitea Connect"` | This is for setting up the gitea display name. |
| auth.gitea.enabled | bool | `false` | This is for setting up the gitea enabled. |
| auth.gitea.existingSecret | object | `{"clientSecretKey":"client-secret","name":""}` | This is for setting up the gitea existing secret. If it's set, clientSecret will be ignored. |
| auth.gitea.existingSecret.clientSecretKey | string | `"client-secret"` | This is for setting up the gitea secret key. |
| auth.gitea.existingSecret.name | string | `""` | This is for setting up the gitea existing secret name. |
| auth.gitea.scopes | list | `["openid","profile","email"]` | This is for setting up the gitea scopes. |
| auth.gitea.usernameClaim | string | `"preferred_username"` | This is for setting up the gitea username claim. |
| auth.github | object | `{"appId":"","appName":"","appPrivateKey":"","clientId":"","clientSecret":"","enabled":false,"existingSecret":{"appPrivateKeyKey":"app-private-key","clientSecretKey":"client-secret","name":""}}` | This is for setting up the github. More information about github can be found here: https://docs.getoutline.com/s/hosting/doc/github-GchT3NNxI9 |
| auth.github.appId | string | `""` | This is for setting up the github app id. |
| auth.github.appName | string | `""` | This is for setting up the github app name. |
| auth.github.appPrivateKey | string | `""` | This is for setting up the github app private key. |
| auth.github.clientId | string | `""` | This is for setting up the github client id. |
| auth.github.clientSecret | string | `""` | This is for setting up the github client secret. |
| auth.github.enabled | bool | `false` | This is for setting up the github enabled. |
| auth.github.existingSecret | object | `{"appPrivateKeyKey":"app-private-key","clientSecretKey":"client-secret","name":""}` | This is for setting up the github existing secret. If it's set, clientSecret and appPrivateKey will be ignored. |
| auth.github.existingSecret.appPrivateKeyKey | string | `"app-private-key"` | This is for setting up the github app private key key. |
| auth.github.existingSecret.clientSecretKey | string | `"client-secret"` | This is for setting up the github secret key. |
| auth.github.existingSecret.name | string | `""` | This is for setting up the github existing secret name. |
| auth.gitlab | object | `{"baseUrl":"","clientId":"","clientSecret":"","displayName":"GitLab Connect","enabled":false,"existingSecret":{"clientSecretKey":"client-secret","name":""},"scopes":["openid","profile","email"],"usernameClaim":"preferred_username"}` | This is for setting up the gitlab. More information about gitlab can be found here: https://docs.gitlab.com/ee/integration/oauth_provider.html |
| auth.gitlab.baseUrl | string | `""` | This is for setting up the gitlab base url. |
| auth.gitlab.clientId | string | `""` | This is for setting up the gitlab client id. |
| auth.gitlab.clientSecret | string | `""` | This is for setting up the gitlab client secret. |
| auth.gitlab.displayName | string | `"GitLab Connect"` | This is for setting up the gitlab display name. |
| auth.gitlab.enabled | bool | `false` | This is for setting up the gitlab enabled. |
| auth.gitlab.existingSecret | object | `{"clientSecretKey":"client-secret","name":""}` | This is for setting up the gitlab existing secret. If it's set, clientSecret will be ignored. |
| auth.gitlab.existingSecret.clientSecretKey | string | `"client-secret"` | This is for setting up the gitlab secret key. |
| auth.gitlab.existingSecret.name | string | `""` | This is for setting up the gitlab existing secret name. |
| auth.gitlab.scopes | list | `["openid","profile","email"]` | This is for setting up the gitlab scopes. |
| auth.gitlab.usernameClaim | string | `"preferred_username"` | This is for setting up the gitlab username claim. |
| auth.google | object | `{"clientId":"","clientSecret":"","enabled":false,"existingSecret":{"clientSecretKey":"client-secret","name":""}}` | This is for setting up the google. More information about google can be found here: https://docs.getoutline.com/s/hosting/doc/google-hOuvtCmTqQ |
| auth.google.clientId | string | `""` | This is for setting up the google client id. |
| auth.google.clientSecret | string | `""` | This is for setting up the google client secret. |
| auth.google.enabled | bool | `false` | This is for setting up the google enabled. |
| auth.google.existingSecret | object | `{"clientSecretKey":"client-secret","name":""}` | This is for setting up the google existing secret. If it's set, clientSecret will be ignored. |
| auth.google.existingSecret.clientSecretKey | string | `"client-secret"` | This is for setting up the google secret key. |
| auth.google.existingSecret.name | string | `""` | This is for setting up the google existing secret name. |
| auth.keycloak | object | `{"baseUrl":"","clientId":"","clientSecret":"","displayName":"Keycloak Connect","enabled":false,"existingSecret":{"clientSecretKey":"client-secret","name":""},"realmName":"","scopes":["openid","profile","email"],"usernameClaim":"preferred_username"}` | This is for setting up the keycloak. More details about the Keycloak OIDC implementation can be found here: https://www.keycloak.org/securing-apps/oidc-layers |
| auth.keycloak.baseUrl | string | `""` | This is for setting up the keycloak base url. |
| auth.keycloak.clientId | string | `""` | This is for setting up the keycloak client id. |
| auth.keycloak.clientSecret | string | `""` | This is for setting up the keycloak client secret. |
| auth.keycloak.displayName | string | `"Keycloak Connect"` | This is for setting up the keycloak display name. |
| auth.keycloak.enabled | bool | `false` | This is for setting up the keycloak enabled. |
| auth.keycloak.existingSecret | object | `{"clientSecretKey":"client-secret","name":""}` | This is for setting up the keycloak existing secret. If it's set, clientSecret will be ignored. |
| auth.keycloak.existingSecret.clientSecretKey | string | `"client-secret"` | This is for setting up the keycloak secret key. |
| auth.keycloak.existingSecret.name | string | `""` | This is for setting up the keycloak existing secret name. |
| auth.keycloak.realmName | string | `""` | This is for setting up the keycloak realm name. |
| auth.keycloak.scopes | list | `["openid","profile","email"]` | This is for setting up the keycloak scopes. |
| auth.keycloak.usernameClaim | string | `"preferred_username"` | This is for setting up the keycloak username claim. |
| auth.oidc | object | `{"authUri":"","clientId":"","clientSecret":"","displayName":"OpenID Connect","enabled":false,"existingSecret":{"clientSecretKey":"client-secret","name":""},"logoutUri":"","scopes":["openid","profile","email"],"tokenUri":"","userInfoUri":"","usernameClaim":"preferred_username"}` | This is for setting up the oidc. More information about oidc can be found here: https://docs.getoutline.com/s/hosting/doc/oidc-8CPBm6uC0I |
| auth.oidc.authUri | string | `""` | This is for setting up the oidc auth uri. |
| auth.oidc.clientId | string | `""` | This is for setting up the oidc client id. |
| auth.oidc.clientSecret | string | `""` | This is for setting up the oidc client secret. |
| auth.oidc.displayName | string | `"OpenID Connect"` | This is for setting up the oidc display name. |
| auth.oidc.enabled | bool | `false` | This is for setting up the oidc enabled. |
| auth.oidc.existingSecret | object | `{"clientSecretKey":"client-secret","name":""}` | This is for setting up the oidc existing secret. If it's set, clientSecret will be ignored. |
| auth.oidc.existingSecret.clientSecretKey | string | `"client-secret"` | This is for setting up the oidc secret key. |
| auth.oidc.existingSecret.name | string | `""` | This is for setting up the oidc existing secret name. |
| auth.oidc.logoutUri | string | `""` | This is for setting up the oidc logout uri. This is optional. |
| auth.oidc.scopes | list | `["openid","profile","email"]` | This is for setting up the oidc scopes. |
| auth.oidc.tokenUri | string | `""` | This is for setting up the oidc token uri. |
| auth.oidc.userInfoUri | string | `""` | This is for setting up the oidc user info uri. |
| auth.oidc.usernameClaim | string | `"preferred_username"` | This is for setting up the oidc username claim. |
| auth.saml | object | `{"cert":"","enabled":false,"existingSecret":{"certKey":"cert","name":""},"ssoEndpoint":""}` | This is for setting up the saml. More information about saml can be found here: https://docs.getoutline.com/s/hosting/doc/saml-hCmJIfmAjt |
| auth.saml.cert | string | `""` | This is for setting up the saml cert. |
| auth.saml.enabled | bool | `false` | This is for setting up the saml enabled. |
| auth.saml.existingSecret | object | `{"certKey":"cert","name":""}` | This is for setting up the saml existing secret. If it's set, cert will be ignored. |
| auth.saml.existingSecret.certKey | string | `"cert"` | This is for setting up the saml secret key. |
| auth.saml.existingSecret.name | string | `""` | This is for setting up the saml existing secret name. |
| auth.saml.ssoEndpoint | string | `""` | This is for setting up the saml sso endpoint. |
| auth.slack | object | `{"clientId":"","clientSecret":"","enabled":false,"existingSecret":{"clientSecretKey":"client-secret","name":""}}` | This is for setting up the slack. More information about slack can be found here: https://docs.getoutline.com/s/hosting/doc/slack-sgMujR8J9J |
| auth.slack.clientId | string | `""` | This is for setting up the slack client id. |
| auth.slack.clientSecret | string | `""` | This is for setting up the slack client secret. |
| auth.slack.enabled | bool | `false` | This is for setting up the slack enabled. |
| auth.slack.existingSecret | object | `{"clientSecretKey":"client-secret","name":""}` | This is for setting up the slack existing secret. If it's set, clientSecret will be ignored. |
| auth.slack.existingSecret.clientSecretKey | string | `"client-secret"` | This is for setting up the slack secret key. |
| auth.slack.existingSecret.name | string | `""` | This is for setting up the slack existing secret name. |
| autoUpdate | object | `{"enabled":false,"telemetry":false}` | This is for setting up the auto update. |
| autoUpdate.enabled | bool | `false` | This is for setting up the auto update enabled. |
| autoUpdate.telemetry | bool | `false` | This is for setting up the enable telemetry. |
| database | object | `{"connectionPoolMax":"20","connectionPoolMin":"","sslMode":"disable"}` | Database configuration |
| database.connectionPoolMax | string | `"20"` | The maximum number of connections in the connection pool. |
| database.connectionPoolMin | string | `""` | The minimum number of connections in the connection pool. |
| database.sslMode | string | `"disable"` | The SSL mode to use for the database connection. possible values are: "disable", "allow", "require", "prefer", "verify-ca", "verify-full" |
| defaultLanguage | string | `"en_US"` | This is for setting up the default language. See translate.getoutline.com for a list of available language codes and their rough percentage translated |
| dnsConfig | object | `{}` | For more information checkout: https://kubernetes.io/docs/concepts/services-networking/dns-pod-service/#pod-dns-config |
| dnsPolicy | string | `""` | For more information checkout: https://kubernetes.io/docs/concepts/services-networking/dns-pod-service/#pod-s-dns-policy |
| externalPostgresql | object | `{"database":"outline","existingSecret":"","host":"","password":"","port":5432,"secretKey":"postgres-password","username":"postgres"}` | External PostgreSQL parameters |
| externalPostgresql.database | string | `"outline"` | The name of the external PostgreSQL database. For more information: https://docs.getoutline.com/s/hosting/doc/docker-7pfeLP5a8t |
| externalPostgresql.existingSecret | string | `""` | The name of an existing secret with PostgreSQL (must contain key `postgres-password`) and credentials. When it's set, the `externalPostgresql.password` parameter is ignored |
| externalPostgresql.host | string | `""` | External PostgreSQL server host |
| externalPostgresql.password | string | `""` | External PostgreSQL password |
| externalPostgresql.port | int | `5432` | External PostgreSQL server port |
| externalPostgresql.secretKey | string | `"postgres-password"` | This is for setting up the external postgresql secret key. |
| externalPostgresql.username | string | `"postgres"` | External PostgreSQL username |
| externalRedis | object | `{"existingSecret":"","host":"","password":"","passwordSecretKey":"redis-password","port":6379,"username":"","usernameSecretKey":"redis-username"}` | External Redis parameters |
| externalRedis.existingSecret | string | `""` | The name of an existing secret with Redis (must contain key `redis-password`) and Sentinel credentials. When it's set, the `externalRedis.password` parameter is ignored |
| externalRedis.host | string | `""` | External Redis server host |
| externalRedis.password | string | `""` | External Redis password |
| externalRedis.passwordSecretKey | string | `"redis-password"` | This is for setting up the external redis password secret key. |
| externalRedis.port | int | `6379` | External Redis server port |
| externalRedis.username | string | `""` | External Redis username |
| externalRedis.usernameSecretKey | string | `"redis-username"` | This is for setting up the external redis username secret key. |
| extraContainers | list | `[]` | Additional containers (sidecars) on the output Deployment definition. |
| extraEnvVars | object | `{}` | This is for setting up the extra environment variables. |
| extraSecretNamesForEnvFrom | list | `[]` | This is for setting up the extra secrets for environment variables. |
| fileStorage | object | `{"importMaxSize":"","local":{"persistence":{"accessModes":["ReadWriteOnce"],"annotations":{},"enabled":false,"existingClaim":"","size":"8Gi","storageClass":"","volumeMode":""},"rootDir":"/var/lib/outline/data"},"mode":"local","s3":{"accelerateUrl":"","accessKeyId":"","accessKeyIdSecretKey":"access-key-id","acl":"private","bucket":"outline","bucketUrl":"","existingSecret":"","forcePathStyle":true,"region":"us-east-1","secretAccessKey":"","secretAccessKeySecretKey":"secret-access-key"},"uploadMaxSize":"262144000","workspaceImportMaxSize":""}` | This is for setting up the file storage. More information about file storage can be found here: https://docs.getoutline.com/s/hosting/doc/file-storage-N4M0T6Ypu7 |
| fileStorage.importMaxSize | string | `""` | This is for setting up the file storage import max size. |
| fileStorage.local | object | `{"persistence":{"accessModes":["ReadWriteOnce"],"annotations":{},"enabled":false,"existingClaim":"","size":"8Gi","storageClass":"","volumeMode":""},"rootDir":"/var/lib/outline/data"}` | This is for setting up the local file storage. |
| fileStorage.local.persistence | object | `{"accessModes":["ReadWriteOnce"],"annotations":{},"enabled":false,"existingClaim":"","size":"8Gi","storageClass":"","volumeMode":""}` | This is for setting up the local file storage persistence. |
| fileStorage.local.persistence.accessModes | list | `["ReadWriteOnce"]` | This is for setting up the local file storage persistence access modes. |
| fileStorage.local.persistence.annotations | object | `{}` | This is for setting up the local file storage persistence annotations. |
| fileStorage.local.persistence.enabled | bool | `false` | This is for setting up the local file storage persistence enabled. |
| fileStorage.local.persistence.existingClaim | string | `""` | This is for setting up the local file storage persistence existing claim. |
| fileStorage.local.persistence.size | string | `"8Gi"` | This is for setting up the local file storage persistence size. |
| fileStorage.local.persistence.storageClass | string | `""` | This is for setting up the local file storage persistence storage class. |
| fileStorage.local.persistence.volumeMode | string | `""` | This is for setting up the local file storage persistence volume mode. |
| fileStorage.local.rootDir | string | `"/var/lib/outline/data"` | This is for setting up the local file storage root directory. |
| fileStorage.mode | string | `"local"` | This is for setting up the file storage mode. Possible values are: local or s3 |
| fileStorage.s3 | object | `{"accelerateUrl":"","accessKeyId":"","accessKeyIdSecretKey":"access-key-id","acl":"private","bucket":"outline","bucketUrl":"","existingSecret":"","forcePathStyle":true,"region":"us-east-1","secretAccessKey":"","secretAccessKeySecretKey":"secret-access-key"}` | This is for setting up the s3 file storage. |
| fileStorage.s3.accelerateUrl | string | `""` | This is for setting up the s3 file storage accelerate url. |
| fileStorage.s3.accessKeyId | string | `""` | This is for setting up the s3 file storage access key id. |
| fileStorage.s3.accessKeyIdSecretKey | string | `"access-key-id"` | This is for setting up the s3 file storage access key id secret key. |
| fileStorage.s3.acl | string | `"private"` | This is for setting up the s3 file storage acl. |
| fileStorage.s3.bucket | string | `"outline"` | This is for setting up the s3 file storage bucket. |
| fileStorage.s3.bucketUrl | string | `""` | This is for setting up the s3 file storage bucket url. |
| fileStorage.s3.existingSecret | string | `""` | This is for setting up the s3 file storage existing secret. Must contain access-key-id and secret-access-key keys. |
| fileStorage.s3.forcePathStyle | bool | `true` | This is for setting up the s3 file storage force path style. |
| fileStorage.s3.region | string | `"us-east-1"` | This is for setting up the s3 file storage region. |
| fileStorage.s3.secretAccessKey | string | `""` | This is for setting up the s3 file storage secret access key. |
| fileStorage.s3.secretAccessKeySecretKey | string | `"secret-access-key"` | This is for setting up the s3 file storage secret access key secret key. |
| fileStorage.uploadMaxSize | string | `"262144000"` | This is for setting up the file storage upload max size. |
| fileStorage.workspaceImportMaxSize | string | `""` | This is for setting up the file storage workspace import max size. |
| fullnameOverride | string | `""` | This is to override the full name of the chart. |
| hostAliases | list | `[]` | Host aliases for the pod. For more information checkout: https://kubernetes.io/docs/tasks/network/customize-hosts-file-for-pods/#adding-additional-entries-with-hostaliases |
| image | object | `{"pullPolicy":"IfNotPresent","repository":"outlinewiki/outline","tag":""}` | This sets the container image more information can be found here: https://kubernetes.io/docs/concepts/containers/images/ |
| image.pullPolicy | string | `"IfNotPresent"` | This sets the pull policy for images. |
| image.tag | string | `""` | Overrides the image tag whose default is the chart appVersion. |
| imagePullSecrets | list | `[]` | This is for the secrets for pulling an image from a private repository more information can be found here: https://kubernetes.io/docs/tasks/configure-pod-container/pull-image-private-registry/ |
| ingress | object | `{"annotations":{},"className":"","enabled":false,"hosts":[{"host":"outline.mydomain.com","paths":[{"path":"/","pathType":"ImplementationSpecific"}]}],"tls":[]}` | This block is for setting up the ingress for more information can be found here: https://kubernetes.io/docs/concepts/services-networking/ingress/ |
| ingress.annotations | object | `{}` | This is for setting up the ingress annotations. |
| ingress.className | string | `""` | This is for setting up the ingress class name. |
| ingress.enabled | bool | `false` | This is for setting up the ingress enabled. |
| ingress.hosts | list | `[{"host":"outline.mydomain.com","paths":[{"path":"/","pathType":"ImplementationSpecific"}]}]` | This is for setting up the ingress hosts. |
| ingress.tls | list | `[]` | This is for setting up the ingress tls. |
| initContainers | list | `[]` | Additional init containers on the output Deployment definition. |
| integrations | object | `{"dropbox":{"appKey":"","enabled":false,"existingSecret":{"appKeyKey":"app-key","name":""}},"iframely":{"apiKey":"","enabled":false,"existingSecret":{"apiKeyKey":"api-key","name":""},"url":""},"linear":{"clientId":"","clientSecret":"","enabled":false,"existingSecret":{"clientSecretKey":"client-secret","name":""}},"notion":{"clientId":"","clientSecret":"","enabled":false,"existingSecret":{"clientSecretKey":"client-secret","name":""}},"openAI":{"apiKey":"","enabled":false,"existingSecret":{"apiKeyKey":"api-key","name":""},"url":"","vectorDatabaseUrl":""},"pdfExport":{"enabled":false,"gotenbergUrl":""},"sentry":{"dsn":"","enabled":false,"tunnel":""},"slack":{"appId":"","enabled":false,"existingSecret":{"name":"","verificationTokenKey":"verification-token"},"messageActions":true,"verificationToken":""}}` | This is for setting up the integrations. More information about integrations can be found here: https://docs.getoutline.com/s/hosting/doc/integrations-Oav5MXNDJk |
| integrations.dropbox | object | `{"appKey":"","enabled":false,"existingSecret":{"appKeyKey":"app-key","name":""}}` | This is for setting up the dropbox. |
| integrations.dropbox.appKey | string | `""` | This is for setting up the dropbox app key. |
| integrations.dropbox.enabled | bool | `false` | This is for setting up the dropbox enabled. |
| integrations.dropbox.existingSecret | object | `{"appKeyKey":"app-key","name":""}` | This is for setting up the dropbox existing secret. If it's set, appKey will be ignored. |
| integrations.dropbox.existingSecret.appKeyKey | string | `"app-key"` | This is for setting up the dropbox secret key. |
| integrations.dropbox.existingSecret.name | string | `""` | This is for setting up the dropbox existing secret name. |
| integrations.iframely | object | `{"apiKey":"","enabled":false,"existingSecret":{"apiKeyKey":"api-key","name":""},"url":""}` | This is for setting up the iframely. More information about iframely can be found here: https://docs.getoutline.com/s/hosting/doc/iframely-HwLF1EZ9mo |
| integrations.iframely.apiKey | string | `""` | This is for setting up the iframely api key. |
| integrations.iframely.enabled | bool | `false` | This is for setting up the iframely enabled. |
| integrations.iframely.existingSecret | object | `{"apiKeyKey":"api-key","name":""}` | This is for setting up the iframely existing secret. If it's set, apiKey will be ignored. |
| integrations.iframely.existingSecret.apiKeyKey | string | `"api-key"` | This is for setting up the iframely secret key. |
| integrations.iframely.existingSecret.name | string | `""` | This is for setting up the iframely existing secret name. |
| integrations.iframely.url | string | `""` | This is for setting up the iframely url. |
| integrations.linear | object | `{"clientId":"","clientSecret":"","enabled":false,"existingSecret":{"clientSecretKey":"client-secret","name":""}}` | This is for setting up the linear. More information about linear can be found here: https://docs.getoutline.com/s/hosting/doc/linear-g8N2riMweL |
| integrations.linear.clientId | string | `""` | This is for setting up the linear client id. |
| integrations.linear.clientSecret | string | `""` | This is for setting up the linear client secret. |
| integrations.linear.enabled | bool | `false` | This is for setting up the linear enabled. |
| integrations.linear.existingSecret | object | `{"clientSecretKey":"client-secret","name":""}` | This is for setting up the linear existing secret. If it's set, clientSecret will be ignored. |
| integrations.linear.existingSecret.clientSecretKey | string | `"client-secret"` | This is for setting up the linear secret key. |
| integrations.linear.existingSecret.name | string | `""` | This is for setting up the linear existing secret name. |
| integrations.notion | object | `{"clientId":"","clientSecret":"","enabled":false,"existingSecret":{"clientSecretKey":"client-secret","name":""}}` | This is for setting up the notion. More information about notion can be found here: https://docs.getoutline.com/s/hosting/doc/notion-2v6g7WY3l3 |
| integrations.notion.clientId | string | `""` | This is for setting up the notion client id. |
| integrations.notion.clientSecret | string | `""` | This is for setting up the notion client secret. |
| integrations.notion.enabled | bool | `false` | This is for setting up the notion enabled. |
| integrations.notion.existingSecret | object | `{"clientSecretKey":"client-secret","name":""}` | This is for setting up the notion existing secret. If it's set, clientSecret will be ignored. |
| integrations.notion.existingSecret.clientSecretKey | string | `"client-secret"` | This is for setting up the notion secret key. |
| integrations.notion.existingSecret.name | string | `""` | This is for setting up the notion existing secret name. |
| integrations.openAI | object | `{"apiKey":"","enabled":false,"existingSecret":{"apiKeyKey":"api-key","name":""},"url":"","vectorDatabaseUrl":""}` | This is for setting up the openai. More information about openai can be found here: https://docs.getoutline.com/s/hosting/doc/openai-iiTYCN9Nct |
| integrations.openAI.apiKey | string | `""` | This is for setting up the openai api key. |
| integrations.openAI.enabled | bool | `false` | This is for setting up the openai enabled. |
| integrations.openAI.existingSecret | object | `{"apiKeyKey":"api-key","name":""}` | This is for setting up the openai existing secret. If it's set, apiKey will be ignored. |
| integrations.openAI.existingSecret.apiKeyKey | string | `"api-key"` | This is for setting up the openai secret key. |
| integrations.openAI.existingSecret.name | string | `""` | This is for setting up the openai existing secret name. |
| integrations.openAI.url | string | `""` | This is for setting up the openai url. |
| integrations.openAI.vectorDatabaseUrl | string | `""` | This is for setting up the openai vector database url. |
| integrations.pdfExport | object | `{"enabled":false,"gotenbergUrl":""}` | This is for setting up the pdf export. More information about pdf export can be found here: https://docs.getoutline.com/s/hosting/doc/pdf-export-7Dn1hCyUo5 |
| integrations.pdfExport.enabled | bool | `false` | This is for setting up the pdf export enabled. |
| integrations.pdfExport.gotenbergUrl | string | `""` | This is for setting up the pdf export gotenberg url. |
| integrations.sentry | object | `{"dsn":"","enabled":false,"tunnel":""}` | This is for setting up the sentry. More information about sentry can be found here: https://docs.getoutline.com/s/hosting/doc/sentry-jxcFttcDl5 |
| integrations.sentry.dsn | string | `""` | This is for setting up the sentry dsn. |
| integrations.sentry.enabled | bool | `false` | This is for setting up the sentry enabled. |
| integrations.sentry.tunnel | string | `""` | This is for setting up the sentry tunnel. |
| integrations.slack | object | `{"appId":"","enabled":false,"existingSecret":{"name":"","verificationTokenKey":"verification-token"},"messageActions":true,"verificationToken":""}` | This is for setting up the slack. More information about slack can be found here: https://docs.getoutline.com/s/hosting/doc/slack-G2mc8DOJHk |
| integrations.slack.appId | string | `""` | This is for setting up the slack app id. |
| integrations.slack.enabled | bool | `false` | This is for setting up the slack enabled. |
| integrations.slack.existingSecret | object | `{"name":"","verificationTokenKey":"verification-token"}` | This is for setting up the slack existing secret. If it's set, verificationToken will be ignored. |
| integrations.slack.existingSecret.name | string | `""` | This is for setting up the slack existing secret name. |
| integrations.slack.existingSecret.verificationTokenKey | string | `"verification-token"` | This is for setting up the slack secret key. |
| integrations.slack.messageActions | bool | `true` | This is for setting up the slack message actions. |
| integrations.slack.verificationToken | string | `""` | This is for setting up the slack verification token. |
| livenessProbe | object | `{"failureThreshold":5,"httpGet":{"path":"/_health","port":"http"},"initialDelaySeconds":10,"periodSeconds":30,"timeoutSeconds":3}` | This is to setup the liveness probe more information can be found here: https://kubernetes.io/docs/tasks/configure-pod-container/configure-liveness-readiness-startup-probes/ |
| livenessProbe.failureThreshold | int | `5` | This is for setting up the failure threshold. |
| livenessProbe.httpGet | object | `{"path":"/_health","port":"http"}` | This is for setting up the http get. |
| livenessProbe.httpGet.path | string | `"/_health"` | This is for setting up the path. |
| livenessProbe.httpGet.port | string | `"http"` | This is for setting up the port. |
| livenessProbe.initialDelaySeconds | int | `10` | This is for setting up the initial delay seconds. |
| livenessProbe.periodSeconds | int | `30` | This is for setting up the period seconds. |
| livenessProbe.timeoutSeconds | int | `3` | This is for setting up the timeout seconds. |
| logging | object | `{"extraDebug":[],"level":"info"}` | This is for setting up the logging. |
| logging.extraDebug | list | `[]` | This is for setting up the extra debug. Available modules:    - lifecycle    - http    - editor    - router    - collaboration    - misc    - store    - plugins    - policies |
| logging.level | string | `"info"` | This is for setting up the logging level. |
| minio | object | `{"buckets":[{"name":"outline","policy":"none","purge":false,"versioning":false}],"consoleIngress":{"enabled":false,"hosts":["minio-console.mydomain.com"],"path":"/"},"deploymentUpdate":{"type":"Recreate"},"drivesPerNode":1,"enabled":false,"ingress":{"enabled":true,"hosts":["minio.mydomain.com"],"path":"/"},"mode":"standalone","persistence":{"accessMode":"ReadWriteOnce","annotations":{},"enabled":true,"existingClaim":"","size":"40Gi","storageClass":"","subPath":"","volumeName":""},"policies":[{"name":"outline-policy","statements":[{"actions":["s3:AbortMultipartUpload","s3:GetObject","s3:DeleteObject","s3:PutObject","s3:ListMultipartUploadParts"],"resources":["arn:aws:s3:::outline/*"]},{"actions":["s3:GetBucketLocation","s3:ListBucket","s3:ListBucketMultipartUploads"],"resources":["arn:aws:s3:::outline"]}]}],"pools":1,"replicas":1,"resources":{"requests":{"memory":"1Gi"}},"rootPassword":"","rootUser":"","statefulSetUpdate":{"updateStrategy":"Recreate"},"users":[{"accessKey":"outline","policy":"outline-policy","secretKey":"Change_Me"}]}` | Minio configuration |
| minio.buckets | list | `[{"name":"outline","policy":"none","purge":false,"versioning":false}]` | Minio buckets |
| minio.buckets[0] | object | `{"name":"outline","policy":"none","purge":false,"versioning":false}` | Outline bucket |
| minio.buckets[0].policy | string | `"none"` | Policy to be set on the bucket [none|download|upload|public] |
| minio.consoleIngress | object | `{"enabled":false,"hosts":["minio-console.mydomain.com"],"path":"/"}` | Minio console ingress |
| minio.consoleIngress.enabled | bool | `false` | Enable ingress |
| minio.consoleIngress.hosts | list | `["minio-console.mydomain.com"]` | Ingress hosts |
| minio.consoleIngress.path | string | `"/"` | Ingress path |
| minio.deploymentUpdate | object | `{"type":"Recreate"}` | Minio deployment update strategy |
| minio.drivesPerNode | int | `1` | Number of drives attached to a node |
| minio.enabled | bool | `false` | Enable minio |
| minio.ingress | object | `{"enabled":true,"hosts":["minio.mydomain.com"],"path":"/"}` | Minio ingress. Outline will use this ingress to access Minio. It's required when fileStorage.mode is s3. |
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
| minio.policies | list | `[{"name":"outline-policy","statements":[{"actions":["s3:AbortMultipartUpload","s3:GetObject","s3:DeleteObject","s3:PutObject","s3:ListMultipartUploadParts"],"resources":["arn:aws:s3:::outline/*"]},{"actions":["s3:GetBucketLocation","s3:ListBucket","s3:ListBucketMultipartUploads"],"resources":["arn:aws:s3:::outline"]}]}]` | Minio policies |
| minio.policies[0] | object | `{"name":"outline-policy","statements":[{"actions":["s3:AbortMultipartUpload","s3:GetObject","s3:DeleteObject","s3:PutObject","s3:ListMultipartUploadParts"],"resources":["arn:aws:s3:::outline/*"]},{"actions":["s3:GetBucketLocation","s3:ListBucket","s3:ListBucketMultipartUploads"],"resources":["arn:aws:s3:::outline"]}]}` | Outline policy |
| minio.policies[0].statements[0] | object | `{"actions":["s3:AbortMultipartUpload","s3:GetObject","s3:DeleteObject","s3:PutObject","s3:ListMultipartUploadParts"],"resources":["arn:aws:s3:::outline/*"]}` | Outline policy statements |
| minio.pools | int | `1` | Number of expanded MinIO clusters |
| minio.replicas | int | `1` | Number of MinIO containers running |
| minio.resources | object | `{"requests":{"memory":"1Gi"}}` | Minio resources |
| minio.resources.requests | object | `{"memory":"1Gi"}` | Minio requests |
| minio.resources.requests.memory | string | `"1Gi"` | Minio requests memory |
| minio.rootPassword | string | `""` | Minio root password. Length should be at least 8 characters. |
| minio.rootUser | string | `""` | Minio root user. Length should be at least 3 characters. |
| minio.statefulSetUpdate | object | `{"updateStrategy":"Recreate"}` | Minio statefulset update strategy |
| minio.users | list | `[{"accessKey":"outline","policy":"outline-policy","secretKey":"Change_Me"}]` | Minio users |
| minio.users[0] | object | `{"accessKey":"outline","policy":"outline-policy","secretKey":"Change_Me"}` | Outline user |
| minio.users[0].policy | string | `"outline-policy"` | Outline user policy |
| minio.users[0].secretKey | string | `"Change_Me"` | Outline user secret key |
| nameOverride | string | `""` | This is to override the chart name. |
| nodeSelector | object | `{}` | For more information checkout: https://kubernetes.io/docs/concepts/scheduling-eviction/assign-pod-node/#nodeselector |
| podAnnotations | object | `{}` | This is for setting Kubernetes Annotations to a Pod. For more information checkout: https://kubernetes.io/docs/concepts/overview/working-with-objects/annotations/ |
| podLabels | object | `{}` | This is for setting Kubernetes Labels to a Pod. For more information checkout: https://kubernetes.io/docs/concepts/overview/working-with-objects/labels/ |
| podSecurityContext | object | `{"fsGroup":1001,"fsGroupChangePolicy":"OnRootMismatch"}` | This is for setting Security Context to a Pod. For more information checkout: https://kubernetes.io/docs/tasks/configure-pod-container/security-context/ |
| postgresql | object | `{"architecture":"standalone","auth":{"database":"outline","password":"","username":""},"enabled":false,"primary":{"persistence":{"enabled":true,"existingClaim":""},"service":{"ports":{"postgresql":5432}}}}` | Bitnami PostgreSQL configuration |
| postgresql.architecture | string | `"standalone"` | Enable postgresql architecture. |
| postgresql.auth | object | `{"database":"outline","password":"","username":""}` | This is for setting up the auth. |
| postgresql.auth.database | string | `"outline"` | This is for setting up the auth database. |
| postgresql.auth.password | string | `""` | This is for setting up the auth password. |
| postgresql.auth.username | string | `""` | This is for setting up the auth username. |
| postgresql.enabled | bool | `false` | Enable postgresql |
| postgresql.primary | object | `{"persistence":{"enabled":true,"existingClaim":""},"service":{"ports":{"postgresql":5432}}}` | This is for setting up the primary service. |
| postgresql.primary.persistence | object | `{"enabled":true,"existingClaim":""}` | This is for setting up the persistence. |
| postgresql.primary.persistence.enabled | bool | `true` | This is for setting up the persistence enabled. |
| postgresql.primary.persistence.existingClaim | string | `""` | This is for setting up the persistence existing claim. |
| postgresql.primary.service | object | `{"ports":{"postgresql":5432}}` | This is for setting up the primary service. |
| postgresql.primary.service.ports | object | `{"postgresql":5432}` | This is for setting up the service ports. |
| postgresql.primary.service.ports.postgresql | int | `5432` | This is for setting up the postgresql port. |
| rateLimiter | object | `{"enabled":false,"limit":100,"window":60}` | This is for setting up the rate limiter. |
| rateLimiter.enabled | bool | `false` | This is for setting up the rate limiter enabled. |
| rateLimiter.limit | int | `100` | This is for setting up the rate limiter limit. |
| rateLimiter.window | int | `60` | This is for setting up the rate limiter window. |
| readinessProbe | object | `{"failureThreshold":5,"httpGet":{"path":"/_health","port":"http"},"initialDelaySeconds":10,"periodSeconds":30,"timeoutSeconds":3}` | This is to setup the readiness probe more information can be found here: https://kubernetes.io/docs/tasks/configure-pod-container/configure-liveness-readiness-startup-probes/ |
| readinessProbe.failureThreshold | int | `5` | This is for setting up the failure threshold. |
| readinessProbe.httpGet | object | `{"path":"/_health","port":"http"}` | This is for setting up the http get. |
| readinessProbe.httpGet.path | string | `"/_health"` | This is for setting up the path. |
| readinessProbe.httpGet.port | string | `"http"` | This is for setting up the port. |
| readinessProbe.initialDelaySeconds | int | `10` | This is for setting up the initial delay seconds. |
| readinessProbe.periodSeconds | int | `30` | This is for setting up the period seconds. |
| readinessProbe.timeoutSeconds | int | `3` | This is for setting up the timeout seconds. |
| redis | object | `{"architecture":"standalone","auth":{"enabled":true},"enabled":false,"master":{"persistence":{"enabled":false},"service":{"ports":{"redis":6379}}}}` | Bitnami Redis configuration |
| redis.enabled | bool | `false` | Enable redis |
| replicaCount | int | `1` |  |
| resources | object | `{}` | This is to setup the resources more information can be found here: https://kubernetes.io/docs/concepts/configuration/manage-resources-containers/ |
| secretKey | string | `""` | This is for setting up the secret key. It will be auto generated if not set. |
| securityContext | object | `{"allowPrivilegeEscalation":false,"capabilities":{"drop":["ALL"]},"privileged":false,"readOnlyRootFilesystem":false,"runAsGroup":1001,"runAsNonRoot":true,"runAsUser":1001}` | This is for setting Security Context to a Container. For more information checkout: https://kubernetes.io/docs/tasks/configure-pod-container/security-context/ |
| service | object | `{"annotations":{},"enabled":true,"name":"http","port":3000,"type":"ClusterIP"}` | This is for setting up a service more information can be found here: https://kubernetes.io/docs/concepts/services-networking/service/ |
| service.annotations | object | `{}` | Additional service annotations |
| service.enabled | bool | `true` | This sets the service enabled. |
| service.name | string | `"http"` | Default Service name |
| service.port | int | `3000` | This sets the ports more information can be found here: https://kubernetes.io/docs/concepts/services-networking/service/#field-spec-ports |
| service.type | string | `"ClusterIP"` | This sets the service type more information can be found here: https://kubernetes.io/docs/concepts/services-networking/service/#publishing-services-service-types |
| serviceAccount | object | `{"annotations":{},"automount":true,"create":true,"name":""}` | This section builds out the service account more information can be found here: https://kubernetes.io/docs/concepts/security/service-accounts/ |
| serviceAccount.annotations | object | `{}` | Annotations to add to the service account. AWS EKS users can assign role arn from here. Please find more information from here: https://docs.aws.amazon.com/eks/latest/userguide/associate-service-account-role.html |
| serviceAccount.automount | bool | `true` | Automatically mount a ServiceAccount's API credentials? |
| serviceAccount.create | bool | `true` | Specifies whether a service account should be created |
| serviceAccount.name | string | `""` | The name of the service account to use. If not set and create is true, a name is generated using the fullname template |
| smtp | object | `{"existingSecret":{"name":"","passwordKey":"password","usernameKey":"username"},"fromEmail":"","host":"","password":"","port":587,"replyEmail":"","secure":true,"tlsCiphers":"","username":""}` | This is for setting up the smtp. More information about smtp can be found here: https://docs.getoutline.com/s/hosting/doc/smtp-cqCJyZGMIB |
| smtp.existingSecret | object | `{"name":"","passwordKey":"password","usernameKey":"username"}` | This is for setting up the smtp existing secret. If it's set, password will be ignored. |
| smtp.existingSecret.name | string | `""` | This is for setting up the smtp existing secret name. |
| smtp.existingSecret.passwordKey | string | `"password"` | This is for setting up the smtp secret key. |
| smtp.existingSecret.usernameKey | string | `"username"` | This is for setting up the smtp username key. |
| smtp.fromEmail | string | `""` | This is for setting up the smtp from email. |
| smtp.host | string | `""` | This is for setting up the smtp host. |
| smtp.password | string | `""` | This is for setting up the smtp password. |
| smtp.port | int | `587` | This is for setting up the smtp port. |
| smtp.replyEmail | string | `""` | This is for setting up the smtp reply email. |
| smtp.secure | bool | `true` | This is for setting up the smtp secure. |
| smtp.tlsCiphers | string | `""` | This is for setting up the smtp tls ciphers. |
| smtp.username | string | `""` | This is for setting up the smtp username. |
| strategy | object | `{"rollingUpdate":{"maxSurge":"25%","maxUnavailable":"25%"},"type":"RollingUpdate"}` | This will set the deployment strategy more information can be found here: https://kubernetes.io/docs/concepts/workloads/controllers/deployment/#strategy |
| tolerations | list | `[]` | For more information checkout: https://kubernetes.io/docs/concepts/scheduling-eviction/taint-and-toleration/ |
| url | string | `""` | This is for setting up the url manually. It will be auto generated if not set. Depending to your ingress configuration, it can be automatically generated from ingress domain or service definition. |
| utilsSecret | string | `""` | This is for setting up the utils secret. It will be auto generated if not set. |
| volumeMounts | list | `[]` |  |
| volumes | list | `[]` | Additional volumes on the output Deployment definition. |
| web | object | `{"concurrency":1,"forceHttps":true,"skipSSLVerification":false}` | This is for setting up the web. |
| web.concurrency | int | `1` | This is for setting up the web concurrency. |
| web.forceHttps | bool | `true` | This is for setting up the web force https. |
| web.skipSSLVerification | bool | `false` | This is for setting up the skip ssl verification to allow insecure connections. |

**Homepage:** <https://www.getoutline.com/>

## Source Code

* <https://github.com/community-charts/helm-charts>
* <https://github.com/outline/outline/>

## Chart Development

Please install unittest helm plugin with `helm plugin install https://github.com/helm-unittest/helm-unittest.git` command and use following command to run helm unit tests.

```console
helm unittest --strict --file 'unittests/**/*.yaml' charts/outline
```

## Maintainers

| Name | Email | Url |
| ---- | ------ | --- |
| burakince | <burak.ince@linux.org.tr> | <https://www.burakince.com> |
