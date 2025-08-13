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

resource "azuread_service_principal_password" "terraform" {
  count                = var.cloud_provider == "azure" ? 1 : 0
  service_principal_id = azuread_service_principal.terraform[0].id
}

resource "azurerm_role_assignment" "terraform" {
  count                = var.cloud_provider == "azure" ? 1 : 0
  scope                = azurerm_resource_group.this[0].id
  role_definition_name = "Contributor"
  principal_id         = azuread_service_principal.terraform[0].id
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


#TODO ADD AZURE SUBSCRIPTION AS A SECRET EITHER THROUGH A DATA LOOKUP OR CREATING A NEW ONE
