# helm-charts
a collection of notes on getting started with Helm.

## helm version
( "v3.6.1" at the time of writing )

## Chart notes

### chart dir/file info:

This creates most of the helm specific files for the chart

- Chart.yaml:
	metadata regarding the chart.
- Values.yaml:
	Contains the default values for the chart.
        Information regarding the kubernetes manifests / deployments / allocation etc.
	These values may be overridden by users during helm install or helm upgrade.
- .helmignore
    files to ignore for creating k8s manifest. (Excludes k8s generated content)
- charts/:
	contains sub-charts
- templates/:
	kubernetes manifest definitions with golang template code in them, that gets run through the golang templating render engine to generated k8s manifest files.
    Can also include raw/bare k8s manifest that also gets uploaded to k8s.
    all _ files are treated as non-k8s manifests ( Used for helm templates ).
    These _ files are used to store partials and helpers.

some template examples:
- templates/_helpers.tpl:
    This file is the default location for template partials.
    maybe some logic when checking Chart.yaml+values.yaml and setting variables.
- templates/deployment.yaml:
    k8s deployment manifest.
- templates/hpa.yaml:
	k8s horisontal pod autoscaler.
- templates/ingress.yaml:
	k8s network ingress manifest.
- templates/servicemonitor.yaml:
    k8s ServiceMonitor manifest
- templates/serviceaccount.yaml:
    k8s ServiceAccount manifest
- templates/service.yaml:
    k8s Service manifest

Some notes after user successfully installed helm chart

- templates/NOTES.txt:
	This is a templated, plaintext file that gets printed out after the chart is successfully deployed.
        As we'll see when we deploy our first chart, this is a useful place to briefly describe the next steps for using a chart.
        Since NOTES.txt is run through the template engine,
        you can use templating to print out working commands for obtaining an IP address, or getting a password from a Secret object.

### go template library
Helm has over 60 available functions. Some of them are defined by the Go template language itself. Most of the others are part of the Sprig template library.
https://godoc.org/text/template

## Useful built in objects ( used in golang rendering engine )
The built-in values always begin with a capital letter. This is in keeping with Go's naming convention.

#### Release
This object describes the release itself. It has several objects inside of it:

##### Release.Name
at the time of installing the helm chart
Ex: helm install <RELEASE_NAME> ./mychart
usage: `{{ .Release.Name }}`

##### Release.Namespace
The namespace to be released into, (If the manifest doesn't override it)
Ex: helm install --namespace abc <RELEASE_NAME> ./mychart
usage: `{{ .Release.Namespace }}`

##### Release.IsUpgrade
This is set to true if the current operation is an upgrade or rollback.
usage: `{{ .Release.IsUpgrade }}`

##### Release.IsInstall
This is set to true if the current operation is an install.
usage: `{{ .Release.IsInstall }}`

##### Release.Revision
The revision number for this release. On install, this is 1, and it is incremented with each upgrade and rollback.
usage: `{{ .Release.Revision }}`

##### Release.Service
The service that is rendering the present template. On Helm, this is always Helm.
usage: `{{ .Release.Service }}`

#### Values
Values files are plain YAML files.
Values passed into the template from the `values.yaml` file and from user-supplied files. By default, Values is empty.
`Values` come from multiple sources: (The list below is in order of specificity)
- The values.yaml file in the chart
- If this is a subchart, the values.yaml file of a parent chart
- A values file if passed into helm install or helm upgrade with the -f flag (helm install -f myvals.yaml ./mychart)
- Individual parameters passed with --set (such as helm install --set foo=bar ./mychart)

Tip:
`helm install --set foo=bar` trumps `-f xxx.yaml` trumps `parent values` trumps `values.yaml`.

Ex: `helm install -f myvalues.yaml myredis ./redis`
usage: `{{ .Values.abc }}`

#### Chart
The contents of the Chart.yaml file. Any data in Chart.yaml will be accessible here. For example {{ .Chart.Name }}-{{ .Chart.Version }} will print out the mychart-0.1.0.
usage: `{{ .Chart.Name }}`

#### Files
This provides access to all non-special files in a chart. While you cannot use it to access templates, you can use it to access other files in the chart.

##### Files.Get
is a function for getting a file by name (.Files.Get config.ini)
usage: `{{ .Files.Get }}`

##### Files.GetBytes
is a function for getting the contents of a file as an array of bytes instead of as a string. This is useful for things like images.
usage: `{{ .Files.GetBytes }}`

##### Files.Glob
is a function that returns a list of files whose names match the given shell glob pattern.
usage: `{{ .Files.Glob }}`

##### Files.Lines
is a function that reads a file line-by-line. This is useful for iterating over each line in a file.
usage: `{{ .Files.Lines }}`

##### Files.AsSecrets
Is a function that returns the file bodies as Base 64 encoded strings.
usage: `{{ .Files.AsSecrets }}`

##### Files.AsConfig
is a function that returns file bodies as a YAML map.
usage: `{{ .Files.AsConfig }}`


#### Capabilities
This provides information about what capabilities the Kubernetes cluster supports.

##### Capabilities.APIVersions
is a set of versions.
usage:

##### Capabilities.APIVersions.Has $version
indicates whether a version (e.g., batch/v1) or resource (e.g., apps/v1/Deployment) is available on the cluster.
usage:

##### Capabilities.KubeVersion / Capabilities.KubeVersion.Version
Capabilities.KubeVersion and Capabilities.KubeVersion.Version is the Kubernetes version.
Ex: 4.7.6 ( 4=mayor, 7=minor, 6=patches)
usage: `{{ .Capabilities.KubeVersion }}`
usage: `{{ .Capabilities.KubeVersion.Version }}`

##### Capabilities.KubeVersion.Major
is the Kubernetes major version.
Ex: 4.7.6 ( 4=mayor, 7=minor, 6=patches)
usage: `{{ .Capabilities.KubeVersion.Major }}`

##### Capabilities.KubeVersion.Minor
is the Kubernetes minor version.
Ex: 4.7.6 ( 4=mayor, 7=minor, 6=patches)
usage: `{{ .Capabilities.KubeVersion.Minor }}`

##### Capabilities.HelmVersion
is the object containing the Helm Version details, it is the same output of helm version
usage: `{{ .Capabilities.HelmVersion }}`

##### Capabilities.HelmVersion.Version
is the current Helm version in semver format.
usage: `{{ .Capabilities.HelmVersion.Version }}`

##### Capabilities.HelmVersion.GitCommit
is the Helm git sha1.
usage: `{{ .Capabilities.HelmVersion.GitCommit }}`

##### Capabilities.HelmVersion.GitTreeState
is the state of the Helm git tree.
usage: `{{ .Capabilities.HelmVersion.GitTreeState }}`

##### Capabilities.HelmVersion.GoVersion
is the version of the Go compiler used.
usage: `{{ .Capabilities.HelmVersion.GoVersion }}`


#### Template
Contains information about the current template that is being executed

##### Template.Name
A namespaced file path to the current template (e.g. mychart/templates/mytemplate.yaml)
usage: `{{ .Template.Name }}`

##### Template.BasePath
The namespaced path to the templates directory of the current chart (e.g. mychart/templates).
usage: `{{ .Template.BasePath }}`


## Flow Control

- `if/else` for creating conditional blocks
- `with` to specify a scope
- `range`, which provides a "for each"-style loop

declaring and using named template segments:

- `define` declares a new named template inside of your template
- `template` imports a named (define) template
- `block` declares a special kind of fillable template area

## Subcharts

a few important details to learn about subcharts

- A subchart is considered "stand-alone", which means a subchart can never explicitly depend on its parent chart.
- For that reason, a subchart cannot access the values of its parent.
- A parent chart can override values for subcharts.
- Helm has a concept of global values that can be accessed by all charts.


## Chart commands

### create chart
$ helm create mychart

### inspecting the generated k8s manifest

Usage:  helm install [NAME] [CHART] [flags]

There are five different ways you can express the chart you want to install:

1. By chart reference: helm install mymaria example/mariadb
2. By path to a packaged chart: helm install mynginx ./nginx-1.2.3.tgz
3. By path to an unpacked chart directory: helm install mynginx ./nginx
4. By absolute URL: helm install mynginx https://example.com/charts/nginx-1.2.3.tgz
5. By chart reference and repo url: helm install --repo https://example.com/charts/ mynginx nginx

### Check contents by doing a dry run

`$ helm install <RELEASE_NAME> --dry-run --debug ./mychart`

### Installing chart into k8s

`$ helm install <RELEASE_NAME> ./mychart`

### checking the generated k8s files ( manifests )

`$ helm get manifest <RELEASE_NAME>`

### removing k8s manifest / Uninstalling a helm chart

`$ helm uninstall <RELEASE_NAME>`

### Linting

`$ cd CHART-DIR`
`$ helm lint`

### k8s manifest
This is a good way to see what templates are installed on the server.

`$ helm get manifest`