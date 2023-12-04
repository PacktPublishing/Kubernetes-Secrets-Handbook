#!/bin/bash

EXTERNAL_VAULT_ADDR=$(minikube ssh "dig +short host.docker.internal" | tr -d '\r')

helm repo add hashicorp https://helm.releases.hashicorp.com 
helm repo update
helm install vault hashicorp/vault --set "global.externalVaultAddr=http://$EXTERNAL_VAULT_ADDR:8200" --set="csi.enabled=true"

kubectl get deployment vault-agent-injector
kubectl get clusterrole vault-agent-injector-clusterrole -o yaml 

kubectl apply -f vault.sa.yaml

# retrieve Kubernetes secret for the service account 

VAULT_HELM_SECRET_NAME=$(kubectl get secrets --output=json | jq -r '.items[].metadata | select(.name|startswith("vault")).name') 

# retrieve service account token 

TOKEN_REVIEW_JWT=$(kubectl get secret $VAULT_HELM_SECRET_NAME --output='go-template={{ .data.token }}' | base64 --decode) 

# retrieve Kubernetes certificate 

KUBE_CA_CERT=$(kubectl config view --raw --minify --flatten --output='jsonpath={.clusters[].cluster.certificate-authority-data}' | base64 --decode) 

# retrieve the Kubernetes host 

KUBE_HOST=$(kubectl config view --raw --minify --flatten --output='jsonpath={.clusters[].cluster.server}') 

# point to local vault address 

export VAULT_ADDR=http://0.0.0.0:8200 

# login to vault using the root token 

vault login mytoken 

# enabled kubernetes authentication on vault 
vault auth enable kubernetes 

# write Kubernetes authentication configuration 

vault write auth/kubernetes/config \
token_reviewer_jwt="$TOKEN_REVIEW_JWT" \
kubernetes_host="$KUBE_HOST" \
kubernetes_ca_cert="$KUBE_CA_CERT" \
issuer="https://kubernetes.default.svc.cluster.local"