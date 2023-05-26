#!/bin/bash

kubectl create sa secret-admin

kubectl apply -f ./secret-admin-cluster.yaml

kubectl apply -f ./kubectl-create-secrets.yaml

kubectl delete secret test

kubectl delete -f ./secret-admin-cluster.yaml

kubectl delete sa secret-admin