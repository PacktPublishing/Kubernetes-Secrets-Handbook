data "azurerm_client_config" "current" {
}

resource "azurerm_key_vault" "ksm_key_vault" {
  name                       = "ksm-key-vault"
  location                   = azurerm_resource_group.ksm_resource_group.location
  resource_group_name        = azurerm_resource_group.ksm_resource_group.name
  tenant_id                  = data.azurerm_client_config.current.tenant_id
  sku_name                   = "standard"
  enable_rbac_authorization = true
  soft_delete_retention_days = 7
}

resource "azurerm_user_assigned_identity" "keyvault_reader" {
  name                = "keyvault-reader"
  location            = azurerm_resource_group.ksm_resource_group.location
  resource_group_name = azurerm_resource_group.ksm_resource_group.name
}

resource "azurerm_role_assignment" "ksm_key_vault_reader" {
  scope = azurerm_key_vault.ksm_key_vault.id
  role_definition_name = "Key Vault Reader"
  principal_id         = azurerm_user_assigned_identity.keyvault_reader.principal_id
}

resource "azurerm_role_assignment" "ksm_key_vault_user" {
  scope = azurerm_key_vault.ksm_key_vault.id
  role_definition_name = "Key Vault Secrets User"
  principal_id         = azurerm_user_assigned_identity.keyvault_reader.principal_id
}

resource "azurerm_federated_identity_credential" "example" {
  name                = "ksm-reader-identity"
  resource_group_name = azurerm_resource_group.ksm_resource_group.name
  issuer              = azurerm_kubernetes_cluster.ksm_aks.oidc_issuer_url
  audience = ["api://AzureADTokenExchange"]
  parent_id           = azurerm_user_assigned_identity.keyvault_reader.id
  subject             = "system:serviceaccount:default:service-token-reader"
}

resource "azurerm_monitor_diagnostic_setting" "ksm_key_vault_logs" {
  name               = "ksm-key-vault-logs"
  target_resource_id = azurerm_key_vault.ksm_key_vault.id
  storage_account_id = azurerm_storage_account.ksm_storage_account.id
  

  log {
    category = "AuditEvent"
    enabled  = true

    retention_policy {
      enabled = false
    }
  }

  metric {
    category = "AllMetrics"

    retention_policy {
      enabled = false
    }
  }
}

