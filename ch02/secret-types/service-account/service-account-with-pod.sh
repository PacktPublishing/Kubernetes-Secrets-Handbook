#!/bin/bash

kubectl create sa example-service-account

kubectl apply -f ./pod-with-service-account.yaml

kubectl wait --for=condition=ready pod/busybox

kubectl exec -it busybox -- cat /var/run/secrets/kubernetes.io/serviceaccount/token

kubectl delete -f ./pod-with-service-account.yaml

kubectl delete sa example-service-account