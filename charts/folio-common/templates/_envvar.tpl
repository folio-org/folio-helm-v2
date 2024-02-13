{{/* vim: set filetype=mustache: */}}

{{- define "folio-common.envvar" -}}
env:
{{- if .Values.extraEnvVars }}
{{- include "folio-common.tplvalues.render" (dict "value" .Values.extraEnvVars "context" $) | nindent 2 }}
{{- end }}
  - name: JAVA_OPTIONS
    value: {{ include "folio-common.javaOpts.render" . }}
envFrom:
{{- $secrets := list -}}
{{- $secretsString := "" -}}
{{- if .Values.extraEnvVarsSecrets -}}
{{- range $secret := .Values.extraEnvVarsSecrets -}}
{{- $secrets = append $secrets $secret -}}
{{- $secretsString = printf "%s,%s" $secretsString $secret }}
  - secretRef:
      name: {{ $secret }}
{{- end -}}
{{- end -}}
{{- range $integration, $config := .Values.integrations -}}
  {{- if and $config.enabled }}
    {{- $secretName := "" -}}
    {{- if $config.existingSecret }}
      {{- $secretName = $config.existingSecret -}}
    {{- else }}
      {{- $secretName = printf "%s-%s" (include "folio-common.fullname" $) $integration -}}
    {{- end }}
    {{- if not (contains $secretName $secretsString) }}
    {{- $secrets = append $secrets $secretName }}
    {{- $secretsString = printf "%s,%s" $secretsString $secretName }}
  - secretRef:
      name: {{ $secretName }}
    {{- end }}
  {{- end }}
{{- end -}}
{{- end -}}