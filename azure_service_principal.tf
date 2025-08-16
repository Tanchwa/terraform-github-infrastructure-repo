resource "azuread_application" "terraform" {
  count        = var.cloud_provider == "azure" ? 1 : 0
  display_name = local.azure_service_principal_name
  tags         = var.tags
}

resource "azuread_service_principal" "terraform" {
  count     = var.cloud_provider == "azure" ? 1 : 0
  client_id = azuread_application.terraform[0].application_id
  tags      = var.tags
}

# THIS DOES NOT ADD THE SECRET TO THE REPO SINCE WE USE OIDC FOR AUTH
# BUT WE DO NEED IT TO CREATE THE CONTEXT FOR THE NEW RESOURCE GROUP IN THIS CODE
resource "azuread_service_principal_password" "terraform" {
  count                = var.cloud_provider == "azure" ? 1 : 0
  service_principal_id = azuread_service_principal.terraform[0].id
}

resource "azurerm_federated_identity_credential" "terraform" {
  count               = var.cloud_provider == "azure" ? 1 : 0
  resource_group_name = var.resource_group_name
  parent_id           = azuread_service_principal.terraform[0].id
  name                = "github-actions"
  issuer              = "https://token.actions.githubusercontent.com"
  audience            = ["api://AzureADTokenExchange"]
  subject             = "repo:${var.repository_owner}/${var.repository_name}"
}

data "azurerm_client_config" "current" {}

resource "github_actions_secret" "azure_service_principal" {
  count           = var.cloud_provider == "azure" ? 1 : 0
  repository      = github_repository.infrastructure-deployment.name
  secret_name     = "AZURERM_CLIENT_ID"
  plaintext_value = azuread_service_principal.terraform.client_id
}

resource "github_actions_secret" "azure_tenant_id" {
  count           = var.cloud_provider == "azure" ? 1 : 0
  repository      = github_repository.infrastructure-deployment.name
  secret_name     = "AZURERM_TENANT_ID"
  plaintext_value = data.azurerm_client_config.current.tenant_id
}
