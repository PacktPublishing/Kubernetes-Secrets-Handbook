#!/bin/bash

docker --config ./ login --username=$1 --password=$2

DOCKER_CONFIG=$(cat ./config.json|base64) 

cat docker-credentials-template.yaml|sed "s/REPLACE_WITH_BASE64/$DOCKER_CONFIG/" > docker-credentials.yaml 

kubectl apply -f ./docker-credentials.yaml

kubectl apply -f ./nginx.yaml

kubectl wait --for=condition=ready pod/nginx

kubectl delete -f ./nginx.yaml

kubectl delete -f ./docker-credentials.yaml

rm docker-credentials.yaml