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

{{- define "folio-common.configmap.apiconfig" -}}
metadata:
  name: {{ printf "%s-apiconfig" (include "folio-common.fullname" .) }}
data:
  {{ .Values.configMaps.apiconfig.fileName }}: |-
{{ tpl ($.Files.Get (printf "resources/%s" .Values.configMaps.apiconfig.fileName)) $ | indent 4 }}
{{- end -}}

{{- define "folio-common.configmap.sip2config" -}}
metadata:
  name: {{ printf "%s-sip2config" (include "folio-common.fullname" .) }}
data:
  {{ .Values.configMaps.sip2config.fileName }}: |-
{{ tpl ($.Files.Get (printf "resources/%s" .Values.configMaps.sip2config.fileName)) $ | indent 4 }}
{{- end -}}

{{- define "folio-common.configmap.sip2tenants" -}}
metadata:
  name: {{ printf "%s-sip2tenants" (include "folio-common.fullname" .) }}
data:
  {{ .Values.configMaps.sip2tenants.fileName }}: |-
{{ tpl ($.Files.Get (printf "resources/%s" .Values.configMaps.sip2tenants.fileName)) $ | indent 4 }}
{{- end -}}

{{- define "folio-common.configmap.jmx-config" -}}
metadata:
  name: {{ printf "%s-jmx-config" (include "folio-common.fullname" .) }}
data:
  prometheus-jmx-config.yaml: |-
{{ tpl (.Files.Get "resources/prometheus-jmx-config.yaml") $ | indent 4 }}
{{- end -}}

{{- define "folio-common.configmap.jmx-install" -}}
metadata:
  name: {{ printf "%s-jmx-install" (include "folio-common.fullname" .) }}
data:
  jmx-install.sh: |-
{{ tpl (.Files.Get "resources/jmx-install.sh") $ | indent 4 }}
{{- end -}}
