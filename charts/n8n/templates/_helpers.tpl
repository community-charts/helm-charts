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
Main name
*/}}
{{- define "n8n.main.name" -}}
{{- printf "%s-main" (include "n8n.name" .) | trunc 63 | trimSuffix "-" -}}
{{- end }}

{{/*
Create n8n main full name
*/}}
{{- define "n8n.main.fullname" -}}
{{- printf "%s-main" (include "n8n.fullname" .) | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Main labels
*/}}
{{- define "n8n.main.labels" -}}
helm.sh/chart: {{ include "n8n.chart" . }}
{{ include "n8n.main.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
app.kubernetes.io/component: main
app.kubernetes.io/part-of: n8n
{{- end }}

{{/*
Main selector labels
Selector fields are immutable after kubernetes resource creation. Do not edit this function.
*/}}
{{- define "n8n.main.selectorLabels" -}}
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
app.kubernetes.io/part-of: n8n
{{- end }}

{{/*
Worker selector labels
Selector fields are immutable after kubernetes resource creation. Do not edit this function.
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
{{- end }}

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
app.kubernetes.io/part-of: n8n
{{- end }}

{{/*
Webhook selector labels
Selector fields are immutable after kubernetes resource creation. Do not edit this function.
*/}}
{{- define "n8n.webhook.selectorLabels" -}}
app.kubernetes.io/name: {{ include "n8n.webhook.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
app.kubernetes.io/component: webhook
{{- end }}

{{/*
MCP webhook name
*/}}
{{- define "n8n.mcp-webhook.name" -}}
{{- printf "%s-mcp-webhook" (include "n8n.name" .) | trunc 63 | trimSuffix "-" -}}
{{- end }}

{{/*
Create n8n MCP webhook full name
*/}}
{{- define "n8n.mcp-webhook.fullname" -}}
{{- printf "%s-mcp-webhook" (include "n8n.fullname" .) | trunc 63 | trimSuffix "-" -}}
{{- end }}

{{/*
n8n MCP webhook labels
*/}}
{{- define "n8n.mcp-webhook.labels" -}}
helm.sh/chart: {{ include "n8n.chart" . }}
{{ include "n8n.mcp-webhook.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
app.kubernetes.io/part-of: n8n
{{- end }}

{{/*
n8n MCP webhook selector labels
Selector fields are immutable after kubernetes resource creation. Do not edit this function.
*/}}
{{- define "n8n.mcp-webhook.selectorLabels" -}}
app.kubernetes.io/name: {{ include "n8n.mcp-webhook.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
app.kubernetes.io/component: mcp
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
app.kubernetes.io/part-of: n8n
{{- end }}

{{/*
Task runners selector labels
Selector fields are immutable after kubernetes resource creation. Do not edit this function.
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

{{/*
n8n main persistence name
*/}}
{{- define "n8n-main.persistence.name" -}}
{{- printf "%s-persistence" (include "n8n.main.name" .) | trunc 63 | trimSuffix "-" -}}
{{- end }}

{{/*
n8n main persistence full name
*/}}
{{- define "n8n-main.persistence.fullname" -}}
{{- printf "%s-persistence" (include "n8n.main.fullname" .) | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
n8n main persistence labels
*/}}
{{- define "n8n-main.persistence.labels" -}}
helm.sh/chart: {{ include "n8n.chart" . }}
{{ include "n8n-main.persistence.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
app.kubernetes.io/part-of: n8n
{{- end }}

{{/*
n8n main persistence selector labels
Selector fields are immutable after kubernetes resource creation. Do not edit this function.
*/}}
{{- define "n8n-main.persistence.selectorLabels" -}}
app.kubernetes.io/name: {{ include "n8n-main.persistence.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
app.kubernetes.io/component: persistence
{{- end }}

{{/*
n8n worker persistence name
*/}}
{{- define "n8n-worker.persistence.name" -}}
{{- printf "%s-persistence" (include "n8n.worker.name" .) | trunc 63 | trimSuffix "-" -}}
{{- end }}

{{/*
n8n worker persistence full name
*/}}
{{- define "n8n-worker.persistence.fullname" -}}
{{- printf "%s-persistence" (include "n8n.worker.fullname" .) | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
n8n worker persistence labels
*/}}
{{- define "n8n-worker.persistence.labels" -}}
helm.sh/chart: {{ include "n8n.chart" . }}
{{ include "n8n-worker.persistence.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
app.kubernetes.io/part-of: n8n
{{- end }}

{{/*
n8n worker persistence selector labels
Selector fields are immutable after kubernetes resource creation. Do not edit this function.
*/}}
{{- define "n8n-worker.persistence.selectorLabels" -}}
app.kubernetes.io/name: {{ include "n8n-worker.persistence.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
app.kubernetes.io/component: persistence
{{- end }}

{{/*
n8n npm install script logic
*/}}
{{- define "n8n.npmInstallScript" -}}
export PACKAGES="{{ join " " .Values.nodes.external.packages }}"
export COMMUNITY_PACKAGES="{{ include "n8n.communityPackages" . }}"
export NON_COMMUNITY_PACKAGES="{{ include "n8n.nonCommunityPackages" . }}"
echo "$PACKAGES" | sha256sum > /npmdata/packages.hash.new
if [ ! -f /npmdata/packages.hash ] || ! cmp /npmdata/packages.hash /npmdata/packages.hash.new; then
  if [ -n "$NON_COMMUNITY_PACKAGES" ]; then
    npm install --loglevel {{ include "n8n.npmLogLevel" .Values.log.level }} --no-save $NON_COMMUNITY_PACKAGES --prefix /npmdata
  fi
  if [ -n "$COMMUNITY_PACKAGES" ]; then
    npm install --loglevel {{ include "n8n.npmLogLevel" .Values.log.level }} --no-save $COMMUNITY_PACKAGES --prefix /nodesdata/nodes
  fi
  mv /npmdata/packages.hash.new /npmdata/packages.hash
else
  rm /npmdata/packages.hash.new
fi
{{- end -}}
