#!/bin/bash

kubectl apply -f ./basic-auth-secret.yaml

kubectl get secret basic-auth-secret  -o yaml

kubectl delete -f ./basic-auth-secret.yaml