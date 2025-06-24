# How
juju switch baremodel
juju deploy grafana-agent-k8s --channel stable --trust
juju relate bareapp grafana-agent-k8s:logging-provider