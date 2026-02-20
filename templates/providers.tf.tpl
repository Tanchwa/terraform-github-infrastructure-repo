terraform {
  required_providers {
%{ if cloud_provider == "aws" }
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.28.0"
    }
  }
  backend "s3" {
  # backend config set in pipleine
  }
%{ endif }
%{ if cloud_provider == "gcp" }
    google = {
      source  = "hashicorp/google"
      version = "~> 7.16.0"
    }
  }
  backend "gcs" {
  # backend config set in pipleine
  }
%{ endif }
%{ if cloud_provider == "azure" }
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.58.0"
    }
  }
  backend "azurerm" {
# backend config set in pipleine
  }
%{ endif }
  
%{ if cloud_provider == "aws" }
provider "aws" {}
%{ endif }
%{ if cloud_provider == "gcp" }
provider "google" {}
%{ endif }
%{ if cloud_provider == "azure" }
provider "azurerm" {
  features {}
  use_oidc = true
  resource_provider_registrations = "extended"
  storage_use_azuread = true
}
%{ endif }
