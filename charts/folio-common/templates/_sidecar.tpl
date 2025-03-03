{{/* vim: set filetype=mustache: */}}

{{- define "folio-common.sidecar" -}}
- name: {{ .sidecar.name | default "sidecar" }}
  image: "{{ .sidecar.image.repository }}:{{ .sidecar.image.tag | default "latest" }}"
  imagePullPolicy: {{ .sidecar.image.pullPolicy | default "IfNotPresent" }}
  {{- if or .sidecar.envVars .sidecar.extraEnvVars }}
  env:
  {{- range .sidecar.envVars -}}
  {{- if contains "{{" (toJson .) }}
    {{- tpl . $.global | nindent 2 }}
  {{- else if and .name .value }}
  - name: {{ .name }}
    value: {{ .value }}
  {{- else }}
  - {{- typeIs "string" . | ternary . (toYaml .) | indent 4 }}
  {{- end }}
  {{- end }}
  {{- range .sidecar.extraEnvVars -}}
  {{- if contains "{{" (toJson .) }}
    {{- tpl . $.global | nindent 2 }}
  {{- else if and .name .value }}
  - name: {{ .name }}
    value: {{ .value }}
  {{- else }}
  - {{- typeIs "string" . | ternary . (toYaml .) | indent 4 }}
  {{- end }}
  {{- end }}
  {{- end }}
  {{- if .sidecar.resources }}
  resources: {{ toYaml .sidecar.resources | nindent 4 }}
  {{- end }}
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
  value: "180000"
- name: QUARKUS_REST_CLIENT_CONNECT_TIMEOUT
  value: "180000"
- name: QUARKUS_REST_CLIENT_SEND_TIMEOUT
  value: "180000"
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
  value: "true"
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
  value: "-Dquarkus.log.level=DEBUG -Dquarkus.http.host=0.0.0.0 -Djava.util.logging.manager=org.jboss.logmanager.LogManager -XX:+UseZGC -Xms64m -Xmx64m -Dquarkus.log.category.'org.apache.kafka'.level=DEBUG"
- name: SC_LOG_LEVEL
  value: "INFO"
- name: ROOT_LOG_LEVEL
  value: "INFO"
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
