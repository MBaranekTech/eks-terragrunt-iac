# K8S PODS DEPLOYMENT CONFIGURATION
include "root" {
  path = find_in_parent_folders()
}

include "envcommon" {
  path   = "../../../_envcommon/k8s-deployment.hcl"
  expose = true
}

dependency "eks" {
  config_path = "../eks"
  
  mock_outputs = {
    cluster_name = "dev-eks-cluster"
  }
  mock_outputs_allowed_terraform_commands = ["init", "validate", "plan"]
}

inputs = {
  # Override defaults from _envcommon if needed
  # replicas = 6
  # app_name = "custom-app"
}