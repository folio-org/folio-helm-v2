{{/* vim: set filetype=mustache: */}}

{{- define "folio-common.envvar" -}}
env:
{{- if .Values.envVars }}
{{- include "folio-common.tplvalues.render" (dict "value" .Values.envVars "context" $) | nindent 2 }}
{{- end }}
{{- if .Values.extraEnvVars }}
{{- include "folio-common.tplvalues.render" (dict "value" .Values.extraEnvVars "context" $) | nindent 2 }}
{{- end }}
  - name: JAVA_OPTIONS
    value: {{ include "folio-common.javaOpts.render" . }}
envFrom:
{{- $secrets := list -}}
{{- $secretsString := "" -}}
{{- if .Values.extraEnvVarsSecrets -}}
{{- range $secret := .Values.extraEnvVarsSecrets -}}
{{- $secrets = append $secrets $secret -}}
{{- $secretsString = printf "%s,%s" $secretsString $secret }}
  - secretRef:
      name: {{ $secret }}
{{- end -}}
{{- end -}}
{{- range $integration, $config := .Values.integrations -}}
  {{- if and $config.enabled }}
    {{- $secretName := "" -}}
    {{- if $config.existingSecret }}
      {{- $secretName = $config.existingSecret -}}
    {{- else }}
      {{- $secretName = printf "%s-%s" (include "folio-common.fullname" $) $integration -}}
    {{- end }}
    {{- if not (contains $secretName $secretsString) }}
    {{- $secrets = append $secrets $secretName }}
    {{- $secretsString = printf "%s,%s" $secretsString $secretName }}
  - secretRef:
      name: {{ $secretName }}
    {{- end }}
  {{- end }}
{{- end -}}
{{- end -}}

{{/*
Sidecar env vars part of container specs.
*/}}
{{- define "folio-common.sidecar.env.vars" -}}
env:
- name: AM_CLIENT_URL
  value: "{{ .Values.eureka.sidecarContainer.amClientUrl | default "http://mgr-applications" }}"
- name: TE_CLIENT_URL
  value: "{{ .Values.eureka.sidecarContainer.teClientUrl | default "http://mgr-tenant-entitlements" }}"
- name: TM_CLIENT_URL
  value: "{{ .Values.eureka.sidecarContainer.tmClientUrl | default "http://mgr-tenants" }}"
- name: MODULE_URL
  value: "http://{{ .Chart.Name }}"
- name: MODULE_NAME
  value: {{ .Chart.Name | quote }}
- name: MODULE_VERSION
  value: "{{ (split "-" .Values.image.tag)._0 | default .Values.image.tag }}"
- name: SIDECAR_FORWARD_UNKNOWN_REQUESTS
  value: "true"
- name: SIDECAR_URL
  value: "http://{{ .Chart.Name }}:{{ .Values.eureka.sidecarContainer.port | default "8082" }}"
- name: SIDECAR
  value: "true"
- name: JAVA_OPTS
  value: "--server.port={{ .Values.eureka.sidecarContainer.port | default "8082" }} -Dquarkus.http.host=0.0.0.0 -Djava.util.logging.manager=org.jboss.logmanager.LogManager -XX:+UseZGC -Xmx128m"
- name: {{ .Chart.Name | replace "-" "_" | upper }}_URL
  value: "http://{{ .Chart.Name }}/{{ .Chart.Name }}"
- name: SIDECAR_FORWARD_UNKNOWN_REQUESTS_DESTINATION
  valueFrom:
    secretKeyRef:
      name: eureka-common
      key: KONG_ADMIN_URL
{{- end }}
