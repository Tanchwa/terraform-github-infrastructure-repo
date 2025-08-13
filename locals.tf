locals {
  azure_resource_group_name          = format("%s-RG", upper(var.repository_name))
  azure_service_principal_name       = format("sp-%s-terraform", var.repository_name)
  google_project_name                = format("%s Project", upper(var.repository_name))
  google_project_id                  = format("%s-project", lower(var.repository_name))
  google_service_account_id          = format("sa-%s-terraform", lower(var.repository_name))
  workload_identity_pool_id          = format("id-pool-%s-terraform", lower(var.repository_name))
  workload_identity_pool_provider_id = format("id-pool-provider-%s-terraform", lower(var.repository_name))
}
