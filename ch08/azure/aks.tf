resource "azurerm_kubernetes_cluster" "ksm_aks" {
  name = "ksm-aks"
  location = azurerm_resource_group.ksm_resource_group.location
  resource_group_name = azurerm_resource_group.ksm_resource_group.name
  dns_prefix = "private-aks-cluster"
  private_cluster_enabled = false

  oidc_issuer_enabled = true
  workload_identity_enabled = true

  role_based_access_control_enabled = true
  
  network_profile {
    network_plugin     = "kubenet"
    dns_service_ip     = "192.168.1.1"
    service_cidr       = "192.168.0.0/16"
    pod_cidr           = "172.16.0.0/22"
  }

  key_vault_secrets_provider {
    secret_rotation_enabled = true
  }


  identity {
    type = "SystemAssigned"
  }


  default_node_pool {
    name           = "default"
    node_count     = 1
    vm_size        = "Standard_A2_v2"
    vnet_subnet_id = azurerm_subnet.ksm_subnet.id
  }

}