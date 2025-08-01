#!/bin/bash

modelname=nodejs
appname=nodejs-app

juju deploy nginx-ingress-integrator --channel=latest/stable --trust
juju integrate nginx-ingress-integrator $appname
juju config nginx-ingress-integrator service-hostname=$appname path-routes=/
curl http://$appname --resolve $appname:80:127.0.0.1