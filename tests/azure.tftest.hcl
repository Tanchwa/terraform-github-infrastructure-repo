variables {
  cloud_provider = "azure"

  resource_group_name              = "core-state-rg"
  repository_name                  = "example-infra-repo"
  repository_owner                 = "Tanchwa"
  location                         = "East US"
  billing_scope                    = "4a83b80c-d5ec-4259-bc7b-9cb0e4860000"
  billing_account_name             = "9c0340d0-7ff4-570b-8e73-a08aaa319c34:35f0ba03-c1f5-452c-a155-915b524d37e5_2019-05-31"
  billing_account_type             = "mca"
  billing_profile_name             = "AOUS-EPO7-BG7-PGB"
  azure_private_endpoint_subnet_id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/core-state-rg/providers/Microsoft.Network/virtualNetworks/core-vnet/subnets/private-endpoints"
}


provider "azurerm" {
  features {}
  resource_provider_registrations = "extended"
  storage_use_azuread             = true
}

provider "github" {}

# The following plan-only runs only exercise variable validation (which is evaluated
# before any provider/data source calls), so they don't need real EA/MPA billing
# accounts to test against, and never touch live Azure.

run "mca_requires_billing_profile_name" {
  command = plan

  variables {
    billing_profile_name = ""
  }

  expect_failures = [
    var.billing_profile_name,
  ]
}

run "enrollment_requires_billing_scope" {
  command = plan

  variables {
    billing_account_type = "enrollment"
    billing_scope        = ""
  }

  expect_failures = [
    var.billing_scope,
  ]
}

run "mpa_requires_customer_name" {
  command = plan

  variables {
    billing_account_type = "mpa"
    customer_name        = ""
  }

  expect_failures = [
    var.customer_name,
  ]
}

# Full end-to-end apply against live Azure/GitHub -- commented out for now since it
# consumes real trial credit and requires an upgraded (non-FreeTrial) Azure plan.
# Re-enable once ready to burn through the $200 credit, or once the account is upgraded.
#
# run "setup_repo" {
#   command = apply
#
#   assert {
#     condition     = data.azurerm_billing_mca_account_scope.terraform[0].id == "/providers/Microsoft.Billing/billingAccounts/9c0340d0-7ff4-570b-8e73-a08aaa319c34:35f0ba03-c1f5-452c-a155-915b524d37e5_2019-05-31/billingProfiles/AOUS-EPO7-BG7-PGB/invoiceSections/4a83b80c-d5ec-4259-bc7b-9cb0e4860000"
#     error_message = "Azure billing MCA account scope is incorrect."
#   }
#   assert {
#     condition     = github_actions_secret.azure_subscription_id[0].created_at != ""
#     error_message = "GitHub Actions secret for ARM_SUBSCRIPTION_ID was not created."
#   }
# }
#
# run "post_setup" {
#   module {
#     source = "./tests/post_setup"
#   }
# }


