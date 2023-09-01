terraform {
  required_version = "= 1.5.1"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "3.62.1"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "2.21.1"
    }
    # statuscake = {
    #   source  = "StatusCakeDev/statuscake"
    #   version = "2.1.0"
    # }
  }
  backend "azurerm" {
    container_name = "terraform-state"
  }
}

provider "azurerm" {
  features {}
}

provider "kubernetes" {
  host                   = module.cluster_data.kubernetes_host
  client_certificate     = module.cluster_data.kubernetes_client_certificate
  client_key             = module.cluster_data.kubernetes_client_key
  cluster_ca_certificate = module.cluster_data.kubernetes_cluster_ca_certificate
}
