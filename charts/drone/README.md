# drone

![drone](https://raw.githubusercontent.com/drone/brand/master/logos/vector/drone-logo-back-with-text.svg)

A Helm chart for Drone Server and Drone Kubernetes Runner

![Version: 0.0.9](https://img.shields.io/badge/Version-0.0.9-informational?style=flat-square) ![Type: application](https://img.shields.io/badge/Type-application-informational?style=flat-square) ![AppVersion: 2.12.1](https://img.shields.io/badge/AppVersion-2.12.1-informational?style=flat-square)

## Get Helm Repository Info

```console
helm repo add community-charts https://community-charts.github.io/helm-charts
helm repo update
```

_See [`helm repo`](https://helm.sh/docs/helm/helm_repo/) for command documentation._

## Installing the Chart

```console
helm install [RELEASE_NAME] community-charts/drone
```

_See [configuration](#configuration) below._

_See [helm install](https://helm.sh/docs/helm/helm_install/) for command documentation._

> **Tip**: Search all available chart versions using `helm search repo community-charts -l`. Please don't forget to run `helm repo update` before the command.

## Values File Examples

Please find the following example of Drone CI with Kubernetes Ingress and Postgres DB and Gitea integration.

```yaml
server:
  ingress:
    enabled: true
    hosts:
      - host: drone.example.com
        paths:
          - path: /
            pathType: ImplementationSpecific

  env:
    DRONE_SERVER_HOST: drone.example.com
    DRONE_SERVER_PROTO: http
    DRONE_DATABASE_DRIVER: postgres
    DRONE_GITEA_SERVER: http://gitea.example.com

  secrets:
    # openssl rand -hex 16
    # DRONE_DATABASE_SECRET: a1501fdf503fbbdda9e736c1b020b8fc
    DRONE_DATABASE_DATASOURCE: "postgres://postgres:postgres@postgres-service:5432/postgres?sslmode=disable"
    # DRONE_GITEA_CLIENT_ID: 6a6e252b-8bad-4aeb-9178-ee8ed6b84150
    # DRONE_GITEA_CLIENT_SECRET: RyJ3hmG2A4Q2MDMEO433qIkokbpR7QjEodxHTylMV7xj
    DRONE_USER_CREATE: "username:testuser,admin:true"
    DRONE_USER_FILTER: testuser
```

You can generate an database secret with `openssl rand -hex 16` command. Please never store any secret in your git repository. You can pass them with the helm set command.

```console
helm upgrade --install drone community-charts/drone/ \
  --set server.secrets.DRONE_DATABASE_SECRET="a1501fdf503fbbdda9e736c1b020b8fc" \
  --set server.secrets.DRONE_GITEA_CLIENT_ID="6a6e252b-8bad-4aeb-9178-ee8ed6b84150" \
  --set server.secrets.DRONE_GITEA_CLIENT_SECRET="RyJ3hmG2A4Q2MDMEO433qIkokbpR7QjEodxHTylMV7xj" \
  --values values.yaml
```

## Requirements

Kubernetes: `>=1.13.0-0`

## Uninstall Helm Chart

```console
helm uninstall [RELEASE_NAME]
```

This removes all the Kubernetes components associated with the chart and deletes the release.

_See [helm uninstall](https://helm.sh/docs/helm/helm_uninstall/) for command documentation._

## Upgrading Chart

```console
helm upgrade [RELEASE_NAME] community-charts/drone
```

## Values

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| fullnameOverride | string | `""` | String to override the default generated fullname |
| imagePullSecrets | list | `[]` | Image pull secrets for private docker registry usages Ref: https://kubernetes.io/docs/tasks/configure-pod-container/pull-image-private-registry/ |
| kubeRunner.affinity | object | `{}` | Set the affinity for the kube runner pod. |
| kubeRunner.enabled | bool | `true` | Specifies whether a kube runner should be created |
| kubeRunner.env.DRONE_NAMESPACE_DEFAULT | string | `"default"` | Determines the default Kubernetes namespace for Drone builds to run in. Ref: https://docs.drone.io/runner/kubernetes/configuration/reference/drone-namespace-default/ |
| kubeRunner.env.DRONE_RPC_PROTO | string | `"http"` | The protocol to use for communication with Drone server. Ref: https://docs.drone.io/runner/kubernetes/configuration/reference/drone-rpc-proto/ |
| kubeRunner.extraSecretNamesForEnvFrom | list | `[]` | If you'd like to provide your own Kubernetes Secret object instead of passing your values in un-encrypted, pass in the name of a created + populated Secret in the same Namespace as the Kubernetes runner. All secrets within this configmap will be mounted as environment variables, with each key/value mapping to a corresponding environment variable on the Kubernetes runner. |
| kubeRunner.extraVolumeMounts | list | `[]` | If you have declared extra volumes, mount them here, per the Pod Container's "volumeMounts" section. |
| kubeRunner.extraVolumes | list | `[]` | If you'd like to make additional files or volumes available to the runner, declare additional Volumes here per the Pod spec's "volumes" section. Ref: https://kubernetes.io/docs/concepts/storage/volumes/ |
| kubeRunner.image.pullPolicy | string | `"IfNotPresent"` | The kube runner image pull policy |
| kubeRunner.image.repository | string | `"drone/drone-runner-kube"` | The kube runner docker image repository to use |
| kubeRunner.image.tag | string | `"1.0.0-rc.2"` | The kube runner image tag to use |
| kubeRunner.ingress.annotations | object | `{}` | Additional kube runner ingress annotations |
| kubeRunner.ingress.className | string | `""` | Specifies if you want to use different ingress controller for kube runner |
| kubeRunner.ingress.enabled | bool | `false` | Specifies if you want to create an ingress access to kube runner |
| kubeRunner.ingress.hosts[0].host | string | `"chart-example.local"` |  |
| kubeRunner.ingress.hosts[0].paths[0].path | string | `"/"` |  |
| kubeRunner.ingress.hosts[0].paths[0].pathType | string | `"ImplementationSpecific"` | Kube runner ingress path type |
| kubeRunner.ingress.tls | list | `[]` | Kube runner ingress tls configuration for https access |
| kubeRunner.nodeSelector | object | `{}` | If you'd like to force the Drone runner to run on a specific node or set of nodes, set a selector here. |
| kubeRunner.podAnnotations | object | `{}` | Annotations for the kube runner pod |
| kubeRunner.podSecurityContext | object | `{}` | Security context for all kube runner pod |
| kubeRunner.rbac | object | `{"buildNamespaces":["default"]}` | Each namespace listed below will be configured such that the runner can run build Pods in it. This comes in the form of a Role and a RoleBinding. If you change env.DRONE_NAMESPACE_DEFAULT or the other DRONE_NAMESPACE_* variables, make sure to update this list to include all namespaces. |
| kubeRunner.replicaCount | int | `1` | Numbers of runner replicas For small or experimental deployments of the Kubernetes runner, 1 replica will suffice. For production cases, 2-3 are recommended. This does not grant additional parallelism, but does ensure that upgrades, config changes, and disruptions are handled more gracefully. |
| kubeRunner.resources | object | `{}` | Set the kube runner resources requests and limits |
| kubeRunner.securityContext | object | `{}` | Security context for the kube runner container |
| kubeRunner.service.annotations | object | `{}` | Additional kube runner service annotations |
| kubeRunner.service.port | int | `3000` | Default kube runner Service port |
| kubeRunner.service.type | string | `"ClusterIP"` | Specifies what type of kube runner Service should be created |
| kubeRunner.serviceAccount.annotations | object | `{}` | Annotations to add to the kube runner service account |
| kubeRunner.serviceAccount.create | bool | `true` | Specifies whether a kube runner service account should be created |
| kubeRunner.serviceAccount.name | string | `""` | The name of the kube runner service account to use. If not set and create is true, a name is generated using the fullname template |
| kubeRunner.terminationGracePeriodSeconds | int | `3600` | When the runner receives a SIGTERM/SIGINT (config update, upgrade, etc), it will wait until all jobs that particular pod has spawned complete. It is for this reason that you'll want to make sure that this value is longer than your longest job. |
| kubeRunner.tolerations | list | `[]` | Set the tolerations for the kube runner pod. |
| nameOverride | string | `""` | String to override the default generated name |
| server.affinity | object | `{}` | Set the affinity for the drone server pod. |
| server.emptyDir | object | `{"sizeLimit":""}` | If persistentVolume.enabled is set to false, Drone will mount an emptyDir instead of a PVC for any state that it needs to persist. |
| server.emptyDir.sizeLimit | string | `""` | Total space to request for the emptyDir. An empty value here means no limit. |
| server.env.DRONE_GIT_ALWAYS_AUTH | bool | `false` | If you are using self-hosted GitHub or GitLab, you'll need to set this to true. Ref: https://docs.drone.io/server/reference/drone-git-always-auth/ |
| server.env.DRONE_SERVER_HOST | string | `"drone.example.com"` | REQUIRED: Set the user-visible Drone hostname, sans protocol. Ref: https://docs.drone.io/server/reference/drone-server-host/ |
| server.env.DRONE_SERVER_PROTO | string | `"http"` | The protocol to pair with the value in DRONE_SERVER_HOST (http or https). Ref: https://docs.drone.io/server/reference/drone-server-proto/ |
| server.extraVolumeMounts | list | `[]` | If you have declared extra volumes, mount them here, per the Pod Container's "volumeMounts" section. |
| server.extraVolumes | list | `[]` | If you'd like to make additional files or volumes available to Drone, declare additional Volumes here per the Pod spec's "volumes" section. Ref: https://kubernetes.io/docs/concepts/storage/volumes/ |
| server.image.pullPolicy | string | `"IfNotPresent"` | The drone server image pull policy |
| server.image.repository | string | `"drone/drone"` | The drone server docker image repository to use |
| server.image.tag | string | `""` | The drone server image tag to use. Default app version |
| server.ingress.annotations | object | `{}` | Additional drone server ingress annotations |
| server.ingress.className | string | `""` | Specifies if you want to use different ingress controller for drone server |
| server.ingress.enabled | bool | `false` | Specifies if you want to create an ingress access to drone server |
| server.ingress.hosts[0].host | string | `"chart-example.local"` |  |
| server.ingress.hosts[0].paths[0].path | string | `"/"` |  |
| server.ingress.hosts[0].paths[0].pathType | string | `"ImplementationSpecific"` | Drone server ingress path type |
| server.ingress.tls | list | `[]` | Drone server ingress tls configuration for https access |
| server.nodeSelector | object | `{}` | Set the node selector for the drone server pod. |
| server.persistentVolume.accessModes | list | `["ReadWriteOnce"]` | Drone server data Persistent Volume access modes Must match those of existing PV or dynamic provisioner Ref: http://kubernetes.io/docs/user-guide/persistent-volumes/ |
| server.persistentVolume.annotations | object | `{}` | Drone server data Persistent Volume annotations |
| server.persistentVolume.enabled | bool | `true` | If you are using SQLite as your DB for Drone, it is recommended to enable persistence. If enabled, the Chart will create a PersistentVolumeClaim to store its state in. If you are using a DB other than SQLite, set this to false to avoid allocating unused storage. If set to false, Drone will use an emptyDir instead, which is ephemeral. |
| server.persistentVolume.existingClaim | string | `""` | If you'd like to bring your own PVC for persisting Drone state, pass the name of the created + ready PVC here. If set, this Chart will not create the default PVC. Requires server.persistentVolume.enabled: true |
| server.persistentVolume.mountPath | string | `"/data"` | Drone server data Persistent Volume mount root path |
| server.persistentVolume.size | string | `"8Gi"` | Drone server data Persistent Volume size |
| server.persistentVolume.storageClass | string | `""` | Drone server data Persistent Volume Storage Class If defined, storageClassName: <storageClass> If set to "-", storageClassName: "", which disables dynamic provisioning If undefined (the default) or set to null, no storageClassName spec is   set, choosing the default provisioner.  (gp2 on AWS, standard on   GKE, AWS & OpenStack) |
| server.persistentVolume.subPath | string | `""` | Subdirectory of Drone server data Persistent Volume to mount Useful if the volume's root directory is not empty |
| server.persistentVolume.volumeMode | string | `""` | Drone server data Persistent Volume Binding Mode If defined, volumeMode: <volumeMode> If empty (the default) or set to null, no volumeBindingMode spec is set, choosing the default mode. |
| server.podAnnotations | object | `{}` | Annotations for the drone server pod |
| server.podSecurityContext | object | `{}` | Security context for all drone server pod |
| server.replicaCount | int | `1` | Numbers of server replicas |
| server.resources | object | `{}` | Set the drone server resources requests and limits |
| server.secrets | object | `{}` | Drone server secrets |
| server.securityContext | object | `{}` | Security context for the drone server container |
| server.service.annotations | object | `{}` | Additional drone server service annotations |
| server.service.port | int | `80` | Default drone server Service port |
| server.service.type | string | `"ClusterIP"` | Specifies what type of drone server Service should be created |
| server.serviceAccount.annotations | object | `{}` | Annotations to add to the drone server service account. |
| server.serviceAccount.create | bool | `true` | Specifies whether a Drone server ServiceAccount should be created |
| server.serviceAccount.name | string | `""` | The name of the drone server service account to use. If not set and create is true, a name is generated using the fullname template |
| server.tolerations | list | `[]` | Set the tolerations for the drone server pod. |

## Support

For questions, suggestions, and discussion, visit the [Drone community site](https://discourse.drone.io/).

**Homepage:** <https://www.drone.io>

## Source Code

* <https://github.com/community-charts/helm-charts>
* <https://github.com/drone>

## Maintainers

| Name | Email | Url |
| ---- | ------ | --- |
| burakince | <burak.ince@linux.org.tr> | <https://www.burakince.net> |
