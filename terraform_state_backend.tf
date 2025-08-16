resource "aws_s3_bucket" "terraform_state_bucket" {
  count = var.cloud_provider == "aws" ? 1 : 0

  bucket = "${var.repository_name}-terraform-state"

  tags = var.tags
}

resource "azurerm_storage_account" "terraform_state_account" {
  count               = var.cloud_provider == "azure" ? 1 : 0
  resource_group_name = var.resource_group_name
  location            = var.location

  name = "${var.repository_name}terraformstate"

  account_tier             = "Standard"
  account_kind             = "Blob"
  account_replication_type = "LRS"

  blob_properties {
    versioning_enabled = true
  }

  tags = var.tags
}

resource "azurerm_storage_container" "terraform_state_container" {
  count                 = var.cloud_provider == "azure" ? 1 : 0
  name                  = "${var.repository_name}-tfstate"
  storage_account_id    = azurerm_storage_account.terraform_state_account[0].id
  container_access_type = "private"
}

resource "azurerm_role_assignment" "terraform_state_role_assignment" {
  count                = var.cloud_provider == "azure" ? 1 : 0
  scope                = azurerm_storage_account.terraform_state_account[0].id
  role_definition_name = "Storage Blob Data Contributor"
  principal_id         = azuread_service_principal.terraform[0].object_id

  depends_on = [azurerm_storage_container.terraform_state_container]
  #This may need to be done in the secondary subscription's context, keeping it here for now
}

resource "google_storage_bucket" "terraform_state_bucket" {
  count         = var.cloud_provider == "google" ? 1 : 0
  name          = "${var.repository_name}-terraform-state"
  location      = var.location
  project       = "HARDCODE THE TERRAFORM META PROJECT ID HERE"
  force_destroy = true

  uniform_bucket_level_access = true

  labels = var.tags

  versioning {
    enabled = true
  }
}

resource "google_storage_bucket_iam_member" "terraform_state_role_assignment" {
  count  = var.cloud_provider == "google" ? 1 : 0
  bucket = google_storage_bucket.terraform_state_bucket[0].name
  role   = "roles/storage.objectAdmin"
  member = "serviceAccount:${google_service_account.terraform_service_account[0].email}"

  depends_on = [google_storage_bucket.terraform_state_bucket]
}
