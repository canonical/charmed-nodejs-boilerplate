# Host Setup
Step by step instructions and descriptions to prepare a host to run this charm locally

## LXD Installation
LXD is required for building a rock. Below are the steps to get it running:
```
sudo snap install lxd
sudo lxd init --auto
```

## Docker Installation (try to avoid)
If possible avoid installing docker on the same host, but for testing you might need.  
Information about why: [here](https://documentation.ubuntu.com/lxd/latest/howto/network_bridge_firewalld/#prevent-connectivity-issues-with-lxd-and-docker)
```
sudo snap install docker
sudo addgroup --system docker
sudo adduser $USER docker
newgrp docker

sudo snap disable docker
sudo snap enable docker
```

## Rockcraft Install
In order to create a rock, we'll need to install Rockcraft
```
sudo snap install rockcraft --classic --channel latest/edge
```

## Charmcraft Install
In order to create a charm, we'll need to install Charmcraft
```
sudo snap install charmcraft --channel latest/edge --classic
```

## MicroK8s Install
In order to deploy locally, MicroK8s is required
```
sudo snap install microk8s --channel 1.31-strict/stable
sudo adduser $USER snap_microk8s
newgrp snap_microk8s
```
Several MicroK8s add-ons are required or deployment:
```
# Required for Juju to provide storage volumes
sudo microk8s enable hostpath-storage
# Required to host the OCI image of the application
sudo microk8s enable registry
# Required to expose the application
sudo microk8s enable ingress
```

## Juju Install
Juju is required to deploy the application
```
sudo snap install juju --channel 3.6/stable
mkdir -p ~/.local/share
juju bootstrap microk8s dev-controller
```

## Check Installations
```
lxd --version
rockcraft --version
charmcraft --version
sudo microk8s status --wait-ready
# if you followed step by step until here, controller is the only juju model and we are switching to that. 
# Don't use this model for anything if you don't know what you are doing
juju switch controller 
juju status --color --relations
```