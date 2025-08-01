# Pack and Deploy the Charm

This guide details the steps to package your Node.js application into a Rock, build its Charm, and then deploy or refresh it in a local Juju environment. These steps are encapsulated in [scripts/packanddeploy.sh](../../scripts/packanddeploy.sh).

## Overview

The process involves:
1.  Reading the application version.
2.  Updating configuration files with the current version.
3.  Packing the application into an OCI image (Rock).
4.  Uploading the Rock to a local Docker registry (MicroK8s registry).
5.  Packing the Charm itself.
6.  Deploying or refreshing the Charm on a Juju model.

## Prerequisites
* Ensure your development environment is set up, including LXD, MicroK8s, and Juju, as described in [Host Setup](./host-setup.md).
* Your application should be built and ready to be packaged.

## Steps

### 1. Prepare and Pack the Rock

First, we read the version from the [version](../../version) file and update [rockcraft.yaml](../../rockcraft.yaml) and [charm/src/charm.py](../../charm/src/charm.py) with this version. Then, we pack the Rock.

```bash
# Ensure you are in the root of your project directory
version=$(cat version)

# Update version in rockcraft.yaml and charm.py
sed -i "s/^version: \".*\"/version: \"$version\"/" rockcraft.yaml
sed -i "s/self.unit.set_workload_version(\".*\")/self.unit.set_workload_version(\"$version\")/" charm/src/charm.py

# Enable experimental addon for expressjs
export ROCKCRAFT_ENABLE_EXPERIMENTAL_EXTENSIONS=True 
# Clean any previous Rock builds and pack the new Rock
rockcraft clean
rockcraft pack
```

### 2. Upload Rock to Local Registry

The packed Rock (OCI image) needs to be available to your Kubernetes environment. This step uploads it to the local MicroK8s registry.

```bash
# Extract rock name and architecture
rockname=$(grep '^name:' "rockcraft.yaml" | cut -d':' -f2 | xargs)
version=$(cat version)
archname=$(dpkg --print-architecture)

# Copy the Rock to the local MicroK8s registry
rockcraft.skopeo copy --insecure-policy --dest-tls-verify=false oci-archive:${rockname}_${version}_${archname}.rock docker://localhost:32000/${rockname}:${version}
```

### 3. Pack the Charm

Next, the Charm itself is packaged. This includes fetching any necessary charm libraries.

```bash
# Enable experimental addon for expressjs
export CHARMCRAFT_ENABLE_EXPERIMENTAL_EXTENSIONS=True 

# Navigate into the charm directory
cd charm

# Clean any previous Charm builds, fetch libraries, and pack the Charm
charmcraft clean
charmcraft fetch-lib
charmcraft fetch-lib charms.tempo_coordinator_k8s.v0.tracing
charmcraft fetch-lib charms.smtp_integrator.v0.smtp
charmcraft fetch-lib charms.openfga_k8s.v1.openfga
charmcraft pack

# Navigate back to the project root
cd ..
```

### 4. Deploy or Refresh the Application

Finally, the packed Charm is deployed to your chosen Juju model. If the application already exists in the model, it will be refreshed to the new version; otherwise, it will be deployed.

```bash
modelname=baremodel # The target Juju model name
appname=bareapp # The name of your application within Juju
charmname=$(grep '^name:' "charm/charmcraft.yaml" | cut -d':' -f2 | xargs)
rockname=$(grep '^name:' "rockcraft.yaml" | cut -d':' -f2 | xargs)
version=$(cat version)
archname=$(dpkg --print-architecture)

# Create the Juju model if it doesn't exist, then switch to it
if ! juju models | grep -q "${modelname}"; then
    juju add-model "${modelname}"
    echo "Model '${modelname}' created."
else
    echo "Model '${modelname}' already exists."
fi
juju switch $modelname

# Set model constraints based on architecture
juju set-model-constraints -m "$modelname" arch="$archname"

# Deploy or refresh the application
if juju status --color --relations | grep -q "^$appname\s"; then
  echo "Application '$appname' exists. Running juju refresh..."
  juju refresh ${appname} --path ./charm/${charmname}_${archname}.charm --resource app-image=localhost:32000/${rockname}:${version}
else
  echo "Application '$appname' does not exist. Running juju deploy..."
  juju deploy ./charm/${charmname}_${archname}.charm ${appname} --resource app-image=localhost:32000/${rockname}:${version}
fi
```
By following these steps, your Node.js application will be packaged into a Rock, transformed into a Charm, and deployed or updated within your Juju environment.