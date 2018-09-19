#!/usr/bin/env bash

if [[ $# -eq 0 ]] ; then
    echo 'Please provide release name'
    exit 0
else
    now="$(date +'%H-%M-%d-%m-%Y')"
    docker build -t zabbix .
    docker tag zabbix levkov/zabbix:$now
    docker push levkov/zabbix:$now

    sleep 10
    helm upgrade --install  $1 .chart --debug --set image.tag=$now
fi