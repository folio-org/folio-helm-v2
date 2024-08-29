{{- define "okapi.hazelcast.configmap" -}}
metadata:
  name: okapi-hazelcast-conf
data:
  hazelcast.xml: |-
{{ tpl (.Files.Get "resources/hazelcast-config.xml") . | indent 4 }}
{{- end -}}
