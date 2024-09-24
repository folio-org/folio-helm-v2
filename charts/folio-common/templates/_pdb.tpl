{{/* vim: set filetype=mustache: */}}

{{- define "folio-common.pdb.tpl" }}
{{- if and .Values.pdb .Values.pdb.enabled }}
apiVersion: policy/v1
kind: PodDisruptionBudget
{{ template "folio-common.metadata" . }}
spec:
  {{- if .Values.pdb.minAvailable }}
  minAvailable: {{ .Values.pdb.minAvailable }}
  {{- end }}
  {{- if or .Values.pdb.maxUnavailable (not .Values.pdb.minAvailable) }}
  maxUnavailable: {{ .Values.pdb.maxUnavailable | default 1 }}
  {{- end }}
  selector:
    matchLabels:
      {{- include "folio-common.selectorLabels" . | nindent 6 }}
{{- end }}
{{- end }}

{{- define "folio-common.pdb" -}}
{{- template "folio-common.util.merge" (append . "folio-common.pdb.tpl") -}}
{{- end -}}
