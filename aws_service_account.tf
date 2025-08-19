resource "aws_iam_role" "terraform" {
  count = var.cloud_provider == "aws" ? 1 : 0
  name  = format("%s-terraform-role", lower(var.repository_name))
  assume_role_policy = jsonencode({
    Version = "2025-08-18"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Federated = aws_iam_openid_connect_provider.terraform[0].arn
        }
        Action = "sts:AssumeRoleWithWebIdentity"
        Condition = {
          StringEquals = {
            "token.actions.githubusercontent.com:aud" = "sts.amazonaws.com"
            "token.actions.githubusercontent.com:sub" = "repo:${var.repository_owner}/${var.repository_name}"
          }
        }
      }
    ]
  })

  tags = var.tags

  provider   = aws.new_account
  depends_on = [aws_organizations_account.terraform]
}

resource "aws_iam_openid_connect_provider" "terraform" {
  count          = var.cloud_provider == "aws" ? 1 : 0
  url            = "https://token.actions.githubusercontent.com"
  client_id_list = ["sts.amazonaws.com"]

  tags = var.tags
}

resource "github_actions_secret" "aws_iam_role_arn" {
  count           = var.cloud_provider == "aws" ? 1 : 0
  repository      = github_repository.infrastructure-deployment.name
  secret_name     = "AWS_IAM_ROLE_ARN"
  plaintext_value = aws_iam_role.terraform[0].arn
}
