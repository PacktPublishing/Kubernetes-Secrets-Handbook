#!/bin/bash

KUBE_HOST=$(kubectl config view --raw --minify --flatten --output='jsonpath={.clusters[].cluster.server}')

port=$(echo $KUBE_HOST | awk -F/ '{print $3}' | cut -d: -f2)

docker exec -it -e port=$port vault_node_1 /port-forward.sh