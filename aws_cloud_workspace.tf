resource "aws_organizations_account" "terraform" {
  count     = var.cloud_provider == "aws" ? 1 : 0
  name      = format("%s Account", upper(var.repository_name))
  email     = var.aws_account_email
  parent_id = try(var.parent_organization_id, null)
  role_name = lower(format("%sTerraformRole", join("", splitwords(title(var.repository_name)))))

  tags = var.tags
}

provider "aws" {
  alias  = "new_account"
  region = var.location
  assume_role {
    role_arn     = "arn:aws:iam::${aws_organizations_account.terraform[0].id}:role/${aws_organizations_account.terraform[0].role_name}"
    session_name = "TerraformProvisioningSession"
  }
}

resource "aws_vpc" "terraform" {
  count = var.cloud_provider == "aws" ? 1 : 0

  cidr_block = var.aws_vpc_cidr_block

  tags = var.tags

  provider   = aws.new_account
  depends_on = [aws_organizations_account.terraform]
}
