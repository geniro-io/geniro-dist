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
Resolve OpenBao address.
*/}}
{{- define "geniro.openbaoAddr" -}}
{{- if .Values.openbao.enabled }}
{{- printf "http://%s-openbao:%v" (include "geniro.fullname" .) .Values.openbao.service.port }}
{{- else }}
{{- .Values.externalOpenbao.addr }}
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
Returns "true" when the k8s Pod sandbox runtime is active.
*/}}
{{- define "geniro.isK8sRuntime" -}}
{{- if eq .Values.runtime.provider "k8s" -}}true{{- end -}}
{{- end }}

{{/*
Returns "true" when Daytona is the active sandbox runtime.
*/}}
{{- define "geniro.isDaytonaRuntime" -}}
{{- if eq .Values.runtime.provider "daytona" -}}true{{- end -}}
{{- end }}

{{/*
Returns "true" when the API pod should mount the host Docker socket.
Auto-enabled when runtime.provider=docker; can also be forced via
api.mountDockerSocket=true.
*/}}
{{- define "geniro.mountDockerSocket" -}}
{{- if or .Values.api.mountDockerSocket (eq .Values.runtime.provider "docker") -}}true{{- end -}}
{{- end }}

{{/*
API ServiceAccount name (used when runtime.provider=k8s).
Empty string means "don't set serviceAccountName" (falls back to the namespace default SA).
*/}}
{{- define "geniro.apiSaName" -}}
{{- if include "geniro.isK8sRuntime" . }}
{{- if .Values.k8sRuntime.serviceAccount.apiName }}
{{- .Values.k8sRuntime.serviceAccount.apiName }}
{{- else }}
{{- printf "%s-api" (include "geniro.fullname" .) }}
{{- end }}
{{- end }}
{{- end }}

{{/*
ServiceAccount name that sandbox pods run as (in the runtime namespace).
*/}}
{{- define "geniro.k8sRuntimeSaName" -}}
{{- default "geniro-runtime" .Values.k8sRuntime.serviceAccount.runtimeName }}
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
{{- if and .Values.daytona.enabled .Values.externalDaytona.apiUrl }}
{{- fail "Cannot enable both daytona.enabled and externalDaytona.apiUrl. Use one or the other." }}
{{- end }}
{{- if and .Values.externalDaytona.apiUrl (not .Values.externalDaytona.apiKey) (not .Values.secrets.existingSecret) }}
{{- fail "externalDaytona.apiKey is required when externalDaytona.apiUrl is set and secrets.existingSecret is not used." }}
{{- end }}
{{- $valid := list "docker" "daytona" "k8s" }}
{{- if not (has .Values.runtime.provider $valid) }}
{{- fail (printf "runtime.provider must be one of: docker, daytona, k8s. Got: %q" .Values.runtime.provider) }}
{{- end }}
{{- if eq .Values.runtime.provider "daytona" }}
{{- if and (not .Values.daytona.enabled) (not .Values.externalDaytona.apiUrl) }}
{{- fail "runtime.provider=daytona requires either daytona.enabled=true (bundled) or externalDaytona.apiUrl (external)." }}
{{- end }}
{{- else }}
{{- if .Values.daytona.enabled }}
{{- fail (printf "daytona.enabled=true is only valid when runtime.provider=daytona. Current provider: %q" .Values.runtime.provider) }}
{{- end }}
{{- if .Values.externalDaytona.apiUrl }}
{{- fail (printf "externalDaytona.apiUrl is only valid when runtime.provider=daytona. Current provider: %q" .Values.runtime.provider) }}
{{- end }}
{{- end }}
{{- if and .Values.keycloak.enabled (or (eq .Values.keycloak.auth.adminPassword "admin") (lt (len .Values.keycloak.auth.adminPassword) 8)) }}
{{- fail "keycloak.auth.adminPassword must be at least 8 characters and not 'admin'." }}
{{- end }}
{{- if and .Values.postgresql.enabled (or (eq .Values.postgresql.auth.postgresPassword "geniro") (lt (len .Values.postgresql.auth.postgresPassword) 8)) }}
{{- fail "postgresql.auth.postgresPassword must be at least 8 characters and not 'geniro'." }}
{{- end }}
{{- if .Values.api.env.AUTH_DEV_MODE }}
{{- fail "api.env.AUTH_DEV_MODE=true bypasses all authentication. This is not permitted in Helm-managed deployments. Remove or set to false." }}
{{- end }}
{{- if and (not .Values.openbao.enabled) (not .Values.secrets.existingSecret) }}
{{- if not .Values.externalOpenbao.addr }}
{{- fail "externalOpenbao.addr is required when openbao.enabled=false" }}
{{- end }}
{{- if not .Values.externalOpenbao.token }}
{{- fail "externalOpenbao.token is required when openbao.enabled=false (unless using secrets.existingSecret)" }}
{{- end }}
{{- end }}
{{- if include "geniro.isK8sRuntime" . }}
{{- if not .Values.k8sRuntime.namespace }}
{{- fail "k8sRuntime.namespace is required when runtime.provider=k8s" }}
{{- end }}
{{- if eq .Values.k8sRuntime.namespace .Release.Namespace }}
{{- fail "k8sRuntime.namespace must be different from the release namespace to isolate sandbox pods from platform workloads" }}
{{- end }}
{{- end }}
{{- end }}

{{/*
Validate Daytona secrets.
*/}}
{{- define "geniro.validateDaytona" -}}
{{- if .Values.daytona.enabled }}
{{- if not .Values.daytona.api.env.DAYTONA_ADMIN_API_KEY }}
{{- fail "daytona.api.env.DAYTONA_ADMIN_API_KEY is required when daytona.enabled=true. Generate with: openssl rand -hex 32" }}
{{- end }}
{{- if not .Values.daytona.api.env.DAYTONA_RUNNER_API_KEY }}
{{- fail "daytona.api.env.DAYTONA_RUNNER_API_KEY is required when daytona.enabled=true. Generate with: openssl rand -hex 32" }}
{{- end }}
{{- if not .Values.daytona.api.env.DAYTONA_ENCRYPTION_KEY }}
{{- fail "daytona.api.env.DAYTONA_ENCRYPTION_KEY is required when daytona.enabled=true. Generate with: openssl rand -hex 16" }}
{{- end }}
{{- if not .Values.daytona.api.env.DAYTONA_ENCRYPTION_SALT }}
{{- fail "daytona.api.env.DAYTONA_ENCRYPTION_SALT is required when daytona.enabled=true. Generate with: openssl rand -hex 16" }}
{{- end }}
{{- end }}
{{- end }}
