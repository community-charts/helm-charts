# mlflow

![mlflow](https://raw.githubusercontent.com/mlflow/mlflow/refs/heads/master/docs/static/images/logo-light.svg)

A Helm chart for Mlflow open source platform for the machine learning lifecycle

![Version: 1.11.2](https://img.shields.io/badge/Version-1.11.2-informational?style=flat-square) ![Type: application](https://img.shields.io/badge/Type-application-informational?style=flat-square) ![AppVersion: 3.14.0](https://img.shields.io/badge/AppVersion-3.14.0-informational?style=flat-square)

## Official Documentation

For detailed usage instructions, configuration options, and additional information about the `mlflow` Helm chart, refer to the [official documentation](https://community-charts.github.io/docs/charts/mlflow/usage).

## Get Helm Repository Info

```console
helm repo add community-charts https://community-charts.github.io/helm-charts
helm repo update
```

_See [`helm repo`](https://helm.sh/docs/helm/helm_repo/) for command documentation._

## Installing the Chart

```console
helm install [RELEASE_NAME] community-charts/mlflow
```

_See [configuration](#configuration) below._

_See [helm install](https://helm.sh/docs/helm/helm_install/) for command documentation._

> **Tip**: Search all available chart versions using `helm search repo community-charts -l`. Please don't forget to run `helm repo update` before the command.

## Supported Databases

Currently, we support the following two databases as a backend repository for Mlflow.

* [PostgreSQL](https://www.postgresql.org/)
* [MySQL](https://www.mysql.com/)

## Supported Cloud Providers

We currently support the following three cloud providers for [BLOB](https://de.wikipedia.org/wiki/Binary_Large_Object) storage integration.

* [AWS (S3)](https://aws.amazon.com/s3/)
* [Google Cloud Platform (Cloud Storage)](https://cloud.google.com/storage)
* [Azure Cloud (Azure Blob Storage)](https://azure.microsoft.com/en-us/services/storage/blobs/)

## Values Files Examples

## Postgres Database Migration Values Files Example

```yaml
backendStore:
  databaseMigration: true
  postgres:
    enabled: true
    host: "postgresql-instance1.cg034hpkmmjt.eu-central-1.rds.amazonaws.com"
    port: 5432
    database: "mlflow"
    user: "mlflowuser"
    password: "Pa33w0rd!"
```

## Postgres Database with Existing Database Secret Example

```yaml
backendStore:
  postgres:
    enabled: true
    host: "postgresql-instance1.cg034hpkmmjt.eu-central-1.rds.amazonaws.com"
    port: 5432
    database: "mlflow"

  existingDatabaseSecret:
    name: "postgres-database-secret"
    usernameKey: "username"
    passwordKey: "password"
```

## Bitnami's Postgres Database Migration Values Files Example

```yaml
backendStore:
  databaseMigration: true
postgres:
  enabled: true
```

## MySQL Database Migration Values Files Example

```yaml
backendStore:
  databaseMigration: true
  mysql:
    enabled: true
    host: "mysql-instance1.cg034hpkmmjt.eu-central-1.rds.amazonaws.com"
    port: 3306
    database: "mlflow"
    user: "mlflowuser"
    password: "Pa33w0rd!"
```

## MySQL Database with Existing Database Secret Example

```yaml
backendStore:
  mysql:
    enabled: true
    host: "mysql-instance1.cg034hpkmmjt.eu-central-1.rds.amazonaws.com"
    port: 3306
    database: "mlflow"

  existingDatabaseSecret:
    name: "mysql-database-secret"
    usernameKey: "username"
    passwordKey: "password"
```

## Bitnami's MySQL Database Migration Values Files Example

```yaml
backendStore:
  databaseMigration: true
mysql:
  enabled: true
```

## Postgres Database Connection Check Values Files Example

```yaml
backendStore:
  databaseConnectionCheck: true
  postgres:
    enabled: true
    host: "postgresql-instance1.cg034hpkmmjt.eu-central-1.rds.amazonaws.com"
    port: 5432
    database: "mlflow"
    user: "mlflowuser"
    password: "Pa33w0rd!"
```

## Bitnami's Postgres Database Connection Check Values Files Example

```yaml
backendStore:
  databaseConnectionCheck: true
postgres:
  enabled: true
```

## MySQL Database Connection Check Values Files Example

```yaml
backendStore:
  databaseConnectionCheck: true
  mysql:
    enabled: true
    host: "mysql-instance1.cg034hpkmmjt.eu-central-1.rds.amazonaws.com"
    port: 3306
    database: "mlflow"
    user: "mlflowuser"
    password: "Pa33w0rd!"
```

## Bitnami's MySQL Database Connection Check Values Files Example

```yaml
backendStore:
  databaseConnectionCheck: true
mysql:
  enabled: true
```

## MSSQL Database Migration Values Files Example

```yaml
backendStore:
  databaseMigration: true
  mssql:
    enabled: true
    host: "mssql-instance1.database.windows.net"
    port: 1433
    database: "mlflow"
    user: "mlflowuser"
    password: "Pa33w0rd!"
```

## MSSQL Database with Azure Active Directory or MSI Connection URL Example

For Azure AD or Managed Service Identity (MSI) authentication, pass a full SQLAlchemy connection URL via `connectionUrl`. When set, `host`, `port`, `database`, `user`, and `password` are all ignored.

```yaml
backendStore:
  databaseMigration: true
  mssql:
    enabled: true
    connectionUrl: "mssql+pyodbc:///?odbc_connect=Driver={ODBC Driver 18 for SQL Server};Server=mssql-instance1.database.windows.net,1433;Database=mlflow;Authentication=ActiveDirectoryMsi"
```

## MSSQL Database with Existing Connection URL Secret Example

Store a credential-bearing connection URL in a Kubernetes Secret. `existingConnectionUrlSecret` takes priority over `connectionUrl` when set.

```yaml
backendStore:
  databaseMigration: true
  mssql:
    enabled: true
    existingConnectionUrlSecret:
      name: "mssql-connection-secret"
      key: "connection-url"
```

## AWS Installation Examples

You can use 2 different way to connect your S3 backend.

- First way, you can access to your S3 with IAM user's awsAccessKeyId and awsSecretAccessKey.
- Second way, you can create an aws role for your service account. And you can assign your role ARN from serviceAccount annotation. You don't need to create or manage IAM user anymore. Please find more information from [here](https://docs.aws.amazon.com/IAM/latest/UserGuide/id_roles_create_for-idp_oidc.html).

> **Tip**: Please follow [this tutorial](https://aws.amazon.com/getting-started/hands-on/create-connect-postgresql-db/) to create your own RDS postgres cluster.

## S3 (Minio) and PostgreSQL DB Configuration on Helm Upgrade Command Example

```console
helm upgrade --install mlflow community-charts/mlflow \
  --set backendStore.databaseMigration=true \
  --set backendStore.postgres.enabled=true \
  --set backendStore.postgres.host=postgres-service \
  --set backendStore.postgres.port=5432 \
  --set backendStore.postgres.database=postgres \
  --set backendStore.postgres.user=postgres \
  --set backendStore.postgres.password=postgres \
  --set artifactRoot.s3.enabled=true \
  --set artifactRoot.s3.bucket=mlflow \
  --set artifactRoot.s3.awsAccessKeyId=minioadmin \
  --set artifactRoot.s3.awsSecretAccessKey=minioadmin \
  --set extraEnvVars.MLFLOW_S3_ENDPOINT_URL=http://minio-service:9000 \
  --set serviceMonitor.enabled=true
```

## S3 (Minio) and MySQL DB Configuration on Helm Upgrade Command Example

```console
helm upgrade --install mlflow community-charts/mlflow \
  --set backendStore.databaseMigration=true \
  --set backendStore.mysql.enabled=true \
  --set backendStore.mysql.host=mysql-service \
  --set backendStore.mysql.port=3306 \
  --set backendStore.mysql.database=mlflow \
  --set backendStore.mysql.user=mlflow \
  --set backendStore.mysql.password=mlflow \
  --set artifactRoot.s3.enabled=true \
  --set artifactRoot.s3.bucket=mlflow \
  --set artifactRoot.s3.awsAccessKeyId=minioadmin \
  --set artifactRoot.s3.awsSecretAccessKey=minioadmin \
  --set extraEnvVars.MLFLOW_S3_ENDPOINT_URL=http://minio-service:9000 \
  --set serviceMonitor.enabled=true
```

## S3 Access with awsAccessKeyId and awsSecretAccessKey Values Files Example

```yaml
backendStore:
  postgres:
    enabled: true
    host: "postgresql-instance1.cg034hpkmmjt.eu-central-1.rds.amazonaws.com"
    port: 5432
    database: "mlflow"
    user: "mlflowuser"
    password: "Pa33w0rd!"

artifactRoot:
  s3:
    enabled: true
    bucket: "my-mlflow-artifact-root-backend"
    awsAccessKeyId: "a1b2c3d4"
    awsSecretAccessKey: "a1b2c3d4"
```

## S3 Access with AWS EKS Role ARN Values Files Example

> **Tip**: [Associate an IAM role to a service account](https://docs.aws.amazon.com/eks/latest/userguide/specify-service-account-role.html)

```yaml
serviceAccount:
  create: true
  annotations:
    eks.amazonaws.com/role-arn: "arn:aws:iam::account-id:role/iam-role-name"
  name: "mlflow"

backendStore:
  postgres:
    enabled: true
    host: "postgresql-instance1.cg034hpkmmjt.eu-central-1.rds.amazonaws.com"
    port: 5432
    database: "mlflow"
    user: "mlflowuser"
    password: "Pa33w0rd!"

artifactRoot:
  s3:
    enabled: true
    bucket: "my-mlflow-artifact-root-backend"
```

## Built-in MinIO Subchart for S3-Compatible Artifact Storage

The chart ships an optional [MinIO](https://min.io/) subchart. Enable it to deploy a self-contained S3-compatible object store in the same namespace — no external object storage required.

When `minio.enabled` is `true` and `artifactRoot.s3.bucket` is empty, the chart automatically uses the first bucket name from `minio.buckets`.

```yaml
backendStore:
  databaseMigration: true
  postgres:
    enabled: true
    host: "postgresql-instance1.cg034hpkmmjt.eu-central-1.rds.amazonaws.com"
    port: 5432
    database: "mlflow"
    user: "mlflowuser"
    password: "Pa33w0rd!"

artifactRoot:
  s3:
    enabled: true

minio:
  enabled: true
  buckets:
    - name: mlflow-artifacts
      policy: none
      purge: false
```

> **Note**: When `minio.enabled` is `true`, the chart reads `AWS_ACCESS_KEY_ID` and `AWS_SECRET_ACCESS_KEY` directly from the MinIO secret (`rootUser`/`rootPassword` keys) and sets `MLFLOW_S3_ENDPOINT_URL` automatically — do not set those values under `artifactRoot.s3`. `minio.rootUser` and `minio.rootPassword` are optional; MinIO auto-generates stable credentials on first install if omitted.

## Azure Cloud Installation Example

> **Tip**: Please follow [this tutorial](https://docs.microsoft.com/en-us/azure/postgresql/tutorial-design-database-using-azure-portal) to create your own postgres database.
> **Tip**: Please follow [this tutorial](https://docs.microsoft.com/en-us/azure/storage/blobs/storage-blobs-introduction) to create your azure blob storage and container.

```yaml
backendStore:
  postgres:
    enabled: true
    host: "mydemoserver.postgres.database.azure.com"
    port: 5432
    database: "mlflow"
    user: "mlflowuser"
    password: "Pa33w0rd!"

artifactRoot:
  azureBlob:
    enabled: true
    container: "mlflow"
    storageAccount: "mystorageaccount"
    accessKey: "Eby8vdM02xNOcqFlqUwJPLlmEtlCDXJ1OUzFT50uSRZ6IFsuFq2UVErCz4I6tq/K1SZFPTOtr/KBHBeksoGMGw=="
```

## PVC Mount with Sqlite and File Based Artifactory Example

### Prerequisites

Please create your PVC before the installation of your helm chart. You can use something similar as the following yaml file.

```yaml
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: mlflow-pvc
spec:
  accessModes:
    - ReadWriteOnce
  resources:
    requests:
      storage: 5Gi
  storageClassName: standard
```

You need to create the PVC under same namespace as your mlflow helm chart.

### Example Chart Parameters

```yaml
strategy:
  type: Recreate

extraVolumes:
  - name: mlflow-volume
    persistentVolumeClaim:
      claimName: mlflow-pvc

extraVolumeMounts:
  - name: mlflow-volume
    mountPath: /mlflow/data

backendStore:
  defaultSqlitePath: "/mlflow/data/mlflow.db"

artifactRoot:
  proxiedArtifactStorage: true
  defaultArtifactsDestination: "/mlflow/data/mlartifacts"

ingress:
  enabled: true
  hosts:
    - host: my-mlflow-server-domain-name.com
      paths:
        - path: /
          pathType: ImplementationSpecific
```

## Authentication Example

> **Tip**: `auth`, `ldapAuth`, and `oidcAuth` are mutually exclusive — enable only one at a time!

### Authentication with Plain Admin Settings Example

```yaml
auth:
  enabled: true
  adminUsername: "admin"
  adminPassword: "S3cr3+"
```

### Authentication with Existing Admin Credentials Secret Example

```yaml
auth:
  enabled: true
  existingAdminSecret:
    name: auth-admin-secret
```

Use following configuration for centralised PosgreSQL DB backend for authentication backend.

### Authentication Postgres DB Backend with Plain Settings Example

```yaml
auth:
  enabled: true
  adminUsername: "admin"
  adminPassword: "S3cr3+"
  postgres:
    enabled: true
    host: "postgresql--auth-instance1.abcdef1234.eu-central-1.rds.amazonaws.com"
    port: 5432
    database: "auth"
    user: "mlflowauth"
    password: "A4m1nPa33w0rd!"
```

### Authentication Postgres DB Backend with Existing Secret Example

```yaml
auth:
  enabled: true
  existingAdminSecret:
    name: auth-admin-secret
  postgres:
    enabled: true
    host: postgresql--auth-instance1.abcdef1234.eu-central-1.rds.amazonaws.com
    port: 5432
    database: auth
    existingSecret:
      name: auth-postgres-database-secret
```

## Basic Authentication with LDAP Backend

> **Tip**: `auth`, `ldapAuth`, and `oidcAuth` are mutually exclusive — enable only one at a time!

```yaml
ldapAuth:
  enabled: true
  uri: "ldap://lldap:3890/dc=mlflow,dc=test"
  tlsVerification: required
  lookupBind: "uid=%s,ou=people,dc=mlflow,dc=test"
  groupAttribute: "dn"
  searchBaseDistinguishedName: "ou=groups,dc=mlflow,dc=test"
  searchFilter: "(&(objectclass=groupOfUniqueNames)(uniquemember=%s))"
  adminGroupDistinguishedName: "cn=test-admin,ou=groups,dc=mlflow,dc=test"
  userGroupDistinguishedName: "cn=test-user,ou=groups,dc=mlflow,dc=test"
```

## Basic Authentication with LDAP Backend and self-signed CA certificate

If you use self-signed certificate for your LDAP server, you can pass your self-signed CA certificate from `encodedTrustedCACertificate` variable by encoding it.

```yaml
ldapAuth:
  enabled: true
  uri: "ldap://lldap:3890/dc=mlflow,dc=test"
  tlsVerification: required
  lookupBind: "uid=%s,ou=people,dc=mlflow,dc=test"
  groupAttribute: "dn"
  searchBaseDistinguishedName: "ou=groups,dc=mlflow,dc=test"
  searchFilter: "(&(objectclass=groupOfUniqueNames)(uniquemember=%s))"
  adminGroupDistinguishedName: "cn=test-admin,ou=groups,dc=mlflow,dc=test"
  userGroupDistinguishedName: "cn=test-user,ou=groups,dc=mlflow,dc=test"
  encodedTrustedCACertificate: "LS0tLS1CRUdJTiBDRVJUSUZJQ0FURS0tLS0tCk1JSURoRENDQW15Z0F3SUJBZ0lSQUx1a3VyZnlCMFF0Z1FtbnphZDlMNWN3RFFZSktvWklodmNOQVFFTEJRQXcKU3pFZ01CNEdBMVVFQXd3WFRVeEdiRzkzSUV4RVFWQXRVMU5NTFZSbGMzUWdRMEV4RHpBTkJnTlZCQW9NQmsxTQpSbXh2ZHpFV01CUUdBMVVFQ3d3TlRFUkJVQzFUVTB3dFZHVnpkREFlRncweU5UQXpNRE14TnpJMU1qVmFGdzB5Ck5UQXpNRFF4TnpJMU1qVmFNRXN4SURBZUJnTlZCQU1NRjAxTVJteHZkeUJNUkVGUUxWTlRUQzFVWlhOMElFTkIKTVE4d0RRWURWUVFLREFaTlRFWnNiM2N4RmpBVUJnTlZCQXNNRFV4RVFWQXRVMU5NTFZSbGMzUXdnZ0VpTUEwRwpDU3FHU0liM0RRRUJBUVVBQTRJQkR3QXdnZ0VLQW9JQkFRRHNBNDc1NkRrZlVXRThZZjRHN0Z4ZFJkL0pnNXNkCjRJUVp1K3ZQcDRMTm5uM3E5VWlZeUtHZkVFRDJTMnRvYUVTS1VNakJyYWVRd3crUDV0dDVHcjNMQ3JQUmpjZTUKQ2xuMEh3NE5pRGJ5bkhWcDkxWXRjdHJObWtGMFRGdUYxNVE5OUMyR1lpbmNYUW93THduMWZXN2pTZjFuU3N1Kwpvek0veHFUa2FyQndtcVFkYTRlcW56cG5Xa2ZqL2ZHQTNVcnpwMHV6ZG1ZdnNhcmtiTkt0aGZSWTJ4UDhQZGc0Cm15dDJ6SmlycjN2MEo1OFNHeFN6ZWlab0tYUTNtTW5hRDZGTUVTcEg5THUydDVTRUVPZjlubFJLS2l4UzF0aWMKVHJUMDkzUVNKcWNRRkMyNTNwWmF1ZkpQNWR2SlVIR0NvcHFzVU5xc0Jkd2Ivd1grNnJFQm5YYUJBZ01CQUFHagpZekJoTUE4R0ExVWRFd0VCL3dRRk1BTUJBZjh3RGdZRFZSMFBBUUgvQkFRREFnRUdNQjBHQTFVZERnUVdCQlJsCnZVRmphb0c5NU1sWmxBSUs2SDRsaVlvMUNqQWZCZ05WSFNNRUdEQVdnQlJsdlVGamFvRzk1TWxabEFJSzZINGwKaVlvMUNqQU5CZ2txaGtpRzl3MEJBUXNGQUFPQ0FRRUFCNy96YWtlOHB6QWF3eHhvUW5mV3N1MkpSNWhyZkpjcQpjdCt1UEVnSWdnc3lFSmRGbndvbSt2UUV3a3NnT2tEYk10UGZnWTdRUVdUeHo4d1pQOXJDZVZaVUJ0T1FrdytKCjZCR2NLc1gwVnl5bUx5a1VOWUF5U2pEUE1Ma0NES2ZsRyt2eWFPWTZQbFdkZVJJTTVRMVZRL1B1SmQrbCtobEgKd2dFbU1RK2VjeVB2Wkhnd0t3cE41Zzh3YzI3bjI3RURqS29wUHpFMXpzRFN0MjFwUnMvcUdnZXZ6QTl2RlB5eAprWXdXdWJkblQ5NkwyTUUrVjcwTmJzbWt5ekl2T2NzajBlRnE0Z2EyNUQxQ2FhLzlyUnVOSlhwanYyQndYUm1tClNDNnBIV1dRWnh3NDRLQnJCM09EM1hLS25rMU94RFBDUzVwMzN2SHo4ZEZOMHNzb3EwV1VPUT09Ci0tLS0tRU5EIENFUlRJRklDQVRFLS0tLS0K"
```

Or if you already stored your self-signed CA certifica in an external secret, you can pass secret name from `externalSecretForTrustedCACertificate` variable. The secret must keep CA certificate with `ca.crt` key.

```yaml
ldapAuth:
  enabled: true
  uri: "ldap://lldap:3890/dc=mlflow,dc=test"
  tlsVerification: required
  lookupBind: "uid=%s,ou=people,dc=mlflow,dc=test"
  groupAttribute: "dn"
  searchBaseDistinguishedName: "ou=groups,dc=mlflow,dc=test"
  searchFilter: "(&(objectclass=groupOfUniqueNames)(uniquemember=%s))"
  adminGroupDistinguishedName: "cn=test-admin,ou=groups,dc=mlflow,dc=test"
  userGroupDistinguishedName: "cn=test-user,ou=groups,dc=mlflow,dc=test"
  externalSecretForTrustedCACertificate: "external-ca-certificate-secret"
```

## OIDC Authentication Example

> **Tip**: `oidcAuth`, `auth`, `ldapAuth`, and `oauth2Proxy` are mutually exclusive — enable only one at a time!

The `oidcAuth` block activates the `mlflow-oidc-auth` plugin that is already bundled in the `burakince/mlflow` image. Unlike `oauth2Proxy` (a sidecar proxy), this approach provides native OIDC authentication inside MLflow, mapping OIDC groups to MLflow permissions.

### OIDC Auth with Keycloak (minimal)

```yaml
oidcAuth:
  enabled: true
  discoveryUrl: "https://keycloak.example.com/realms/mlflow/.well-known/openid-configuration"
  clientId: "mlflow-client"
  clientSecret: "mlflow-client-secret"
  groupName:
    - mlflow-users
  adminGroupName:
    - mlflow-admin
```

### OIDC Auth with Existing Secret

```yaml
oidcAuth:
  enabled: true
  discoveryUrl: "https://keycloak.example.com/realms/mlflow/.well-known/openid-configuration"
  clientId: "mlflow-client"
  existingSecret:
    name: my-oidc-secret
    clientSecretKey: "OIDC_CLIENT_SECRET"
  groupName:
    - mlflow-users
  adminGroupName:
    - mlflow-admin
```

### OIDC Auth with Redis Cache (multi-replica)

```yaml
oidcAuth:
  enabled: true
  discoveryUrl: "https://keycloak.example.com/realms/mlflow/.well-known/openid-configuration"
  clientId: "mlflow-client"
  clientSecret: "mlflow-client-secret"
  groupName:
    - mlflow-users
  adminGroupName:
    - mlflow-admin
  cache:
    enabled: true
    redisUrl: "redis://redis:6379/0"
```

### OIDC Auth with PostgreSQL User Database

```yaml
oidcAuth:
  enabled: true
  discoveryUrl: "https://keycloak.example.com/realms/mlflow/.well-known/openid-configuration"
  clientId: "mlflow-client"
  clientSecret: "mlflow-client-secret"
  groupName:
    - mlflow-users
  adminGroupName:
    - mlflow-admin
  database:
    postgres:
      enabled: true
      host: "oidc-users-db.example.com"
      port: 5432
      database: "oidc_users"
      user: "oidcuser"
      password: "S3cr3t!"
```

### OIDC Auth with PostgreSQL User Database and Existing Secret

```yaml
oidcAuth:
  enabled: true
  discoveryUrl: "https://keycloak.example.com/realms/mlflow/.well-known/openid-configuration"
  clientId: "mlflow-client"
  existingSecret:
    name: my-oidc-secret
    clientSecretKey: "OIDC_CLIENT_SECRET"
  groupName:
    - mlflow-users
  adminGroupName:
    - mlflow-admin
  database:
    postgres:
      enabled: true
      host: "oidc-users-db.example.com"
      port: 5432
      database: "oidc_users"
      existingSecret:
        name: oidc-db-secret
        usernameKey: "username"
        passwordKey: "password"
```

## OAuth2 Proxy Example

> **Tip**: `oidcAuth` and `oauth2Proxy` are mutually exclusive. `oauth2Proxy` can coexist with `auth` or `ldapAuth` (proxy in front, MLflow auth behind).

The `oauth2Proxy` block deploys an [oauth2-proxy](https://oauth2-proxy.github.io/oauth2-proxy/) sidecar container in the same pod. All traffic flows through the proxy first (`Ingress → 4180 → 5000`), so MLflow itself requires no auth configuration.

### OAuth2 Proxy with Keycloak (chart-managed secret)

```yaml
oauth2Proxy:
  enabled: true
  createSecret: true
  cookieSecret: "a-random-32-char-cookie-secret!!"
  provider:
    name: keycloak-oidc
    issuerURL: "https://keycloak.example.com/realms/mlflow"
    clientID: "mlflow-client"
    clientSecret: "mlflow-client-secret"
    redirectURL: "https://mlflow.example.com/oauth2/callback"
```

### OAuth2 Proxy with Existing Secret

```yaml
oauth2Proxy:
  enabled: true
  existingSecret:
    name: my-oauth2-proxy-secret
    clientIDKey: "client-id"
    clientSecretKey: "client-secret"
    cookieSecretKey: "cookie-secret"
  provider:
    name: keycloak-oidc
    issuerURL: "https://keycloak.example.com/realms/mlflow"
    redirectURL: "https://mlflow.example.com/oauth2/callback"
```

## Server Host Binding Example

By default MLflow binds to `0.0.0.0` (all interfaces). When you deploy an `oauth2Proxy` sidecar, set `serverHost: "127.0.0.1"` so MLflow is reachable only through the proxy — without this, pod-to-pod traffic can reach MLflow directly and bypass authentication.

```yaml
serverHost: "127.0.0.1"

oauth2Proxy:
  enabled: true
  createSecret: true
  cookieSecret: "a-random-32-char-cookie-secret!!"
  provider:
    name: keycloak-oidc
    issuerURL: "https://keycloak.example.com/realms/mlflow"
    clientID: "mlflow-client"
    clientSecret: "mlflow-client-secret"
    redirectURL: "https://mlflow.example.com/oauth2/callback"
```

## Security Middleware Example

MLflow 3.x runs on uvicorn and includes security middleware that protects against DNS rebinding, CORS, and clickjacking attacks. The chart automatically configures `MLFLOW_SERVER_ALLOWED_HOSTS` and `MLFLOW_SERVER_CORS_ALLOWED_ORIGINS` from your ingress hosts so the middleware does not block legitimate requests.

### Auto-detection from Ingress

When `ingress.enabled` is `true` and hosts are configured the chart derives both env vars automatically:

- `MLFLOW_SERVER_ALLOWED_HOSTS` is set to the bare hostnames (e.g. `mlflow.example.com`)
- `MLFLOW_SERVER_CORS_ALLOWED_ORIGINS` is set to `https://hostname` when `ingress.tls` is configured, or `http://hostname` otherwise

```yaml
ingress:
  enabled: true
  hosts:
    - host: mlflow.example.com
      paths:
        - path: /
          pathType: ImplementationSpecific
  tls:
    - secretName: mlflow-tls
      hosts:
        - mlflow.example.com
# Results in:
#   MLFLOW_SERVER_ALLOWED_HOSTS: "mlflow.example.com"
#   MLFLOW_SERVER_CORS_ALLOWED_ORIGINS: "https://mlflow.example.com"
```

### Appending Extra Hosts or Origins

Use `serverAllowedHosts` and `corsAllowedOrigins` to add entries beyond what is auto-detected. Ingress-derived values always come first; entries from these lists are appended and duplicates are removed automatically.

```yaml
ingress:
  enabled: true
  hosts:
    - host: mlflow.example.com
      paths:
        - path: /
          pathType: ImplementationSpecific

serverAllowedHosts:
  - dashboard.example.com   # extra hostname that also routes to MLflow

corsAllowedOrigins:
  - https://dashboard.example.com   # frontend served from a different origin
# Results in:
#   MLFLOW_SERVER_ALLOWED_HOSTS: "mlflow.example.com,dashboard.example.com"
#   MLFLOW_SERVER_CORS_ALLOWED_ORIGINS: "http://mlflow.example.com,https://dashboard.example.com"
```

### Wildcard for Development

A single `"*"` entry collapses the entire list to just `*`, ignoring all other entries including auto-detected ingress values:

```yaml
corsAllowedOrigins:
  - "*"
serverAllowedHosts:
  - "*"
```

### Runtime Override

`extraEnvVars` always wins at runtime via Kubernetes `env:` → `envFrom:` precedence, so you can override both env vars without touching `serverAllowedHosts` or `corsAllowedOrigins`:

```yaml
extraEnvVars:
  MLFLOW_SERVER_ALLOWED_HOSTS: "mlflow.example.com,other.example.com"
  MLFLOW_SERVER_CORS_ALLOWED_ORIGINS: "https://mlflow.example.com,https://other.example.com"
```

## Extra Kubernetes Resources Example

Use `extraDeploy` to render arbitrary Kubernetes objects alongside the chart. Each item is evaluated with `tpl`, so Helm template expressions work inside the objects.

### ExternalSecret via External Secrets Operator

Each item in `extraDeploy` is evaluated with `tpl`, so Helm template expressions work inside the objects (e.g. `{{ include "mlflow.fullname" . }}`).

```yaml
extraDeploy:
  - apiVersion: external-secrets.io/v1
    kind: SecretStore
    metadata:
      name: mlflow
    spec:
      provider:
        aws:
          service: SecretsManager
          region: eu-central-1
          auth:
            jwt:
              serviceAccountRef:
                name: mlflow

  - apiVersion: external-secrets.io/v1
    kind: ExternalSecret
    metadata:
      name: mlflow-db-credentials
    spec:
      secretStoreRef:
        name: mlflow
        kind: SecretStore
      target:
        name: mlflow-db-credentials
      data:
        - secretKey: username
          remoteRef:
            key: mlflow/db
            property: username
        - secretKey: password
          remoteRef:
            key: mlflow/db
            property: password

backendStore:
  postgres:
    enabled: true
    host: "postgresql-instance1.cg034hpkmmjt.eu-central-1.rds.amazonaws.com"
    port: 5432
    database: "mlflow"
  existingDatabaseSecret:
    name: "mlflow-db-credentials"
    usernameKey: "username"
    passwordKey: "password"
```

## Deployment Annotations Example

Use `deploymentAnnotations` to add annotations to the `Deployment` resource metadata (not the pod). This is distinct from `podAnnotations`, which annotates the pod template.

```yaml
deploymentAnnotations:
  velero.database/restart-on-restore: "mlflow"
```

This allows external tooling to discover deployments by annotation, for example to scale them down before a database restore operation.

## Auto Scaling Example

This Helm chart supports Horizontal Pod Autoscaling (HPA) to dynamically scale the MLflow `Deployment` based on metrics. The HPA resource is created when `autoscaling.enabled` is `true` and specific conditions are met (see Prerequisites).

### Prerequisites

The HPA is created only if:

- `autoscaling.enabled: true`
- A backend store is enabled (`backendStore.postgres.enabled`, `backendStore.mysql.enabled`, `postgresql.enabled`, or `mysql.enabled`).
- An artifact store is enabled (`artifactRoot.azureBlob.enabled`, `artifactRoot.s3.enabled`, or `artifactRoot.gcs.enabled`).
- Auth is either enabled with Postgres (`auth.enabled` and `auth.postgres.enabled`) or disabled (`auth.enabled: false`).

A metrics source (e.g., Metrics Server) is required for scaling.

### Example 1: Basic CPU Scaling

Scale between 1 and 5 replicas based on CPU usage:

```yaml
autoscaling:
  enabled: true
  minReplicas: 1
  maxReplicas: 5
  metrics:
    - type: Resource
      resource:
        name: cpu
        target:
          type: Utilization
          averageUtilization: 80

backendStore:
  postgres:
    enabled: true
    host: "postgresql-instance1.cg034hpkmmjt.eu-central-1.rds.amazonaws.com"
    port: 5432
    database: "mlflow"
    user: "mlflowuser"
    password: "Pa33w0rd!"

artifactRoot:
  s3:
    enabled: true
    bucket: "my-mlflow-artifact-root-backend"
    awsAccessKeyId: "a1b2c3d4"
    awsSecretAccessKey: "a1b2c3d4"
```

### Example 2: Custom Scaling Behavior

Scale with custom behavior (1.18+):

```yaml
autoscaling:
  enabled: true
  minReplicas: 2
  maxReplicas: 10
  metrics:
    - type: Resource
      resource:
        name: cpu
        target:
          type: Utilization
          averageUtilization: 70
  behavior:
    scaleUp:
      stabilizationWindowSeconds: 30
      policies:
        - type: Percent
          value: 100
          periodSeconds: 60
    scaleDown:
      stabilizationWindowSeconds: 300

backendStore:
  postgres:
    enabled: true
    host: "postgresql-instance1.cg034hpkmmjt.eu-central-1.rds.amazonaws.com"
    port: 5432
    database: "mlflow"
    user: "mlflowuser"
    password: "Pa33w0rd!"

artifactRoot:
  s3:
    enabled: true
    bucket: "my-mlflow-artifact-root-backend"
    awsAccessKeyId: "a1b2c3d4"
    awsSecretAccessKey: "a1b2c3d4"

auth:
  enabled: true
  adminUsername: "admin"
  adminPassword: "S3cr3+"
  postgres:
    enabled: true
    host: "postgresql--auth-instance1.abcdef1234.eu-central-1.rds.amazonaws.com"
    port: 5432
    database: "auth"
    user: "mlflowauth"
    password: "A4m1nPa33w0rd!"
```

## Upgrading

This section outlines major updates and breaking changes for each version of the Helm Chart to help you transition smoothly between releases.

---

###  Version-Specific Upgrade Notes

#### Upgrading to Version 1.0.x

##### Action Required

We started to use new `mlflow` major version 3 starting with this chart major version. Please consider to check [mlflow-3 breaking changes](https://mlflow.org/docs/3.0.0rc3/mlflow-3/breaking-changes) official page.
The new `mlflow` major version 3 has some changes in the database schema. Please run database migrations before upgrading to the new version.

You can enable database migrations with the following configuration.

```yaml
backendStore:
  databaseMigration: true
```

Or you can use the following mlflow CLI command to upgrade the database. You can find more information about the database migrations in the [mlflow documentation](https://mlflow.org/docs/latest/api_reference/cli.html#mlflow-db-upgrade).

```console
mlflow db upgrade <database_uri>
```

## Requirements

Kubernetes: `>=1.16.0-0`

| Repository | Name | Version |
|------------|------|---------|
| https://charts.bitnami.com/bitnami | mysql | 14.0.3 |
| https://charts.bitnami.com/bitnami | postgresql | 18.7.6 |
| https://charts.min.io/ | minio | 5.4.0 |

## Uninstall Helm Chart

```console
helm uninstall [RELEASE_NAME]
```

This removes all the Kubernetes components associated with the chart and deletes the release.

_See [helm uninstall](https://helm.sh/docs/helm/helm_uninstall/) for command documentation._

## Upgrading Chart

```console
helm upgrade [RELEASE_NAME] community-charts/mlflow
```

## Values

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| affinity | object | `{}` | For more information checkout: https://kubernetes.io/docs/concepts/scheduling-eviction/assign-pod-node/#affinity-and-anti-affinity |
| artifactRoot.azureBlob | object | `{"accessKey":"","connectionString":"","container":"","enabled":false,"path":"","storageAccount":""}` | Specifies if you want to use Azure Blob Storage Mlflow Artifact Root |
| artifactRoot.azureBlob.accessKey | string | `""` | Azure Cloud Storage Account Access Key for the container |
| artifactRoot.azureBlob.connectionString | string | `""` | Azure Cloud Connection String for the container. Only connectionString or accessKey required |
| artifactRoot.azureBlob.container | string | `""` | Azure blob container name |
| artifactRoot.azureBlob.enabled | bool | `false` | Specifies if you want to use Azure Blob Storage Mlflow Artifact Root |
| artifactRoot.azureBlob.path | string | `""` | Azure blob container folder. If you want to use root level, please don't set anything. |
| artifactRoot.azureBlob.storageAccount | string | `""` | Azure storage account name |
| artifactRoot.defaultArtifactRoot | string | `"./mlruns"` | Specifies the default artifact root. |
| artifactRoot.defaultArtifactsDestination | string | `"./mlartifacts"` | Specifies the default artifacts destination |
| artifactRoot.gcs | object | `{"bucket":"","enabled":false,"path":""}` | Specifies if you want to use Google Cloud Storage Mlflow Artifact Root |
| artifactRoot.gcs.bucket | string | `""` | Google Cloud Storage bucket name |
| artifactRoot.gcs.enabled | bool | `false` | Specifies if you want to use Google Cloud Storage Mlflow Artifact Root |
| artifactRoot.gcs.path | string | `""` | Google Cloud Storage bucket folder. If you want to use root level, please don't set anything. |
| artifactRoot.proxiedArtifactStorage | bool | `false` | Specifies if you want to enable proxied artifact storage access |
| artifactRoot.s3 | object | `{"awsAccessKeyId":"","awsSecretAccessKey":"","bucket":"","enabled":false,"existingSecret":{"keyOfAccessKeyId":"AWS_ACCESS_KEY_ID","keyOfSecretAccessKey":"AWS_SECRET_ACCESS_KEY","name":""},"path":""}` | Specifies if you want to use AWS S3 Mlflow Artifact Root |
| artifactRoot.s3.awsAccessKeyId | string | `""` | AWS IAM user AWS_ACCESS_KEY_ID which has attached policy for access to the S3 bucket |
| artifactRoot.s3.awsSecretAccessKey | string | `""` | AWS IAM user AWS_SECRET_ACCESS_KEY which has attached policy for access to the S3 bucket |
| artifactRoot.s3.bucket | string | `""` | S3 bucket name |
| artifactRoot.s3.enabled | bool | `false` | Specifies if you want to use AWS S3 Mlflow Artifact Root |
| artifactRoot.s3.existingSecret | object | `{"keyOfAccessKeyId":"AWS_ACCESS_KEY_ID","keyOfSecretAccessKey":"AWS_SECRET_ACCESS_KEY","name":""}` | Existing secret for AWS IAM user AWS_ACCESS_KEY_ID and AWS_SECRET_ACCESS_KEY secrets. |
| artifactRoot.s3.existingSecret.keyOfAccessKeyId | string | `"AWS_ACCESS_KEY_ID"` | Key in the existing secret that holds the AWS_ACCESS_KEY_ID value. |
| artifactRoot.s3.existingSecret.keyOfSecretAccessKey | string | `"AWS_SECRET_ACCESS_KEY"` | Key in the existing secret that holds the AWS_SECRET_ACCESS_KEY value. |
| artifactRoot.s3.existingSecret.name | string | `""` | This is for setting up the AWS IAM user secrets existing secret name. |
| artifactRoot.s3.path | string | `""` | S3 bucket folder. If you want to use root level, please don't set anything. |
| auth | object | `{"adminPassword":"","adminUsername":"","appName":"basic-auth","authorizationFunction":"mlflow.server.auth:authenticate_request_basic_auth","configFile":"basic_auth.ini","configPath":"/etc/mlflow/auth/","defaultPermission":"READ","enabled":false,"existingAdminSecret":{"name":"","passwordKey":"password","usernameKey":"username"},"postgres":{"database":"","driver":"","enabled":false,"existingSecret":{"name":"","passwordKey":"password","usernameKey":"username"},"host":"","password":"","port":5432,"user":""},"sqliteFile":"basic_auth.db","sqliteFullPath":""}` | Mlflow authentication settings |
| auth.adminPassword | string | `""` | Mlflow admin user password |
| auth.adminUsername | string | `""` | Mlflow admin user username |
| auth.appName | string | `"basic-auth"` | Default registered authentication app name. If you want to use your custom authentication function, please look at: https://mlflow.org/docs/latest/auth/index.html#custom-authentication |
| auth.authorizationFunction | string | `"mlflow.server.auth:authenticate_request_basic_auth"` | Default authentication function |
| auth.configFile | string | `"basic_auth.ini"` | Mlflow authentication INI file |
| auth.configPath | string | `"/etc/mlflow/auth/"` | Mlflow authentication INI configuration file path. |
| auth.defaultPermission | string | `"READ"` | Default permission for all users. More details: https://mlflow.org/docs/latest/auth/index.html#permissions |
| auth.enabled | bool | `false` | Specifies if you want to enable mlflow authentication. auth, ldapAuth, and oidcAuth can't be enabled at same time. |
| auth.existingAdminSecret | object | `{"name":"","passwordKey":"password","usernameKey":"username"}` | Specifies if you want to use an existing admin credentials secret for auth. If it's set, adminUsername and adminPassword will be ignored. |
| auth.existingAdminSecret.name | string | `""` | The name of the existing admin credentials secret. |
| auth.existingAdminSecret.passwordKey | string | `"password"` | The key of the admin password in the existing admin credentials secret. |
| auth.existingAdminSecret.usernameKey | string | `"username"` | The key of the admin username in the existing admin credentials secret. |
| auth.postgres | object | `{"database":"","driver":"","enabled":false,"existingSecret":{"name":"","passwordKey":"password","usernameKey":"username"},"host":"","password":"","port":5432,"user":""}` | PostgreSQL based centrilised authentication database |
| auth.postgres.database | string | `""` | mlflow authorization database name created before in the postgres instance |
| auth.postgres.driver | string | `""` | postgres database connection driver. e.g.: "psycopg2" |
| auth.postgres.enabled | bool | `false` | Specifies if you want to use postgres auth backend storage |
| auth.postgres.existingSecret | object | `{"name":"","passwordKey":"password","usernameKey":"username"}` | Specifies if you want to use an existing database secret for auth. If it's set, user and password will be ignored. |
| auth.postgres.existingSecret.name | string | `""` | The name of the existing database secret. |
| auth.postgres.existingSecret.passwordKey | string | `"password"` | The key of the password in the existing database secret. |
| auth.postgres.existingSecret.usernameKey | string | `"username"` | The key of the username in the existing database secret. |
| auth.postgres.host | string | `""` | Postgres host address. e.g. your RDS or Azure Postgres Service endpoint |
| auth.postgres.password | string | `""` | postgres database user password which can access to mlflow authorization database |
| auth.postgres.port | int | `5432` | Postgres service port |
| auth.postgres.user | string | `""` | postgres database user name which can access to mlflow authorization database |
| auth.sqliteFile | string | `"basic_auth.db"` | SQLite database file |
| auth.sqliteFullPath | string | `""` | SQLite database folder. Default is user home directory. |
| autoscaling | object | `{"behavior":{},"enabled":false,"maxReplicas":5,"metrics":[{"resource":{"name":"memory","target":{"averageUtilization":80,"type":"Utilization"}},"type":"Resource"},{"resource":{"name":"cpu","target":{"averageUtilization":80,"type":"Utilization"}},"type":"Resource"}],"minReplicas":1}` | Autoscaling settings. Can be enabled only when backendStore is not sqlite and artifactRoot is one of blob storage systems. |
| autoscaling.behavior | object | `{}` | The behavior of the autoscaler. Only supported on K8s 1.18.0 or later. |
| autoscaling.enabled | bool | `false` | If true, the number of replicas will be automatically scaled based on default metrics. On default, it will scale based on CPU and memory. For more information can be found here: https://kubernetes.io/docs/concepts/workloads/autoscaling/" |
| autoscaling.maxReplicas | int | `5` | The maximum number of replicas. |
| autoscaling.metrics | list | `[{"resource":{"name":"memory","target":{"averageUtilization":80,"type":"Utilization"}},"type":"Resource"},{"resource":{"name":"cpu","target":{"averageUtilization":80,"type":"Utilization"}},"type":"Resource"}]` | The metrics to use for autoscaling. |
| autoscaling.minReplicas | int | `1` | The minimum number of replicas. |
| backendStore | object | `{"databaseConnectionCheck":false,"databaseMigration":false,"defaultSqlitePath":":memory:","existingDatabaseSecret":{"name":"","passwordKey":"password","usernameKey":"username"},"mssql":{"connectionUrl":"","database":"","driver":"pymssql","enabled":false,"existingConnectionUrlSecret":{"key":"","name":""},"host":"","password":"","port":1433,"user":""},"mysql":{"database":"","driver":"pymysql","enabled":false,"host":"","password":"","port":3306,"user":""},"postgres":{"database":"","driver":"","enabled":false,"host":"","password":"","port":5432,"user":""}}` | Mlflow database connection settings |
| backendStore.databaseConnectionCheck | bool | `false` | Add an additional init container, which checks for database availability |
| backendStore.databaseMigration | bool | `false` | Specifies if you want to run database migration |
| backendStore.defaultSqlitePath | string | `":memory:"` | Specifies the default sqlite path |
| backendStore.existingDatabaseSecret | object | `{"name":"","passwordKey":"password","usernameKey":"username"}` | Specifies if you want to use an existing database secret. |
| backendStore.existingDatabaseSecret.name | string | `""` | The name of the existing database secret. |
| backendStore.existingDatabaseSecret.passwordKey | string | `"password"` | The key of the password in the existing database secret. |
| backendStore.existingDatabaseSecret.usernameKey | string | `"username"` | The key of the username in the existing database secret. |
| backendStore.mssql.connectionUrl | string | `""` | Full SQLAlchemy connection URL for mssql (e.g. for Azure AD / MSI authentication with no embedded credentials). When set, host/port/database/user/password are ignored and this URL is used directly as --backend-store-uri. Example: "mssql+pyodbc://?odbc_connect=DRIVER%3D...%3BAuthentication%3DActiveDirectoryMsi%3B" |
| backendStore.mssql.database | string | `""` | mlflow database name created before in the mssql instance |
| backendStore.mssql.driver | string | `"pymssql"` | mssql database connection driver. e.g.: "pymssql" |
| backendStore.mssql.enabled | bool | `false` | Specifies if you want to use mssql backend storage |
| backendStore.mssql.existingConnectionUrlSecret | object | `{"key":"","name":""}` | Existing Kubernetes Secret containing the full MSSQL connection URL as a secret value. Use this instead of connectionUrl when the connection string contains credentials. The secret value is exposed as MSSQL_CONNECTION_URL and passed directly as --backend-store-uri. Takes precedence over connectionUrl when name is set. |
| backendStore.mssql.existingConnectionUrlSecret.key | string | `""` | Key within the secret that holds the connection URL |
| backendStore.mssql.existingConnectionUrlSecret.name | string | `""` | Name of the existing secret |
| backendStore.mssql.host | string | `""` | mssql host address |
| backendStore.mssql.password | string | `""` | mssql database user password which can access to mlflow database |
| backendStore.mssql.port | int | `1433` | mssql service port |
| backendStore.mssql.user | string | `""` | mssql database user name which can access to mlflow database |
| backendStore.mysql.database | string | `""` | mlflow database name created before in the mysql instance |
| backendStore.mysql.driver | string | `"pymysql"` | mysql database connection driver. e.g.: "pymysql" |
| backendStore.mysql.enabled | bool | `false` | Specifies if you want to use mysql backend storage |
| backendStore.mysql.host | string | `""` | MySQL host address. e.g. your Amazon RDS for MySQL |
| backendStore.mysql.password | string | `""` | mysql database user password which can access to mlflow database |
| backendStore.mysql.port | int | `3306` | MySQL service port |
| backendStore.mysql.user | string | `""` | mysql database user name which can access to mlflow database |
| backendStore.postgres.database | string | `""` | mlflow database name created before in the postgres instance |
| backendStore.postgres.driver | string | `""` | postgres database connection driver. e.g.: "psycopg2" |
| backendStore.postgres.enabled | bool | `false` | Specifies if you want to use postgres backend storage |
| backendStore.postgres.host | string | `""` | Postgres host address. e.g. your RDS or Azure Postgres Service endpoint |
| backendStore.postgres.password | string | `""` | postgres database user password which can access to mlflow database |
| backendStore.postgres.port | int | `5432` | Postgres service port |
| backendStore.postgres.user | string | `""` | postgres database user name which can access to mlflow database |
| corsAllowedOrigins | list | `[]` | List of allowed CORS origins for the MLflow server security middleware (env: MLFLOW_SERVER_CORS_ALLOWED_ORIGINS). When ingress is enabled, origins are automatically derived from ingress hosts: https:// if ingress.tls is configured, http:// otherwise. Set explicitly to override auto-detection (e.g. ["*"] for dev, or origins behind a load balancer with TLS termination before ingress). Requires uvicorn, which is the default server in MLflow 3.x. |
| deploymentAnnotations | object | `{}` | Annotations for the Deployment resource |
| extraArgs | object | `{}` | A map of arguments and values to pass to the `mlflow server` command. Keys must be camelcase. Helm will turn them to kebabcase style. |
| extraContainers | list | `[]` | Extra containers for the mlflow pod |
| extraDeploy | list | `[]` | Array of extra Kubernetes objects to deploy alongside the chart (e.g. SecretStore, ExternalSecret). Supports Helm templating via tpl. |
| extraEnvVars | object | `{}` | Extra environment variables |
| extraFlags | list | `[]` | A list of flags to pass to `mlflow server` command. Items must be camelcase. Helm will turn them to kebabcase style. |
| extraPodLabels | object | `{}` | Extra labels for the pod |
| extraSecretNamesForEnvFrom | list | `[]` | Extra secrets for environment variables |
| extraVolumeMounts | list | `[]` | Extra Volume Mounts for the mlflow container |
| extraVolumes | list | `[]` | Extra Volumes for the pod |
| flaskServerSecretKey | string | `""` | Mlflow Flask Server Secret Key. Default: Will be auto generated. |
| fullnameOverride | string | `""` | String to override the default generated fullname |
| image | object | `{"digest":"","pullPolicy":"IfNotPresent","repository":"burakince/mlflow","tag":""}` | Image of mlflow |
| image.digest | string | `""` | Image digest in the format sha256:<hex>. When set, overrides the tag for immutable pulls. |
| image.pullPolicy | string | `"IfNotPresent"` | The docker image pull policy |
| image.repository | string | `"burakince/mlflow"` | The docker image repository to use |
| image.tag | string | `""` | The docker image tag to use. Default app version |
| imagePullSecrets | list | `[]` | Image pull secrets for private docker registry usages |
| ingress.annotations | object | `{}` | Additional ingress annotations |
| ingress.className | string | `""` | New style ingress class name. Only possible if you use K8s 1.18.0 or later version |
| ingress.enabled | bool | `false` | Specifies if you want to create an ingress access |
| ingress.hosts[0].host | string | `"chart-example.local"` |  |
| ingress.hosts[0].paths[0].path | string | `"/"` |  |
| ingress.hosts[0].paths[0].pathType | string | `"ImplementationSpecific"` | Ingress path type |
| ingress.tls | list | `[]` | Ingress tls configuration for https access |
| initContainers | list | `[]` | Init Containers for Mlflow Pod |
| initImages | object | `{"dbchecker":{"pullPolicy":"IfNotPresent","repository":"busybox","tag":"1.38.0"},"iniFileInitializer":{"pullPolicy":"IfNotPresent","repository":"busybox","tag":"1.38.0"},"mlflowDbMigration":{"pullPolicy":"IfNotPresent","repository":"burakince/mlflow","tag":""}}` | mlflow init images |
| initImages.dbchecker | object | `{"pullPolicy":"IfNotPresent","repository":"busybox","tag":"1.38.0"}` | dbchecker init container image configuration |
| initImages.dbchecker.pullPolicy | string | `"IfNotPresent"` | dbchecker init container image pull policy |
| initImages.dbchecker.repository | string | `"busybox"` | dbchecker init container image repository to use |
| initImages.dbchecker.tag | string | `"1.38.0"` | dbchecker init container image tag to use |
| initImages.iniFileInitializer | object | `{"pullPolicy":"IfNotPresent","repository":"busybox","tag":"1.38.0"}` | ini-file-initializer init container image configuration |
| initImages.iniFileInitializer.pullPolicy | string | `"IfNotPresent"` | ini-file-initializer init container image pull policy |
| initImages.iniFileInitializer.repository | string | `"busybox"` | ini-file-initializer init container image repository to use |
| initImages.iniFileInitializer.tag | string | `"1.38.0"` | ini-file-initializer init container image tag to use |
| initImages.mlflowDbMigration | object | `{"pullPolicy":"IfNotPresent","repository":"burakince/mlflow","tag":""}` | mlflow-db-migration init container image configuration |
| initImages.mlflowDbMigration.pullPolicy | string | `"IfNotPresent"` | mlflow-db-migration init container image pull policy. |
| initImages.mlflowDbMigration.repository | string | `"burakince/mlflow"` | mlflow-db-migration init container image repository to use. |
| initImages.mlflowDbMigration.tag | string | `""` | mlflow-db-migration init container image tag to use. Default app version |
| ldapAuth | object | `{"adminGroupDistinguishedName":"","enabled":false,"encodedTrustedCACertificate":"","externalSecretForTrustedCACertificate":"","groupAttribute":"dn","groupAttributeKey":"","lookupBind":"","searchBaseDistinguishedName":"","searchFilter":"(&(objectclass=groupOfUniqueNames)(uniquemember=%s))","tlsVerification":"required","uri":"","userGroupDistinguishedName":""}` | Basic Authentication with LDAP backend |
| ldapAuth.adminGroupDistinguishedName | string | `""` | LDAP DN for the admin group. e.g.: "cn=test-admin,ou=groups,dc=mlflow,dc=test" |
| ldapAuth.enabled | bool | `false` | Specifies if you want to enable mlflow LDAP authentication. auth, ldapAuth, and oidcAuth can't be enabled at same time. |
| ldapAuth.encodedTrustedCACertificate | string | `""` | Base64 encoded trusted CA certificate for LDAP server connection. |
| ldapAuth.externalSecretForTrustedCACertificate | string | `""` | External secret name for trusted CA certificate for LDAP server connection. |
| ldapAuth.groupAttribute | string | `"dn"` | LDAP group attribute. |
| ldapAuth.groupAttributeKey | string | `""` | Optional group attribute key for Active Directory users. e.g.: "attributes" |
| ldapAuth.lookupBind | string | `""` | LDAP Loopup Bind. e.g.: "uid=%s,ou=people,dc=mlflow,dc=test" |
| ldapAuth.searchBaseDistinguishedName | string | `""` | LDAP base DN for the search. e.g.: "ou=groups,dc=mlflow,dc=test" |
| ldapAuth.searchFilter | string | `"(&(objectclass=groupOfUniqueNames)(uniquemember=%s))"` | LDAP query filter for search |
| ldapAuth.tlsVerification | string | `"required"` | TLS verification mode. Options: required, optional, none |
| ldapAuth.uri | string | `""` | LDAP URI. e.g.: "ldap://lldap:3890/dc=mlflow,dc=test" |
| ldapAuth.userGroupDistinguishedName | string | `""` | LDAP DN for the user group. e.g.: "cn=test-user,ou=groups,dc=mlflow,dc=test" |
| livenessProbe | object | `{"failureThreshold":5,"initialDelaySeconds":10,"periodSeconds":30,"timeoutSeconds":3}` | Liveness probe configurations. Please look to [here](https://kubernetes.io/docs/tasks/configure-pod-container/configure-liveness-readiness-startup-probes/#configure-probes). |
| log | object | `{"enabled":true,"level":"info"}` | Mlflow logging settings |
| log.enabled | bool | `true` | Specifies if you want to enable mlflow logging. |
| log.level | string | `"info"` | Mlflow logging level. |
| minio | object | `{"buckets":[{"name":"mlflow","policy":"none","purge":false}],"deploymentUpdate":{"type":"Recreate"},"drivesPerNode":1,"enabled":false,"mode":"standalone","persistence":{"accessMode":"ReadWriteOnce","annotations":{},"enabled":true,"existingClaim":"","size":"10Gi","storageClass":"","subPath":"","volumeName":""},"policies":[],"pools":1,"replicas":1,"resources":{"requests":{"memory":"1Gi"}},"rootPassword":"","rootUser":"","statefulSetUpdate":{"updateStrategy":"Recreate"},"users":[]}` | MinIO subchart for S3-compatible local artifact storage. When enabled, the MLflow deployment automatically receives AWS_ACCESS_KEY_ID, AWS_SECRET_ACCESS_KEY, and MLFLOW_S3_ENDPOINT_URL from the MinIO secret and service. artifactRoot.s3.enabled must also be set to true with a matching bucket name. |
| minio.buckets | list | `[{"name":"mlflow","policy":"none","purge":false}]` | Buckets to create on startup |
| minio.deploymentUpdate | object | `{"type":"Recreate"}` | Minio deployment update strategy |
| minio.drivesPerNode | int | `1` | Number of drives attached to a node |
| minio.enabled | bool | `false` | Enable the MinIO subchart |
| minio.mode | string | `"standalone"` | MinIO mode |
| minio.persistence | object | `{"accessMode":"ReadWriteOnce","annotations":{},"enabled":true,"existingClaim":"","size":"10Gi","storageClass":"","subPath":"","volumeName":""}` | MinIO persistence settings |
| minio.persistence.accessMode | string | `"ReadWriteOnce"` | Minio persistence access mode |
| minio.persistence.annotations | object | `{}` | Minio persistence annotations |
| minio.persistence.enabled | bool | `true` | Enable persistent storage for MinIO. Disable for ephemeral/test deployments. |
| minio.persistence.existingClaim | string | `""` | Minio persistence existing claim |
| minio.persistence.size | string | `"10Gi"` | Minio persistence size |
| minio.persistence.storageClass | string | `""` | Minio persistence storage class |
| minio.persistence.subPath | string | `""` | Minio persistence sub path |
| minio.persistence.volumeName | string | `""` | Minio persistence volume name |
| minio.policies | list | `[]` | MinIO model bucket policy. |
| minio.pools | int | `1` | Number of expanded MinIO clusters |
| minio.replicas | int | `1` | Number of MinIO containers running |
| minio.resources | object | `{"requests":{"memory":"1Gi"}}` | MinIO resources |
| minio.resources.requests | object | `{"memory":"1Gi"}` | MinIO requests |
| minio.resources.requests.memory | string | `"1Gi"` | MinIO memory request |
| minio.rootPassword | string | `""` | MinIO root password (secret key). Length must be at least 8 characters. |
| minio.rootUser | string | `""` | MinIO root user (access key). Length must be at least 3 characters. |
| minio.statefulSetUpdate | object | `{"updateStrategy":"Recreate"}` | Minio statefulset update strategy |
| minio.users | list | `[]` | MinIO users |
| mysql | object | `{"architecture":"standalone","auth":{"database":"mlflow","password":"","username":""},"enabled":false,"image":{"repository":"bitnamilegacy/mysql"},"primary":{"persistence":{"enabled":true,"existingClaim":""},"service":{"ports":{"mysql":3306}}}}` | Bitnami MySQL configuration. For more information checkout: https://github.com/bitnami/charts/tree/main/bitnami/mysql |
| mysql.auth.database | string | `"mlflow"` | The name of the MySQL database. |
| mysql.enabled | bool | `false` | Enable mysql |
| mysql.image.repository | string | `"bitnamilegacy/mysql"` | This is temporary workaround because of bitnami's deprecation until to completely replace it with our solution. |
| nameOverride | string | `""` | String to override the default generated name |
| nodeSelector | object | `{}` | For more information checkout: https://kubernetes.io/docs/concepts/scheduling-eviction/assign-pod-node/#nodeselector |
| oauth2Proxy | object | `{"cookieSecret":"","createSecret":false,"enabled":false,"existingSecret":{"clientIDKey":"client-id","clientSecretKey":"client-secret","cookieSecretKey":"cookie-secret","name":""},"extraArgs":["--cookie-secure=true","--cookie-samesite=lax"],"extraEnv":{},"image":{"pullPolicy":"IfNotPresent","repository":"quay.io/oauth2-proxy/oauth2-proxy","tag":"v7.15.3"},"listenPort":4180,"provider":{"clientID":"","clientSecret":"","issuerURL":"","name":"keycloak","redirectURL":""},"resources":{}}` | oauth2-proxy sidecar configuration |
| oauth2Proxy.cookieSecret | string | `""` | Cookie secret plaintext value — only used when createSecret is true |
| oauth2Proxy.createSecret | bool | `false` | If true the chart will create a Kubernetes secret with the oauth client id/secret |
| oauth2Proxy.enabled | bool | `false` | Enable deploying oauth2-proxy as a sidecar to the mlflow pod |
| oauth2Proxy.existingSecret | object | `{"clientIDKey":"client-id","clientSecretKey":"client-secret","cookieSecretKey":"cookie-secret","name":""}` | Reference a pre-existing secret instead of creating one. All key name fields below are used both when creating and when referencing an existing secret. |
| oauth2Proxy.existingSecret.clientIDKey | string | `"client-id"` | Secret key that holds the OAuth2 client ID |
| oauth2Proxy.existingSecret.clientSecretKey | string | `"client-secret"` | Secret key that holds the OAuth2 client secret |
| oauth2Proxy.existingSecret.cookieSecretKey | string | `"cookie-secret"` | Secret key that holds the cookie secret |
| oauth2Proxy.existingSecret.name | string | `""` | Name of the pre-existing secret; if empty the chart creates one when createSecret is true |
| oauth2Proxy.extraArgs | list | `["--cookie-secure=true","--cookie-samesite=lax"]` | Extra args to pass to oauth2-proxy as flags |
| oauth2Proxy.extraEnv | object | `{}` | Extra environment variables for oauth2-proxy |
| oauth2Proxy.image | object | `{"pullPolicy":"IfNotPresent","repository":"quay.io/oauth2-proxy/oauth2-proxy","tag":"v7.15.3"}` | OAuth2 Proxy image |
| oauth2Proxy.image.pullPolicy | string | `"IfNotPresent"` | OAuth2 Proxy image pull policy |
| oauth2Proxy.image.repository | string | `"quay.io/oauth2-proxy/oauth2-proxy"` | OAuth2 Proxy image repository |
| oauth2Proxy.image.tag | string | `"v7.15.3"` | OAuth2 Proxy image tag |
| oauth2Proxy.listenPort | int | `4180` | Port oauth2-proxy listens on inside the pod |
| oauth2Proxy.provider | object | `{"clientID":"","clientSecret":"","issuerURL":"","name":"keycloak","redirectURL":""}` | Provider specific settings (example: keycloak) |
| oauth2Proxy.provider.clientID | string | `""` | OAuth2 client ID |
| oauth2Proxy.provider.clientSecret | string | `""` | OAuth2 client secret — prefer existingSecret for production |
| oauth2Proxy.provider.issuerURL | string | `""` | OIDC issuer URL for the provider |
| oauth2Proxy.provider.name | string | `"keycloak"` | Provider name (e.g. keycloak, keycloak-oidc, google, github) |
| oauth2Proxy.provider.redirectURL | string | `""` | OAuth2 redirect / callback URL |
| oauth2Proxy.resources | object | `{}` | Resources for the oauth2-proxy container |
| oidcAuth | object | `{"adminGroupName":["mlflow-admin"],"audience":"","cache":{"enabled":false,"keyPrefix":"mlflow_oidc_auth:","redisUrl":""},"clientId":"","clientSecret":"","database":{"postgres":{"database":"","driver":"","enabled":false,"existingSecret":{"name":"","passwordKey":"password","usernameKey":"username"},"host":"","password":"","port":5432,"user":""},"uri":""},"defaultPermission":"MANAGE","discoveryUrl":"","enabled":false,"existingSecret":{"clientSecretKey":"OIDC_CLIENT_SECRET","name":""},"groupName":["mlflow"],"groupsAttribute":"groups","providerDisplayName":"Login with OIDC","redirectUri":"","scope":"openid,email,profile","sessionCookieSamesite":"lax","sessionCookieSecure":true,"trustedProxies":[]}` | OIDC Authentication via the mlflow-oidc-auth plugin (already bundled in the burakince/mlflow image). Mutually exclusive with auth, ldapAuth, and oauth2Proxy — enable only one auth mechanism. |
| oidcAuth.adminGroupName | list | `["mlflow-admin"]` | Groups whose members receive admin/MANAGE permission (env: OIDC_ADMIN_GROUP_NAME) |
| oidcAuth.audience | string | `""` | Optional audience claim validation (env: OIDC_AUDIENCE) |
| oidcAuth.cache | object | `{"enabled":false,"keyPrefix":"mlflow_oidc_auth:","redisUrl":""}` | Shared cache backend for multi-replica deployments (requires mlflow-oidc-auth[cache], already in image) |
| oidcAuth.cache.enabled | bool | `false` | Set true to use Redis instead of in-process TTLCache (env: CACHE_BACKEND) |
| oidcAuth.cache.keyPrefix | string | `"mlflow_oidc_auth:"` | Cache key prefix to avoid collisions when sharing a Redis instance (env: CACHE_KEY_PREFIX) |
| oidcAuth.cache.redisUrl | string | `""` | Redis connection URL (env: CACHE_REDIS_URL) |
| oidcAuth.clientId | string | `""` | OIDC client ID (env: OIDC_CLIENT_ID) |
| oidcAuth.clientSecret | string | `""` | OIDC client secret — use existingSecret for production (env: OIDC_CLIENT_SECRET) |
| oidcAuth.database | object | `{"postgres":{"database":"","driver":"","enabled":false,"existingSecret":{"name":"","passwordKey":"password","usernameKey":"username"},"host":"","password":"","port":5432,"user":""},"uri":""}` | OIDC user/permission database — separate from the MLflow tracking store. Defaults to sqlite:///auth.db when postgres is not enabled and uri is empty. |
| oidcAuth.database.postgres.database | string | `""` | Database name for the OIDC user/permission database |
| oidcAuth.database.postgres.driver | string | `""` | Postgres driver (e.g. psycopg2; leave empty for the default) |
| oidcAuth.database.postgres.enabled | bool | `false` | Use PostgreSQL for the OIDC user/permission database |
| oidcAuth.database.postgres.existingSecret | object | `{"name":"","passwordKey":"password","usernameKey":"username"}` | Reference a pre-existing DB credentials secret instead of using user and password above |
| oidcAuth.database.postgres.existingSecret.name | string | `""` | Name of the pre-existing DB credentials secret; if empty the chart creates one |
| oidcAuth.database.postgres.existingSecret.passwordKey | string | `"password"` | Key in the secret that holds the database password |
| oidcAuth.database.postgres.existingSecret.usernameKey | string | `"username"` | Key in the secret that holds the database username |
| oidcAuth.database.postgres.host | string | `""` | Postgres host for the OIDC user/permission database |
| oidcAuth.database.postgres.password | string | `""` | Postgres password for the OIDC user/permission database — prefer existingSecret for production |
| oidcAuth.database.postgres.port | int | `5432` | Postgres port for the OIDC user/permission database |
| oidcAuth.database.postgres.user | string | `""` | Postgres username for the OIDC user/permission database |
| oidcAuth.database.uri | string | `""` | Full URI override (env: OIDC_USERS_DB_URI); takes precedence over postgres block when set. Example: postgresql+psycopg2://user:pass@host:5432/oidc_users |
| oidcAuth.defaultPermission | string | `"MANAGE"` | Default permission for authenticated users: NO_PERMISSIONS / READ / EDIT / MANAGE (env: DEFAULT_MLFLOW_PERMISSION) |
| oidcAuth.discoveryUrl | string | `""` | OIDC discovery URL (env: OIDC_DISCOVERY_URL) e.g. https://keycloak/realms/mlflow/.well-known/openid-configuration |
| oidcAuth.existingSecret | object | `{"clientSecretKey":"OIDC_CLIENT_SECRET","name":""}` | Reference a pre-existing secret instead of creating one from clientSecret above |
| oidcAuth.existingSecret.clientSecretKey | string | `"OIDC_CLIENT_SECRET"` | Key in the secret that holds the OIDC client secret value |
| oidcAuth.existingSecret.name | string | `""` | Name of the pre-existing secret; if empty the chart creates one from clientSecret |
| oidcAuth.groupName | list | `["mlflow"]` | Groups whose members are allowed to access MLflow (env: OIDC_GROUP_NAME) |
| oidcAuth.groupsAttribute | string | `"groups"` | JWT claim that contains group memberships (env: OIDC_GROUPS_ATTRIBUTE) |
| oidcAuth.providerDisplayName | string | `"Login with OIDC"` | Display name on the Login button in the MLflow UI (env: OIDC_PROVIDER_DISPLAY_NAME) |
| oidcAuth.redirectUri | string | `""` | Optional redirect URI; auto-detected from request headers when empty (env: OIDC_REDIRECT_URI) |
| oidcAuth.scope | string | `"openid,email,profile"` | Scopes requested from the OIDC provider (env: OIDC_SCOPE) |
| oidcAuth.sessionCookieSamesite | string | `"lax"` | SameSite policy for session cookies: lax / strict / none (env: SESSION_COOKIE_SAMESITE) |
| oidcAuth.sessionCookieSecure | bool | `true` | Require HTTPS for session cookies; set false only in local/dev environments (env: SESSION_COOKIE_SECURE) |
| oidcAuth.trustedProxies | list | `[]` | List of trusted proxy IPs/CIDRs (e.g. ingress controller CIDR). Required when MLflow runs behind an ingress; fixes redirect URI auto-detection. (env: TRUSTED_PROXIES) |
| podAnnotations | object | `{}` | Annotations for the pod |
| podSecurityContext | object | `{"fsGroup":1001,"fsGroupChangePolicy":"OnRootMismatch"}` | This is for setting Security Context to a Pod. For more information checkout: https://kubernetes.io/docs/tasks/configure-pod-container/security-context/ |
| postgresql | object | `{"architecture":"standalone","auth":{"database":"mlflow","password":"","username":""},"enabled":false,"image":{"repository":"bitnamilegacy/postgresql"},"primary":{"persistence":{"enabled":true,"existingClaim":""},"service":{"ports":{"postgresql":5432}}}}` | Bitnami PostgreSQL configuration. For more information checkout: https://github.com/bitnami/charts/tree/main/bitnami/postgresql |
| postgresql.auth.database | string | `"mlflow"` | The name of the PostgreSQL database. |
| postgresql.enabled | bool | `false` | Enable postgresql |
| postgresql.image.repository | string | `"bitnamilegacy/postgresql"` | This is temporary workaround because of bitnami's deprecation until to completely replace it with our solution. |
| priorityClassName | string | `""` | For more information checkout: https://kubernetes.io/docs/concepts/scheduling-eviction/pod-priority-preemption/ |
| readinessProbe | object | `{"failureThreshold":5,"initialDelaySeconds":10,"periodSeconds":30,"timeoutSeconds":3}` | Readiness probe configurations. Please look to [here](https://kubernetes.io/docs/tasks/configure-pod-container/configure-liveness-readiness-startup-probes/#configure-probes). |
| replicaCount | int | `1` | Numbers of replicas |
| resources | object | `{}` | This block is for setting up the resource management for the pod more information can be found here: https://kubernetes.io/docs/concepts/configuration/manage-resources-containers/ |
| revisionHistoryLimit | string | `nil` | The number of old ReplicaSets to retain for rollback. More information can be found here: https://kubernetes.io/docs/concepts/workloads/controllers/deployment/#clean-up-policy |
| securityContext | object | `{"allowPrivilegeEscalation":false,"capabilities":{"drop":["ALL"]},"privileged":false,"readOnlyRootFilesystem":true,"runAsGroup":1001,"runAsNonRoot":true,"runAsUser":1001}` | This is for setting Security Context to a Container. For more information checkout: https://kubernetes.io/docs/tasks/configure-pod-container/security-context/ |
| serverAllowedHosts | list | `[]` | List of allowed hostnames for the MLflow server security middleware (env: MLFLOW_SERVER_ALLOWED_HOSTS). When ingress is enabled, hostnames are automatically derived from ingress hosts. Set explicitly to override auto-detection (e.g. to add extra hostnames beyond the ingress host, or when not using ingress). Requires uvicorn, which is the default server in MLflow 3.x. |
| serverHost | string | `"0.0.0.0"` |  |
| service | object | `{"annotations":{},"containerPort":5000,"containerPortName":"mlflow","enabled":true,"name":"http","port":80,"type":"ClusterIP"}` | This is for setting up a service more information can be found here: https://kubernetes.io/docs/concepts/services-networking/service/ |
| service.annotations | object | `{}` | Additional service annotations |
| service.containerPort | int | `5000` | Default container port |
| service.containerPortName | string | `"mlflow"` | Default container port name |
| service.enabled | bool | `true` | Specifies if you want to create a service |
| service.name | string | `"http"` | Port protocol name for the main HTTP port in the Service spec. This sets spec.ports[].name, not the Service resource name. To rename the Service resource itself use nameOverride or fullnameOverride. |
| service.port | int | `80` | This sets the ports more information can be found here: https://kubernetes.io/docs/concepts/services-networking/service/#field-spec-ports |
| service.type | string | `"ClusterIP"` | This sets the service type more information can be found here: https://kubernetes.io/docs/concepts/services-networking/service/#publishing-services-service-types |
| serviceAccount.annotations | object | `{}` | Annotations to add to the service account. AWS EKS users can assign role arn from here. Please find more information from here: https://docs.aws.amazon.com/eks/latest/userguide/associate-service-account-role.html |
| serviceAccount.automount | bool | `true` | Automatically mount a ServiceAccount's API credentials? |
| serviceAccount.create | bool | `true` | Specifies whether a ServiceAccount should be created |
| serviceAccount.name | string | `""` | The name of the ServiceAccount to use. If not set and create is true, a name is generated using the fullname template |
| serviceMonitor.enabled | bool | `false` | When set true then use a ServiceMonitor to configure scraping |
| serviceMonitor.interval | string | `"30s"` | Set how frequently Prometheus should scrape |
| serviceMonitor.labels | object | `{"release":"prometheus"}` | Set labels for the ServiceMonitor, use this to define your scrape label for Prometheus Operator |
| serviceMonitor.labels.release | string | `"prometheus"` | default `kube prometheus stack` helm chart serviceMonitor selector label Mostly it's your prometheus helm release name. Please find more information from here: https://github.com/prometheus-operator/prometheus-operator/blob/main/Documentation/platform/troubleshooting.md#troubleshooting-servicemonitor-changes |
| serviceMonitor.metricRelabelings | list | `[]` | Set of rules to relabel your exist metric labels |
| serviceMonitor.namespace | string | `"monitoring"` | Set the namespace the ServiceMonitor should be deployed |
| serviceMonitor.targetLabels | list | `[]` | Set of labels to transfer on the Kubernetes Service onto the target. |
| serviceMonitor.telemetryPath | string | `"/metrics"` | Set path to mlflow telemetry-path |
| serviceMonitor.timeout | string | `"10s"` | Set timeout for scrape |
| serviceMonitor.useServicePort | bool | `false` | When set true then use a service port. On default use a pod port. |
| strategy | object | `{"rollingUpdate":{"maxSurge":"100%","maxUnavailable":0},"type":"RollingUpdate"}` | This will set the deployment strategy more information can be found here: https://kubernetes.io/docs/concepts/workloads/controllers/deployment/#strategy |
| telemetry | object | `{"enabled":false}` | Mlflow Usage Tracking settings. More information can be found here: https://mlflow.org/docs/latest/community/usage-tracking/ |
| telemetry.enabled | bool | `false` | Specifies if you want to enable collecting anonymized usage data about how core features of the platform are used. |
| tolerations | list | `[]` | For more information checkout: https://kubernetes.io/docs/concepts/scheduling-eviction/taint-and-toleration/ |

**Homepage:** <https://mlflow.org>

## Source Code

* <https://github.com/community-charts/helm-charts>
* <https://github.com/burakince/mlflow>
* <https://github.com/mlflow/mlflow>

## Chart Development

Please install unittest helm plugin with `helm plugin install https://github.com/helm-unittest/helm-unittest.git` command and use following command to run helm unit tests.

```console
helm unittest --strict --file 'unittests/**/*.yaml' charts/mlflow
```

## Maintainers

| Name | Email | Url |
| ---- | ------ | --- |
| burakince | <burak.ince@linux.org.tr> | <https://www.burakince.com> |
