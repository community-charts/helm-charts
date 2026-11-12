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

{{/*
Render the MLflow basic auth INI file content (the [mlflow] section).
Shared by the auth INI ConfigMap and the deployment's checksum/auth-config annotation.
*/}}
{{- define "mlflow.authIni" -}}
{{- $defaultPermission := "" }}
{{- $databaseUri := "" }}
{{- $adminUsername := "" }}
{{- $adminPassword := "" }}
{{- $authorizationFunction := "" }}

{{- if .Values.auth.enabled }}
  {{- $defaultPermission = .Values.auth.defaultPermission }}
  {{- if .Values.auth.postgres.enabled }}
    {{- $dbConnectionDriver := "" }}
    {{- if .Values.auth.postgres.driver }}
      {{- $dbConnectionDriver = printf "+%s" .Values.auth.postgres.driver }}
    {{- end }}
    {{- $pgHost := required "auth.postgres.host must be specified" .Values.auth.postgres.host }}
    {{- $pgPort := required "auth.postgres.port must be specified" .Values.auth.postgres.port | toString }}
    {{- $pgDatabase := required "auth.postgres.database must be specified" .Values.auth.postgres.database }}
    {{- $databaseUri = printf "postgresql%s://$(POSTGRES_USERNAME_PLACEHOLDER):$(POSTGRES_PASSWORD_PLACEHOLDER)@%s:%s/%s" $dbConnectionDriver $pgHost $pgPort $pgDatabase }}
  {{- else if .Values.postgresql.enabled }}
    {{- $pgHost := include "mlflow.postgresql.fullname" . }}
    {{- $pgPort := default "5432" .Values.postgresql.primary.service.ports.postgresql | toString }}
    {{- $pgDatabase := .Values.postgresql.auth.database }}
    {{- $databaseUri = printf "postgresql://$(POSTGRES_USERNAME_PLACEHOLDER):$(POSTGRES_PASSWORD_PLACEHOLDER)@%s:%s/%s" $pgHost $pgPort $pgDatabase }}
  {{- else }}
    {{- $sqliteFile := .Values.auth.sqliteFile }}
    {{- if .Values.auth.sqliteFullPath }}
      {{- $path := printf "%s/" .Values.auth.sqliteFullPath | trimSuffix "/" }}
      {{- $databaseUri = printf "sqlite:///%s%s" $path $sqliteFile }}
    {{- else }}
      {{- $databaseUri = printf "sqlite:///%s" $sqliteFile }}
    {{- end }}
  {{- end }}
  {{- $adminUsername = "$(ADMIN_USERNAME_PLACEHOLDER)" }}
  {{- $adminPassword = "$(ADMIN_PASSWORD_PLACEHOLDER)" }}
  {{- $authorizationFunction = required "auth.authorizationFunction can not be empty!" .Values.auth.authorizationFunction }}
{{- else }}
  {{- $defaultPermission = "READ" }}
  {{- $databaseUri = "sqlite:///ldap_basic_auth.db" }}
  {{- $adminUsername = "fakeuser" }}
  {{- $adminPassword = "fakepassword" }}
  {{- $authorizationFunction = "mlflowstack.auth.ldap:authenticate_request_basic_auth" }}
{{- end -}}
[mlflow]
default_permission = {{ $defaultPermission }}
database_uri = {{ $databaseUri }}
admin_username = {{ $adminUsername }}
admin_password = {{ $adminPassword }}
authorization_function = {{ $authorizationFunction }}
{{- range $key, $value := .Values.auth.extraConfig }}
  {{- if has $key (list "default_permission" "database_uri" "admin_username" "admin_password" "authorization_function") }}
    {{- fail (printf "auth.extraConfig.%s is managed by the chart and can not be overridden" $key) }}
  {{- end }}
  {{- if not (regexMatch "^[a-z][a-z0-9_]*$" $key) }}
    {{- fail (printf "auth.extraConfig key %q is invalid, keys must match ^[a-z][a-z0-9_]*$" $key) }}
  {{- end }}
  {{- if or (kindIs "map" $value) (kindIs "slice" $value) (kindIs "invalid" $value) }}
    {{- fail (printf "auth.extraConfig.%s must be a string, number or boolean" $key) }}
  {{- end }}
  {{- if and (kindIs "float64" $value) (eq (floor $value) $value) }}
    {{- $value = int64 $value }}
  {{- end }}
  {{- if regexMatch "[\r\n]" (toString $value) }}
    {{- fail (printf "auth.extraConfig.%s must be a single line value" $key) }}
  {{- end }}
{{ $key }} = {{ $value }}
{{- end }}
{{- end }}
