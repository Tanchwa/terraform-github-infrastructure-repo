data "google_billing_account" "terraform" {
  count        = var.cloud_provider == "google" ? 1 : 0
  display_name = var.billing_scope
}

resource "google_project" "terraform" {
  count           = var.cloud_provider == "google" ? 1 : 0
  name            = local.google_project_name
  project_id      = local.google_project_id
  billing_account = data.google_billing_account.terraform[0].name
  org_id          = try(var.parent_organization_id, null)

  labels = var.tags
}

resource "google_project_iam_member" "terraform" {
  count   = var.cloud_provider == "google" ? 1 : 0
  project = google_project.terraform[0].project_id
  role    = "roles/editor"
  member  = "serviceAccount:${google_service_account.terraform[0].email}"
}

resource "github_actions_secret" "google_project_id" {
  count           = var.cloud_provider == "google" ? 1 : 0
  repository      = github_repository.infrastructure-deployment.name
  secret_name     = "PROJECT_ID"
  plaintext_value = google_project.terraform[0].project_id
}
