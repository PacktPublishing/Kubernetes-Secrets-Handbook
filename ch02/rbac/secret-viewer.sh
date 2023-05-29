#!/bin/bash

kubectl create secret generic secret-toview --from-literal=literal1=text-for-literal-1

kubectl create sa secret-viewer

kubectl apply -f ./secret-viewer.yaml

kubectl apply -f ./kubectl-get-secrets.yaml
