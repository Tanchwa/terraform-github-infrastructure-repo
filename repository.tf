resource "github_repository" "infrastructure-deployment" {
  name        = var.repository_name
  description = "Infrastructure repository for ${var.repository_name}"
  visibility  = "private"

  template {
    owner                = var.repository_owner
    repository           = "infrastructure-deployment-template"
    include_all_branches = true
  }

  vulnerability_alerts = true
}

resource "github_branch_protection" "main" {
  repository_id = github_repository.infrastructure-deployment.node_id

  pattern                 = "main"
  enforce_admins          = true
  required_linear_history = true
  require_signed_commits  = true

  required_pull_request_reviews {
    dismiss_stale_reviews           = true
    require_last_push_approval      = true
    required_approving_review_count = 2
  }

  # use this to require successful test pipeline runs before allowing merges
  #required_status_checks {
  #  strict   = true
  #  contexts = [""]
  #}
}

resource "github_repository_file" "providers" {
  repository = github_repository.infrastructure-deployment.name
  file       = "providers.tf"
  content = templatefile("templates/providers.tf.tpl", {
    cloud_provider = var.cloud_provider,
  })
  commit_message = "Add providers configuration for ${var.cloud_provider}"
}
