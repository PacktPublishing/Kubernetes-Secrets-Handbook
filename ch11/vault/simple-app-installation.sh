#!/bin/bash

export VAULT_ADDR='http://0.0.0.0:8200'
export VAULT_TOKEN="mytoken"

vault audit enable file file_path=/tmp/vault_audit.log

vault kv put secret/webapp/admin username='john.doe' password='strong-password'

vault policy write webapp_admin_r  ./webapp_admin_r.hcl

vault write auth/kubernetes/role/webapp_admin_r bound_service_account_names=simple-app bound_service_account_namespaces=default policies=webapp_admin_r ttl=24h

kubectl create sa simple-app 

kubectl apply -f ./role-tokenreview-binding.yaml

kubectl apply -f webapp.yaml