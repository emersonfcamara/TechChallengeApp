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
}

resource "azurerm_resource_group" "akc-rg" {
  name     = "${var.resource_group_name}"
  location = "${var.resource_group_location}"
}

#an attempt to keep the aci container group name (and dns label) somewhat unique
resource "random_integer" "random_int" {
  min = 100
  max = 999
}

resource azurerm_network_security_group "aks_advanced_network" {
  name                = "akc-${random_integer.random_int.result}-nsg"
  location            = "${var.resource_group_location}"
  resource_group_name = "${azurerm_resource_group.akc-rg.name}"
}

resource "azurerm_virtual_network" "aks_advanced_network" {
  name                = "akc-${random_integer.random_int.result}-vnet"
  location            = "${var.resource_group_location}"
  resource_group_name = "${azurerm_resource_group.akc-rg.name}"
  address_space       = ["10.1.0.0/16"]
}

resource "azurerm_subnet" "aks_subnet" {
  name                      = "akc-${random_integer.random_int.result}-subnet"
  resource_group_name       = "${azurerm_resource_group.akc-rg.name}"
  address_prefixes          = ["10.1.0.0/24"]
  virtual_network_name      = "${azurerm_virtual_network.aks_advanced_network.name}"
}

resource "azurerm_kubernetes_cluster" "aks_container" {
  name       = "akc-${random_integer.random_int.result}"
  location   = "${var.resource_group_location}"
  dns_prefix = "akc-${random_integer.random_int.result}"

  resource_group_name = "${azurerm_resource_group.akc-rg.name}"

  default_node_pool {
    name       = "default"
    node_count = 2
    vm_size    = "Standard_DS2_v2"
  }

    # Required for advanced networking
    vnet_subnet_id = "${azurerm_subnet.aks_subnet.id}"
    
  service_principal {
    client_id     = "${var.client_id}"
    client_secret = "${var.client_secret}"
  }

  network_profile {
    network_plugin     = "azure"
    dns_service_ip     = "10.0.0.10"
    docker_bridge_cidr = "172.17.0.1/16"
    service_cidr       = "10.0.0.0/16"
  }
}