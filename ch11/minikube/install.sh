#!/bin/bash

EXTERNAL_VAULT_ADDR=$(minikube ssh "dig +short host.docker.internal" | tr -d '\r')

echo $EXTERNAL_VAULT_ADDR

helm repo update
helm repo add hashicorp https://helm.releases.hashicorp.com
helm install vault hashicorp/vault --set "global.externalVaultAddr=http://$EXTERNAL_VAULT_ADDR:8200" --set="csi.enabled=true"

kubectl apply -f ./vault-sa-token.yaml

#wait for token to be generated
sleep 2

VAULT_HELM_SECRET_NAME=$(kubectl get secrets --output=json | jq -r '.items[].metadata | select(.name|startswith("vault")).name')
echo $VAULT_HELM_SECRET_NAME
TOKEN_REVIEW_JWT=$(kubectl get secret $VAULT_HELM_SECRET_NAME --output='go-template={{ .data.token }}' | base64 --decode)
echo $TOKEN_REVIEW_JWT
KUBE_CA_CERT=$(kubectl config view --raw --minify --flatten --output='jsonpath={.clusters[].cluster.certificate-authority-data}' | base64 --decode)
echo $KUBE_CA_CERT
KUBE_HOST=$(kubectl config view --raw --minify --flatten --output='jsonpath={.clusters[].cluster.server}') 
echo $KUBE_HOST

export VAULT_ADDR=http://0.0.0.0:8200 
vault login mytoken
vault auth enable kubernetes
vault write auth/kubernetes/config \
     token_reviewer_jwt="$TOKEN_REVIEW_JWT" \
     kubernetes_host="$KUBE_HOST" \
     kubernetes_ca_cert="$KUBE_CA_CERT" \
     issuer="https://kubernetes.default.svc.cluster.local" 

vault kv put secret/webapp/admin username='john.doe' password='strong-password'

vault policy write webapp_admin_r ./vault-policy.hcl

vault write auth/kubernetes/role/webapp_admin_r \
    bound_service_account_names=simple-app \
    bound_service_account_namespaces=default \
    policies=webapp_admin_r \
    ttl=24h 

kubectl create sa simple-app

kubectl apply -f ./simple-app-auth-delegator.yaml