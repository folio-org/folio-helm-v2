{{/* vim: set filetype=mustache: */}}

{{- define "folio-common.service.tpl" }}
apiVersion: v1
kind: Service
{{ template "folio-common.metadata" . }}
  annotations:
    {{- toYaml .Values.service.annotations | nindent 4 }}
spec:
  type: {{ .Values.service.type }}
  ports:
    {{- range .Values.service.ports }}
    - name: {{ .name }}
      protocol: {{ .protocol }}
      port: {{ .port }}
      targetPort: {{ .targetPort }}
    {{- end }}
    {{- range $sidecarName, $sidecarConfig := .Values.sidecarContainers }}
    {{- if eq (include "folio-common.tplvalues.render" (dict "value" $sidecarConfig.enabled "context" $)) "true" }}
    {{- range $index, $val := $sidecarConfig.ports }}
    - name: {{ $val.name | default "sidecar-{{ $sidecarName }}-{{ $index }}" }}
      protocol: {{ $val.protocol | default "TCP" }}
      port: {{ $val.port | default "8082" }}
      targetPort: {{ "sidecar" }}
    {{- end }}
    {{- end }}
    {{- end }}
    {{- if .Values.jmx.enabled }}
    - name: jmx
      protocol: TCP
      port: {{ .Values.jmx.port }}
      targetPort: {{ .Values.jmx.port }}
    {{- end }}
  selector:
    {{- include "folio-common.selectorLabels" . | nindent 4 }}
{{- end }}

{{- define "folio-common.service" -}}
{{- template "folio-common.util.merge" (append . "folio-common.service.tpl") -}}
{{- end -}}
