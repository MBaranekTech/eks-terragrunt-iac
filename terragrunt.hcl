# ROOT TERRAGRUNT CONFIGURATION
# This file is inherited by ALL modules in this project

locals {
  # Read configurations from parent folders
  # These files will be in dev/account.hcl, dev/region.hcl, etc.
  account_vars     = read_terragrunt_config(find_in_parent_folders("account.hcl"))
  region_vars      = read_terragrunt_config(find_in_parent_folders("region.hcl"))
  environment_vars = read_terragrunt_config(find_in_parent_folders("env.hcl"))
  
  # Extract commonly used values
  account_name = local.account_vars.locals.account_name
  account_id   = local.account_vars.locals.aws_account_id
  aws_region   = local.region_vars.locals.aws_region
  environment  = local.environment_vars.locals.environment
  
  # Tags applied to ALL resources
  common_tags = {
    Environment = local.environment
    ManagedBy   = "Terragrunt"
    Project     = "EKS-Learning"
    Owner       = "YourName"  # CHANGE THIS
  }
}

# Generate AWS provider configuration
generate "provider" {
  path      = "provider.tf"
  if_exists = "overwrite_terragrunt"
  contents  = <<EOF
provider "aws" {
  region = "${local.aws_region}"
  
  default_tags {
    tags = ${jsonencode(local.common_tags)}
  }
}
EOF
}

# Configure remote state in S3
remote_state {
  backend = "s3"
  config = {
    encrypt        = true
    bucket         = "terragrunt-state-${local.account_name}-${local.aws_region}"
    key            = "${path_relative_to_include()}/terraform.tfstate"
    region         = local.aws_region
    dynamodb_table = "terragrunt-locks-${local.account_name}"
  }
  generate = {
    path      = "backend.tf"
    if_exists = "overwrite_terragrunt"
  }
}

# Make variables available to all modules
inputs = merge(
  local.account_vars.locals,
  local.region_vars.locals,
  local.environment_vars.locals,
  {
    common_tags = local.common_tags
  }
)