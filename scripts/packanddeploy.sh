#!/bin/bash

version=$(grep '^version:' "rockcraft.yaml" | cut -d'"' -f2)


rockname=$(grep '^name:' "rockcraft.yaml" | cut -d':' -f2 | xargs)
charmname=$(grep '^name:' "charm/charmcraft.yaml" | cut -d':' -f2 | xargs)


clear
echo "============================================================"
echo "== Packing Rock ============================================"
echo "============================================================"
echo "Charm Name: ### $charmname ###"
echo "Rock Name: ### $rockname ###"
echo "Rock Version: ### $version ###"

rockcraft clean
rockcraft pack


echo
echo
echo "============================================================"
echo "== Uploading Rock to Registry =============================="
echo "============================================================"
rockcraft.skopeo copy --insecure-policy --dest-tls-verify=false oci-archive:${rockname}_${version}_amd64.rock docker://localhost:32000/${rockname}:${version}


echo
echo
echo "============================================================"
echo "== Packing Charm ==========================================="
echo "============================================================"
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
echo "== Refreshing Application =================================="
echo "============================================================"
# juju deploy ./charm/${charmname}_amd64.charm exapp --resource app-image=localhost:32000/${rockname}:${version}
juju refresh exapp --path ./charm/${charmname}_amd64.charm --resource app-image=localhost:32000/${rockname}:${version}