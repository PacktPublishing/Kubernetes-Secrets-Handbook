RESOURCE_GROUP=ksm-resource-group
CLUSTER_NAME=ksm-aks

az aks create -n ksm-aks -g ksm-resource-group --enable-addons azure-keyvault-secrets-provider --enable-oidc-issuer --enable-workload-identity

az keyvault create -n ksm-key-vault -g ksm-resource-group  -l eastus --enable-rbac-authorization

KEYVAULT_RESOURCE_ID=$(az keyvault list -g ksm-resource-group -o tsv --query '[0].id')

az role assignment create --role "Key Vault Crypto Officer" --assignee-object-id $(az ad signed-in-user show --query id --out tsv) --assignee-principal-type "User" --scope $KEYVAULT_RESOURCE_ID

az role assignment create --role "Key Vault Secrets Officer" --assignee-object-id $(az ad signed-in-user show --query id --out tsv) --assignee-principal-type "User" --scope $KEYVAULT_RESOURCE_ID

az keyvault key create --name key1 --vault-name ksm-key-vault

az keyvault secret set --name secret1 --value=test --vault-name ksm-key-vault

az identity create --name keyvault-reader --resource-group ksm-resource-group

IDENTITY=$(az identity list --resource-group ksm-resource-group -o tsv --query '[0].id')

az role assignment create --role "Key Vault Reader" --assignee-object-id $(az ad signed-in-user show --query id --out tsv) --assignee-principal-type "User" --scope $IDENTITY

az role assignment create --role "Key Vault Secrets User" --assignee-object-id $(az ad signed-in-user show --query id --out tsv) --assignee-principal-type "User" --scope $IDENTITY

SERVICE_ACCOUNT_ISSUER=$(az aks show -n $CLUSTER_NAME -g $RESOURCE_GROUP --query "oidcIssuerProfile.issuerUrl" -otsv)

IDENTITY_NAME=keyvault-reader

az identity federated-credential create \
  --name "ksm-reader-identity" \
  --identity-name "${IDENTITY_NAME}" \
  --resource-group "${RESOURCE_GROUP}" \
  --issuer "${SERVICE_ACCOUNT_ISSUER}" \
  --subject "system:serviceaccount:default:service-token-reader"

SUBSCRIPTION=$(az account subscription list --query='[0].subscriptionId' -o tsv)

az aks get-credentials --name ksm-aks --resource-group ksm-resource-group --subscription $SUBSCRIPTION --admin 