#!/bin/bash

RESOURCE_GROUP=ksm-resource-group
UAMI=keyvault-reader

CLUSTER_NAME=ksm-aks

IDENTITY_TENANT=$(az aks show --name $CLUSTER_NAME --resource-group $RESOURCE_GROUP --query identity.tenantId -o tsv)


USER_ASSIGNED_CLIENT_ID="$(az identity show -g $RESOURCE_GROUP --name $UAMI --query 'clientId' -o tsv)"

cat <<EOF > service-account.yaml
apiVersion: v1
kind: ServiceAccount
metadata:
  annotations:
    azure.workload.identity/client-id: ${USER_ASSIGNED_CLIENT_ID}
  labels:
    azure.workload.identity/use: "true"
  name: service-token-reader
  namespace: default
EOF

kubectl apply -f service-account.yaml

rm service-account.yaml