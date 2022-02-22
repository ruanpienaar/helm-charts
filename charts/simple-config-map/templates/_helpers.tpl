{{- define "single-config-map.fullname" -}}
{{- default .Chart.Name "simple_config_map" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{- define "simple-config-map.labels" }}
  labels:
    generator: helm
    date: {{ now | htmlDate }}
    chart: {{ .Chart.Name }}
    version: {{ .Chart.Version }}
{{- end }}

{{- define "simple-config-map.app" -}}
app_name: {{ .Chart.Name }}
app_version: "{{ .Chart.Version }}"
{{- end -}}