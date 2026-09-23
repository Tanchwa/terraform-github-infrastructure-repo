locals {
  azure_subscription_alias          = format("sub-%s-terraform", lower(var.repository_name))
  azure_user_assigned_identity_name = format("id-%s-terraform", var.repository_name)
  google_project_name               = format("%s Project", upper(var.repository_name))

  # GCP caps these identifiers at 30-32 chars, so repository_name alone can easily overflow
  # them once a fixed prefix/suffix is added. Truncate the sanitized name and disambiguate
  # with a short deterministic hash of the full repository_name instead of the raw name.
  repository_name_gcp_safe  = lower(replace(replace(var.repository_name, "_", "-"), " ", "-"))
  repository_name_gcp_hash  = substr(sha1(var.repository_name), 0, 6)
  repository_name_gcp_trunc = substr(local.repository_name_gcp_safe, 0, 12)

  google_project_id                  = "proj-${local.repository_name_gcp_trunc}-${local.repository_name_gcp_hash}"
  google_service_account_id          = "sa-${local.repository_name_gcp_trunc}-${local.repository_name_gcp_hash}"
  workload_identity_pool_id          = "pool-${local.repository_name_gcp_trunc}-${local.repository_name_gcp_hash}"
  workload_identity_pool_provider_id = "provider-${local.repository_name_gcp_trunc}-${local.repository_name_gcp_hash}"

  # Key Vault names are globally unique across all of Azure and capped at 24 chars, so
  # apply the same truncate-and-hash treatment used for the GCP identifiers above.
  repository_name_azure_safe  = lower(replace(replace(var.repository_name, "_", "-"), " ", "-"))
  repository_name_azure_hash  = substr(sha1(var.repository_name), 0, 6)
  repository_name_azure_trunc = substr(local.repository_name_azure_safe, 0, 12)

  azure_key_vault_name = "kv-${local.repository_name_azure_trunc}-${local.repository_name_azure_hash}"

  aws_target_account_role_arn = try(
    "arn:aws:iam::${aws_organizations_account.terraform[0].id}:role/${aws_organizations_account.terraform[0].role_name}",
    null
  )
}
