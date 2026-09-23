data "google_billing_account" "terraform" {
  count        = var.cloud_provider == "gcp" ? 1 : 0
  display_name = var.billing_scope

}

resource "google_project" "terraform" {
  count           = var.cloud_provider == "gcp" ? 1 : 0
  name            = local.google_project_name
  project_id      = local.google_project_id
  billing_account = data.google_billing_account.terraform[0].id
  org_id          = try(var.parent_organization_id, null)

  labels = { for k, v in var.tags : lower(k) => v }
}

resource "google_project_iam_audit_config" "terraform" {
  count   = var.cloud_provider == "gcp" ? 1 : 0
  project = google_project.terraform[0].project_id
  service = "allServices"

  audit_log_config {
    log_type = "ADMIN_READ"
  }
  audit_log_config {
    log_type = "DATA_READ"
  }
  audit_log_config {
    log_type = "DATA_WRITE"
  }
}

resource "google_project_iam_member" "terraform" {
  count   = var.cloud_provider == "gcp" ? 1 : 0
  project = google_project.terraform[0].project_id
  role    = "roles/editor"
  member  = "serviceAccount:${google_service_account.terraform[0].email}"
}

resource "github_actions_secret" "google_project_id" {
  count           = var.cloud_provider == "gcp" ? 1 : 0
  repository      = github_repository.infrastructure-deployment.name
  secret_name     = "PROJECT_ID"
  plaintext_value = google_project.terraform[0].project_id
}
