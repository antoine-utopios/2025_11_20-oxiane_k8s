{{ define "exo02.fullName" -}}
{{ printf "%s-%s" $.Release.Name $.Chart.Name }}
{{- end }}

{{ define "exo02.storageClassHandler" -}}
{{- if eq $.Values.persistentVolume.defaultStorageClassName "manual" -}}
storageClassName: manual
  hostPath:
    path: {{ $.Values.persistentVolume.defaultHostPath.path }}
    type: {{ $.Values.persistentVolume.defaultHostPath.type }}
{{- end }}
{{- end }}

{{ define "exo02.selectorLabels" -}}
app: {{ .Release.Name }}-{{ .Chart.Name }}
{{- end }}