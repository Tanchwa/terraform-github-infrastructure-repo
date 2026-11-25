on:
  push:
    branches:
      - '*'
      - '!main'
  pull_request:
    types:
      - closed


jobs:
  upload_tf_vars:
    name: 'Upload tfvars to Artifact'
    runs-on: ubuntu-latest
    permissions:
      contents: read
    steps:
      - name: Checkout
        uses: actions/checkout@v4


      - name: Upload tfvars
        uses: actions/upload-artifact@v4
        with:
          name: tfvars
          path: 'test.tfvars.json'


  plan:
    if: (github.event.pull_request.merged && github.base_ref == 'main') && github.repository != 'Tanchwa/infrastructure-deployment-template'
    name: 'Terraform Plan'
    uses: Tanchwa/workflows-terraform-deployment/.github/workflows/terraform_plan.yaml@main
    needs: upload_tf_vars
    secrets: #`pragma: allowlist secret`
      INFRACOST_API_KEY: $${{ secrets.INFRACOST_API_KEY }} #`pragma: allowlist secret`
%{ if cloud_provider == "aws" ~}
      AWS_IAM_ROLE_ARN: $${{ secrets.AWS_IAM_ROLE_ARN }} #`pragma: allowlist secret`
      AWS_STATE_BUCKET: $${{ secrets.AWS_STATE_BUCKET }} #`pragma: allowlist secret`
      AWS_STATE_REGION: $${{ secrets.AWS_STATE_REGION }} #`pragma: allowlist secret`
%{ endif ~}
%{ if cloud_provider == "azure" ~}
      ARM_CLIENT_ID: $${{ secrets.ARM_CLIENT_ID }} #`pragma: allowlist secret`
      ARM_TENANT_ID: $${{ secrets.ARM_TENANT_ID }} #`pragma: allowlist secret`
      ARM_SUBSCRIPTION_ID: $${{ secrets.ARM_SUBSCRIPTION_ID }} #`pragma: allowlist secret`
      AZ_RESOURCE_GROUP_NAME: $${{ secrets.AZ_RESOURCE_GROUP_NAME }} #`pragma: allowlist secret`
      AZ_STATE_STORE: $${{ secrets.AZ_STATE_STORE }} #`pragma: allowlist secret`
      AZ_STATE_CONTAINER: $${{ secrets.AZ_STATE_CONTAINER }} #`pragma: allowlist secret`
%{ endif ~}
%{ if cloud_provider == "gcp" ~}
      GOOGLE_WORKLOAD_IDENTITY_PROVIDER: $${{ secrets.GCP_WORKLOAD_IDENTITY_PROVIDER }} #`pragma: allowlist secret`
      GOOGLE_SERVICE_ACCOUNT_EMAIL: $${{ secrets.GCP_SERVICE_ACCOUNT_EMAIL }} #`pragma: allowlist secret`
      GOOGLE_STATE_BUCKET: $${{ secrets.GCP_STATE_BUCKET }} #`pragma: allowlist secret`
%{ endif ~}
    permissions:
      contents: read
      pull-requests: write
      id-token: write
    with:
      terraform_version: "1.12"
      working_directory: "."
      tf_vars_artifact: "tfvars"
      tf_vars_filename: "test.tfvars.json"
      environment: "test"

  apply:
    if: (github.event.pull_request.merged && github.base_ref == 'main') && github.repository != 'Tanchwa/infrastructure-deployment-template'
    needs:
      - plan
      - upload_tf_vars
    name: 'Terraform Apply'
    uses: Tanchwa/workflows-terraform-deployment/.github/workflows/terraform_apply.yaml@main
    secrets: #`pragma: allowlist secret`
      INFRACOST_API_KEY: $${{ secrets.INFRACOST_API_KEY }} #`pragma: allowlist secret`
%{ if cloud_provider == "aws" ~}
      AWS_IAM_ROLE_ARN: $${{ secrets.AWS_IAM_ROLE_ARN }} #`pragma: allowlist secret`
      AWS_STATE_BUCKET: $${{ secrets.AWS_STATE_BUCKET }} #`pragma: allowlist secret`
      AWS_STATE_REGION: $${{ secrets.AWS_STATE_REGION }} #`pragma: allowlist secret`
%{ endif ~}
%{ if cloud_provider == "azure" ~}
      ARM_CLIENT_ID: $${{ secrets.ARM_CLIENT_ID }} #`pragma: allowlist secret`
      ARM_TENANT_ID: $${{ secrets.ARM_TENANT_ID }} #`pragma: allowlist secret`
      ARM_SUBSCRIPTION_ID: $${{ secrets.ARM_SUBSCRIPTION_ID }} #`pragma: allowlist secret`
      AZ_RESOURCE_GROUP_NAME: $${{ secrets.AZ_RESOURCE_GROUP_NAME }} #`pragma: allowlist secret`
      AZ_STATE_STORE: $${{ secrets.AZ_STATE_STORE }} #`pragma: allowlist secret`
      AZ_STATE_CONTAINER: $${{ secrets.AZ_STATE_CONTAINER }} #`pragma: allowlist secret`
%{ endif ~}
%{ if cloud_provider == "gcp" ~}
      GOOGLE_WORKLOAD_IDENTITY_PROVIDER: $${{ secrets.GCP_WORKLOAD_IDENTITY_PROVIDER }} #`pragma: allowlist secret`
      GOOGLE_SERVICE_ACCOUNT_EMAIL: $${{ secrets.GCP_SERVICE_ACCOUNT_EMAIL }} #`pragma: allowlist secret`
      GOOGLE_STATE_BUCKET: $${{ secrets.GCP_STATE_BUCKET }} #`pragma: allowlist secret`
%{ endif ~}
    permissions:
      contents: read
      pull-requests: write
      id-token: write
    with:
      terraform_version: "1.12"
      working_directory: "."
      tf_vars_artifact: "tfvars"
      tf_vars_filename: "test.tfvars.json"
      environment: "test"
