{{/* vim: set filetype=mustache: */}}

{{- define "folio-common.service.tpl" }}
apiVersion: v1
kind: Service
{{ template "folio-common.metadata" . }}
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
    {{- if and $sidecarConfig.enabled }}
    {{- range $index, $val := $sidecarConfig.ports }}
    - name: {{ $val.name | default "sidecar-{{ $sidecarName }}-{{ $index }}" }}
      protocol: {{ $val.protocol | default "TCP" }}
      port: {{ $val.port | default "8082" }}
      targetPort: {{ $val.containerPort | default "8082" }}
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
