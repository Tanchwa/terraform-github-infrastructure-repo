variable "cloud_provider" {
  description = "The cloud provider to use for the infrastructure."
  type        = string
  default     = "aws"

  validation {
    condition     = contains(["aws", "azure", "gcp"], var.cloud_provider)
    error_message = "The cloud provider must be one of: aws, azure, gcp."
  }
}

#variable "aws_vpc_cidr_block" {
#  description = "The CIDR block for the AWS VPC."
#  type        = string
#  default     = ""
#}

variable "repository_name" {
  description = "The name of the repository to create."
  type        = string
  default     = "my-repo"
}

variable "repository_owner" {
  description = "The owner of the repository."
  type        = string
  default     = "my-org"
}

variable "location" {
  description = "Location of the cloud resources to be created; cloud agnostic"
  type        = string
}

variable "billing_account" {
  description = "Billing account Display Name for the cloud provider (if applicable)."
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

