variables {
  cloud_provider = "gcp"

  repository_name        = "example-infra-repo"
  repository_owner       = "Tanchwa"
  location               = "us-east1"
  billing_scope          = "My Billing Account"
  parent_organization_id = "123456789012"
}

provider "google" {}

# azurerm's provider schema mandates a top-level `features {}` block even when unused
# (count = 0 everywhere here) -- aws/google have no such requirement, so they don't need
# an equivalent stub.
provider "azurerm" {
  features {}
}

provider "github" {}

# This plan-only run only exercises variable validation (which is evaluated before any
# provider/data source calls), so it never touches live GCP.
run "gcp_requires_billing_scope" {
  command = plan

  variables {
    billing_scope = ""
  }

  expect_failures = [
    var.billing_scope,
  ]
}

# Full end-to-end apply against live GCP/GitHub -- commented out for now, same reasoning
# as tests/azure.tftest.hcl: this creates a real GCP project plus real IAM/service-account/
# workload-identity resources against whatever GCP credentials are configured. Replace the
# placeholder billing_scope/parent_organization_id above with your real billing account
# display name and GCP Organization ID before uncommenting.
#
# run "setup_repo" {
#   command = apply
#
#   assert {
#     condition     = google_project.terraform[0].project_id == local.google_project_id
#     error_message = "GCP project ID does not match the expected computed value."
#   }
#   assert {
#     condition     = github_actions_secret.google_project_id[0].created_at != ""
#     error_message = "GitHub Actions secret for PROJECT_ID was not created."
#   }
#   assert {
#     condition     = github_actions_secret.google_service_account_email[0].created_at != ""
#     error_message = "GitHub Actions secret for GOOGLE_SERVICE_ACCOUNT_EMAIL was not created."
#   }
#   assert {
#     condition     = github_actions_secret.google_workload_identity_provider[0].created_at != ""
#     error_message = "GitHub Actions secret for GOOGLE_WORKLOAD_IDENTITY_PROVIDER was not created."
#   }
# }
#
# run "post_setup" {
#   variables {
#     cloud_provider = "google"
#   }
#
#   module {
#     source = "./tests/post_setup"
#   }
# }
