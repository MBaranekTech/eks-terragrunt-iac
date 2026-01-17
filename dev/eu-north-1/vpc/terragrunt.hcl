# VPC DEPLOYMENT CONFIGURATION
# This is the ACTUAL deployment file
# It's tiny because it inherits everything from _envcommon/vpc.hcl!

# Include root configuration
# This gives us: provider, remote state, common tags
include "root" {
  path = find_in_parent_folders()
}

# Include common VPC configuration
# This gives us: all the VPC settings from _envcommon/vpc.hcl
include "envcommon" {
  path   = "${dirname(find_in_parent_folders())}/_envcommon/vpc.hcl"
  expose = true
}

# That's it! Just 11 lines instead of hundreds.
# This is the power of Terragrunt and the _envcommon pattern!