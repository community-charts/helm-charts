# kserve

![kserve](https://raw.githubusercontent.com/kserve/website/main/docs/images/logo/kserve.png)

Helm chart for KServe Serverless Inferencing on Kubernetes

![Version: 1.0.1](https://img.shields.io/badge/Version-1.0.1-informational?style=flat-square) ![Type: application](https://img.shields.io/badge/Type-application-informational?style=flat-square) ![AppVersion: v0.8.0](https://img.shields.io/badge/AppVersion-v0.8.0-informational?style=flat-square)

## Get Helm Repository Info

```console
helm repo add community-charts https://community-charts.github.io/helm-charts
helm repo update
```

_See [`helm repo`](https://helm.sh/docs/helm/helm_repo/) for command documentation._

## Installing the Chart

```console
helm install [RELEASE_NAME] community-charts/kserve
```

_See [configuration](#configuration) below._

_See [helm install](https://helm.sh/docs/helm/helm_install/) for command documentation._

> **Tip**: Search all available chart versions using `helm search repo community-charts -l`. Please don't forget to run `helm repo update` before the command.

## Requirements

| Repository | Name | Version |
|------------|------|---------|
| https://charts.jetstack.io | cert-manager(cert-manager) | >=1.5.0 |

## Uninstall Helm Chart

```console
helm uninstall [RELEASE_NAME]
```

This removes all the Kubernetes components associated with the chart and deletes the release.

_See [helm uninstall](https://helm.sh/docs/helm/helm_uninstall/) for command documentation._

## Upgrading Chart

```console
helm upgrade [RELEASE_NAME] community-charts/kserve
```

## Values

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| certManager.enabled | bool | `true` |  |
| kserve.agent.image | string | `"kserve/agent:v0.8.0"` |  |
| kserve.controller.deploymentMode | string | `"Serverless"` |  |
| kserve.controller.gateway.domain | string | `"example.com"` |  |
| kserve.controller.gateway.ingressGateway.gateway | string | `"knative-serving/knative-ingress-gateway"` |  |
| kserve.controller.gateway.ingressGateway.gatewayService | string | `"istio-ingressgateway.istio-system.svc.cluster.local"` |  |
| kserve.controller.gateway.localGateway.gateway | string | `"knative-serving/knative-local-gateway"` |  |
| kserve.controller.gateway.localGateway.gatewayService | string | `"knative-local-gateway.istio-system.svc.cluster.local"` |  |
| kserve.controller.image | string | `"kserve/kserve-controller:v0.8.0"` |  |
| kserve.controller.resources.limits.cpu | string | `"100m"` |  |
| kserve.controller.resources.limits.memory | string | `"300Mi"` |  |
| kserve.controller.resources.requests.cpu | string | `"100m"` |  |
| kserve.controller.resources.requests.memory | string | `"300Mi"` |  |
| kserve.modelmesh.config.modelmeshImage | string | `"kserve/modelmesh"` |  |
| kserve.modelmesh.config.modelmeshImageTag | string | `"v0.8.0"` |  |
| kserve.modelmesh.config.modelmeshRuntimeAdapterImage | string | `"kserve/modelmesh-runtime-adapter"` |  |
| kserve.modelmesh.config.modelmeshRuntimeAdapterImageTag | string | `"v0.8.0"` |  |
| kserve.modelmesh.config.podsPerRuntime | int | `2` |  |
| kserve.modelmesh.config.restProxyImage | string | `"kserve/rest-proxy"` |  |
| kserve.modelmesh.config.restProxyImageTag | string | `"v0.1.1"` |  |
| kserve.modelmesh.controller.image | string | `"kserve/modelmesh-controller:v0.8.0"` |  |
| kserve.servingruntime.aix.defaultVersion | string | `"v0.8.0"` |  |
| kserve.servingruntime.aix.image | string | `"kserve/aix-explainer"` |  |
| kserve.servingruntime.alibi.defaultVersion | string | `"v0.8.0"` |  |
| kserve.servingruntime.alibi.image | string | `"kserve/alibi-explainer"` |  |
| kserve.servingruntime.art.defaultVersion | string | `"v0.8.0"` |  |
| kserve.servingruntime.art.image | string | `"kserve/art-explainer"` |  |
| kserve.servingruntime.lgbserver.image | string | `"kserve/lgbserver"` |  |
| kserve.servingruntime.lgbserver.tag | string | `"v0.8.0"` |  |
| kserve.servingruntime.mlserver.image | string | `"docker.io/seldonio/mlserver"` |  |
| kserve.servingruntime.mlserver.modelClassPlaceholder | string | `"{{.Labels.modelClass}}"` |  |
| kserve.servingruntime.mlserver.tag | string | `"0.5.3"` |  |
| kserve.servingruntime.modelNamePlaceholder | string | `"{{.Name}}"` |  |
| kserve.servingruntime.paddleserver.image | string | `"kserve/paddleserver"` |  |
| kserve.servingruntime.paddleserver.tag | string | `"v0.8.0"` |  |
| kserve.servingruntime.pmmlserver.image | string | `"kserve/pmmlserver"` |  |
| kserve.servingruntime.pmmlserver.tag | string | `"v0.8.0"` |  |
| kserve.servingruntime.sklearnserver.image | string | `"kserve/sklearnserver"` |  |
| kserve.servingruntime.sklearnserver.tag | string | `"v0.8.0"` |  |
| kserve.servingruntime.tensorflow.image | string | `"tensorflow/serving"` |  |
| kserve.servingruntime.tensorflow.tag | string | `"2.6.2"` |  |
| kserve.servingruntime.torchserve.image | string | `"kserve/torchserve-kfs"` |  |
| kserve.servingruntime.torchserve.serviceEnvelopePlaceholder | string | `"{{.Labels.serviceEnvelope}}"` |  |
| kserve.servingruntime.torchserve.tag | string | `"0.5.2"` |  |
| kserve.servingruntime.tritonserver.image | string | `"nvcr.io/nvidia/tritonserver"` |  |
| kserve.servingruntime.tritonserver.tag | string | `"21.09-py3"` |  |
| kserve.servingruntime.xgbserver.image | string | `"kserve/xgbserver"` |  |
| kserve.servingruntime.xgbserver.tag | string | `"v0.8.0"` |  |
| kserve.storage.image | string | `"kserve/storage-initializer:v0.8.0"` |  |
| kserve.storage.s3.accessKeyIdName | string | `"AWS_ACCESS_KEY_ID"` |  |
| kserve.storage.s3.secretAccessKeyName | string | `"AWS_SECRET_ACCESS_KEY"` |  |

**Homepage:** <https://kserve.github.io/website/>

## Source Code

* <http://github.com/kserve/kserve>
* <https://github.com/community-charts/helm-charts>

## Maintainers

| Name | Email | Url |
| ---- | ------ | --- |
| burakince | <burak.ince@linux.org.tr> | <https://www.burakince.net> |
