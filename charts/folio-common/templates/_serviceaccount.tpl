{{/* vim: set filetype=mustache: */}}

{{- define "folio-common.serviceaccount.tpl" }}
{{- if .Values.serviceAccount.create }}
apiVersion: v1
kind: ServiceAccount
{{ template "folio-common.metadata" . }}
{{- with .Values.serviceAccount.annotations }}
  annotations:
    {{- toYaml . | nindent 4 }}
{{- end }}
{{- end }}
{{- end }}
