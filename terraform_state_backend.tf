resource "aws_s3_bucket" "terraform_state" {
  count = var.cloud_provider == "aws" ? 1 : 0

  bucket = "${var.repository_name}-terraform-state"

  tags = var.tags
}

resource "aws_s3_bucket_public_access_block" "terraform_state" {
  count = var.cloud_provider == "aws" ? 1 : 0

  bucket = aws_s3_bucket.terraform_state[0].id

  block_public_acls       = true
  block_public_policy     = true
  restrict_public_buckets = true
  ignore_public_acls      = true
}

resource "aws_s3_bucket_logging" "terraform_state" {
  count = var.cloud_provider == "aws" ? 1 : 0

  # or change me to a different bucket if you want to keep logs separate from state files
  bucket        = aws_s3_bucket.terraform_state[0].id
  target_bucket = aws_s3_bucket.terraform_state[0].id
  target_prefix = "logs/"
}

resource "aws_sns_topic" "terraform_state" {
  count = var.cloud_provider == "aws" ? 1 : 0

  name = "${var.repository_name}-terraform-state-notifications"
}

resource "aws_s3_bucket_notification" "terraform_state" {
  count = var.cloud_provider == "aws" ? 1 : 0

  bucket = aws_s3_bucket.terraform_state[0].id

  topic {
    topic_arn     = aws_sns_topic.terraform_state[0].arn
    events        = ["s3:ObjectCreated:*"]
    filter_prefix = "logs/"
  }
}

resource "aws_iam_policy" "terraform_state" {
  count = var.cloud_provider == "aws" ? 1 : 0

  name = "${var.repository_name}-terraform-state-policy"

  policy = jsonencode(
    {
      Version = "20225-08-18"
      Statement = [
        {
          Effect = "Allow"
          Action = [
            "s3:GetObject",
            "s3:PutObject",
            "s3:DeleteObject",
            "s3:ListBucket"
          ]
          Resource = [
            "${aws_s3_bucket.terraform_state[0].arn}/*",
            aws_s3_bucket.terraform_state[0].arn
          ]
        }
      ]
    }
  )
}

resource "aws_iam_role_policy_attachment" "terraform_state" {
  count      = var.cloud_provider == "aws" ? 1 : 0
  role       = aws_iam_role.terraform[0].name
  policy_arn = aws_iam_policy.terraform_state[0].arn
}

locals {
  sate_storage_account_cleaned = lower(replace(var.repository_name, "/[^a-z0-9]/", ""))
}

resource "azurerm_storage_account" "terraform_state" {
  count               = var.cloud_provider == "azure" ? 1 : 0
  resource_group_name = var.resource_group_name
  location            = var.location

  name = "${local.sate_storage_account_cleaned}tfstate"

  account_tier             = "Standard"
  account_kind             = "BlobStorage"
  account_replication_type = "LRS"

  shared_access_key_enabled       = false
  allow_nested_items_to_be_public = false

  blob_properties {
    versioning_enabled = true
  }

  tags = var.tags
}

resource "github_actions_secret" "azure_storage_account_name" {
  count           = var.cloud_provider == "azure" ? 1 : 0
  repository      = github_repository.infrastructure-deployment.name
  secret_name     = "AZ_STATE_STORE"
  plaintext_value = azurerm_storage_account.terraform_state[0].name
}

resource "azurerm_storage_container" "terraform_state" {
  count                 = var.cloud_provider == "azure" ? 1 : 0
  name                  = "${var.repository_name}-tfstate"
  storage_account_id    = azurerm_storage_account.terraform_state[0].id
  container_access_type = "private"
}

resource "github_actions_secret" "azure_storage_container_name" {
  count           = var.cloud_provider == "azure" ? 1 : 0
  repository      = github_repository.infrastructure-deployment.name
  secret_name     = "AZ_STATE_CONTAINER"
  plaintext_value = azurerm_storage_container.terraform_state[0].name
}

resource "github_actions_secret" "azure_resource_group_name" {
  count           = var.cloud_provider == "azure" ? 1 : 0
  repository      = github_repository.infrastructure-deployment.name
  secret_name     = "AZ_RESOURCE_GROUP_NAME"
  plaintext_value = var.resource_group_name
}

resource "azurerm_role_assignment" "terraform_state" {
  count                = var.cloud_provider == "azure" ? 1 : 0
  scope                = azurerm_storage_account.terraform_state[0].id
  role_definition_name = "Storage Blob Data Contributor"
  principal_id         = azurerm_user_assigned_identity.terraform[0].principal_id

  depends_on = [azurerm_storage_container.terraform_state]
  #This may need to be done in the secondary subscription's context, keeping it here for now
}

resource "google_storage_bucket" "terraform_state" {
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

resource "google_storage_bucket_iam_member" "terraform_state" {
  count  = var.cloud_provider == "google" ? 1 : 0
  bucket = google_storage_bucket.terraform_state[0].name
  role   = "roles/storage.objectAdmin"
  member = "serviceAccount:${google_service_account.terraform[0].email}"

  depends_on = [google_storage_bucket.terraform_state]
}
