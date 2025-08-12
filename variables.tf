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

variable "tags" {
  description = "A map of tags to apply to the resources."
  type        = map(string)
  default = {
    ManagedBy = "Terraform"
  }
}
