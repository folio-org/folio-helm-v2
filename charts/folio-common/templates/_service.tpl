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
    {{- if .Values.eureka.enabled | default false }}
    - name: sidecar
      protocol: TCP
      port: {{ .Values.eureka.sidecarContainer.port | default "8082" }}
      targetPort: {{ .Values.eureka.sidecarContainer.port | default "8082" }}
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
