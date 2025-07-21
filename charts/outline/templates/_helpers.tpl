{{/*
Expand the name of the chart.
*/}}
{{- define "outline.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "outline.fullname" -}}
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
Create redis name secret name.
*/}}
{{- define "outline.redis.fullname" -}}
{{- printf "%s-redis" (include "outline.fullname" .) | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Create redis host
*/}}
{{- define "outline.redis.host" -}}
{{- if .Values.redis.enabled }}
{{- printf "%s-redis-master" (include "outline.fullname" .) }}
{{- else }}
{{- printf "%s" (required "externalRedis.host is required" .Values.externalRedis.host) }}
{{- end }}
{{- end }}

{{/*
Create redis port
*/}}
{{- define "outline.redis.port" -}}
{{- if .Values.redis.enabled }}
{{- printf "%d" (default 6379 .Values.redis.master.service.ports.redis | int) }}
{{- else }}
{{- printf "%d" (required "externalRedis.port is required" .Values.externalRedis.port | int) }}
{{- end }}
{{- end }}

{{/*
Create postgresql name secret name.
*/}}
{{- define "outline.postgresql.fullname" -}}
{{- printf "%s-postgresql" (include "outline.fullname" .) | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Create PostgreSQL database username
*/}}
{{- define "outline.postgresql.username" -}}
{{- if .Values.postgresql.enabled }}
{{- printf "%s" .Values.postgresql.auth.username | default "postgres" }}
{{- else }}
{{- printf "%s" .Values.externalPostgresql.username | default "postgres" }}
{{- end }}
{{- end }}

{{/*
Create PostgreSQL host
*/}}
{{- define "outline.postgresql.host" -}}
{{- if .Values.postgresql.enabled }}
{{- printf "%s-postgresql" (include "outline.fullname" .) }}
{{- else }}
{{- printf "%s" (required "externalPostgresql.host is required" .Values.externalPostgresql.host) }}
{{- end }}
{{- end }}

{{/*
Create PostgreSQL port
*/}}
{{- define "outline.postgresql.port" -}}
{{- if .Values.postgresql.enabled }}
{{- printf "%d" (default 5432 .Values.postgresql.primary.service.ports.postgresql | int) }}
{{- else }}
{{- printf "%d" (default 5432 .Values.externalPostgresql.port | int) }}
{{- end }}
{{- end }}

{{/*
Create PostgreSQL database name
*/}}
{{- define "outline.postgresql.database" -}}
{{- if .Values.postgresql.enabled }}
{{- printf "%s" .Values.postgresql.auth.database | default "outline" }}
{{- else }}
{{- printf "%s" .Values.externalPostgresql.database | default "outline" }}
{{- end }}
{{- end }}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "outline.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "outline.labels" -}}
helm.sh/chart: {{ include "outline.chart" . }}
{{ include "outline.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "outline.selectorLabels" -}}
app.kubernetes.io/name: {{ include "outline.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Create the name of the service account to use
*/}}
{{- define "outline.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- default (include "outline.fullname" .) .Values.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}

{{/*
Generate random hex similar to `openssl rand -hex 32` command.
Usage: {{ include "outline.generateRandomHex" 64 }}
*/}}
{{- define "outline.generateRandomHex" -}}
{{- $length := . -}}
{{- $chars := list "0" "1" "2" "3" "4" "5" "6" "7" "8" "9" "a" "b" "c" "d" "e" "f" -}}
{{- $result := "" -}}
{{- range $i := until $length -}}
  {{- $result = print $result (index $chars (randInt 0 16)) -}}
{{- end -}}
{{- $result -}}
{{- end -}}
