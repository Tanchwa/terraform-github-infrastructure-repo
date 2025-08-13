resource "aws_s3_bucket" "terraform_state_bucket" {
  count = var.cloud_provider == "aws" ? 1 : 0

  bucket = "${var.repository_name}-terraform-state"

  tags = var.tags
}

resource "azurerm_storage_account" "terraform_state_account" {
  count               = var.cloud_provider == "azure" ? 1 : 0
  resource_group_name = "TERRAFORM-META-RG"
  location            = var.location

  name = "${var.repository_name}terraformstate"

  account_tier             = "Standard"
  account_kind             = "Blob"
  account_replication_type = "LRS"

  tags = var.tags
}

resource "azurerm_storage_container" "terraform_state_container" {
  count                 = var.cloud_provider == "azure" ? 1 : 0
  name                  = "${var.repository_name}-tfstate"
  storage_account_name  = azurerm_storage_account.terraform_state_account[0].name
  container_access_type = "private"
}
