{{/* vim: set filetype=mustache: */}}

{{- define "folio-common.configmap.tpl" -}}
apiVersion: v1
kind: ConfigMap
{{ template "folio-common.metadata" . }}
data: {}
{{- end -}}

{{- define "folio-common.configmap" -}}
{{- template "folio-common.util.merge" (append . "folio-common.configmap.tpl") -}}
{{- end -}}

{{- define "folio-common.configmap.log4j" -}}
metadata:
  name: {{ printf "%s-log4j" (include "folio-common.fullname" .) }}
data:
  {{ .Values.configMaps.log4j.fileName }}: |-
{{ tpl ($.Files.Get (printf "resources/%s" .Values.configMaps.log4j.fileName)) $ | indent 4 }}
{{- end -}}

{{- define "folio-common.configmap.ephemeral" -}}
metadata:
  name: {{ printf "%s-ephemeral" (include "folio-common.fullname" .) }}
data:
  {{ .Values.configMaps.ephemeral.fileName }}: |-
{{ tpl ($.Files.Get (printf "resources/%s" .Values.configMaps.ephemeral.fileName)) $ | indent 4 }}
{{- end -}}
