# K8S DEPLOYMENT CONFIGURATION
# 4 pods for High Availability
locals {
  environment_vars = read_terragrunt_config(find_in_parent_folders("env.hcl"))
  region_vars      = read_terragrunt_config(find_in_parent_folders("region.hcl"))
  
  environment  = local.environment_vars.locals.environment
  aws_region   = local.region_vars.locals.aws_region
  cluster_name = "${local.environment}-eks-cluster"
}

terraform {
    source = "../../../modules//k8s-deployment"
}

inputs = {
  cluster_name = local.cluster_name
  
  # Kubernetes configuration
  namespace = "${local.environment}-apps"
  app_name  = "my-app"
  replicas  = 4
  
  # Container configuration
  container_image = "nginx:1.25-alpine"
  container_port  = 80
  
  # Resource configuration
  memory_request = "128Mi"
  memory_limit   = "256Mi"
  cpu_request    = "100m"
  cpu_limit      = "200m"
  
  # Health check
  health_check_path = "/"
}