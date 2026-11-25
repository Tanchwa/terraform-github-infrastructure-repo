<!-- BEGIN_TF_DOCS -->
# Cloud Landingzone Github Repository

- [Purpose](#purpose)
- [Details](#details)
- [Usage](#usage)
- [Gotchas](#gotchas)
- [Inputs](#inputs)
- [Outputs](#outputs)
- [Contributing](#contributing)

## Purpose
Deploys an infrastructure github repository and the cloud infrastructure to support it. This is a 1 to 1 relationship, meaning that each repository will have its own set of cloud resources.
## Details
The repository will be set up to use GitHub actions for deploying terraform infrastructure, and will include a basic workflow file. The upstream source of these can be found in the [infrastructure-deployment-template](https://github.com/Tanchwa/infrastructure-deployment-template) repository. In addition, this module will automatically create the necessary secrets and resources for OIDC connect for passwordless authentication to the cloud provider.
The module will create an authentication context specific to the cloud provider specified (usually a service principal/account) and will grant full read, write, and delete permissions to the resources within a specific context, such as an Account in AWS, Project in GCP, or Subscription in Azure. These resources were chosen due to their ability to be used to easily assign billing accounts, and to get out of the way of the user. A default resource "container" (Resource Group in Azure, Project/ VPC in GCP, or VPC in AWS) will also be created.
Finally, the module will also create a blob storage for the backend terraform state files. This will live in a "meta" context in the cloud provider, meaning that it will not be tied to a specific repository, but rather to the organization or account as a whole. The service context created will be able to create and read the files, but will not be able to delete the storage account or container.
## Usage
These module should be consumed from a central repository used to manage the landingzone infrastructure. It is not intended to be used as a standalone module, but rather as part of a larger infrastructure deployment process. The central repository should include things like management groups, policies, and other resources that are necessary for the overall infrastructure management.
## Gotchas
### Auto-created Variable Naming
Variables related to the authentication of the cloud provider will be pre-pended with their ususal prefix for that context. For example, ARM\_, AWS\_, GOOGLE\_. Additionally, any non ARM\\_ variables for Azure will be pre-pended with AZ\\_, such as AZ\\_STATE\\_STORE.

Any OTHER variables specific to the repo instance will NOT be pre-pended. Some examples of these variables are: PROJECT\_ID (GCP) and RESOURCE\_GROUP\_NAME (Azure).

## Required Inputs

The following input variables are required:

### <a name="input_location"></a> [location](#input\_location)

Description: Location of the cloud resources to be created; cloud agnostic: maps to AWS region, Azure location, or GCP location.

Type: `string`

### <a name="input_repository_name"></a> [repository\_name](#input\_repository\_name)

Description: The name of the repository to create.

Type: `string`

### <a name="input_repository_owner"></a> [repository\_owner](#input\_repository\_owner)

Description: The owner of the repository.

Type: `string`

## Optional Inputs

The following input variables are optional (have default values):

### <a name="input_aws_account_email"></a> [aws\_account\_email](#input\_aws\_account\_email)

Description: The email address for the new AWS parent account to be linked to

Type: `string`

Default: `""`

### <a name="input_aws_close_account_on_deletion"></a> [aws\_close\_account\_on\_deletion](#input\_aws\_close\_account\_on\_deletion)

Description: Whether `terraform destroy` should actually request closure of the AWS Organizations member account (subject to AWS's own restrictions, e.g. accounts can't be closed within ~7 days of creation). When false, destroy only removes the account from Terraform state and it must be closed manually. Only applicable to AWS.

Type: `bool`

Default: `false`

### <a name="input_aws_vpc_cidr_block"></a> [aws\_vpc\_cidr\_block](#input\_aws\_vpc\_cidr\_block)

Description: The CIDR block for the AWS VPC.

Type: `string`

Default: `""`

### <a name="input_azure_log_analytics_workspace_id"></a> [azure\_log\_analytics\_workspace\_id](#input\_azure\_log\_analytics\_workspace\_id)

Description: Optional existing Log Analytics Workspace ID to additionally stream the state storage account's blob service diagnostic logs to. If left blank, logs are only sent to the storage account itself (self-logging, mirroring the AWS S3 access-logging setup) -- wire up a Log Analytics Workspace later by setting this and re-applying, or use the azure\_terraform\_state\_blob\_service\_diagnostic\_target\_id output to attach one manually.

Type: `string`

Default: `""`

### <a name="input_azure_private_dns_zone_id_blob"></a> [azure\_private\_dns\_zone\_id\_blob](#input\_azure\_private\_dns\_zone\_id\_blob)

Description: Optional existing privatelink.blob.core.windows.net Private DNS Zone ID to register the state storage account's private endpoint in. If left blank, the private endpoint is created without DNS integration -- wire up name resolution separately (e.g. a centrally managed private DNS zone).

Type: `string`

Default: `""`

### <a name="input_azure_private_dns_zone_id_keyvault"></a> [azure\_private\_dns\_zone\_id\_keyvault](#input\_azure\_private\_dns\_zone\_id\_keyvault)

Description: Optional existing privatelink.vaultcore.azure.net Private DNS Zone ID to register the state Key Vault's private endpoint in. If left blank, the private endpoint is created without DNS integration -- wire up name resolution separately (e.g. a centrally managed private DNS zone).

Type: `string`

Default: `""`

### <a name="input_azure_private_endpoint_subnet_id"></a> [azure\_private\_endpoint\_subnet\_id](#input\_azure\_private\_endpoint\_subnet\_id)

Description: Subnet ID the private endpoints for the Terraform state storage account and Key Vault are attached to. Required when cloud\_provider = "azure", since both have public network access disabled.

Type: `string`

Default: `""`

### <a name="input_billing_account_name"></a> [billing\_account\_name](#input\_billing\_account\_name)

Description: Azure Billing Account name, e.g. "<guid>:<guid>\_2019-05-31" for MCA, or an enrollment/partner billing account name for other types (see the `id` of `az billing account list`). Only applicable to Azure.

Type: `string`

Default: `""`

### <a name="input_billing_account_type"></a> [billing\_account\_type](#input\_billing\_account\_type)

Description: Which Azure billing scope shape to use when creating the subscription: "mca" (Microsoft Customer Agreement), "enrollment" (Enterprise Agreement enrollment account), or "mpa" (Microsoft Partner Agreement). Only applicable to Azure.

Type: `string`

Default: `"mca"`

### <a name="input_billing_profile_name"></a> [billing\_profile\_name](#input\_billing\_profile\_name)

Description: Azure Billing Profile name under the billing account (see `az billing profile list`). Only applicable when cloud\_provider = "azure" and billing\_account\_type = "mca".

Type: `string`

Default: `""`

### <a name="input_billing_scope"></a> [billing\_scope](#input\_billing\_scope)

Description: Billing Scope Name for the cloud provider. Not applicable to AWS, instead use the AWS parent organization ID. (see https://docs.aws.amazon.com/awsaccountbilling/latest/aboutv2/consolidated-billing.html) For Azure, this is the MCA invoice section name or EA enrollment account name, depending on billing\_account\_type; not applicable when billing\_account\_type = "mpa". For GCP, this is the billing account display name.

Type: `string`

Default: `""`

### <a name="input_cloud_provider"></a> [cloud\_provider](#input\_cloud\_provider)

Description: The cloud provider to use for the infrastructure.

Type: `string`

Default: `"aws"`

### <a name="input_customer_name"></a> [customer\_name](#input\_customer\_name)

Description: Azure MPA Customer name/ID under the Partner billing account (see `az billing customer list`). Only applicable when cloud\_provider = "azure" and billing\_account\_type = "mpa".

Type: `string`

Default: `""`

### <a name="input_environments"></a> [environments](#input\_environments)

Description: In Preview. A list of environemnts to add to the repo and cloud environment. A new Environment per list item will be created in the repository, as well as a cloud workspace for each.

Type: `list(string)`

Default:

```json
[
  "dev"
]
```

### <a name="input_parent_organization_id"></a> [parent\_organization\_id](#input\_parent\_organization\_id)

Description: The AWS parent Organization or OU, or GCP Organization ID to link the new account or Project to

Type: `string`

Default: `""`

### <a name="input_resource_group_name"></a> [resource\_group\_name](#input\_resource\_group\_name)

Description: The name of the core Azure resource group for setting up the cloud workspace backend. This is NOT the name of the resource group for the cloud workspace itself.

Type: `string`

Default: `"core-resource-group"`

### <a name="input_tags"></a> [tags](#input\_tags)

Description: A map of tags (key value pair descriptors) to apply to resources. In GCP, these are known as labels

Type: `map(string)`

Default:

```json
{
  "ManagedBy": "Terraform"
}
```

### <a name="input_template_sync_github_app_id"></a> [template\_sync\_github\_app\_id](#input\_template\_sync\_github\_app\_id)

Description: App ID of the GitHub App used by the template\_sync workflow (see infrastructure-deployment-template/.github/workflows/template\_sync.yaml) to authenticate across the template repo and this child repo. Leave blank to skip wiring up the secret (the workflow will fail until it's set).

Type: `string`

Default: `""`

### <a name="input_template_sync_github_app_private_key"></a> [template\_sync\_github\_app\_private\_key](#input\_template\_sync\_github\_app\_private\_key)

Description: PEM private key of the GitHub App used by the template\_sync workflow. Leave blank to skip wiring up the secret (the workflow will fail until it's set).

Type: `string`

Default: `""`

## Outputs

The following outputs are exported:

### <a name="output_aws_account_id"></a> [aws\_account\_id](#output\_aws\_account\_id)

Description: The account ID of the cloud provider account created by this module. Null unless cloud\_provider = "aws".

### <a name="output_aws_terraform_state_sns_topic_arn"></a> [aws\_terraform\_state\_sns\_topic\_arn](#output\_aws\_terraform\_state\_sns\_topic\_arn)

Description: ARN of the SNS topic that receives S3 event notifications for the Terraform state bucket. Null unless cloud\_provider = "aws".

### <a name="output_azure_terraform_state_blob_service_diagnostic_target_id"></a> [azure\_terraform\_state\_blob\_service\_diagnostic\_target\_id](#output\_azure\_terraform\_state\_blob\_service\_diagnostic\_target\_id)

Description: Sub-resource ID for the state storage account's blob service -- the target\_resource\_id needed to attach another diagnostic setting (e.g. a Log Analytics Workspace) to it later. Null unless cloud\_provider = "azure".

### <a name="output_azure_terraform_state_storage_account_id"></a> [azure\_terraform\_state\_storage\_account\_id](#output\_azure\_terraform\_state\_storage\_account\_id)

Description: Resource ID of the Terraform state storage account. Null unless cloud\_provider = "azure".

## Contributing
### Pre-Commit Hooks

Git hook scripts are useful for identifying simple issues before submisston to code reviev. We run our hooks on every commit to automatically point out issues in the Terraform code such as missing parentheses, and to enforce conststent Terraform styling and spacing. By pointing these issues out before code review, this allows a code reviewer to focus on the architecture of a change while not wasting time with trivial style nitpicks.

## Pre-Commtt Installation
Before you can run hooks, you need to have the pre-commit package manager installed.

Using pip:
```
pip install pre-commit
```

Non-administrative installation:

to upgrade: run again, to uninstall: pass uninstall to python
does not work on platrorms wlthout symlink support (windows)

```
curl https://pre-commit.com/install-local.py | python
```

Afterward, `pre-commit --version` should show you what version you're using.

## Installing Other Pre-Commit tools
detect-secrets, terraform-docs, and checkov all need to be installed separately.
terraform-docs can be installed via your package manager of choice, for example via brew:

```
brew install terraform-docs
```

detect-secrets and checkov can be installed via pip:

```
python3 -m pip install detect-secrets
python3 -m pip install checkov
```

To set up detect-secrets, run the following command to initialize the baseline file:

```
detect-secrets scan > .secrets.baseline
```

## Pre-Commit Configuration
The pre-commit config for this repo may be found in`.pre-commtt-config.yaml`, the contents of which takes the following form:

Run `pre-commit install` to set up the git hook scripts:

```
$ pre-commit install
pre-commit installed at .git/hooks/pre-commit
```

Now pre-commit will run automatically on git commit
<!-- END_TF_DOCS -->


####this README is auto-generated by [terraform-docs](https://terraform-docs.io)