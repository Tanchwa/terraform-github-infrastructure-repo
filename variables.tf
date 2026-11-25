variable "cloud_provider" {
  description = "The cloud provider to use for the infrastructure."
  type        = string
  default     = "aws"

  validation {
    condition     = contains(["aws", "azure", "gcp"], var.cloud_provider)
    error_message = "The cloud provider must be one of: aws, azure, gcp."
  }
}

variable "resource_group_name" {
  description = "The name of the core Azure resource group for setting up the cloud workspace backend. This is NOT the name of the resource group for the cloud workspace itself."
  type        = string
  default     = "core-resource-group"
}

variable "aws_vpc_cidr_block" {
  description = "The CIDR block for the AWS VPC."
  type        = string
  default     = ""
}

variable "repository_name" {
  description = "The name of the repository to create."
  type        = string
}

variable "repository_owner" {
  description = "The owner of the repository."
  type        = string
}

variable "environments" {
  description = "In Preview. A list of environemnts to add to the repo and cloud environment. A new Environment per list item will be created in the repository, as well as a cloud workspace for each."
  type        = list(string)
  default     = ["dev"]
}

variable "location" {
  description = "Location of the cloud resources to be created; cloud agnostic: maps to AWS region, Azure location, or GCP location."
  type        = string
}

variable "billing_scope" {
  description = "Billing Scope Name for the cloud provider. Not applicable to AWS, instead use the AWS parent organization ID. (see https://docs.aws.amazon.com/awsaccountbilling/latest/aboutv2/consolidated-billing.html) For Azure, this is the MCA invoice section name or EA enrollment account name, depending on billing_account_type; not applicable when billing_account_type = \"mpa\". For GCP, this is the billing account display name."
  type        = string
  default     = ""

  validation {
    condition = (
      (var.cloud_provider != "azure" || contains(["mca", "enrollment"], var.billing_account_type) == false)
      && var.cloud_provider != "gcp"
    ) || var.billing_scope != ""
    error_message = "billing_scope is required when cloud_provider = \"gcp\", or cloud_provider = \"azure\" with billing_account_type \"mca\" or \"enrollment\"."
  }
}

variable "billing_account_name" {
  description = "Azure Billing Account name, e.g. \"<guid>:<guid>_2019-05-31\" for MCA, or an enrollment/partner billing account name for other types (see the `id` of `az billing account list`). Only applicable to Azure."
  type        = string
  default     = ""

  validation {
    condition     = var.cloud_provider != "azure" || var.billing_account_name != ""
    error_message = "billing_account_name is required when cloud_provider = \"azure\"."
  }
}

variable "billing_account_type" {
  description = "Which Azure billing scope shape to use when creating the subscription: \"mca\" (Microsoft Customer Agreement), \"enrollment\" (Enterprise Agreement enrollment account), or \"mpa\" (Microsoft Partner Agreement). Only applicable to Azure."
  type        = string
  default     = "mca"

  validation {
    condition     = contains(["mca", "enrollment", "mpa"], var.billing_account_type)
    error_message = "billing_account_type must be one of: mca, enrollment, mpa."
  }
}

variable "billing_profile_name" {
  description = "Azure Billing Profile name under the billing account (see `az billing profile list`). Only applicable when cloud_provider = \"azure\" and billing_account_type = \"mca\"."
  type        = string
  default     = ""

  validation {
    condition     = var.cloud_provider != "azure" || var.billing_account_type != "mca" || var.billing_profile_name != ""
    error_message = "billing_profile_name is required when cloud_provider = \"azure\" and billing_account_type = \"mca\"."
  }
}

variable "customer_name" {
  description = "Azure MPA Customer name/ID under the Partner billing account (see `az billing customer list`). Only applicable when cloud_provider = \"azure\" and billing_account_type = \"mpa\"."
  type        = string
  default     = ""

  validation {
    condition     = var.cloud_provider != "azure" || var.billing_account_type != "mpa" || var.customer_name != ""
    error_message = "customer_name is required when cloud_provider = \"azure\" and billing_account_type = \"mpa\"."
  }
}

variable "aws_account_email" {
  description = "The email address for the new AWS parent account to be linked to"
  type        = string
  default     = ""

  validation {
    condition     = var.cloud_provider != "aws" || var.aws_account_email != ""
    error_message = "aws_account_email is required when cloud_provider = \"aws\"."
  }
}

variable "parent_organization_id" {
  description = "The AWS parent Organization or OU, or GCP Organization ID to link the new account or Project to"
  type        = string
  default     = ""
}

variable "aws_close_account_on_deletion" {
  description = "Whether `terraform destroy` should actually request closure of the AWS Organizations member account (subject to AWS's own restrictions, e.g. accounts can't be closed within ~7 days of creation). When false, destroy only removes the account from Terraform state and it must be closed manually. Only applicable to AWS."
  type        = bool
  default     = false
}

variable "azure_private_endpoint_subnet_id" {
  description = "Subnet ID the private endpoints for the Terraform state storage account and Key Vault are attached to. Required when cloud_provider = \"azure\", since both have public network access disabled."
  type        = string
  default     = ""

  validation {
    condition     = var.cloud_provider != "azure" || var.azure_private_endpoint_subnet_id != ""
    error_message = "azure_private_endpoint_subnet_id is required when cloud_provider = \"azure\"."
  }
}

variable "azure_private_dns_zone_id_blob" {
  description = "Optional existing privatelink.blob.core.windows.net Private DNS Zone ID to register the state storage account's private endpoint in. If left blank, the private endpoint is created without DNS integration -- wire up name resolution separately (e.g. a centrally managed private DNS zone)."
  type        = string
  default     = ""
}

variable "azure_private_dns_zone_id_keyvault" {
  description = "Optional existing privatelink.vaultcore.azure.net Private DNS Zone ID to register the state Key Vault's private endpoint in. If left blank, the private endpoint is created without DNS integration -- wire up name resolution separately (e.g. a centrally managed private DNS zone)."
  type        = string
  default     = ""
}

variable "azure_log_analytics_workspace_id" {
  description = "Optional existing Log Analytics Workspace ID to additionally stream the state storage account's blob service diagnostic logs to. If left blank, logs are only sent to the storage account itself (self-logging, mirroring the AWS S3 access-logging setup) -- wire up a Log Analytics Workspace later by setting this and re-applying, or use the azure_terraform_state_blob_service_diagnostic_target_id output to attach one manually."
  type        = string
  default     = ""
}

variable "template_sync_github_app_id" {
  description = "App ID of the GitHub App used by the template_sync workflow (see infrastructure-deployment-template/.github/workflows/template_sync.yaml) to authenticate across the template repo and this child repo. Leave blank to skip wiring up the secret (the workflow will fail until it's set)."
  type        = string
  default     = ""
}

variable "template_sync_github_app_private_key" {
  description = "PEM private key of the GitHub App used by the template_sync workflow. Leave blank to skip wiring up the secret (the workflow will fail until it's set)."
  type        = string
  sensitive   = true
  default     = ""
}

variable "tags" {
  description = "A map of tags (key value pair descriptors) to apply to resources. In GCP, these are known as labels"
  type        = map(string)
  default = {
    ManagedBy = "Terraform"
  }
}

