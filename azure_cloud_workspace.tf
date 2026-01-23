data "azurerm_billing_account" "terraform" {
  count                = var.cloud_provider == "azure" ? 1 : 0
  billing_account_name = var.billing_account
}

resource "azurerm_subscription" "terraform" {
  count             = var.cloud_provider == "azure" ? 1 : 0
  alias             = local.azure_subscription_alias
  subscription_name = format("%s Subscription", upper(var.repository_name))
  billing_scope_id  = data.azurerm_billing_account.terraform[0].id
}

resource "azurerm_role_assignment" "terraform" {
  count                = var.cloud_provider == "azure" ? 1 : 0
  scope                = azurerm_subscription.terraform[0].id
  role_definition_name = "Contributor"
  principal_id         = azuread_service_principal.terraform[0].id
}

resource "github_actions_secret" "azure_subscription_id" {
  count           = var.cloud_provider == "azure" ? 1 : 0
  repository      = github_repository.infrastructure-deployment.name
  secret_name     = "ARM_SUBSCRIPTION_ID"
  plaintext_value = azurerm_subscription.terraform[0].id
}
