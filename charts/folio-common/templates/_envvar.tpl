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
- name: QUARKUS_HTTP_PORT
  value: "{{ .Values.eureka.sidecarContainer.port | default "8082" }}"
- name: QUARKUS_REST_CLIENT_READ_TIMEOUT
  value: "180000"
- name: QUARKUS_REST_CLIENT_CONNECT_TIMEOUT
  value: "180000"
- name: QUARKUS_REST_CLIENT_SEND_TIMEOUT
  value: "180000"
- name: TE_CLIENT_URL
  value: "{{ .Values.eureka.sidecarContainer.teClientUrl | default "http://mgr-tenant-entitlements" }}"
- name: TM_CLIENT_URL
  value: "{{ .Values.eureka.sidecarContainer.tmClientUrl | default "http://mgr-tenants" }}"
- name: MODULE_URL
  value: "http://localhost:{{- with (index .Values.service.ports 0) }}{{ .containerPort | default "8080" }} {{- end}}"
- name: MODULE_NAME
  value: "{{ .Chart.Name }}"
- name: MODULE_VERSION
  value: "{{ default .Values.image.tag }}"
- name: SIDECAR_FORWARD_UNKNOWN_REQUESTS
  value: "true"
- name: SIDECAR_URL
  value: "http://localhost:{{ .Values.eureka.sidecarContainer.port | default "8082" }}"
- name: SIDECAR
  value: "true"
- name: REQUEST_TIMEOUT
  value: "604800000"
- name: KC_LOGIN_CLIENT_SUFFIX
  value: "-application"
- name: KC_URI_VALIDATION_ENABLED
  value: "false"
- name: ALLOW_CROSS_TENANT_REQUESTS
  value: "true"
- name: QUARKUS_HTTP_LIMITS_MAX_INITIAL_LINE_LENGTH
  value: "8192"
- name: JAVA_OPTS
  value: "-Dquarkus.log.level=DEBUG -Dquarkus.http.host=0.0.0.0 -Djava.util.logging.manager=org.jboss.logmanager.LogManager -XX:+UseZGC -Xmx128m -Dquarkus.log.category.'org.apache.kafka'.level=DEBUG"
- name: SC_LOG_LEVEL
  value: "DEBUG"
- name: ROOT_LOG_LEVEL
  value: "DEBUG"
- name: SECRET_STORE_TYPE
  valueFrom:
    secretKeyRef:
      name: eureka-common
      key: SECRET_STORE_TYPE
- name: SECRET_STORE_AWS_SSM_REGION
  valueFrom:
    secretKeyRef:
      name: eureka-common
      key: SECRET_STORE_AWS_SSM_REGION
- name: ENV
  valueFrom:
    secretKeyRef:
      name: db-credentials
      key: ENV
- name: SIDECAR_FORWARD_UNKNOWN_REQUESTS_DESTINATION
  valueFrom:
    secretKeyRef:
      name: eureka-common
      key: SIDECAR_FORWARD_UNKNOWN_REQUESTS_DESTINATION
- name: KAFKA_HOST
  valueFrom:
    secretKeyRef:
      name: kafka-credentials
      key: KAFKA_HOST
- name: KAFKA_PORT
  valueFrom:
    secretKeyRef:
      name: kafka-credentials
      key: KAFKA_PORT
- name: MOD_USERS_KEYCLOAK_URL
  valueFrom:
    secretKeyRef:
      name: eureka-common
      key: MOD_USERS_KEYCLOAK_URL
- name: MOD_USERS_BL
  valueFrom:
    secretKeyRef:
      name: eureka-common
      key: MOD_USERS_BL
- name: KC_URL
  valueFrom:
    secretKeyRef:
      name: eureka-common
      key: KC_URL
{{- end }}
