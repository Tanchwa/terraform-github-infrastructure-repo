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

variable "location" {
  description = "Location of the cloud resources to be created; cloud agnostic: maps to AWS region, Azure location, or GCP location."
  type        = string
}

variable "billing_scope" {
  description = "Billing Scope Name for the cloud provider. Not applicable to AWS, instead use the AWS parent organization ID. (see https://docs.aws.amazon.com/awsaccountbilling/latest/aboutv2/consolidated-billing.html)"
  type        = string
  default     = ""
}

variable "aws_account_email" {
  description = "The email address for the new AWS parent account to be linked to"
  type        = string
  default     = ""
}

variable "parent_organization_id" {
  description = "The AWS parent Organization or OU, or GCP Organization ID to link the new account or Project to"
  type        = string
  default     = ""
}

variable "tags" {
  description = "A map of tags (key value pair descriptors) to apply to resources. In GCP, these are known as labels"
  type        = map(string)
  default = {
    ManagedBy = "Terraform"
  }
}

