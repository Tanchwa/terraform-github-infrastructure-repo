variables {
  cloud_provider = "aws"

  repository_name        = "example-infra-repo"
  repository_owner       = "Tanchwa"
  location               = "us-east-1"
  aws_account_email      = "aws+example-infra-repo@example.com"
  parent_organization_id = "ou-example-00000000"
}

provider "aws" {}

# azurerm's provider schema mandates a top-level `features {}` block even when unused
# (count = 0 everywhere here) -- aws/google have no such requirement, so they don't need
# an equivalent stub.
provider "azurerm" {
  features {}
}

provider "github" {}

# This plan-only run only exercises variable validation (which is evaluated before any
# provider/data source calls), so it never touches live AWS.
run "aws_requires_account_email" {
  command = plan

  variables {
    aws_account_email = ""
  }

  expect_failures = [
    var.aws_account_email,
  ]
}

# Full end-to-end apply against live AWS/GitHub -- commented out for now, same reasoning
# as tests/azure.tftest.hcl: this creates a real AWS Organizations member account plus
# real IAM/S3/SNS resources against whatever AWS credentials are configured. Replace the
# placeholder aws_account_email/parent_organization_id above with real values for your
# AWS Organization before uncommenting.
#
# run "setup_repo" {
#   command = apply
#
#   assert {
#     condition     = aws_organizations_account.terraform[0].id != ""
#     error_message = "AWS Organizations account was not created."
#   }
#   assert {
#     condition     = github_actions_secret.aws_iam_role_arn[0].created_at != ""
#     error_message = "GitHub Actions secret for AWS_IAM_ROLE_ARN was not created."
#   }
#   assert {
#     condition     = github_actions_secret.aws_target_account_role_arn[0].created_at != ""
#     error_message = "GitHub Actions secret for AWS_TARGET_ACCOUNT_ROLE_ARN was not created."
#   }
# }
#
# run "post_setup" {
#   variables {
#     cloud_provider = "aws"
#   }
#
#   module {
#     source = "./tests/post_setup"
#   }
# }
