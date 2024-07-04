{{/*
Expand the name of the chart.
*/}}
{{- define "ldp.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "ldp.fullname" -}}
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
{{- define "ldp.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "ldp.labels" -}}
helm.sh/chart: {{ include "ldp.chart" . }}
{{ include "ldp.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "ldp.selectorLabels" -}}
app.kubernetes.io/name: {{ include "ldp.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Create the name of the service account to use
*/}}
{{- define "ldp.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- default (include "ldp.fullname" .) .Values.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}

{{- define "ldp.container.env" -}}
- name: PATH
  value: "/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin"
- name: DATADIR
  value: "{{ .Values.ldpDataDirPath }}"
{{- end }}


{{- define "ldp.container.volumeMounts" -}}
- name: ldp-data
  mountPath: {{ .Values.ldpDataDirPath }}
- name: ldp-config
  mountPath: {{ .Values.ldpDataDirPath }}/ldpconf.json
  subPath: ldpconf.json
{{- end }}

{{- define "ldp.volumes" -}}
- name: ldp-data
  persistentVolumeClaim:
    claimName: {{ .Values.volumeClaims.ldpData.name }}
- name: ldp-config
  configMap:
    name: {{ .Values.ldpConfigMapName }}
{{- end }}
