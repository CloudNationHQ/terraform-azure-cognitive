output "account" {
  description = "Contains all the outputs for the cognitive account"
  value       = azurerm_cognitive_account.cognitive_account
}

output "deployments" {
  description = "Contains all the outputs for the cognitive deployments"
  value       = azurerm_cognitive_deployment.deployment
}

output "blocklists" {
  description = "Contains all the outputs for the cognitive blocklists"
  value       = azurerm_cognitive_account_rai_blocklist.blocklist
}

output "identity" {
  description = "Contains all the outputs for the identity"
  value       = azurerm_user_assigned_identity.identity
}
