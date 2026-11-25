# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [v0.2.0]
### Added
- `template_sync_github_app_id` / `template_sync_github_app_private_key` variables, wired into each child repo as the `TEMPLATE_SYNC_APP_ID` / `TEMPLATE_SYNC_APP_PRIVATE_KEY` secrets consumed by the `template_sync` workflow in `infrastructure-deployment-template`.
- `templates/pull_request.yaml.tpl`, `templates/terraform_apply.yaml.tpl`, `templates/forget_me_not_destroy.yaml.tpl`: render the child repo's CI workflows with the real `AWS_*` / `ARM_*` & `AZ_*` / `GOOGLE_*` secret names for `var.cloud_provider`, overwriting the template's generic `EXAMPLE_SECRET` placeholders at creation time (same pattern as `providers.tf`).

### Fixed
- `pull_request.yaml`'s generated workflow now guards on `Tanchwa/infrastructure-deployment-template` (was erroneously checking `Tanchwa/terraform-module-template`) and passes `working_directory` instead of the undeclared `directory` input to `terraform_test.yaml`.
- GCP secrets now map correctly from this module's `GCP_*` secret names to the `GOOGLE_*` input names `workflows-terraform-deployment`'s reusable workflows actually expect.

## [v0.1.0]
### Added
- Init module
