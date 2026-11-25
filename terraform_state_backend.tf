resource "aws_s3_bucket" "terraform_state" {
  #checkov:skip=CKV2_AWS_62:Event notifications are configured via the separate aws_s3_bucket_notification.terraform_state resource; checkov does not correlate this across resources.
  #checkov:skip=CKV2_AWS_61:Lifecycle configuration is set via the separate aws_s3_bucket_lifecycle_configuration.terraform_state resource; checkov does not correlate this across resources.
  #checkov:skip=CKV_AWS_18:Access logging is configured via the separate aws_s3_bucket_logging.terraform_state resource; checkov does not correlate this across resources.
  #checkov:skip=CKV_AWS_145:Default KMS encryption is set via the separate aws_s3_bucket_server_side_encryption_configuration.terraform_state resource; checkov does not correlate this across resources.
  #checkov:skip=CKV2_AWS_6:Public access block is set via the separate aws_s3_bucket_public_access_block.terraform_state resource; checkov does not correlate this across resources.
  #checkov:skip=CKV_AWS_21:Versioning is enabled via the separate aws_s3_bucket_versioning.terraform_state resource; checkov does not correlate this across resources.
  #checkov:skip=CKV_AWS_144:Cross-region replication is not warranted for this small per-repo Terraform state bucket; accepted risk given versioning + lifecycle + KMS encryption are already in place.
  count = var.cloud_provider == "aws" ? 1 : 0

  bucket = "${var.repository_name}-terraform-state"

  tags = var.tags
}

resource "github_actions_secret" "aws_state_bucket_name" {
  count           = var.cloud_provider == "aws" ? 1 : 0
  repository      = github_repository.infrastructure-deployment.name
  secret_name     = "AWS_STATE_BUCKET" # pragma: allowlist secret
  plaintext_value = aws_s3_bucket.terraform_state[0].bucket
}

resource "github_actions_secret" "aws_state_region" {
  count           = var.cloud_provider == "aws" ? 1 : 0
  repository      = github_repository.infrastructure-deployment.name
  secret_name     = "AWS_STATE_REGION" # pragma: allowlist secret
  plaintext_value = var.location
}

resource "aws_s3_bucket_public_access_block" "terraform_state" {
  count = var.cloud_provider == "aws" ? 1 : 0

  bucket = aws_s3_bucket.terraform_state[0].id

  block_public_acls       = true
  block_public_policy     = true
  restrict_public_buckets = true
  ignore_public_acls      = true
}

resource "aws_s3_bucket_versioning" "terraform_state" {
  count = var.cloud_provider == "aws" ? 1 : 0

  bucket = aws_s3_bucket.terraform_state[0].id

  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_lifecycle_configuration" "terraform_state" {
  count = var.cloud_provider == "aws" ? 1 : 0

  bucket = aws_s3_bucket.terraform_state[0].id

  rule {
    id     = "expire-noncurrent-versions"
    status = "Enabled"

    noncurrent_version_expiration {
      noncurrent_days = 90
    }

    abort_incomplete_multipart_upload {
      days_after_initiation = 7
    }
  }

  depends_on = [aws_s3_bucket_versioning.terraform_state]
}

resource "aws_s3_bucket_server_side_encryption_configuration" "terraform_state" {
  count = var.cloud_provider == "aws" ? 1 : 0

  bucket = aws_s3_bucket.terraform_state[0].id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "aws:kms"
    }
    bucket_key_enabled = true
  }
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

  name              = "${var.repository_name}-terraform-state-notifications"
  kms_master_key_id = "alias/aws/sns"
}

data "aws_caller_identity" "current" {
  count = var.cloud_provider == "aws" ? 1 : 0
}

resource "aws_sns_topic_policy" "terraform_state" {
  count = var.cloud_provider == "aws" ? 1 : 0

  arn = aws_sns_topic.terraform_state[0].arn

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid       = "AllowS3ToPublish"
        Effect    = "Allow"
        Principal = { Service = "s3.amazonaws.com" }
        Action    = "SNS:Publish"
        Resource  = aws_sns_topic.terraform_state[0].arn
        Condition = {
          ArnLike = {
            "aws:SourceArn" = aws_s3_bucket.terraform_state[0].arn
          }
          StringEquals = {
            "aws:SourceAccount" = data.aws_caller_identity.current[0].account_id
          }
        }
      }
    ]
  })
}

resource "aws_s3_bucket_notification" "terraform_state" {
  count = var.cloud_provider == "aws" ? 1 : 0

  bucket = aws_s3_bucket.terraform_state[0].id

  topic {
    topic_arn     = aws_sns_topic.terraform_state[0].arn
    events        = ["s3:ObjectCreated:*"]
    filter_prefix = "logs/"
  }

  depends_on = [aws_sns_topic_policy.terraform_state]
}

resource "aws_iam_policy" "terraform_state" {
  count = var.cloud_provider == "aws" ? 1 : 0

  name = "${var.repository_name}-terraform-state-policy"

  policy = jsonencode(
    {
      Version = "2012-10-17"
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

resource "azurerm_key_vault" "terraform_state" {
  count               = var.cloud_provider == "azure" ? 1 : 0
  name                = local.azure_key_vault_name
  location            = var.location
  resource_group_name = var.resource_group_name
  tenant_id           = data.azurerm_client_config.current.tenant_id
  sku_name            = "standard"

  rbac_authorization_enabled    = true
  purge_protection_enabled      = true
  public_network_access_enabled = false

  network_acls {
    bypass         = "AzureServices"
    default_action = "Deny"
  }

  tags = var.tags
}

resource "azurerm_private_endpoint" "terraform_state_kv" {
  count               = var.cloud_provider == "azure" ? 1 : 0
  name                = "${var.repository_name}-tfstate-kv-pe"
  location            = var.location
  resource_group_name = var.resource_group_name
  subnet_id           = var.azure_private_endpoint_subnet_id

  private_service_connection {
    name                           = "${var.repository_name}-tfstate-kv-psc"
    private_connection_resource_id = azurerm_key_vault.terraform_state[0].id
    subresource_names              = ["vault"]
    is_manual_connection           = false
  }

  dynamic "private_dns_zone_group" {
    for_each = var.azure_private_dns_zone_id_keyvault != "" ? [1] : []
    content {
      name                 = "default"
      private_dns_zone_ids = [var.azure_private_dns_zone_id_keyvault]
    }
  }

  tags = var.tags
}

# The deployer needs an RBAC grant of its own to manage keys under enable_rbac_authorization.
resource "azurerm_role_assignment" "terraform_state_kv_deployer" {
  count                = var.cloud_provider == "azure" ? 1 : 0
  scope                = azurerm_key_vault.terraform_state[0].id
  role_definition_name = "Key Vault Crypto Officer"
  principal_id         = data.azurerm_client_config.current.object_id
}

resource "azurerm_key_vault_key" "terraform_state" {
  count        = var.cloud_provider == "azure" ? 1 : 0
  name         = "tfstate-cmk"
  key_vault_id = azurerm_key_vault.terraform_state[0].id
  key_type     = "RSA"
  key_size     = 2048

  key_opts = [
    "decrypt", "encrypt", "sign", "unwrapKey", "verify", "wrapKey",
  ]

  # The vault has public network access disabled, so key creation (a data-plane call)
  # must wait for the private endpoint to exist and provide network access to it.
  depends_on = [
    azurerm_role_assignment.terraform_state_kv_deployer,
    azurerm_private_endpoint.terraform_state_kv,
  ]
}

resource "azurerm_storage_account" "terraform_state" {
  #checkov:skip=CKV2_AZURE_21:storage insights will be piped into a log analytics workspace outisde of this module
  count               = var.cloud_provider == "azure" ? 1 : 0
  resource_group_name = var.resource_group_name
  location            = var.location

  name = "${local.sate_storage_account_cleaned}tfstate"

  account_tier             = "Standard"
  account_kind             = "BlobStorage"
  account_replication_type = "LRS"

  shared_access_key_enabled       = false
  allow_nested_items_to_be_public = false
  public_network_access           = "Disabled"

  blob_properties {
    versioning_enabled = true

    delete_retention_policy {
      days = 7
    }

    container_delete_retention_policy {
      days = 7
    }
  }

  identity {
    type = "SystemAssigned"
  }

  tags = var.tags

  lifecycle {
    ignore_changes = [customer_managed_key]
  }
}

resource "azurerm_private_endpoint" "terraform_state_storage" {
  count               = var.cloud_provider == "azure" ? 1 : 0
  name                = "${var.repository_name}-tfstate-pe"
  location            = var.location
  resource_group_name = var.resource_group_name
  subnet_id           = var.azure_private_endpoint_subnet_id

  private_service_connection {
    name                           = "${var.repository_name}-tfstate-psc"
    private_connection_resource_id = azurerm_storage_account.terraform_state[0].id
    subresource_names              = ["blob"]
    is_manual_connection           = false
  }

  dynamic "private_dns_zone_group" {
    for_each = var.azure_private_dns_zone_id_blob != "" ? [1] : []
    content {
      name                 = "default"
      private_dns_zone_ids = [var.azure_private_dns_zone_id_blob]
    }
  }

  tags = var.tags
}

# Mirrors the AWS S3 access-logging setup: logs land in the same storage account by
# default. Set azure_log_analytics_workspace_id to additionally stream them there, or
# use the diagnostic target output below to attach a workspace later.
resource "azurerm_monitor_diagnostic_setting" "terraform_state_storage" {
  count                      = var.cloud_provider == "azure" ? 1 : 0
  name                       = "${var.repository_name}-tfstate-diagnostics"
  target_resource_id         = "${azurerm_storage_account.terraform_state[0].id}/blobServices/default"
  storage_account_id         = azurerm_storage_account.terraform_state[0].id
  log_analytics_workspace_id = var.azure_log_analytics_workspace_id != "" ? var.azure_log_analytics_workspace_id : null

  enabled_log {
    category = "StorageRead"
  }
  enabled_log {
    category = "StorageWrite"
  }
  enabled_log {
    category = "StorageDelete"
  }
}

resource "azurerm_role_assignment" "terraform_state_key_access" {
  count                = var.cloud_provider == "azure" ? 1 : 0
  scope                = azurerm_key_vault.terraform_state[0].id
  role_definition_name = "Key Vault Crypto Service Encryption User"
  principal_id         = azurerm_storage_account.terraform_state[0].identity[0].principal_id
}

resource "azurerm_storage_account_customer_managed_key" "terraform_state" {
  count              = var.cloud_provider == "azure" ? 1 : 0
  storage_account_id = azurerm_storage_account.terraform_state[0].id
  key_vault_key_id   = azurerm_key_vault_key.terraform_state[0].id

  depends_on = [azurerm_role_assignment.terraform_state_key_access]
}

resource "github_actions_secret" "azure_storage_account_name" {
  count           = var.cloud_provider == "azure" ? 1 : 0
  repository      = github_repository.infrastructure-deployment.name
  secret_name     = "AZ_STATE_STORE" # pragma: allowlist secret
  plaintext_value = azurerm_storage_account.terraform_state[0].name
}

resource "azurerm_storage_container" "terraform_state" {
  #checkov:skip=CKV2_AZURE_21:Blob service logging (read/write/delete) is configured on the parent storage account via azurerm_monitor_diagnostic_setting.terraform_state_storage, which covers every container in the account; checkov does not correlate this across resources.
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
  count         = var.cloud_provider == "gcp" ? 1 : 0
  name          = "${var.repository_name}-terraform-state"
  location      = var.location
  project       = "HARDCODE THE TERRAFORM META PROJECT ID HERE"
  force_destroy = true

  uniform_bucket_level_access = true

  labels = { for k, v in var.tags : lower(k) => v }

  versioning {
    enabled = true
  }
}

resource "github_actions_secret" "gcp_state_bucket_name" {
  count           = var.cloud_provider == "gcp" ? 1 : 0
  repository      = github_repository.infrastructure-deployment.name
  secret_name     = "GCP_STATE_BUCKET" # pragma: allowlist secret
  plaintext_value = google_storage_bucket.terraform_state[0].name
}

resource "google_storage_bucket_iam_member" "terraform_state" {
  count  = var.cloud_provider == "gcp" ? 1 : 0
  bucket = google_storage_bucket.terraform_state[0].name
  role   = "roles/storage.objectAdmin"
  member = "serviceAccount:${google_service_account.terraform[0].email}"

  depends_on = [google_storage_bucket.terraform_state]
}
