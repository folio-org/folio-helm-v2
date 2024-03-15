{{/* vim: set filetype=mustache: */}}

{{- define "folio-common.ingress.tpl" }}
{{- if .Values.ingress.enabled }}
{{- $fullName := include "folio-common.fullname" . -}}
apiVersion: networking.k8s.io/v1
kind: Ingress
{{ template "folio-common.metadata" . }}
  annotations:
    {{- toYaml .Values.ingress.annotations | nindent 4 }}
spec:
  {{- if .Values.ingress.className }}
  ingressClassName: {{ .Values.ingress.className }}
  {{- end }}
  {{- if .Values.ingress.tls }}
  tls:
    {{- range .Values.ingress.tls }}
    - hosts:
        {{- range .hosts }}
        - {{ . | quote }}
        {{- end }}
      secretName: {{ .secretName }}
    {{- end }}
  {{- end }}
  rules:
    {{- range .Values.ingress.hosts }}
    - host: {{ .host | quote }}
      http:
        paths:
          {{- range .paths }}
          - path: {{ .path }}
            {{- if .pathType }}
            pathType: {{ .pathType }}
            {{- end }}
            backend:
              service:
                name: {{ $fullName }}
                port:
                  number: {{ .servicePort }}
          {{- end }}
    {{- end }}
{{- end }}
{{- end }}

{{- define "folio-common.ingress" -}}
{{- template "folio-common.util.merge" (append . "folio-common.ingress.tpl") -}}
{{- end -}}
