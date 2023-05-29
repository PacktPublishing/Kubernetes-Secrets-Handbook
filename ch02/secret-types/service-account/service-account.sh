#!/bin/bash

kubectl create sa example-service-account

kubectl apply -f ./service-account-secret.yaml

kubectl get secret service-account-secret -o yaml

kubectl delete -f ./service-account-secret.yaml

kubectl delete sa example-service-account