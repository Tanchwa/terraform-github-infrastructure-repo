resource "azurerm_resource_group" "terraform" {
  count    = var.cloud_provider == "azure" ? 1 : 0
  name     = local.azure_resource_group_name
  location = var.location

  tags = var.tags
}

resource "google_project" "terraform" {
  count      = var.cloud_provider == "google" ? 1 : 0
  name       = local.google_project_name
  project_id = local.google_project_id
  #TODO add default org_id or folder_id
  #TODO add default billing_account

  labels = var.tags
}
