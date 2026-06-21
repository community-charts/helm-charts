{{/*
Expand the name of the chart.
*/}}
{{- define "mlflow.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "mlflow.fullname" -}}
{{- if .Values.fullnameOverride }}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- $name := default .Chart.Name .Values.nameOverride }}
{{- if contains $name .Release.Name }}
{{- .Release.Name | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" }}
{{- end }}
{{- end }}
{{- end }}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "mlflow.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "mlflow.labels" -}}
helm.sh/chart: {{ include "mlflow.chart" . }}
{{ include "mlflow.selectorLabels" . }}
{{- if .Chart.AppVersion }}
version: {{ .Chart.AppVersion | quote }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "mlflow.selectorLabels" -}}
app: {{ include "mlflow.name" . }}
app.kubernetes.io/name: {{ include "mlflow.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Create the name of the service account to use
*/}}
{{- define "mlflow.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- default (include "mlflow.fullname" .) .Values.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}

{{/*
Generate random hex similar to `openssl rand -hex 16` command.
Usage: {{ include "mlflow.generateRandomHex" 32 }}
*/}}
{{- define "mlflow.generateRandomHex" -}}
{{- $length := . -}}
{{- $chars := list "0" "1" "2" "3" "4" "5" "6" "7" "8" "9" "a" "b" "c" "d" "e" "f" -}}
{{- $result := "" -}}
{{- range $i := until $length -}}
  {{- $result = print $result (index $chars (randInt 0 16)) -}}
{{- end -}}
{{- $result -}}
{{- end -}}

{{/*
Create postgresql name secret name.
*/}}
{{- define "mlflow.postgresql.fullname" -}}
{{- printf "%s-postgresql" (include "mlflow.fullname" .) | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Create mysql name secret name.
*/}}
{{- define "mlflow.mysql.fullname" -}}
{{- printf "%s-mysql" (include "mlflow.fullname" .) | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Return the name of the oauth2-proxy secret.
When existingSecret.name is set the user manages the secret; otherwise the chart creates one.
Usage: {{ include "mlflow.oauth2ProxySecretName" . }}
*/}}
{{- define "mlflow.oauth2ProxySecretName" -}}
{{- default (printf "%s-oauth2-proxy" (include "mlflow.fullname" .)) .Values.oauth2Proxy.existingSecret.name -}}
{{- end -}}

{{/*
Return the name of the OIDC auth client-credentials secret.
When existingSecret.name is set the user manages the secret; otherwise the chart creates one.
Usage: {{ include "mlflow.oidcAuthSecretName" . }}
*/}}
{{- define "mlflow.oidcAuthSecretName" -}}
{{- default (printf "%s-oidc-auth-secret" (include "mlflow.fullname" .)) .Values.oidcAuth.existingSecret.name -}}
{{- end -}}

{{/*
Return the name of the OIDC auth database credentials secret.
When existingSecret.name is set the user manages the secret; otherwise the chart creates one.
Usage: {{ include "mlflow.oidcAuthDbSecretName" . }}
*/}}
{{- define "mlflow.oidcAuthDbSecretName" -}}
{{- default (printf "%s-oidc-auth-db-secret" (include "mlflow.fullname" .)) .Values.oidcAuth.database.postgres.existingSecret.name -}}
{{- end -}}

{{/*
Build the full container image reference, appending digest when set.
*/}}
{{- define "mlflow.containerImage" -}}
{{- $tag := .Values.image.tag | default .Chart.AppVersion -}}
{{- if .Values.image.digest -}}
{{- printf "%s:%s@%s" .Values.image.repository $tag .Values.image.digest -}}
{{- else -}}
{{- printf "%s:%s" .Values.image.repository $tag -}}
{{- end -}}
{{- end }}

{{/*
Deduplicate a string list and return a comma-separated string.
Collapses the entire list to "*" when the wildcard entry is present.
Returns empty string when the list is empty.
Usage: {{ include "mlflow.normalizeList" $list }}
*/}}
{{- define "mlflow.normalizeList" -}}
{{- $list := . | uniq -}}
{{- if has "*" $list -}}*{{- else if $list -}}{{- join "," $list -}}{{- end -}}
{{- end }}

{{/*
Build the MLFLOW_SERVER_ALLOWED_HOSTS value.
Auto-detects ingress hostnames then appends serverAllowedHosts.
Delegates dedup and wildcard collapsing to mlflow.normalizeList.
Usage: {{ include "mlflow.serverAllowedHosts" . }}
*/}}
{{- define "mlflow.serverAllowedHosts" -}}
{{- $hosts := list -}}
{{- if and .Values.ingress.enabled .Values.ingress.hosts -}}
  {{- range .Values.ingress.hosts -}}
    {{- if .host -}}{{- $hosts = append $hosts .host -}}{{- end -}}
  {{- end -}}
{{- end -}}
{{- range .Values.serverAllowedHosts -}}{{- $hosts = append $hosts . -}}{{- end -}}
{{- include "mlflow.normalizeList" $hosts -}}
{{- end }}

{{/*
Build the MLFLOW_SERVER_CORS_ALLOWED_ORIGINS value.
Auto-detects ingress origins (https when TLS configured, http otherwise) then appends corsAllowedOrigins.
Delegates dedup and wildcard collapsing to mlflow.normalizeList.
Usage: {{ include "mlflow.corsAllowedOrigins" . }}
*/}}
{{- define "mlflow.corsAllowedOrigins" -}}
{{- $origins := list -}}
{{- if and .Values.ingress.enabled .Values.ingress.hosts -}}
  {{- $scheme := "http" -}}
  {{- if .Values.ingress.tls -}}{{- $scheme = "https" -}}{{- end -}}
  {{- range .Values.ingress.hosts -}}
    {{- if .host -}}{{- $origins = append $origins (printf "%s://%s" $scheme .host) -}}{{- end -}}
  {{- end -}}
{{- end -}}
{{- range .Values.corsAllowedOrigins -}}{{- $origins = append $origins . -}}{{- end -}}
{{- include "mlflow.normalizeList" $origins -}}
{{- end }}

{{/*
Return the port number the Ingress should target. If oauth2-proxy sidecar is enabled
use its listenPort, otherwise use the service.port value.
Usage: {{ include "mlflow.servicePort" . }}
*/}}
{{- define "mlflow.servicePort" -}}
{{- if hasKey .Values "oauth2Proxy" }}
  {{- if and (hasKey .Values.oauth2Proxy "enabled") .Values.oauth2Proxy.enabled }}
    {{- .Values.oauth2Proxy.listenPort -}}
  {{- else -}}
    {{- .Values.service.port -}}
  {{- end -}}
{{- else -}}
  {{- .Values.service.port -}}
{{- end -}}
{{- end }}
