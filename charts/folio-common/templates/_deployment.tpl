{{/* vim: set filetype=mustache: */}}

{{- define "folio-common.deployment.tpl" }}
apiVersion: apps/v1
kind: Deployment
metadata:
{{ template "folio-common.metadata" . }}
spec:
  {{- if not .Values.autoscaling.enabled }}
  replicas: {{ .Values.replicaCount }}
  {{- end }}
  selector:
    matchLabels: {{ include "folio-common.selectorLabels" . | nindent 6 }}
  template:
    metadata:
      {{- with .Values.podAnnotations }}
      annotations: {{ toYaml . | nindent 8 }}
      {{- end }}
      labels: {{ include "folio-common.selectorLabels" . | nindent 8 }}
    spec:
      {{- with .Values.imagePullSecrets }}
      imagePullSecrets: {{ toYaml . | nindent 8 }}
      {{- end }}
      serviceAccountName: {{ include "folio-common.serviceAccountName" . }}
      {{- with .Values.podSecurityContext }}
      securityContext: {{ toYaml . | nindent 8 }}
      {{- end }}
      {{- if and .Values.initContainer .Values.initContainer.enabled }}
      {{- with .Values.initContainer }}
      initContainers:
        - name: {{ $.Chart.Name }}-init
          image: {{ .image.repository }}:{{ .image.tag | default "latest" }}
          imagePullPolicy: {{ .image.pullPolicy | default "Always" }}
          {{- if .command }}
          command: {{ .command }}
          {{- end }}
          {{- if .args }}
          args: {{ include "folio-common.tplvalues.render" (dict "value" .args "context" $) | nindent 12 }}
          {{- end }}
      {{- if and .extraVolumeMounts (eq (include "folio-common.list.hasAnyEnabled" .extraVolumeMounts) "true") }}
          volumeMounts: {{- include "folio-common.list.renderEnabled" (list $ .extraVolumeMounts) | nindent 12 }}
      {{- end }}
      {{- end }}
      {{- end }}
      containers:
        - name: {{ .Chart.Name }}
          {{- with .Values.securityContext }}
          securityContext: {{ toYaml . | nindent 12 }}
          {{- end }}
          image: "{{ .Values.image.repository }}:{{ .Values.image.tag | default .Chart.AppVersion }}"
          imagePullPolicy: {{ .Values.image.pullPolicy }}
          {{- if or .Values.args .Values.heapDumpEnabled }}
          args: {{ include "folio-common.args" . | nindent 12 }}
          {{- end }}
          {{- include "folio-common.envvar" . | nindent 10 }}
          {{- with .Values.resources }}
          resources: {{ toYaml . | nindent 12 }}
          {{- end }}
          {{- with .Values.startupProbe }}
          startupProbe: {{ toYaml . | nindent 12 }}
          {{- end }}
          {{- with .Values.readinessProbe }}
          readinessProbe:  {{ toYaml . | nindent 12 }}
          {{- end }}
          {{- with .Values.livenessProbe }}
          livenessProbe: {{ toYaml . | nindent 12 }}
          {{- end }}
        {{- if .Values.eureka.enabled }}
        {{- include "folio-common.sidecar.image" . | nindent 8 }}
        {{- include "folio-common.sidecar.env.vars" . | nindent 10 }}
        {{- end }}
          ports:
            {{- range .Values.service.ports }}
            - name: {{ .targetPort | default "http" }}
              containerPort: {{ .containerPort | default "8080" }}
              protocol: {{ .protocol | default "TCP"}}
            {{- end }}
            {{- if .Values.jmx.enabled }}
            - name: "jmx"
              containerPort: {{ .Values.jmx.port | default "1099" }}
              protocol: "TCP"
            {{- end }}
            {{- if .Values.eureka.enabled }}
            {{- include "folio-common.sidecar.port" . | nindent 12 }}
            {{- end }}
          volumeMounts:
          {{- include "folio-common.volumeMounts" . | indent 12}}
          {{- if and .Values.extraVolumeMounts (eq (include "folio-common.list.hasAnyEnabled" .Values.extraVolumeMounts) "true") }}
          {{- include "folio-common.list.renderEnabled" (list $ .Values.extraVolumeMounts) | nindent 12 }}
          {{- end }}
          {{- if .Values.heapDumpEnabled }}
            - name: heapdump
              mountPath: /tmp/dump
          {{- end }}
      volumes:
      {{- include "folio-common.volumes" . | indent 8}}
    {{- if and .Values.extraVolumes (eq (include "folio-common.list.hasAnyEnabled" .Values.extraVolumes) "true") }}
      {{- include "folio-common.list.renderEnabled" (list $ .Values.extraVolumes) | nindent 8 }}
    {{- end }}
      {{- if .Values.heapDumpEnabled }}
        - name: heapdump
          emptyDir: {}
      {{- end }}
      {{- with .Values.nodeSelector }}
      nodeSelector: {{ toYaml . | nindent 8 }}
      {{- end }}
      {{- with .Values.affinity }}
      affinity: {{ toYaml . | nindent 8 }}
      {{- end }}
      {{- with .Values.tolerations }}
      tolerations: {{ toYaml . | nindent 8 }}
      {{- end }}
{{- end }}

{{- define "folio-common.deployment" -}}
{{- template "folio-common.util.merge" (append . "folio-common.deployment.tpl") -}}
{{- end -}}
