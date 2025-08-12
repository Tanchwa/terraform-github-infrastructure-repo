resource "github_repository" "infrastructure-deployment" {
  name        = var.repository_name
  description = "Infrastructure repository for ${var.repository_name}"
  visibility  = "private"

  template {
    owner                = "Tanchwa"
    repository           = "infrastructure-deployment-template"
    include_all_branches = true
  }
}
