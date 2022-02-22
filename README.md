# helm-charts
helm-charts

## helm version
( "v3.6.1" at the time of writing )

## Chart notes


## create chart
$ helm create mychart

## chart dir/file info:

This creates most of the helm specific files for the chart

- Chart.yaml:
	metadata regarding the chart.
- Values.yaml:
	Contains the default values for the chart.
        Information regarding the kubernetes resources / deployments / allocation etc.
	These values may be overridden by users during helm install or helm upgrade.
.helmignore
- charts/:
	contains sub-charts
- templates/:
	kubernetes resource definitions with golang template code in them, that gets run through the golang templating render engine to generated k8s resource files.
    Can also include raw/bare k8s resources that also gets uploaded to k8s.

some template examples:
- templates/_helpers.tpl:
    the template helper. maybe some logic when checking Chart.yaml+values.yaml and setting variables.
- templates/deployment.yaml:
    k8s deployment resource.
- templates/hpa.yaml:
	k8s horisontal pod autoscaler.
- templates/ingress.yaml:
	k8s network ingress resource.
- templates/servicemonitor.yaml:
    k8s ServiceMonitor resource
- templates/serviceaccount.yaml:
    k8s ServiceAccount resource
- templates/service.yaml:
    k8s Service resource

Some notes after user successfully installed helm chart

- templates/NOTES.txt:
	This is a templated, plaintext file that gets printed out after the chart is successfully deployed.
        As we'll see when we deploy our first chart, this is a useful place to briefly describe the next steps for using a chart.
        Since NOTES.txt is run through the template engine,
        you can use templating to print out working commands for obtaining an IP address, or getting a password from a Secret object.

## inspecting the generated k8s resources

Usage:  helm install [NAME] [CHART] [flags]

### Check contents by doing a dry run

helm install <RELEASE_NAME> --dry-run --debug ./mychart

### Installing chart into k8s

helm install <RELEASE_NAME> ./mychart

### checking the generated k8s files ( manifests )

helm get manifest <RELEASE_NAME>

### removing k8s resources / Uninstalling a helm chart

helm uninstall <RELEASE_NAME>
