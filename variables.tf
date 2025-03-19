variable "account" {
  description = "Configuration for the Azure Cognitive Services account"
  type = object({
    name                                         = string
    location                                     = optional(string)
    resource_group                               = optional(string)
    kind                                         = string
    sku_name                                     = string
    custom_subdomain_name                        = optional(string)
    dynamic_throttling_enabled                   = optional(bool)
    fqdns                                        = optional(list(string))
    local_auth_enabled                           = optional(bool)
    metrics_advisor_aad_client_id                = optional(string)
    metrics_advisor_aad_tenant_id                = optional(string)
    metrics_advisor_super_user_name              = optional(string)
    metrics_advisor_website_name                 = optional(string)
    outbound_network_access_restricted           = optional(bool)
    public_network_access_enabled                = optional(bool)
    qna_runtime_endpoint                         = optional(string)
    custom_question_answering_search_service_id  = optional(string)
    custom_question_answering_search_service_key = optional(string)
    customer_managed_key = optional(object({
      key_vault_key_id   = string
      identity_client_id = optional(string)
    }))
    identity = optional(object({
      type           = optional(string)
      name           = optional(string)
      location       = optional(string)
      resource_group = optional(string)
      identity_ids   = optional(list(string))
    }))
    storage = optional(object({
      storage_account_id = string
      identity_client_id = optional(string)
    }))
    network_acls = optional(object({
      default_action = string
      ip_rules       = optional(list(string))
      virtual_network_rules = optional(object({
        subnet_id                            = string
        ignore_missing_vnet_service_endpoint = optional(bool)
      }))
    }))
    deployments = optional(map(object({
      name = optional(string)
      model = object({
        format  = string
        name    = string
        version = optional(string)
      })
      sku = object({
        name     = string
        tier     = optional(string)
        size     = optional(string)
        family   = optional(string)
        capacity = optional(number)
      })
    })))
    blocklists = optional(map(object({
      name        = optional(string)
      description = optional(string)
    })))
    tags = optional(map(string))
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
