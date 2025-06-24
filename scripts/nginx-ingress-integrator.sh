#!/bin/bash

version=$(grep '^version:' "rockcraft.yaml" | cut -d'"' -f2)

modelname=baremodel
appname=bareapp
rockname=$(grep '^name:' "rockcraft.yaml" | cut -d':' -f2 | xargs)
charmname=$(grep '^name:' "charm/charmcraft.yaml" | cut -d':' -f2 | xargs)

juju deploy nginx-ingress-integrator --channel=latest/stable --trust
juju integrate nginx-ingress-integrator $appname
juju config nginx-ingress-integrator service-hostname=$appname path-routes=/
curl http://$appname --resolve $appname:80:127.0.0.1