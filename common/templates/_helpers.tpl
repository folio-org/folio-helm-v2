{{/*
Expand the name of the chart.
*/}}
{{- define "helm.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "helm.fullname" -}}
{{- if .Values.fullnameOverride }}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- $name := default .Chart.Name .Values.nameOverride }}
{{- if contains $name .Release.Name }}
{{- .Release.Name | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" }}
{{- end }}
{{- end }}
{{- end }}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "helm.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "helm.labels" -}}
helm.sh/chart: {{ include "helm.chart" . }}
team: {{ .Release.Namespace }}
{{ include "helm.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{ with .Values.extraLabels }}
{{- tpl . $ }}
{{- end }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "helm.selectorLabels" -}}
app.kubernetes.io/name: {{ include "helm.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Create the name of the service account to use
*/}}
{{- define "helm.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- default (include "helm.fullname" .) .Values.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}

{{/*
Create Volume Mount structure
*/}}
{{- define "helm.volumeMounts" -}}
{{- range .Values.config }}
- name: {{ tpl .name $ }}
  mountPath: {{ tpl .mountPath $ }}
  {{- if .subPath }}
  subPath: {{ tpl .subPath $ }}
  {{- end }}
{{- end }}
{{- if .Values.volumeMounts }}
{{- range .Values.volumeMounts.secrets }}
- name: {{ tpl .name $ }}
  mountPath: {{ tpl .mountPath $ }}
  {{- if .subPath }}
  subPath: {{ tpl .subPath $ }}
  {{- end }}
  readOnly: true
{{- end }}
{{- range .Values.volumeMounts.emptyDirs }}
- name: {{ tpl .name $ }}
  mountPath: {{ tpl .mountPath $ }}
{{- end }}
{{- range .Values.volumeMounts.pvc }}
- name: {{ tpl .name $ }}
  mountPath: {{ tpl .mountPath $ }}
{{- end }}
{{- end }}
{{- end -}}

{{/*
Create Volume structure
*/}}
{{- define "helm.volumes" -}}
{{- range .Values.config }}
- name: {{ tpl .name $ }}
  configMap:
    name: {{ tpl .name $ }}
    defaultMode: 0755
{{- end }}
{{- if .Values.volumeMounts }}
{{- range .Values.volumeMounts.secrets }}
- name: {{ tpl .name $ }}
  secret:
    secretName: {{ tpl .secretName $ }}
{{- end }}
{{- range .Values.volumeMounts.emptyDirs }}
- name: {{ tpl .name $ }}
  emptyDir: {}
{{- end }}
{{- range .Values.volumeMounts.pvc }}
- name: {{ tpl .name $ }}
  persistentVolumeClaim:
    claimName: {{ tpl .claimName $ }}
{{- end }}
{{- end }}
{{- end -}}
