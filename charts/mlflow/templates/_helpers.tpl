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

{{- define "mlflow.health" -}}
{{- $basPath := default "/" .Values.extraArgs.staticPrefix }}
{{- printf "%s/health" ($basPath | trimSuffix "/" )}}
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
Database environment variables for init containers and main container
*/}}
{{- define "mlflow.databaseEnvVars" -}}
{{- if .Values.postgresql.enabled }}
- name: PGPASSWORD
  valueFrom:
    secretKeyRef:
      name: {{ (include "mlflow.postgresql.fullname" .) }}
  {{- if .Values.postgresql.auth.username }}
      key: password
  {{- else }}
      key: postgres-password
  {{- end }}
      optional: true
{{- end }}
{{- if .Values.mysql.enabled }}
- name: MYSQL_PWD
  valueFrom:
    secretKeyRef:
      name: {{ (include "mlflow.mysql.fullname" .) }}
  {{- if .Values.mysql.auth.username }}
      key: password
  {{- else }}
      key: mysql-root-password
  {{- end }}
      optional: true
{{- end }}
{{- if .Values.backendStore.existingDatabaseSecret.name }}
  {{- if .Values.backendStore.postgres.enabled }}
- name: PGPASSWORD
  valueFrom:
    secretKeyRef:
      name: {{ .Values.backendStore.existingDatabaseSecret.name }}
      key: {{ .Values.backendStore.existingDatabaseSecret.passwordKey }}
- name: PGUSER
  valueFrom:
    secretKeyRef:
      name: {{ .Values.backendStore.existingDatabaseSecret.name }}
      key: {{ .Values.backendStore.existingDatabaseSecret.usernameKey }}
  {{- end }}
  {{- if .Values.backendStore.mysql.enabled }}
- name: MYSQL_PWD
  valueFrom:
    secretKeyRef:
      name: {{ .Values.backendStore.existingDatabaseSecret.name }}
      key: {{ .Values.backendStore.existingDatabaseSecret.passwordKey }}
- name: MYSQL_USERNAME
  valueFrom:
    secretKeyRef:
      name: {{ .Values.backendStore.existingDatabaseSecret.name }}
      key: {{ .Values.backendStore.existingDatabaseSecret.usernameKey }}
  {{- end }}
  {{- if .Values.backendStore.mssql.enabled }}
- name: MSSQL_PWD
  valueFrom:
    secretKeyRef:
      name: {{ .Values.backendStore.existingDatabaseSecret.name }}
      key: {{ .Values.backendStore.existingDatabaseSecret.passwordKey }}
- name: MSSQL_USERNAME
  valueFrom:
    secretKeyRef:
      name: {{ .Values.backendStore.existingDatabaseSecret.name }}
      key: {{ .Values.backendStore.existingDatabaseSecret.usernameKey }}
  {{- end }}
{{- end }}
{{- end -}}

{{/*
Authentication database environment variables for ini-file-initializer
*/}}
{{- define "mlflow.authDatabaseEnvVars" -}}
{{- if .Values.auth.postgres.enabled }}
  {{- if .Values.auth.postgres.existingSecret.name }}
- name: AUTH_POSTGRES_USERNAME
  valueFrom:
    secretKeyRef:
      name: {{ .Values.auth.postgres.existingSecret.name }}
      key: {{ .Values.auth.postgres.existingSecret.usernameKey }}
- name: AUTH_POSTGRES_PWD
  valueFrom:
    secretKeyRef:
      name: {{ .Values.auth.postgres.existingSecret.name }}
      key: {{ .Values.auth.postgres.existingSecret.passwordKey }}
  {{- else }}
- name: AUTH_POSTGRES_USERNAME
  valueFrom:
    secretKeyRef:
      name: {{ template "mlflow.fullname" . }}-auth-pg-secret
      key: username
- name: AUTH_POSTGRES_PWD
  valueFrom:
    secretKeyRef:
      name: {{ template "mlflow.fullname" . }}-auth-pg-secret
      key: password
  {{- end }}
{{- end }}
{{- if .Values.auth.mysql.enabled }}
  {{- if .Values.auth.mysql.existingSecret.name }}
- name: AUTH_MYSQL_USERNAME
  valueFrom:
    secretKeyRef:
      name: {{ .Values.auth.mysql.existingSecret.name }}
      key: {{ .Values.auth.mysql.existingSecret.usernameKey }}
- name: AUTH_MYSQL_PWD
  valueFrom:
    secretKeyRef:
      name: {{ .Values.auth.mysql.existingSecret.name }}
      key: {{ .Values.auth.mysql.existingSecret.passwordKey }}
  {{- else }}
- name: AUTH_MYSQL_USERNAME
  valueFrom:
    secretKeyRef:
      name: {{ template "mlflow.fullname" . }}-auth-mysql-secret
      key: username
- name: AUTH_MYSQL_PWD
  valueFrom:
    secretKeyRef:
      name: {{ template "mlflow.fullname" . }}-auth-mysql-secret
      key: password
  {{- end }}
{{- end }}
- name: ADMIN_USERNAME
  valueFrom:
    secretKeyRef:
      name: {{ default (printf "%s-auth-admin-secret" (include "mlflow.fullname" .)) .Values.auth.existingAdminSecret.name }}
      key: {{ ternary "username" .Values.auth.existingAdminSecret.usernameKey (eq .Values.auth.existingAdminSecret.name "") }}
- name: ADMIN_PASSWORD
  valueFrom:
    secretKeyRef:
      name: {{ default (printf "%s-auth-admin-secret" (include "mlflow.fullname" .)) .Values.auth.existingAdminSecret.name }}
      key: {{ ternary "password" .Values.auth.existingAdminSecret.passwordKey (eq .Values.auth.existingAdminSecret.name "") }}
{{- end -}}

{{/*
Flask Server Secret environment variable for main container
*/}}
{{- define "mlflow.flaskServerSecretEnvVar" -}}
{{- if .Values.flaskServerSecret.existingSecret.name }}
- name: MLFLOW_FLASK_SERVER_SECRET_KEY
  valueFrom:
    secretKeyRef:
      name: {{ .Values.flaskServerSecret.existingSecret.name }}
      key: {{ .Values.flaskServerSecret.existingSecret.key }}
{{- end }}
{{- end -}}

{{/*
S3 credentials environment variables for main container
*/}}
{{- define "mlflow.s3CredentialsEnvVars" -}}
{{- if and .Values.artifactRoot.s3.enabled .Values.artifactRoot.s3.existingSecret.name }}
  {{- if .Values.artifactRoot.s3.existingSecret.keyOfAccessKeyId }}
- name: AWS_ACCESS_KEY_ID
  valueFrom:
    secretKeyRef:
      name: {{ .Values.artifactRoot.s3.existingSecret.name }}
      key: {{ .Values.artifactRoot.s3.existingSecret.keyOfAccessKeyId }}
  {{- end }}
  {{- if .Values.artifactRoot.s3.existingSecret.keyOfSecretAccessKey }}
- name: AWS_SECRET_ACCESS_KEY
  valueFrom:
    secretKeyRef:
      name: {{ .Values.artifactRoot.s3.existingSecret.name }}
      key: {{ .Values.artifactRoot.s3.existingSecret.keyOfSecretAccessKey }}
  {{- end }}
{{- end }}
{{- end -}}
