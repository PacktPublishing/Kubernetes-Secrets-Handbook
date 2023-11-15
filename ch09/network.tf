resource "azurerm_virtual_network" "ksm_virtual_network" {
  name                = "ksm-virtual-network"
  location            = var.location
  resource_group_name = azurerm_resource_group.ksm_resource_group.name
  address_space       = ["10.1.0.0/16"]
}

resource "azurerm_subnet" "ksm_subnet" {
  name                 = "ksm-private-subnt"
  resource_group_name  = azurerm_resource_group.ksm_resource_group.name 
  virtual_network_name = azurerm_virtual_network.ksm_virtual_network.name
  address_prefixes     = ["10.1.0.0/24"]
  enforce_private_link_endpoint_network_policies = true
}