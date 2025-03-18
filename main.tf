resource "azurerm_cognitive_account" "cognitive_account" {
  name                                         = var.account.name
  location                                     = coalesce(try(var.account.location, null), var.location)
  resource_group_name                          = coalesce(try(var.account.resource_group, null), var.resource_group)
  kind                                         = var.account.kind
  sku_name                                     = var.account.sku_name
  custom_subdomain_name                        = try(var.account.custom_subdomain_name, null)
  dynamic_throttling_enabled                   = try(var.account.dynamic_throttling_enabled, false)
  fqdns                                        = try(var.account.fqdns, null)
  local_auth_enabled                           = try(var.account.local_auth_enabled, false)
  metrics_advisor_aad_client_id                = try(var.account.metrics_advisor_aad_client_id, null)
  metrics_advisor_aad_tenant_id                = try(var.account.metrics_advisor_aad_tenant_id, null)
  metrics_advisor_super_user_name              = try(var.account.metrics_advisor_super_user_name, null)
  metrics_advisor_website_name                 = try(var.account.metrics_advisor_website_name, null)
  outbound_network_access_restricted           = try(var.account.outbound_network_access_restricted, false)
  public_network_access_enabled                = try(var.account.public_network_access_enabled, false)
  qna_runtime_endpoint                         = try(var.account.qna_runtime_endpoint, null)
  custom_question_answering_search_service_id  = try(var.account.custom_question_answering_search_service_id, null)
  custom_question_answering_search_service_key = try(var.account.custom_question_answering_search_service_key, null)

  dynamic "customer_managed_key" {
    for_each = try(var.account.customer_managed_key, null) != null ? [var.account.customer_managed_key] : []

    content {
      key_vault_key_id   = try(customer_managed_key.value.key_vault_key_id, null)
      identity_client_id = try([azurerm_user_assigned_identity.identity["uai"].id], each.value.identity_client_id, null)
    }
  }

  dynamic "identity" {
    for_each = try(var.account.identity, null) != null ? { default = var.account.identity } : {}
    content {
      type         = try(var.account.identity.type, "UserAssigned")
      identity_ids = concat([azurerm_user_assigned_identity.identity["uai"].id], try(identity.value.identity_ids, []))
    }
  }

  dynamic "storage" {
    for_each = try(var.account.storage, null) != null ? { default = var.account.storage } : {}

    content {
      storage_account_id = try(storage.value.storage_account_id, null)
      identity_client_id = try(storage.value.identity_client_id, null)
    }
  }

  dynamic "network_acls" {
    for_each = try(var.account.network_acls, null) != null ? { default = var.account.network_acls } : {}

    content {
      default_action = try(network_acls.value.default_action, null)
      ip_rules       = try(network_acls.value.ip_rules, null)

      dynamic "virtual_network_rules" {
        for_each = try(network_acls.value.virtual_network_rules, null) != null ? { default = network_acls.value.virtual_network_rules } : {}

        content {
          subnet_id                            = try(virtual_network_rules.value.subnet_id, null)
          ignore_missing_vnet_service_endpoint = try(virtual_network_rules.value.ignore_missing_vnet_service_endpoint, false)
        }
      }
    }
  }
}

resource "azurerm_cognitive_deployment" "deployment" {
  for_each = {
    for deployments_key, deployments in lookup(var.account, "deployments", {}) : deployments_key => deployments
  }

  name                 = try(each.value.name, "deployment-${each.key}")
  cognitive_account_id = azurerm_cognitive_account.cognitive_account.id

  model {
    format  = each.value.model.format
    name    = each.value.model.name
    version = try(each.value.model.version, null)
  }

  sku {
    name     = each.value.sku.name
    tier     = try(each.value.sku.tier, null)
    size     = try(each.value.sku.size, null)
    family   = try(each.value.sku.family, null)
    capacity = try(each.value.sku.capacity, null)
  }
}

# blocklist
resource "azurerm_cognitive_account_rai_blocklist" "blocklist" {
  for_each = {
    for blocklist_key, blocklist in lookup(var.account, "blocklist", {}) : blocklist_key => blocklist
  }

  name                 = try(each.value.name, "blocklist-${each.key}")
  cognitive_account_id = azurerm_cognitive_account.cognitive_account.id
  description          = try(each.value.description, null)

}

# user assigned identity
resource "azurerm_user_assigned_identity" "identity" {
  for_each = try(var.account.identity, null) != null ? { uai = var.account.identity } : {}

  name                = try(var.account.identity.name, "uai-${var.account.name}")
  resource_group_name = coalesce(try(var.account.identity.resource_group, null), try(var.account.resource_group, null), var.resource_group)
  location            = coalesce(try(var.account.identity.location, null), try(var.account.location, null), var.location)

  tags = try(var.account.tags, var.tags, {})
}
