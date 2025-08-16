data "google_billing_account" "terraform" {
  count        = var.cloud_provider == "google" ? 1 : 0
  display_name = var.billing_account
}

resource "google_project" "terraform" {
  count           = var.cloud_provider == "google" ? 1 : 0
  name            = local.google_project_name
  project_id      = local.google_project_id
  billing_account = data.google_billing_account.terraform[0].name
  #TODO add default org_id or folder_id

  labels = var.tags
}
