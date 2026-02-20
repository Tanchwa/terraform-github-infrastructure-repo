variables {
  cloud_provider = "azure"

  resource_group_name = "core-state-rg"
  repository_name     = "example-infra-repo"
  repository_owner    = "Tanchwa"
  location            = "East US"
  billing_scope       = "edd8e0c7-86c4-42a2-8896-da59090edae7"
}


provider "azurerm" {
  features {}
  resource_provider_registrations = "extended"
  storage_use_azuread             = true
}

provider "github" {}

provider "google" {}

provider "aws" {}

run "setup_repo" {
  command = apply

  assert {
    condition     = data.azurerm_billing_mca_account_scope.terraform[0].id == "/providers/Microsoft.Billing/billingAccounts/de00d5cd-7f5b-515c-0a04–78af3ffdaf86:1ba8d8a0-a375–4591–98cc-07d3f18c0de0_2019–05–31/billingProfiles/Q7VE-6V35-BG7-PGB/invoiceSections/edd8e0c7–86c4–42a2–8896-da59090edae7"
    error_message = "Azure billing MCA account scope is incorrect."
  }
  assert {
    condition     = github_actions_secret.azure_subscription_id[0].created_at != ""
    error_message = "GitHub Actions secret for ARM_SUBSCRIPTION_ID was not created."
  }
}

run "post_setup" {
  module {
    source = "./tests/post_setup"
  }
}


