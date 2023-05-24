#!/bin/bash

kubectl apply -f plain-text.yaml
kubectl get secret plain-text -o yaml|grep value
kubectl delete secret plain-text