data "azurerm_billing_mca_account_scope" "terraform" {
  count                = var.cloud_provider == "azure" && var.billing_account_type == "mca" ? 1 : 0
  billing_account_name = var.billing_account_name
  billing_profile_name = var.billing_profile_name
  invoice_section_name = var.billing_scope
}

data "azurerm_billing_enrollment_account_scope" "terraform" {
  count                   = var.cloud_provider == "azure" && var.billing_account_type == "enrollment" ? 1 : 0
  billing_account_name    = var.billing_account_name
  enrollment_account_name = var.billing_scope
}

data "azurerm_billing_mpa_account_scope" "terraform" {
  count                = var.cloud_provider == "azure" && var.billing_account_type == "mpa" ? 1 : 0
  billing_account_name = var.billing_account_name
  customer_name        = var.customer_name
}

resource "azurerm_subscription" "terraform" {
  count             = var.cloud_provider == "azure" ? 1 : 0
  alias             = local.azure_subscription_alias
  subscription_name = format("%s Subscription", upper(var.repository_name))
  billing_scope_id = coalesce(
    try(data.azurerm_billing_mca_account_scope.terraform[0].id, null),
    try(data.azurerm_billing_enrollment_account_scope.terraform[0].id, null),
    try(data.azurerm_billing_mpa_account_scope.terraform[0].id, null),
  )

  timeouts {
    create = "20m"
    delete = "20m"
  }
}

#resource "azurerm_management_group_subscription_association" "new_subscription" {
#  count               = var.cloud_provider == "azure" ? 1 : 0
#  management_group_id = var.management_group_id
#  subscription_id     = azurerm_subscription.terraform[0].id
#}

resource "azurerm_role_assignment" "terraform" {
  count                = var.cloud_provider == "azure" ? 1 : 0
  scope                = azurerm_subscription.terraform[0].id
  role_definition_name = "Contributor"
  principal_id         = azurerm_user_assigned_identity.terraform[0].principal_id
}

resource "github_actions_secret" "azure_subscription_id" {
  count           = var.cloud_provider == "azure" ? 1 : 0
  repository      = github_repository.infrastructure-deployment.name
  secret_name     = "ARM_SUBSCRIPTION_ID"
  plaintext_value = azurerm_subscription.terraform[0].id
}
