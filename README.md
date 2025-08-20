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
The repository will be set up to use GitHub actions for deploying terraform infrastructure, and will include a basic workflow file. The upstream source of these can be found in the [infrastructure-deployment-template](https://github.Tanchwa/infrastructure-deployment-template)repository. In addition, this module will automatically create the necessary secrets and resources for OIDC connect for passwordless authentication to the cloud provider.
The module will create an authentication context specific to the cloud provider specified (usually a service principal/account) and will grant full read, write, and delete permissions to the resources within a specific context, such as an Account in AWS, Project in GCP, or Subscription in Azure. These resources were chosen due to their ability to be used to easily assign billing accounts, and to get out of the way of the user. A default resource "container" (Resource Group in Azure, Project/ VPC in GCP, or VPC in AWS) will also be created.
Finally, the module will also create a blob storage for the backend terraform state files. This will live in a "meta" context in the cloud provider, meaning that it will not be tied to a specific repository, but rather to the organization or account as a whole. The service context created will be able to create and read the files, but will not be able to delete the storage account or container.
## Usage
These module should be consumed from a central repository used to manage the landingzone infrastructure. It is not intended to be used as a standalone module, but rather as part of a larger infrastructure deployment process. The central repository should include things like management groups, policies, and other resources that are necessary for the overall infrastructure management.
## Gotchas
### Auto-created Variable Naming
Variables related to the authentication of the cloud provider will be pre-pended with their ususal prefix for that context. For example, ARM\_, AWS\_, GOOGLE\_. Any OTHER variables specific to the provider will NOT be pre-pended. Some examples of these variables are: PROJECT\_ID (GCP) and RESOURCE\_GROUP\_NAME (Azure).

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_location"></a> [location](#input\_location) | Location of the cloud resources to be created; cloud agnostic: maps to AWS region, Azure location, or GCP location. | `string` | n/a | yes |
| <a name="input_repository_name"></a> [repository\_name](#input\_repository\_name) | The name of the repository to create. | `string` | n/a | yes |
| <a name="input_repository_owner"></a> [repository\_owner](#input\_repository\_owner) | The owner of the repository. | `string` | n/a | yes |
| <a name="input_aws_account_email"></a> [aws\_account\_email](#input\_aws\_account\_email) | The email address for the new AWS parent account to be linked to | `string` | `""` | no |
| <a name="input_aws_vpc_cidr_block"></a> [aws\_vpc\_cidr\_block](#input\_aws\_vpc\_cidr\_block) | The CIDR block for the AWS VPC. | `string` | `""` | no |
| <a name="input_billing_account"></a> [billing\_account](#input\_billing\_account) | Billing account Display Name for the cloud provider. Not applicable to AWS, instead use the AWS parent organization ID. (see https://docs.aws.amazon.com/awsaccountbilling/latest/aboutv2/consolidated-billing.html) | `string` | `""` | no |
| <a name="input_cloud_provider"></a> [cloud\_provider](#input\_cloud\_provider) | The cloud provider to use for the infrastructure. | `string` | `"aws"` | no |
| <a name="input_parent_organization_id"></a> [parent\_organization\_id](#input\_parent\_organization\_id) | The AWS parent Organization or OU, or GCP Organization ID to link the new account or Project to | `string` | `""` | no |
| <a name="input_resource_group_name"></a> [resource\_group\_name](#input\_resource\_group\_name) | The name of the core Azure resource group for setting up the cloud workspace backend. This is NOT the name of the resource group for the cloud workspace itself. | `string` | `"core-resource-group"` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | A map of tags (key value pair descriptors) to apply to resources. In GCP, these are known as labels | `map(string)` | <pre>{<br/>  "ManagedBy": "Terraform"<br/>}</pre> | no |

## Outputs

No outputs.

## Contributing
### Pre-Commit Hooks

Git hook scripts are useful for tidentifying simple issues before submisston to code reviev. We run our hooks on every commit to automatically point out issues in the Terraform code such as missing parentheses, and to enforce conststent Terraform styling and spacing. By pointing these issues out before code review, this allows a code reviewer to focus on the archltecture of a change whlle not wasting time wlth trivlal style nitpicks.

## Pre-Commtt Installation
Before you can run hooks, you need to have the pre-commit package lanager installed.

Using plp:
```
pip install pre-commit
```

Non-administrative installation:

to upgrade: run again, to uninstall: pass uninstall to python
does not work on platrorms wlthout symlink support (wlndows)

```
curl https://pre-commit.com/install-local.py | python
```

Afterward, `pre-commit --version` should show you what version you're using.

## Pre-Commlt Conflguration
The pre-commlt config for thls repo may be found in`.pre-commtt-config.yaml`, the contents of which takes the following form:

Run `pre-commit install` to set up the git hook scripts:

```
$ pre-commit install
pre-commit installed at .git/hooks/pre-commit
```

Now pre-commit will run automatically on git commit
<!-- END_TF_DOCS -->


####this README is auto-generated by [terraform-docs](https://terraform-docs.io)_