{{/* vim: set filetype=mustache: */}}

{{/*
Sidecar container spec. With native: true it is rendered as a native sidecar (an initContainers
entry with restartPolicy: Always, Kubernetes >= 1.29): the kubelet starts the module container only
after the sidecar's startupProbe passes, and stops the sidecar only after the module exits.
Optional keys: native, startupProbe (native default: tcpSocket on the first sidecar port),
readinessProbe, livenessProbe.
*/}}
{{- define "folio-common.sidecar" -}}
{{- $native := include "folio-common.sidecar.isNative" . -}}
{{- $port := 8082 -}}
{{- with .sidecar.ports }}{{ $port = (index . 0).containerPort | default 8082 }}{{ end -}}
- name: {{ .sidecar.name | default "sidecar" }}
  image: "{{ .sidecar.image.repository }}:{{ .sidecar.image.tag | default "latest" }}"
  imagePullPolicy: {{ .sidecar.image.pullPolicy | default "IfNotPresent" }}
  {{- if $native }}
  restartPolicy: Always
  {{- end }}
  {{- if or .sidecar.envVars .sidecar.extraEnvVars }}
  env:
  {{- range .sidecar.envVars -}}
  {{- if contains "{{" (toJson .) }}
    {{- tpl . $.global | nindent 2 }}
  {{- else if and .name .value }}
  - name: {{ .name }}
    value: {{ .value | quote }}
  {{- else }}
  - {{- typeIs "string" . | ternary . (toYaml .) | indent 2 }}
  {{- end }}
  {{- end }}
  {{- range .sidecar.extraEnvVars -}}
  {{- if contains "{{" (toJson .) }}
    {{- tpl . $.global | nindent 2 }}
  {{- else if and .name .value }}
  - name: {{ .name }}
    value: {{ .value | quote }}
  {{- else }}
  {{- typeIs "string" . | ternary . (toYaml (list .)) | nindent 2 }}
  {{- end }}
  {{- end }}
  {{- end }}
  {{- if .sidecar.resources }}
  resources: {{ toYaml .sidecar.resources | nindent 4 }}
  {{- end }}
  {{- if .sidecar.startupProbe }}
  startupProbe: {{ toYaml .sidecar.startupProbe | nindent 4 }}
  {{- else if $native }}
  startupProbe:
    tcpSocket:
      port: {{ $port }}
    periodSeconds: 5
    failureThreshold: 60
  {{- end }}
  {{- with .sidecar.readinessProbe }}
  readinessProbe: {{ toYaml . | nindent 4 }}
  {{- end }}
  {{- with .sidecar.livenessProbe }}
  livenessProbe: {{ toYaml . | nindent 4 }}
  {{- end }}
{{- end -}}

{{/*
Prints "true" when the sidecar's native value renders to "true".
Usage: include "folio-common.sidecar.isNative" (dict "sidecar" . "global" $)
*/}}
{{- define "folio-common.sidecar.isNative" -}}
{{- if eq (include "folio-common.tplvalues.render" (dict "value" .sidecar.native "context" .global)) "true" }}true{{ end -}}
{{- end -}}

{{/*
Prints "true" when any sidecarContainers entry is both enabled and native.
*/}}
{{- define "folio-common.sidecar.anyNative" -}}
{{- $any := false -}}
{{- range .Values.sidecarContainers -}}
{{- if and (eq (include "folio-common.tplvalues.render" (dict "value" .enabled "context" $)) "true") (include "folio-common.sidecar.isNative" (dict "sidecar" . "global" $)) -}}
{{- $any = true -}}
{{- end -}}
{{- end -}}
{{- if $any }}true{{ end -}}
{{- end -}}

{{/*
Sidecar port part of container specs.
*/}}
{{- define "folio-common.sidecar.port" -}}
{{- $sidecarName := index . 0 -}}
{{- range $index, $val := index . 1 -}}
- name: {{ $val.name | default "sidecar-{{ $sidecarName }}-{{ $index }}" }}
  containerPort: {{ $val.containerPort | default "8082" }}
  protocol: {{ $val.protocol | default "TCP" }}
{{- end -}}
{{- end -}}

{{/*
Sidecar env vars part of container specs.
*/}}
{{- define "folio-common.sidecar.env.eureka.common" -}}
- name: AM_CLIENT_URL
  value: "http://mgr-applications"
- name: QUARKUS_HTTP_PORT
  value: "{{ (index .Values.sidecarContainers.eureka.ports 0).port | default "8082" }}"
- name: QUARKUS_REST_CLIENT_READ_TIMEOUT
  value: "360000"
- name: QUARKUS_REST_CLIENT_CONNECT_TIMEOUT
  value: "360000"
- name: QUARKUS_REST_CLIENT_SEND_TIMEOUT
  value: "360000"
- name: QUARKUS_HTTP_LIMITS_MAX_BODY_SIZE
  value: {{- if and (eq .Release.Namespace "sprint") (or (eq .Release.Name "mod-data-import") (eq .Release.Name "mod-bulk-operations") (eq .Release.Name "mod-data-export")) }} "204800k" {{ else }} "10240K" {{- end }}
- name: TE_CLIENT_URL
  value: "http://mgr-tenant-entitlements"
- name: TM_CLIENT_URL
  value: "http://mgr-tenants"
- name: MODULE_URL
  value: "http://localhost:{{ (index .Values.service.ports 0).containerPort | default "8080" }}"
- name: MODULE_NAME
  value: "{{ .Chart.Name }}"
- name: MODULE_VERSION
  value: "{{ default .Values.image.tag }}"
- name: SIDECAR_FORWARD_UNKNOWN_REQUESTS
  value: {{- if eq .Chart.Name "mod-scheduler" }} "false" {{ else }} "true" {{- end }}
- name: SIDECAR_URL
  value: "http://localhost:{{ (index .Values.sidecarContainers.eureka.ports 0).port | default "8082" }}"
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
  value: "-Dquarkus.log.level=INFO -Dquarkus.http.host=0.0.0.0 -Djava.util.logging.manager=org.jboss.logmanager.LogManager -XX:+UseZGC -Xms64m -Xmx64m -Dquarkus.log.category.'org.apache.kafka'.level=INFO"
- name: SC_LOG_LEVEL
  value: "INFO"
- name: ROOT_LOG_LEVEL
  value: "INFO"
- name: HANDLER_EGRESS_IGNORE_SYSTEM_USER_TOKEN_ERROR
  value: "true"
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
      name: {{- if eq .Release.Namespace "cikarate" }} kafka-credentials-2 {{ else }} kafka-credentials {{- end }}
      key: KAFKA_HOST
- name: KAFKA_PORT
  valueFrom:
    secretKeyRef:
      name: {{- if eq .Release.Namespace "cikarate" }} kafka-credentials-2 {{ else }} kafka-credentials {{- end }}
      key: KAFKA_PORT
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
{{- if eq .Chart.Name "mod-scheduler"  }}
- name: ROUTING_DYNAMIC_ENABLED
  value: "true" 
{{- end }}

{{- end }}
