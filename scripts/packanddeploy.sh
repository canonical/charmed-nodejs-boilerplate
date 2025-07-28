#!/bin/bash

# version=$(grep '^version:' "rockcraft.yaml" | cut -d'"' -f2)
version=$(cat version)

sed -i "s/^version: \".*\"/version: \"$version\"/" rockcraft.yaml
sed -i "s/self.unit.set_workload_version(\".*\")/self.unit.set_workload_version(\"$version\")/" charm/src/charm.py

modelname=baremodel
appname=bareapp
rockname=$(grep '^name:' "rockcraft.yaml" | cut -d':' -f2 | xargs)
charmname=$(grep '^name:' "charm/charmcraft.yaml" | cut -d':' -f2 | xargs)
archname=$(dpkg --print-architecture)

clear
echo "============================================================"
echo "== Packing Rock ============================================"
echo "============================================================"
echo "Model Name:   ### $modelname ###"
echo "App Name:     ### $appname ###"
echo "App Version:  ### $version ###"
echo "Charm Name:   ### $charmname ###"
echo "Rock Name:    ### $rockname ###"

export ROCKCRAFT_ENABLE_EXPERIMENTAL_EXTENSIONS=True

rockcraft clean
rockcraft pack


echo
echo
echo "============================================================"
echo "== Uploading Rock to Registry =============================="
echo "============================================================"
rockcraft.skopeo copy --insecure-policy --dest-tls-verify=false oci-archive:${rockname}_${version}_${archname}.rock docker://localhost:32000/${rockname}:${version}


echo
echo
echo "============================================================"
echo "== Packing Charm ==========================================="
echo "============================================================"

export CHARMCRAFT_ENABLE_EXPERIMENTAL_EXTENSIONS=true

cd charm
charmcraft clean
charmcraft fetch-lib
charmcraft fetch-lib charms.tempo_coordinator_k8s.v0.tracing
charmcraft fetch-lib charms.smtp_integrator.v0.smtp
charmcraft fetch-lib charms.openfga_k8s.v1.openfga
charmcraft pack
cd ..

echo
echo
echo "============================================================"
echo "== Deploying / Refreshing Application ======================"
echo "============================================================"

if ! juju models | grep -q "${modelname}"; then
    echo "Model '${modelname}' does not exist. Creating..."
    juju add-model "${modelname}"
    echo "Model '${modelname}' created."
else
    echo "Model '${modelname}' already exists."
fi

juju switch $modelname

echo "Setting model constraint arch=$archname"
juju set-model-constraints -m "$modelname" arch="$archname"

if juju status --color --relations | grep -q "^$appname\\s"; then
  echo "Application '$appname' exists. Running juju refresh..."
  juju refresh ${appname} --path ./charm/${charmname}_${archname}.charm --resource app-image=localhost:32000/${rockname}:${version}
else
  echo "Application '$appname' does not exist. Running juju deploy..."
  juju deploy ./charm/${charmname}_${archname}.charm ${appname} --resource app-image=localhost:32000/${rockname}:${version}
fi