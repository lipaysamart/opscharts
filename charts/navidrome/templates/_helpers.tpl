{{/*
Expand the name of the chart.
*/}}
{{- define "navidrome.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "navidrome.fullname" -}}
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
{{- define "navidrome.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "navidrome.labels" -}}
helm.sh/chart: {{ include "navidrome.chart" . }}
{{ include "navidrome.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "navidrome.selectorLabels" -}}
app.kubernetes.io/name: {{ include "navidrome.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Create the name of the service account to use
*/}}
{{- define "navidrome.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- default (include "navidrome.fullname" .) .Values.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}

{{/*
Set's up the volume Set's up the volumeClaimTemplates when data is required.
*/}}
{{- define "navidrome.volumeClaims" -}}
  {{- if .Values.dataStorage.enabled }}
volumeClaimTemplates:
  - metadata:
      name: data
    spec:
      accessModes:
        - {{ .Values.dataStorage.accessMode | default "ReadWriteOnce" }}
      resources:
        requests:
          storage: {{ .Values.dataStorage.size }}
        {{- if .Values.dataStorage.storageClass }}
      storageClassName: {{ .Values.dataStorage.storageClass }}
          {{- end }}
    {{- end }}
{{- end -}}

{{/*
Inject extra environment vars in the format key:value, if populated
*/}}
{{- define "navidrome.extraEnvironmentVars" -}}
{{- if .extraEnvironmentVars -}}
{{- range $key, $value := .extraEnvironmentVars }}
- name: {{ printf "%s" $key | replace "." "_" | upper | quote }}
  value: {{ $value | quote }}
{{- end }}
{{- end -}}
{{- end -}}

{{/*
Inject extra environment vars in the format key:value
*/}}
{{- define "navidrome.extraSecretEnvironmentVars" -}}
{{- if .extraSecretEnvironmentVars -}}
{{- range $key, $value := .extraSecretEnvironmentVars }}
- name: {{ .envName }}
  valueFrom:
    name: {{ .secretName }}
    key: {{ .secretKey }}
{{- end -}}
{{- end -}}
{{- end -}}

