# mlflow

![mlflow](https://raw.githubusercontent.com/mlflow/mlflow/refs/heads/master/docs/static/images/logo-light.svg)

A Helm chart for Mlflow open source platform for the machine learning lifecycle

![Version: 1.6.2](https://img.shields.io/badge/Version-1.6.2-informational?style=flat-square) ![Type: application](https://img.shields.io/badge/Type-application-informational?style=flat-square) ![AppVersion: 3.3.2](https://img.shields.io/badge/AppVersion-3.3.2-informational?style=flat-square)

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

> **Tip**: auth and ldapAuth can not be enabled at same time!

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

> **Tip**: auth and ldapAuth can not be enabled at same time!

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

## Auto Scaling Example

This Helm chart supports Horizontal Pod Autoscaling (HPA) to dynamically scale the MLflow `Deployment` based on metrics. The HPA resource is created when `autoscaling.enabled` is `true` and specific conditions are met (see Prerequisites).

### Prerequisites

The HPA is created only if:

- `autoscaling.enabled: true`
- A backend store is enabled (`backendStore.postgres.enabled` or `backendStore.mysql.enabled`).
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
| https://charts.bitnami.com/bitnami | postgresql | 16.7.27 |

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
| artifactRoot.s3 | object | `{"awsAccessKeyId":"","awsSecretAccessKey":"","bucket":"","enabled":false,"existingSecret":{"keyOfAccessKeyId":"","keyOfSecretAccessKey":"","name":""},"path":""}` | Specifies if you want to use AWS S3 Mlflow Artifact Root |
| artifactRoot.s3.awsAccessKeyId | string | `""` | AWS IAM user AWS_ACCESS_KEY_ID which has attached policy for access to the S3 bucket |
| artifactRoot.s3.awsSecretAccessKey | string | `""` | AWS IAM user AWS_SECRET_ACCESS_KEY which has attached policy for access to the S3 bucket |
| artifactRoot.s3.bucket | string | `""` | S3 bucket name |
| artifactRoot.s3.enabled | bool | `false` | Specifies if you want to use AWS S3 Mlflow Artifact Root |
| artifactRoot.s3.existingSecret | object | `{"keyOfAccessKeyId":"","keyOfSecretAccessKey":"","name":""}` | Existing secret for AWS IAM user AWS_ACCESS_KEY_ID and AWS_SECRET_ACCESS_KEY secrets. |
| artifactRoot.s3.existingSecret.keyOfAccessKeyId | string | `""` | This is for setting up the key for AWS_ACCESS_KEY_ID secret. If it's set, awsAccessKeyId will be ignored. |
| artifactRoot.s3.existingSecret.keyOfSecretAccessKey | string | `""` | This is for setting up the key for AWS_SECRET_ACCESS_KEY secret. If it's set, awsSecretAccessKey will be ignored. |
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
| auth.enabled | bool | `false` | Specifies if you want to enable mlflow authentication. auth and ldapAuth can't be enabled at same time. |
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
| backendStore | object | `{"databaseConnectionCheck":false,"databaseMigration":false,"defaultSqlitePath":":memory:","existingDatabaseSecret":{"name":"","passwordKey":"password","usernameKey":"username"},"mysql":{"database":"","driver":"pymysql","enabled":false,"host":"","password":"","port":3306,"user":""},"postgres":{"database":"","driver":"","enabled":false,"host":"","password":"","port":5432,"user":""}}` | Mlflow database connection settings |
| backendStore.databaseConnectionCheck | bool | `false` | Add an additional init container, which checks for database availability |
| backendStore.databaseMigration | bool | `false` | Specifies if you want to run database migration |
| backendStore.defaultSqlitePath | string | `":memory:"` | Specifies the default sqlite path |
| backendStore.existingDatabaseSecret | object | `{"name":"","passwordKey":"password","usernameKey":"username"}` | Specifies if you want to use an existing database secret. |
| backendStore.existingDatabaseSecret.name | string | `""` | The name of the existing database secret. |
| backendStore.existingDatabaseSecret.passwordKey | string | `"password"` | The key of the password in the existing database secret. |
| backendStore.existingDatabaseSecret.usernameKey | string | `"username"` | The key of the username in the existing database secret. |
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
| extraArgs | object | `{}` | A map of arguments and values to pass to the `mlflow server` command. Keys must be camelcase. Helm will turn them to kebabcase style. |
| extraContainers | list | `[]` | Extra containers for the mlflow pod |
| extraEnvVars | object | `{}` | Extra environment variables |
| extraFlags | list | `[]` | A list of flags to pass to `mlflow server` command. Items must be camelcase. Helm will turn them to kebabcase style. |
| extraPodLabels | object | `{}` | Extra labels for the pod |
| extraSecretNamesForEnvFrom | list | `[]` | Extra secrets for environment variables |
| extraVolumeMounts | list | `[]` | Extra Volume Mounts for the mlflow container |
| extraVolumes | list | `[]` | Extra Volumes for the pod |
| flaskServerSecretKey | string | `""` | Mlflow Flask Server Secret Key. Default: Will be auto generated. |
| fullnameOverride | string | `""` | String to override the default generated fullname |
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
| ldapAuth | object | `{"adminGroupDistinguishedName":"","enabled":false,"encodedTrustedCACertificate":"","externalSecretForTrustedCACertificate":"","groupAttribute":"dn","groupAttributeKey":"","lookupBind":"","searchBaseDistinguishedName":"","searchFilter":"(&(objectclass=groupOfUniqueNames)(uniquemember=%s))","tlsVerification":"required","uri":"","userGroupDistinguishedName":""}` | Basic Authentication with LDAP backend |
| ldapAuth.adminGroupDistinguishedName | string | `""` | LDAP DN for the admin group. e.g.: "cn=test-admin,ou=groups,dc=mlflow,dc=test" |
| ldapAuth.enabled | bool | `false` | Specifies if you want to enable mlflow LDAP authentication. auth and ldapAuth can't be enabled at same time. |
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
| mysql | object | `{"architecture":"standalone","auth":{"database":"mlflow","password":"","username":""},"enabled":false,"primary":{"persistence":{"enabled":true,"existingClaim":""},"service":{"ports":{"mysql":3306}}}}` | Bitnami MySQL configuration. For more information checkout: https://github.com/bitnami/charts/tree/main/bitnami/mysql |
| mysql.auth.database | string | `"mlflow"` | The name of the MySQL database. |
| mysql.enabled | bool | `false` | Enable mysql |
| nameOverride | string | `""` | String to override the default generated name |
| nodeSelector | object | `{}` | For more information checkout: https://kubernetes.io/docs/concepts/scheduling-eviction/assign-pod-node/#nodeselector |
| podAnnotations | object | `{}` | Annotations for the pod |
| podSecurityContext | object | `{"fsGroup":1001,"fsGroupChangePolicy":"OnRootMismatch"}` | This is for setting Security Context to a Pod. For more information checkout: https://kubernetes.io/docs/tasks/configure-pod-container/security-context/ |
| postgresql | object | `{"architecture":"standalone","auth":{"database":"mlflow","password":"","username":""},"enabled":false,"primary":{"persistence":{"enabled":true,"existingClaim":""},"service":{"ports":{"postgresql":5432}}}}` | Bitnami PostgreSQL configuration. For more information checkout: https://github.com/bitnami/charts/tree/main/bitnami/postgresql |
| postgresql.auth.database | string | `"mlflow"` | The name of the PostgreSQL database. |
| postgresql.enabled | bool | `false` | Enable postgresql |
| readinessProbe | object | `{"failureThreshold":5,"initialDelaySeconds":10,"periodSeconds":30,"timeoutSeconds":3}` | Readiness probe configurations. Please look to [here](https://kubernetes.io/docs/tasks/configure-pod-container/configure-liveness-readiness-startup-probes/#configure-probes). |
| replicaCount | int | `1` | Numbers of replicas |
| resources | object | `{}` | This block is for setting up the resource management for the pod more information can be found here: https://kubernetes.io/docs/concepts/configuration/manage-resources-containers/ |
| securityContext | object | `{"allowPrivilegeEscalation":false,"capabilities":{"drop":["ALL"]},"privileged":false,"readOnlyRootFilesystem":false,"runAsGroup":1001,"runAsNonRoot":true,"runAsUser":1001}` | This is for setting Security Context to a Container. For more information checkout: https://kubernetes.io/docs/tasks/configure-pod-container/security-context/ |
| service | object | `{"annotations":{},"containerPort":5000,"containerPortName":"mlflow","enabled":true,"name":"http","port":80,"type":"ClusterIP"}` | This is for setting up a service more information can be found here: https://kubernetes.io/docs/concepts/services-networking/service/ |
| service.annotations | object | `{}` | Additional service annotations |
| service.containerPort | int | `5000` | Default container port |
| service.containerPortName | string | `"mlflow"` | Default container port name |
| service.enabled | bool | `true` | Specifies if you want to create a service |
| service.name | string | `"http"` | Default Service name |
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
