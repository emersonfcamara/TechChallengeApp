terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "=2.46.0"
    }
  }
}

# Configure the Microsoft Azure Provider
provider "azurerm" {
  # NOTE: Environment Variables can also be used for Service Principal authentication
  # Terraform also supports authenticating via the Azure CLI too.
  # see here for more info: http://terraform.io/docs/providers/azurerm/index.html
  features {}

  subscription_id = $AZURE_SUB_ID
  client_id       = $AZURE_CLIENT_ID
  client_secret   = $AZURE_CLIENT_SECRET
  tenant_id       = $AZURE_TENANT_ID
}

# Create a resource group
resource "azurerm_resource_group" "servian" {
  name     = "rg-servian"
  location = "East US 2"
}

# Create a virtual network in the web_servers resource group
resource "azurerm_virtual_network" "network" {
  name                = "production-network"
  resource_group_name = "${azurerm_resource_group.servian.name}"
  location            = "${azurerm_resource_group.servian.location}"
  address_space       = ["10.0.0.0/16"]

  subnet {
    name           = "sb-db"
    address_prefix = "10.0.1.0/24"
  }

  subnet {
    name           = "sb-aks"
    address_prefix = "10.0.2.0/24"
  }
}