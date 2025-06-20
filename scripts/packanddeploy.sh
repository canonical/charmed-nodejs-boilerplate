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
charmcraft pack
cd ..

echo
echo
echo "============================================================"
echo "== Refreshing Application =================================="
echo "============================================================"
juju refresh exapp --path ./charm/${charmname}_amd64.charm --resource app-image=localhost:32000/${rockname}:${version}