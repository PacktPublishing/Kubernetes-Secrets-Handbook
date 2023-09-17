variable "location" {
  type = string
  default = "eastus"
}

resource "azurerm_resource_group" "ksm_resource_group" {
  name     = "ksm-resource-group"
  location = var.location
}

resource "azurerm_storage_account" "ksm_storage_account" {
  name = "ksmlogs"
  resource_group_name = azurerm_resource_group.ksm_resource_group.name
  location = var.location
  account_tier = "Standard"
  account_replication_type = "LRS"
}