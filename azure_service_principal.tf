resource "azurerm_user_assigned_identity" "terraform" {
  count               = var.cloud_provider == "azure" ? 1 : 0
  resource_group_name = var.resource_group_name
  name                = local.azure_user_assigned_identity_name
  location            = var.location
}

resource "azurerm_federated_identity_credential" "terraform" {
  count               = var.cloud_provider == "azure" ? 1 : 0
  resource_group_name = var.resource_group_name
  parent_id           = azurerm_user_assigned_identity.terraform[0].id
  name                = "github-actions"
  issuer              = "https://token.actions.githubusercontent.com"
  audience            = ["api://AzureADTokenExchange"]
  subject             = "repo:${var.repository_owner}/${var.repository_name}"
}

data "azurerm_client_config" "current" {}


resource "github_actions_secret" "azure_service_principal" {
  count           = var.cloud_provider == "azure" ? 1 : 0
  repository      = github_repository.infrastructure-deployment.name
  secret_name     = "ARM_CLIENT_ID"
  plaintext_value = azurerm_user_assigned_identity.terraform[0].client_id
}

resource "github_actions_secret" "azure_tenant_id" {
  count           = var.cloud_provider == "azure" ? 1 : 0
  repository      = github_repository.infrastructure-deployment.name
  secret_name     = "ARM_TENANT_ID"
  plaintext_value = data.azurerm_client_config.current.tenant_id
}
