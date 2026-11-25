resource "github_actions_secret" "template_sync_github_app_id" {
  count           = var.template_sync_github_app_id != "" ? 1 : 0
  repository      = github_repository.infrastructure-deployment.name
  secret_name     = "TEMPLATE_SYNC_APP_ID" # pragma: allowlist secret
  plaintext_value = var.template_sync_github_app_id
}

resource "github_actions_secret" "template_sync_github_app_private_key" {
  count           = var.template_sync_github_app_private_key != "" ? 1 : 0
  repository      = github_repository.infrastructure-deployment.name
  secret_name     = "TEMPLATE_SYNC_APP_PRIVATE_KEY" # pragma: allowlist secret
  plaintext_value = var.template_sync_github_app_private_key
}
