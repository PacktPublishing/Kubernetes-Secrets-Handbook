#!/bin/bash

kubectl apply -f plain-text.yaml
kubectl edit secret plain-text 
kubectl get secret plain-text -o yaml
kubectl edit secret plain-text --record=true
kubectl get secret plain-text -o yaml
kubectl edit secret plain-text --save-config=true 
kubectl get secret plain-text -o yaml
kubectl delete secret plain-text