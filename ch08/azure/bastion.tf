resource "azurerm_virtual_network" "ksm_bastion_network" {
  name                = "ksm-bastion-network"
  location            = var.location
  resource_group_name = azurerm_resource_group.ksm_resource_group.name
  address_space       = ["10.0.0.0/16"]
}

resource "azurerm_subnet" "bastion_subnet" {
  name                 = "ksm-bastion-subnet"
  resource_group_name  = azurerm_resource_group.ksm_resource_group.name
  virtual_network_name = azurerm_virtual_network.ksm_bastion_network.name
  address_prefixes     = ["10.0.0.0/24"]
}

resource "azurerm_subnet" "public_bastion_subnet_2" {
  name                 = "AzureBastionSubnet"
  resource_group_name  = azurerm_resource_group.ksm_resource_group.name
  virtual_network_name = azurerm_virtual_network.ksm_bastion_network.name
  address_prefixes     = ["10.0.1.0/24"]
}

resource "azurerm_virtual_network_peering" "bastion_cluster_peering" {
  name                      = "bastion_cluster_peering"
  resource_group_name       = azurerm_resource_group.ksm_resource_group.name
  virtual_network_name      = azurerm_virtual_network.ksm_bastion_network.name
  remote_virtual_network_id = azurerm_virtual_network.ksm_virtual_network.id
}


resource "azurerm_virtual_network_peering" "cluster_bastion_peering" {
  name                      = "cluster_bastion_peeering"
  resource_group_name       = azurerm_resource_group.ksm_resource_group.name
  virtual_network_name      = azurerm_virtual_network.ksm_virtual_network.name
  remote_virtual_network_id = azurerm_virtual_network.ksm_bastion_network.id
}

resource "azurerm_private_dns_zone_virtual_network_link" "dnsnclink_bastion_cluster" {
  name = "dnsnclink-bastion-cluster"
  private_dns_zone_name = join(".", slice(split(".", azurerm_kubernetes_cluster.ksm_aks.private_fqdn), 1, length(split(".", azurerm_kubernetes_cluster.ksm_aks.portal_fqdn))))
  resource_group_name   = "MC_${azurerm_resource_group.ksm_resource_group.name}_${azurerm_kubernetes_cluster.ksm_aks.name}_${var.location}"
  virtual_network_id    = azurerm_virtual_network.ksm_bastion_network.id
}

resource "azurerm_network_interface" "bastion_network_interface" {
  name                = "bastion_network_interface"
  location            = var.location
  resource_group_name = azurerm_resource_group.ksm_resource_group.name
  ip_configuration {
    name                          = "bastion_network_interface"
    subnet_id                     = azurerm_subnet.bastion_subnet.id
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_linux_virtual_machine" "bastion_vm" {
  name                            = "vm-bastion"
  location                        = var.location
  resource_group_name             = azurerm_resource_group.ksm_resource_group.name
  size                            = "Standard_A1_v2"
  admin_username                  = "test-username"
  admin_password                  = "add-strong-password"
  disable_password_authentication = false
  network_interface_ids = [
    azurerm_network_interface.bastion_network_interface.id,
  ]

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "16.04-LTS"
    version   = "latest"
  }
  
}

resource "azurerm_public_ip" "ip_for_bastion_host" {
  name                = "bastion-host-ip"
  location            = var.location
  resource_group_name = azurerm_resource_group.ksm_resource_group.name

  allocation_method = "Static"
  sku               = "Standard"
}

resource "azurerm_bastion_host" "azure-bastion" {
  name                = "azure-bastion"
  location            = var.location
  resource_group_name = azurerm_resource_group.ksm_resource_group.name
  ip_configuration {
    name                 = "configuration"
    subnet_id            = azurerm_subnet.public_bastion_subnet_2.id
    public_ip_address_id = azurerm_public_ip.ip_for_bastion_host.id
  }
}