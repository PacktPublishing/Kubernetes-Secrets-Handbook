#!/bin/bash

kubectl create namespace argocd
kubectl config set-context --current --namespace=argocd
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/v2.5.8/manifests/install.yaml

