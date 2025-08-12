#TODO ADD AWS
#TODO ADD GCP

resource "azuread_application" "terraform" {
  count        = var.cloud_provider == "azure" ? 1 : 0
  display_name = "${var.repository_name}-terraform"
  tags         = var.tags
}

resource "azuread_service_principal" "terraform" {
  count     = var.cloud_provider == "azure" ? 1 : 0
  client_id = azuread_application.terraform.application_id
  tags      = var.tags
}

resource "azuread_service_principal_password" "terraform" {
  count                = var.cloud_provider == "azure" ? 1 : 0
  service_principal_id = azuread_service_principal.terraform.id
}

#TODO ADD AZURE SUBSCRIPTION AS A SECRET EITHER THROUGH A DATA LOOKUP OR CREATING A NEW ONE
#TODO ADD TENANT ID AS A SECRET FROM VARIABLES BUT ONLY REQUIRE IF AZURE IS THE CLOUD PROVIDER

resource "github_actions_secret" "azure_service_principal" {
  count           = var.cloud_provider == "azure" ? 1 : 0
  repository      = github_repository.infrastructure-deployment.name
  secret_name     = "AZURERM_CLIENT_ID"
  plaintext_value = azuread_service_principal.terraform.client_id
}

resource "github_actions_secret" "azure_service_principal_password" {
  count           = var.cloud_provider == "azure" ? 1 : 0
  repository      = github_repository.infrastructure-deployment.name
  secret_name     = "AZURERM_CLIENT_SECRET"
  plaintext_value = azuread_service_principal_password.terraform.value
}
