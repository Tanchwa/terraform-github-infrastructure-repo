locals {
  org_role_name_cleaned = strcontains(var.repository_name, "-") ? title(replace(var.repository_name, "-", "")) : strcontains(var.repository_name, "_") ? title(replace(var.repository_name, "_", "")) : strcontains(var.repository_name, " ") ? title(replace(var.repository_name, " ", "")) : title(var.repository_name)
}

resource "aws_organizations_account" "terraform" {
  count     = var.cloud_provider == "aws" ? 1 : 0
  name      = format("%s Account", upper(var.repository_name))
  email     = var.aws_account_email
  parent_id = try(var.parent_organization_id, null)
  role_name = format("%sTerraformRole", local.org_role_name_cleaned)

  tags = var.tags
}
