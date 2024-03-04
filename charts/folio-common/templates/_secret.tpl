{{/* vim: set filetype=mustache: */}}

{{- define "folio-common.secret.tpl" -}}
apiVersion: v1
kind: Secret
{{ template "folio-common.metadata" . }}
type: Opaque
data: {}
{{- end -}}
{{- define "folio-common.secret" -}}
{{- template "folio-common.util.merge" (append . "folio-common.secret.tpl") -}}
{{- end -}}

{{/*
Generate secret data from a given dictionary.
*/}}
{{- define "folio-common.generateSecretData" -}}
{{- $prefix := index . 0 -}}
{{- $dataDict := index . 1 -}}
{{- range $key, $value := $dataDict }}
  {{- if and $value (not (or (eq $key "existingSecret") (eq $key "enabled"))) }}
  {{ $prefix }}_{{ $key | snakecase | upper | replace "." "_" | replace "-" "_" }}: {{ $value | toString | b64enc | quote }}
  {{- end }}
{{- end }}
{{- end -}}

{{- define "folio-common.okapi.secret" -}}
metadata:
  name: {{ printf "%s-okapi" (include "folio-common.fullname" .) }}
data: {{ include "folio-common.generateSecretData" (list "OKAPI" .Values.integrations.okapi) | nindent 2 }}
{{ include "folio-common.generateSecretData" (list "OKAPI_SERVICE" .Values.integrations.okapi) | nindent 2 }}
{{- end -}}

{{- define "folio-common.db.secret" -}}
metadata:
  name: {{ printf "%s-db" (include "folio-common.fullname" .) }}
data: {{ include "folio-common.generateSecretData" (list "DB" .Values.integrations.db) | nindent 2 }}
{{- end -}}

{{- define "folio-common.kafka.secret" -}}
metadata:
  name: {{ printf "%s-kafka" (include "folio-common.fullname" .) }}
data: {{ include "folio-common.generateSecretData" (list "KAFKA" .Values.integrations.kafka) | nindent 2 }}
{{- end -}}

{{- define "folio-common.opensearch.secret" -}}
metadata:
  name: {{ printf "%s-opensearch" (include "folio-common.fullname" .) }}
data: {{ include "folio-common.generateSecretData" (list "OPENSEARCH" .Values.integrations.opensearch) | nindent 2 }}
{{ include "folio-common.generateSecretData" (list "ELASTICSEARCH" .Values.integrations.opensearch) | nindent 2 }}
{{- end -}}

{{- define "folio-common.systemuser.secret" -}}
metadata:
  name: {{ printf "%s-systemuser" (include "folio-common.fullname" .) }}
data: {{ include "folio-common.generateSecretData" (list "SYSTEM_USER" .Values.integrations.systemuser) | nindent 2 }}
{{- end -}}

{{- define "folio-common.s3.secret" -}}
metadata:
  name: {{ printf "%s-s3" (include "folio-common.fullname" .) }}
data: {{ include "folio-common.generateSecretData" (list "S3" .Values.integrations.s3) | nindent 2 }}
{{ include "folio-common.generateSecretData" (list "AWS" .Values.integrations.s3) | nindent 2 }}
{{ include "folio-common.generateSecretData" (list "LOCAL_FS" .Values.integrations.s3) | nindent 2 }}
{{- end -}}
