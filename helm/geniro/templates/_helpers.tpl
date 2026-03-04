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
{{- printf "http://%s-keycloak:%v" (include "geniro.fullname" .) .Values.keycloak.service.port }}
{{- else }}
{{- .Values.externalKeycloak.url }}
{{- end }}
{{- end }}

{{/*
Resolve Qdrant URL.
*/}}
{{- define "geniro.qdrantUrl" -}}
{{- if .Values.qdrant.enabled }}
{{- printf "http://%s-qdrant:%v" (include "geniro.fullname" .) (dig "service" "httpPort" 6333 .Values.qdrant) }}
{{- else }}
{{- printf "%s://%s:%v" (.Values.externalQdrant.scheme | default "http") .Values.externalQdrant.host .Values.externalQdrant.port }}
{{- end }}
{{- end }}

{{/*
Resolve LiteLLM base URL.
*/}}
{{- define "geniro.litellmUrl" -}}
{{- if .Values.litellm.enabled }}
{{- printf "http://%s-litellm:%v" (include "geniro.fullname" .) .Values.litellm.service.port }}
{{- else }}
{{- .Values.externalLitellm.url }}
{{- end }}
{{- end }}

{{/*
Resolve Zitadel base URL.
*/}}
{{- define "geniro.zitadelUrl" -}}
{{- if .Values.zitadel.enabled }}
{{- printf "http://%s-zitadel:8080" .Release.Name }}
{{- else }}
{{- .Values.externalZitadel.url }}
{{- end }}
{{- end }}

{{/*
Resolve Zitadel OIDC issuer URL.
*/}}
{{- define "geniro.zitadelIssuer" -}}
{{- if .Values.zitadel.enabled }}
{{- printf "http://%s-zitadel:8080" .Release.Name }}
{{- else }}
{{- .Values.externalZitadel.issuer }}
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

{{/*
Validate external service configuration.
Called from configmap.yaml to surface errors at render time.
*/}}
{{- define "geniro.validateExternalServices" -}}
{{- if and (not .Values.postgresql.enabled) (not .Values.externalPostgresql.host) }}
{{- fail "externalPostgresql.host is required when postgresql.enabled=false" }}
{{- end }}
{{- if and (not .Values.redis.enabled) (not .Values.externalRedis.host) }}
{{- fail "externalRedis.host is required when redis.enabled=false" }}
{{- end }}
{{- if and (not .Values.qdrant.enabled) (not .Values.externalQdrant.host) }}
{{- fail "externalQdrant.host is required when qdrant.enabled=false" }}
{{- end }}
{{- if and (not .Values.keycloak.enabled) (not .Values.zitadel.enabled) (not .Values.externalKeycloak.url) (not .Values.externalZitadel.url) }}
{{- fail "An auth provider is required. Set keycloak.enabled=true, zitadel.enabled=true, externalKeycloak.url, or externalZitadel.url" }}
{{- end }}
{{- if and .Values.keycloak.enabled (or (eq .Values.keycloak.auth.adminPassword "admin") (lt (len .Values.keycloak.auth.adminPassword) 8)) }}
{{- fail "keycloak.auth.adminPassword must be at least 8 characters and not 'admin'." }}
{{- end }}
{{- if and .Values.postgresql.enabled (or (eq .Values.postgresql.auth.postgresPassword "geniro") (lt (len .Values.postgresql.auth.postgresPassword) 8)) }}
{{- fail "postgresql.auth.postgresPassword must be at least 8 characters and not 'geniro'." }}
{{- end }}
{{- if .Values.api.env.authDevMode }}
{{- fail "api.env.authDevMode=true bypasses all authentication. This is not permitted in Helm-managed deployments. Remove or set to false." }}
{{- end }}
{{- end }}

{{/*
Validate Daytona secrets.
*/}}
{{- define "geniro.validateDaytona" -}}
{{- if .Values.daytona.enabled }}
{{- if not .Values.daytona.api.env.adminApiKey }}
{{- fail "daytona.api.env.adminApiKey is required when daytona.enabled=true. Generate with: openssl rand -hex 32" }}
{{- end }}
{{- if not .Values.daytona.api.env.runnerApiKey }}
{{- fail "daytona.api.env.runnerApiKey is required when daytona.enabled=true. Generate with: openssl rand -hex 32" }}
{{- end }}
{{- if not .Values.daytona.api.env.encryptionKey }}
{{- fail "daytona.api.env.encryptionKey is required when daytona.enabled=true. Generate with: openssl rand -hex 16" }}
{{- end }}
{{- if not .Values.daytona.api.env.encryptionSalt }}
{{- fail "daytona.api.env.encryptionSalt is required when daytona.enabled=true. Generate with: openssl rand -hex 16" }}
{{- end }}
{{- end }}
{{- end }}
