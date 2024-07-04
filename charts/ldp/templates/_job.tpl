{{- define "ldp.job.template" -}}
apiVersion: batch/v1
kind: Job
metadata:
  name: "{{ .Chart.Name }}-{{ .jobName }}"
  labels:
    {{- include "ldp.labels" . | nindent 4 }}
  {{- with .annotations }}
  annotations:
    {{- toYaml . | nindent 4 }}
  {{- end }}
spec:
  activeDeadlineSeconds: 300
  ttlSecondsAfterFinished: 100
  template:
    metadata:
      labels:
        {{- include "ldp.labels" . | nindent 8 }}
    spec:
      containers:
      - name: {{ .containerName }}
        image: "{{ .Values.image.repository }}:{{ .Values.image.tag | default .Chart.AppVersion }}"
        args:
        - {{ .command }}
        - -D
        - {{ .Values.ldpDataDirPath }}
        - --profile
        - folio
        - --direct-extraction-no-ssl
        env:
          {{- include "ldp.container.env" . | nindent 8 }}
        volumeMounts:
          {{- include "ldp.container.volumeMounts" . | nindent 8 }}
        {{- with .Values.resources }}
        resources: {{ toYaml . | nindent 8 }}
        {{- end }}
      restartPolicy: Never
      volumes:
        {{- include "ldp.volumes" . | nindent 6 }}
  {{- with .podFailurePolicy }}
  podFailurePolicy:
    rules:
    - action: Ignore
      onExitCodes:
        containerName: {{ .containerName }}
        operator: In
        values: [{{ .exitCodes }}]
  {{- end }}
  backoffLimit: 3
{{- end }}
