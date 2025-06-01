{{/* vim: set filetype=mustache: */}}
{{/*
Expand the name of the chart.
*/}}
{{- define "n8n.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "n8n.fullname" -}}
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
{{- define "n8n.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "n8n.labels" -}}
helm.sh/chart: {{ include "n8n.chart" . }}
{{ include "n8n.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "n8n.selectorLabels" -}}
app.kubernetes.io/name: {{ include "n8n.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Create the name of the service account to use
*/}}
{{- define "n8n.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- default (include "n8n.fullname" .) .Values.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}

{{/*
Create redis name secret name.
*/}}
{{- define "n8n.redis.fullname" -}}
{{- printf "%s-redis" (include "n8n.fullname" .) | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Create postgresql name secret name.
*/}}
{{- define "n8n.postgresql.fullname" -}}
{{- printf "%s-postgresql" (include "n8n.fullname" .) | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Create PostgreSQL database username
*/}}
{{- define "n8n.postgresql.username" -}}
{{- if .Values.postgresql.enabled }}
{{- printf "%s" .Values.postgresql.auth.username | default "postgres" }}
{{- else }}
{{- printf "%s" .Values.externalPostgresql.username | default "postgres" }}
{{- end }}
{{- end }}

{{/*
Worker name
*/}}
{{- define "n8n.worker.name" -}}
{{- printf "%s-worker" (include "n8n.name" .) | trunc 63 | trimSuffix "-" -}}
{{- end }}

{{/*
Create n8n worker full name
*/}}
{{- define "n8n.worker.fullname" -}}
{{- printf "%s-worker" (include "n8n.fullname" .) | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
n8n worker labels
*/}}
{{- define "n8n.worker.labels" -}}
helm.sh/chart: {{ include "n8n.chart" . }}
{{ include "n8n.worker.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Worker selector labels
*/}}
{{- define "n8n.worker.selectorLabels" -}}
app.kubernetes.io/name: {{ include "n8n.worker.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
app.kubernetes.io/component: worker
{{- end }}

{{/*
Webhook name
*/}}
{{- define "n8n.webhook.name" -}}
{{- printf "%s-webhook" (include "n8n.name" .) | trunc 63 | trimSuffix "-" -}}
{{- end }}

{{/*
Create n8n webhook full name
*/}}
{{- define "n8n.webhook.fullname" -}}
{{- printf "%s-webhook" (include "n8n.fullname" .) | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
n8n webhook labels
*/}}
{{- define "n8n.webhook.labels" -}}
helm.sh/chart: {{ include "n8n.chart" . }}
{{ include "n8n.webhook.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Webhook selector labels
*/}}
{{- define "n8n.webhook.selectorLabels" -}}
app.kubernetes.io/name: {{ include "n8n.webhook.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
app.kubernetes.io/component: webhook
{{- end }}

{{/*
Generate random hex similar to `openssl rand -hex 16` command.
Usage: {{ include "n8n.generateRandomHex" 32 }}
*/}}
{{- define "n8n.generateRandomHex" -}}
{{- $length := . -}}
{{- $chars := list "0" "1" "2" "3" "4" "5" "6" "7" "8" "9" "a" "b" "c" "d" "e" "f" -}}
{{- $result := "" -}}
{{- range $i := until $length -}}
  {{- $result = print $result (index $chars (randInt 0 16)) -}}
{{- end -}}
{{- $result -}}
{{- end -}}

{{/*
Task runners name
*/}}
{{- define "n8n.taskRunners.name" -}}
{{- printf "%s-task-runners" (include "n8n.name" .) | trunc 63 | trimSuffix "-" -}}
{{- end }}

{{/*
Create n8n task runners full name
*/}}
{{- define "n8n.taskRunners.fullname" -}}
{{- printf "%s-task-runners" (include "n8n.fullname" .) | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
n8n task runners labels
*/}}
{{- define "n8n.taskRunners.labels" -}}
helm.sh/chart: {{ include "n8n.chart" . }}
{{ include "n8n.taskRunners.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Task runners selector labels
*/}}
{{- define "n8n.taskRunners.selectorLabels" -}}
app.kubernetes.io/name: {{ include "n8n.taskRunners.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
app.kubernetes.io/component: task-runners
{{- end }}

{{/*
Extract package names from a list of strings
*/}}
{{- define "n8n.packageNames" -}}
{{- $packageNames := list -}}
{{- range . -}}
  {{- $matches := regexFindAll "^@?[^@]+" . 1 -}}
  {{- if and $matches (not (hasPrefix "n8n-nodes-" (index $matches 0))) -}}
    {{- $packageNames = append $packageNames (index $matches 0) -}}
  {{- end -}}
{{- end -}}
{{- join "," $packageNames -}}
{{- end -}}

{{/*
Filter community packages (starting with n8n-nodes-)
*/}}
{{- define "n8n.communityPackages" -}}
{{- $community := list -}}
{{- range .Values.nodes.external.packages -}}
{{- if hasPrefix "n8n-nodes-" . -}}
{{- $community = append $community . -}}
{{- end -}}
{{- end -}}
{{- join " " $community -}}
{{- end -}}

{{/*
Filter non-community packages (as a space-separated string)
*/}}
{{- define "n8n.nonCommunityPackages" -}}
{{- $nonCommunity := list -}}
{{- range .Values.nodes.external.packages -}}
{{- if not (hasPrefix "n8n-nodes-" .) -}}
{{- $nonCommunity = append $nonCommunity . -}}
{{- end -}}
{{- end -}}
{{- join " " $nonCommunity -}}
{{- end -}}

{{/*
Convert n8n log level to npm log level
*/}}
{{- define "n8n.npmLogLevel" -}}
{{- $level := . | lower -}}
{{- if eq $level "debug" }}verbose
{{- else }}{{ $level }}
{{- end -}}
{{- end -}}