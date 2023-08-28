variable "location" {
  type = string
  default = "eastus"
}

resource "azurerm_resource_group" "ksm_resource_group" {
  name     = "ksm-resource-group"
  location = var.location
}