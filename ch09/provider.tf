terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "=3.0.1"
    }
  }

    backend "azurerm" {
        resource_group_name  = "kubernetes-secrets-state"
        storage_account_name = "tf-storage-account"
        container_name       = "tfstate"
        key                  = "terraform.tfstate"
    }

}

provider "azurerm" {
  features {}
}


