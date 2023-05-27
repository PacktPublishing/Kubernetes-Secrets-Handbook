#!/bin/bash

minikube stop

mkdir -p ~/.minikube/files/etc/ssl/certs

cp secrets-audit-policy.yaml ~/.minikube/files/etc/ssl/certs/audit-policy.yaml

minikube start \
  --extra-config=apiserver.audit-policy-file=/etc/ssl/certs/audit-policy.yaml \
  --extra-config=apiserver.audit-log-path=-

kubectl logs -f kube-apiserver-minikube -n kube-system | grep audit.k8s.io/v1