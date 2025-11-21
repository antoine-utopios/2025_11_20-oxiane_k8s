{{ define "demo-nginx.selectorLabels" -}}
app: example-nginx
type: demo-04
{{- end }}

{{ define "demo-nginx.validateTestValidation" -}}
{{ required "testValidation is a required key" .Values.testValidation }}
{{- end }}

{{ define "demo-nginx.validateTestValidationCorrectValue" -}}
  {{ with .Values.testValidation }}
    {{ if or (or (eq . "LoadBalancer") (eq . "NodePort")) (eq . "ClusterIP")}}
      {{/* Tout est bon! */}}
    {{- else }}
      {{ fail (printf "testValidation doesn't have a correct value: %s, available values are: [NodePort, ClusterIP, LoadBalancer]" . )}}
    {{- end }}
  {{- end }}
{{- end }}
