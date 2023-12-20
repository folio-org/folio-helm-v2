{{/*
Expand the name of the chart.
*/}}
{{- define "folio-common.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "folio-common.fullname" -}}
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
{{- define "folio-common.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "folio-common.labels" -}}
helm.sh/chart: {{ include "folio-common.chart" . }}
{{ include "folio-common.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "folio-common.selectorLabels" -}}
app.kubernetes.io/name: {{ include "folio-common.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Create the name of the service account to use
*/}}
{{- define "folio-common.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- default (include "folio-common.fullname" .) .Values.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}

{{- /*
common.util.merge will merge two YAML templates and output the result.

This takes an array of three values:
- the top context
- the template name of the overrides (destination)
- the template name of the base (source)

*/ -}}
{{- define "folio-common.util.merge" -}}
{{- $top := first . -}}
{{- $overrides := fromYaml (include (index . 1) $top) | default (dict ) -}}
{{- $tpl := fromYaml (include (index . 2) $top) | default (dict ) -}}
{{- toYaml (merge $overrides $tpl) -}}
{{- end -}}

{{/*
Renders a value that contains template perhaps with scope if the scope is present.
*/}}
{{- define "folio-common.tplvalues.render" -}}
{{- $value := typeIs "string" .value | ternary .value (.value | toYaml) }}
{{- if contains "{{" (toJson .value) }}
  {{- if .scope }}
      {{- tpl (cat "{{- with $.RelativeScope -}}" $value "{{- end }}") (merge (dict "RelativeScope" .scope) .context) }}
  {{- else }}
    {{- tpl $value .context }}
  {{- end }}
{{- else }}
    {{- $value }}
{{- end }}
{{- end -}}

{{/*
Merge a list of values that contains template after rendering them.
Merge precedence is consistent with http://masterminds.github.io/sprig/dicts.html#merge-mustmerge
*/}}
{{- define "folio-common.tplvalues.merge" -}}
{{- $dst := dict -}}
{{- range .values -}}
{{- $dst = include "folio-common.tplvalues.render" (dict "value" . "context" $.context "scope" $.scope) | fromYaml | merge $dst -}}
{{- end -}}
{{ $dst | toYaml }}
{{- end -}}

{{/* Check if any integration is enabled */}}
{{- define "folio-common.anyIntegrationEnabled" -}}
{{- $enabled := false -}}
{{- range $key, $value := .Values.integrations }}
  {{- if $value.enabled }}
    {{- $enabled = true -}}
  {{- end }}
{{- end }}
{{- $enabled -}}
{{- end -}}


{{- define "folio-common.args" -}}
{{- $args := list -}}
{{- if .Values.args -}}
  {{- $args = concat $args .Values.args -}}
{{- end -}}
{{- if .Values.heapDumpEnabled -}}
  {{- $heapDumpArgs := list "-XX:+HeapDumpOnOutOfMemoryError" "-XX:HeapDumpPath=/tmp/dump/heapdump" -}}
  {{- $args = concat $args $heapDumpArgs -}}
{{- end -}}
{{- if len $args -}}
{{ include "folio-common.tplvalues.render" (dict "value" $args "context" $) }}
{{- end -}}
{{- end -}}


{{- define "folio-common.volumes" -}}
{{- range $name, $config := .Values.configMaps -}}
  {{- if $config.enabled }}
- name: {{ $name }}
  configMap:
    name: {{ printf "%s-%s" (include "folio-common.fullname" $) $name }}
    defaultMode: 0755
  {{- end }}
{{- end -}}
{{- end -}}

{{- define "folio-common.volumeMounts" -}}
{{- range $name, $config := .Values.configMaps -}}
  {{- if $config.enabled }}
- name: {{ $name }}
  mountPath: {{ $config.mountPath }}
  subPath: {{ $config.fileName }}
  {{- end }}
{{- end -}}
{{- end -}}

{{- define "folio-common.javaOpts.render" -}}
{{- $javaOpts := list -}}
{{- if .Values.javaOpts -}}
  {{- $javaOpts = append $javaOpts (.Values.javaOpts | join " ") -}}
{{- end -}}
{{- if .Values.extraJavaOpts -}}
  {{- $javaOpts = append $javaOpts (.Values.extraJavaOpts | join " ") -}}
{{- end -}}
{{- if .Values.configMaps.log4j -}}
  {{- $log4jOpt := printf "-Dlog4j.configurationFile=%s" .Values.configMaps.log4j.mountPath -}}
  {{- $javaOpts = append $javaOpts $log4jOpt -}}
{{- end -}}
{{- if .Values.configMaps.ephemeral -}}
  {{- $ephemeralOpt := printf "-Dsecure_store_props=%s" .Values.configMaps.ephemeral.mountPath -}}
  {{- $javaOpts = append $javaOpts $ephemeralOpt -}}
{{- end -}}
{{- $javaOpts | join " " | quote -}}
{{- end -}}
