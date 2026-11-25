output "aws_terraform_state_sns_topic_arn" {
  description = "ARN of the SNS topic that receives S3 event notifications for the Terraform state bucket. Null unless cloud_provider = \"aws\"."
  value       = try(aws_sns_topic.terraform_state[0].arn, null)
}

output "azure_terraform_state_storage_account_id" {
  description = "Resource ID of the Terraform state storage account. Null unless cloud_provider = \"azure\"."
  value       = try(azurerm_storage_account.terraform_state[0].id, null)
}

output "azure_terraform_state_blob_service_diagnostic_target_id" {
  description = "Sub-resource ID for the state storage account's blob service -- the target_resource_id needed to attach another diagnostic setting (e.g. a Log Analytics Workspace) to it later. Null unless cloud_provider = \"azure\"."
  value       = try("${azurerm_storage_account.terraform_state[0].id}/blobServices/default", null)
}

output "aws_account_id" {
  description = "The account ID of the cloud provider account created by this module. Null unless cloud_provider = \"aws\"."
  value       = try(aws_organizations_account.terraform[0].id, null)
}
