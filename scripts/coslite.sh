#!/bin/bash

version=$(grep '^version:' "rockcraft.yaml" | cut -d'"' -f2)

modelname=cos
appname=nodejs-app
rockname=$(grep '^name:' "rockcraft.yaml" | cut -d':' -f2 | xargs)
charmname=$(grep '^name:' "charm/charmcraft.yaml" | cut -d':' -f2 | xargs)
IPADDR=$(ip -4 -j route get 2.2.2.2 | jq -r '.[] | .prefsrc')

clear
echo "Model Name: ### $modelname ###"
echo "App Name: ### $appname ###"
echo "Charm Name: ### $charmname ###"
echo "Rock Name: ### $rockname ###"
echo "Rock Version: ### $version ###"
echo "IP Address: ### $IPADDR ###"

sudo microk8s enable dns
sudo microk8s enable hostpath-storage
sudo microk8s enable metallb:$IPADDR-$IPADDR

microk8s kubectl rollout status deployments/hostpath-provisioner -n kube-system -w
microk8s kubectl rollout status deployments/coredns -n kube-system -w
microk8s kubectl rollout status daemonset.apps/speaker -n metallb-system -w

if ! juju models | grep -q "${modelname}"; then
    echo "Model '${modelname}' does not exist. Creating..."
    juju add-model "${modelname}"
    echo "Model '${modelname}' created."
else
    echo "Model '${modelname}' already exists."
fi

juju switch $modelname

curl -L https://raw.githubusercontent.com/canonical/cos-lite-bundle/main/overlays/offers-overlay.yaml -O
curl -L https://raw.githubusercontent.com/canonical/cos-lite-bundle/main/overlays/storage-small-overlay.yaml -O
ls -lh
juju deploy cos-lite \
        --trust \
        --overlay ./offers-overlay.yaml \
        --overlay ./storage-small-overlay.yaml