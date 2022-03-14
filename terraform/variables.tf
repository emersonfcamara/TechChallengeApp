variable "name" {
  type        = string
  description = "Name of this cluster."
  default     = "akc-example"
}

variable "client_id" {
  type        = string
  description = "Client ID"
}

variable "client_secret" {
  type        = string
  description = "Client secret."
}

variable "resource_group_name" {
  type        = string
  description = "Name of the azure resource group."
  default     = "akc-rg"
}

variable "resource_group_location" {
  type        = string
  description = "Location of the azure resource group."
  default     = "eastus"
}