variable "cloud_provider" {
  description = "The cloud provider to use for the infrastructure."
  type        = string
  default     = "aws"

  validation {
    condition     = contains(["aws", "azure", "gcp"], var.cloud_provider)
    error_message = "The cloud provider must be one of: aws, azure, gcp."
  }
}

variable "repository_name" {
  description = "The name of the repository to create."
  type        = string
  default     = "my-repo"
}

variable "location" {
  description = "Location of the cloud resources to be created; cloud agnostic"
  type        = string
}

variable "tags" {
  description = "A map of tags (key value pair descriptors) to apply to resources. In GCP, these are known as labels"
  type        = map(string)
  default = {
    ManagedBy = "Terraform"
  }
}
