data "azurerm_billing_account" "terraform" {
  count                = var.cloud_provider == "azure" ? 1 : 0
  billing_account_name = var.billing_account
}

resource "azurerm_subscription" "terraform" {
  count             = var.cloud_provider == "azure" ? 1 : 0
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
  secret_name     = "AZURERM_SUBSCRIPTION_ID"
  plaintext_value = azurerm_subscription.terraform[0].id
}

provider "azurerm" {
  alias           = "new_subscription"
  subscription_id = azurerm_subscription.terraform[0].id
  client_id       = azuread_service_principal.terraform[0].client_id
  tenant_id       = azuread_service_principal.terraform[0].tenant_id
  client_secret   = azuread_service_principal_password.terraform[0].value
}

resource "azurerm_resource_group" "terraform" {
  count    = var.cloud_provider == "azure" ? 1 : 0
  name     = local.azure_resource_group_name
  location = var.location

  tags = var.tags

  provider = azurerm.new_subscription
  depends_on = [
    azurerm_subscription.terraform,
    azuread_service_principal.terraform,
    azuread_service_principal_password.terraform
  ]
}

resource "github_actions_secret" "azure_resource_group_id" {
  count           = var.cloud_provider == "azure" ? 1 : 0
  repository      = github_repository.infrastructure-deployment.name
  secret_name     = "RESOURCE_GROUP_ID"
  plaintext_value = azurerm_resource_group.terraform[0].id
}
