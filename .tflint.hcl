plugin "terraform" {
  enabled = true
  present = "recommended"
}

plugin "aws" {
  enabled = true
  version = "0.44.0"
  source = "github.com/terraform-linters/tflint-ruleset-aws"
}

plugin "azurerm" {
  enabled = true
  version = "0.30.0"
  source = "github.com/terraform-linters/tflint-ruleset-azurerm"
}

plugin "google" {
  enabled = true
  version = "0.37.1"
  source = "github.com/terraform-linters/tflint-ruleset-google"
}

config {
  format = "compact"
  plugin_dir = "~/.tflint.d/plugins"
  disabled_by_default = false
}

rule "terraform_required_version" {
  enabled = true
}

rule "terraform_required_providers" {
  enabled = true
}

rule "terraform_naming_convention" {
  enabled = true
  format = "snake_case"
}

rule "terraform_typed_variables" {
  enabled = true
}

rule "terraform_unused_declarations" {
  enabled = true
}

rule "terraform_comment_syntax" {
  enabled = true
}

rule "terraform_documentented_outputs" {
  enabled = true
}

rule "terraform_deprecated_interpolation" {
  enabled = true
}

rule "terraform_module_pinned_source" {
  enabled = true
}
