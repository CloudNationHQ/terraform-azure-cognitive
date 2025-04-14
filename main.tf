resource "azurerm_cognitive_account" "cognitive_account" {

  resource_group_name = coalesce(
    lookup(
      var.account, "resource_group", null
    ), var.resource_group
  )

  location = coalesce(
    lookup(var.account, "location", null
    ), var.location
  )

  name                                         = var.account.name
  kind                                         = var.account.kind
  sku_name                                     = var.account.sku_name
  custom_subdomain_name                        = var.account.custom_subdomain_name
  dynamic_throttling_enabled                   = var.account.dynamic_throttling_enabled
  fqdns                                        = var.account.fqdns
  local_auth_enabled                           = var.account.local_auth_enabled
  metrics_advisor_aad_client_id                = var.account.metrics_advisor_aad_client_id
  metrics_advisor_aad_tenant_id                = var.account.metrics_advisor_aad_tenant_id
  metrics_advisor_super_user_name              = var.account.metrics_advisor_super_user_name
  metrics_advisor_website_name                 = var.account.metrics_advisor_website_name
  outbound_network_access_restricted           = var.account.outbound_network_access_restricted
  public_network_access_enabled                = var.account.public_network_access_enabled
  qna_runtime_endpoint                         = var.account.qna_runtime_endpoint
  custom_question_answering_search_service_id  = var.account.custom_question_answering_search_service_id
  custom_question_answering_search_service_key = var.account.custom_question_answering_search_service_key

  dynamic "customer_managed_key" {
    for_each = try(var.account.customer_managed_key, null) != null ? [var.account.customer_managed_key] : []

    content {
      key_vault_key_id   = try(customer_managed_key.value.key_vault_key_id, null)
      identity_client_id = try(azurerm_user_assigned_identity.identity["uai"].id, each.value.identity_client_id, null)
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
  for_each = coalesce(
    var.account.deployments != null ? var.account.deployments : {},
    {}
  )

  name = coalesce(
    each.value.name,
    join("-", [var.naming.cognitive_deployment, each.key])
  )
  cognitive_account_id = azurerm_cognitive_account.cognitive_account.id

  model {
    format  = each.value.model.format
    name    = each.value.model.name
    version = each.value.model.version
  }

  sku {
    name     = each.value.sku.name
    tier     = each.value.sku.tier
    size     = each.value.sku.size
    family   = each.value.sku.family
    capacity = each.value.sku.capacity
  }
}

# blocklist
resource "azurerm_cognitive_account_rai_blocklist" "blocklist" {
  for_each = coalesce(
    var.account.blocklists != null ? var.account.blocklists : {},
    {}
  )

  name                 = coalesce(lookup(each.value, "name", null), "blocklist-${each.key}")
  cognitive_account_id = azurerm_cognitive_account.cognitive_account.id
  description          = each.value.description

}

# user assigned identity
resource "azurerm_user_assigned_identity" "identity" {
  for_each = try(var.account.identity, null) != null ? { uai = var.account.identity } : {}

  name                = try(var.account.identity.name, "uai-${var.account.name}")
  resource_group_name = coalesce(try(var.account.identity.resource_group, null), try(var.account.resource_group, null), var.resource_group)
  location            = coalesce(try(var.account.identity.location, null), try(var.account.location, null), var.location)

  tags = try(var.account.tags, var.tags, {})
}
