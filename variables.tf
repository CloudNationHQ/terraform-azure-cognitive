variable "account" {
  description = "Cognitive Account Details"
  type = object({
    name           = string
    location       = string
    resource_group = string
    tags           = map(string)
    storage = map(object({
      storage_account_id = string
      identity_client_id = string
    }))
    network_acls = map(object({
      default_action = string
      ip_rules       = list(string)
      virtual_network_rules = list(object({
        subnet_id                            = string
        ignore_missing_vnet_service_endpoint = bool
      }))
    }))
    deployments = map(object({
      name     = string
      format   = string
      version  = string
      tier     = string
      size     = string
      family   = string
      capacity = number
    }))
    blocklist = map(object({
      name        = string
      description = string
    }))
  })
}

variable "keyvault" {
  description = "keyvault to store secrets"
  type        = string
  default     = null
}

variable "location" {
  description = "default azure region to be used."
  type        = string
  default     = null
}

variable "resource_group" {
  description = "default resource group to be used."
  type        = string
  default     = null
}

variable "tags" {
  description = "tags to be added to the resources"
  type        = map(string)
  default     = {}
}
