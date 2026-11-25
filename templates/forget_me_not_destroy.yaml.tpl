#on:
#  schedule:
#    - cron: '0 0 * * 0'
#
#jobs:
#  destroy:
#    if: github.repository != 'Tanchwa/infrastructure-deployment-template'
#    name: 'Terraform Destroy'
#    uses: Tanchwa/workflows-terraform-deployment/.github/workflows/terraform_destroy.yaml@main
#    secrets: #`pragma: allowlist secret`
#      INFRACOST_API_KEY: $${{ secrets.INFRACOST_API_KEY }} #`pragma: allowlist secret`
%{ if cloud_provider == "aws" ~}
#      AWS_IAM_ROLE_ARN: $${{ secrets.AWS_IAM_ROLE_ARN }} #`pragma: allowlist secret`
#      AWS_STATE_BUCKET: $${{ secrets.AWS_STATE_BUCKET }} #`pragma: allowlist secret`
#      AWS_STATE_REGION: $${{ secrets.AWS_STATE_REGION }} #`pragma: allowlist secret`
%{ endif ~}
%{ if cloud_provider == "azure" ~}
#      ARM_CLIENT_ID: $${{ secrets.ARM_CLIENT_ID }} #`pragma: allowlist secret`
#      ARM_TENANT_ID: $${{ secrets.ARM_TENANT_ID }} #`pragma: allowlist secret`
#      ARM_SUBSCRIPTION_ID: $${{ secrets.ARM_SUBSCRIPTION_ID }} #`pragma: allowlist secret`
#      AZ_RESOURCE_GROUP_NAME: $${{ secrets.AZ_RESOURCE_GROUP_NAME }} #`pragma: allowlist secret`
#      AZ_STATE_STORE: $${{ secrets.AZ_STATE_STORE }} #`pragma: allowlist secret`
#      AZ_STATE_CONTAINER: $${{ secrets.AZ_STATE_CONTAINER }} #`pragma: allowlist secret`
%{ endif ~}
%{ if cloud_provider == "gcp" ~}
#      GOOGLE_WORKLOAD_IDENTITY_PROVIDER: $${{ secrets.GCP_WORKLOAD_IDENTITY_PROVIDER }} #`pragma: allowlist secret`
#      GOOGLE_SERVICE_ACCOUNT_EMAIL: $${{ secrets.GCP_SERVICE_ACCOUNT_EMAIL }} #`pragma: allowlist secret`
#      GOOGLE_STATE_BUCKET: $${{ secrets.GCP_STATE_BUCKET }} #`pragma: allowlist secret`
%{ endif ~}
#    permissions:
#      contents: read
#      pull-requests: write
#      id-token: write
#    with:
#      terraform_version: "1.12"
#      working_directory: "."
