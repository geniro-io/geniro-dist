{{/*
Expand the name of the chart.
*/}}
{{- define "geniro.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
*/}}
{{- define "geniro.fullname" -}}
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
Create chart label.
*/}}
{{- define "geniro.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels applied to all resources.
*/}}
{{- define "geniro.labels" -}}
helm.sh/chart: {{ include "geniro.chart" . }}
{{ include "geniro.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels (used in matchLabels and Service selectors).
*/}}
{{- define "geniro.selectorLabels" -}}
app.kubernetes.io/name: {{ include "geniro.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Component-specific selector labels.
Usage: {{ include "geniro.componentSelectorLabels" (dict "component" "api" "context" .) }}
*/}}
{{- define "geniro.componentSelectorLabels" -}}
app.kubernetes.io/name: {{ include "geniro.name" .context }}
app.kubernetes.io/instance: {{ .context.Release.Name }}
app.kubernetes.io/component: {{ .component }}
{{- end }}

{{/*
Resolve PostgreSQL host.
*/}}
{{- define "geniro.postgresHost" -}}
{{- if .Values.postgresql.enabled }}
{{- printf "%s-postgresql" (include "geniro.fullname" .) }}
{{- else }}
{{- .Values.externalPostgresql.host }}
{{- end }}
{{- end }}

{{/*
Resolve Redis host.
*/}}
{{- define "geniro.redisHost" -}}
{{- if .Values.redis.enabled }}
{{- printf "%s-redis-master" (include "geniro.fullname" .) }}
{{- else }}
{{- .Values.externalRedis.host }}
{{- end }}
{{- end }}

{{/*
Resolve Keycloak URL.
*/}}
{{- define "geniro.keycloakUrl" -}}
{{- if .Values.keycloak.enabled }}
{{- printf "http://%s-keycloak:80" (include "geniro.fullname" .) }}
{{- else }}
{{- .Values.externalKeycloak.url }}
{{- end }}
{{- end }}

{{/*
Resolve Qdrant URL.
*/}}
{{- define "geniro.qdrantUrl" -}}
{{- if .Values.qdrant.enabled }}
{{- printf "http://%s-qdrant:6333" (include "geniro.fullname" .) }}
{{- else }}
{{- printf "http://%s:%v" .Values.externalQdrant.host .Values.externalQdrant.port }}
{{- end }}
{{- end }}

{{/*
Resolve LiteLLM base URL.
*/}}
{{- define "geniro.litellmUrl" -}}
{{- if .Values.litellm.enabled }}
{{- printf "http://%s-litellm:%v" (include "geniro.fullname" .) .Values.litellm.port }}
{{- else }}
{{- "" }}
{{- end }}
{{- end }}

{{/*
Secret name — existing or generated.
*/}}
{{- define "geniro.secretName" -}}
{{- if .Values.secrets.existingSecret }}
{{- .Values.secrets.existingSecret }}
{{- else }}
{{- printf "%s-secrets" (include "geniro.fullname" .) }}
{{- end }}
{{- end }}
