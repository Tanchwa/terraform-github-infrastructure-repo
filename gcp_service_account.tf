resource "google_service_account" "terraform" {
  count      = var.cloud_provider == "google" ? 1 : 0
  account_id = local.google_service_account_id

  project = google_project.terraform[0].project_id
}

resource "google_project_iam_member" "terraform" {
  count   = var.cloud_provider == "google" ? 1 : 0
  project = google_project.terraform[0].project_id
  role    = "roles/editor"
  member  = "serviceAccount:${google_service_account.terraform[0].email}"
}

resource "google_iam_workload_identity_pool" "terraform" {
  count                     = var.cloud_provider == "google" ? 1 : 0
  workload_identity_pool_id = local.workload_identity_pool_id
}

resource "google_iam_workload_identity_pool_provider" "terraform" {
  count = var.cloud_provider == "google" ? 1 : 0

  workload_identity_pool_provider_id = local.workload_identity_pool_provider_id
  display_name                       = format("GitHub Actions for %s", google_iam_workload_identity_pool.terraform[0].workload_identity_pool_id)

  workload_identity_pool_id = google_iam_workload_identity_pool.terraform[0].id

  oidc {
    issuer_uri = "https://token.actions.githubusercontent.com"
  }
}

resource "github_actions_secret" "google_service_account_email" {
  count           = var.cloud_provider == "google" ? 1 : 0
  repository      = github_repository.infrastructure-deployment.name
  secret_name     = "GOOGLE_SERVICE_ACCOUNT_EMAIL"
  plaintext_value = google_service_account.terraform[0].email
}

resource "github_actions_secret" "google_workload_identity_provider" {
  count           = var.cloud_provider == "google" ? 1 : 0
  repository      = github_repository.infrastructure-deployment.name
  secret_name     = "GOOGLE_WORKLOAD_IDENTITY_PROVIDER"
  plaintext_value = gooele_iam_workload_identity_pool.terraform[0].id
}
