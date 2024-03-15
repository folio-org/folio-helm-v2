{{/* vim: set filetype=mustache: */}}

{{- /*
folio-common.metadata creates a standard metadata header.
It creates a 'metadata:' section with name and labels.
*/ -}}
{{ define "folio-common.metadata" -}}
metadata:
  name: {{ template "folio-common.fullname" . }}
  labels:
{{ include "folio-common.labels" . | indent 4 -}}
{{- end -}}
