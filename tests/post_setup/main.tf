terraform {
  required_providers {
    github = {
      source  = "integrations/github"
      version = "~> 5.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.0"
    }
  }
}

provider "github" {}

variable "cloud_provider" {
  description = "The cloud provider to use (azurerm, google, aws)"
  type        = string
  default     = "azurerm"
  validation {
    condition     = contains(["azurerm", "google", "aws"], var.cloud_provider)
    error_message = "cloud_provider must be one of 'azurerm', 'google', or 'aws'."
  }
}

resource "random_string" "storage_account_suffix" {
  length  = 6
  upper   = false
  lower   = true
  numeric = true
  special = false
}

resource "github_repository_file" "azurerm_storage_account" {
  count          = var.cloud_provider == "azurerm" ? 1 : 0
  repository     = "example-repo"
  file           = "azurerm_storage_account.tf"
  content        = <<-EOT
    resource "azurerm_storage_account" "example" {
      name                     = "examplestorage${random_string.storage_account_suffix.result}"
      resource_group_name      = "example-resources"
      location                 = "West US"
      account_tier             = "Standard"
      account_replication_type = "LRS"
    }
    EOT
  commit_message = "Add azurerm_storage_account resource"
}

resource "github_repository_file" "google_storage_bucket" {
  count          = var.cloud_provider == "google" ? 1 : 0
  repository     = "example-repo"
  file           = "google_storage_bucket.tf"
  content        = <<-EOT
    resource "google_storage_bucket" "example" {
      name     = "example-bucket-${random_string.storage_account_suffix.result}"
      location = "US"
      force_destroy = true
    }
    EOT
  commit_message = "Add google_storage_bucket resource"
}

resource "github_repository_file" "aws_s3_bucket" {
  count          = var.cloud_provider == "aws" ? 1 : 0
  repository     = "example-repo"
  file           = "aws_s3_bucket.tf"
  content        = <<-EOT
    resource "aws_s3_bucket" "example" {
      bucket = "example-bucket-${random_string.storage_account_suffix.result}"
      acl    = "private"
    }
    EOT
  commit_message = "Add aws_s3_bucket resource"
}
