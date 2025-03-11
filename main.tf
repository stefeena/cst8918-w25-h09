terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">=3.0.0"
    }
  }
}

provider "azurerm" {
  features {}

  subscription_id = "d9f49562-ebf4-4890-8399-f98dc64c96b6"  # Ensure correct subscription ID
}

# ✅ Define Resource Group
resource "azurerm_resource_group" "aks_rg" {
  name     = "aks-resource-group"
  location = "East US"
}

# ✅ AKS Cluster (Fixed: Removed `enable_auto_scaling`)
resource "azurerm_kubernetes_cluster" "aks_cluster" {
  name                = "aks-cluster"
  location            = azurerm_resource_group.aks_rg.location
  resource_group_name = azurerm_resource_group.aks_rg.name
  dns_prefix          = "akscluster"

  default_node_pool {
    name        = "agentpool"
    vm_size     = "Standard_B2s"
    node_count  = 1  # ✅ Set a fixed node count (Auto-scaling removed)
  }

  identity {
    type = "SystemAssigned"
  }

  tags = {
    environment = "dev"
  }
}

output "kube_config" {
  value     = azurerm_kubernetes_cluster.aks_cluster.kube_config_raw
  sensitive = true
}
