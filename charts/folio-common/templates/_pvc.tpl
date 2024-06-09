{{/* vim: set filetype=mustache: */}}

{{- define "folio-common.pvc.tpl" -}}
{{- $ := index . 0 -}}
{{- with index . 1 -}}
apiVersion: v1
kind: PersistentVolumeClaim
{{ template "folio-common.pvc.metadata" (list $ .) }}
spec:
  storageClassName: {{ .storageClassName | default "gp2" }}
  accessModes:
  - {{ .accessModes | default "ReadWriteOnce" }}
  resources:
    requests:
      storage: {{ .size | default "10Gi" }}
  volumeMode: Filesystem
{{- end -}}
{{- end -}}

{{- define "folio-common.pvc.metadata" -}}
{{- $ := index . 0 }}
{{- with index . 1 }}
{{- $localMeta := (fromYaml (include "folio-common.pvc.metaName" (list $ .)) | default (dict )) -}}
{{- $commonMeta := (fromYaml (include "folio-common.metadata" $) | default (dict )) -}}
{{- merge $localMeta $commonMeta | toYaml -}}
{{- end -}}
{{- end -}}

{{- define "folio-common.pvc.metaName" -}}
{{- $ := index . 0 }}
{{- with index . 1 }}
metadata:
  name: {{ include "folio-common.tplvalues.render" (dict "value" .name "context" $) }}
{{- end -}}
{{- end -}}
