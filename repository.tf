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

resource "github_repository_environment" "main" {
  for_each = toset(var.environments)

  repository  = github_repository.infrastructure-deployment.name
  environment = each.value

  dynamic "deployment_branch_policy" {
    for_each = each.value == "prod" ? [1] : []
    content {
      custom_branch_policies = false
      protected_branches     = true
    }
  }
}

resource "github_branch_protection" "main" {
  count = github_repository.infrastructure-deployment.visibility != "private" ? 1 : 0
  #|| account is pro

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
  content = templatefile("${path.module}/templates/providers.tf.tpl", {
    cloud_provider = var.cloud_provider,
  })
  commit_message = "Add providers configuration for ${var.cloud_provider}"
}

# The template repository ships these workflow files with generic EXAMPLE_SECRET
# placeholders (see infrastructure-deployment-template's own copies). Rendering them
# here per cloud_provider overwrites the template-copied versions with the real
# secret names this module already wires up via github_actions_secret, the same
# way providers.tf is specialized above.
resource "github_repository_file" "pull_request_workflow" {
  repository = github_repository.infrastructure-deployment.name
  file       = ".github/workflows/pull_request.yaml"
  content = templatefile("${path.module}/templates/pull_request.yaml.tpl", {
    cloud_provider = var.cloud_provider,
  })
  commit_message      = "Wire up ${var.cloud_provider} secrets for pull_request workflow"
  overwrite_on_create = true
}

resource "github_repository_file" "terraform_apply_workflow" {
  repository = github_repository.infrastructure-deployment.name
  file       = ".github/workflows/terraform_apply.yaml"
  content = templatefile("${path.module}/templates/terraform_apply.yaml.tpl", {
    cloud_provider = var.cloud_provider,
  })
  commit_message      = "Wire up ${var.cloud_provider} secrets for terraform_apply workflow"
  overwrite_on_create = true
}

resource "github_repository_file" "forget_me_not_destroy_workflow" {
  repository = github_repository.infrastructure-deployment.name
  file       = ".github/workflows/forget_me_not_destroy.yaml"
  content = templatefile("${path.module}/templates/forget_me_not_destroy.yaml.tpl", {
    cloud_provider = var.cloud_provider,
  })
  commit_message      = "Wire up ${var.cloud_provider} secrets for forget_me_not_destroy workflow (stays commented out)"
  overwrite_on_create = true
}
