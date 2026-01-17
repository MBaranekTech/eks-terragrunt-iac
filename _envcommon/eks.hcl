locals {
  environment_vars = read_terragrunt_config(find_in_parent_folders("env.hcl"))
  region_vars      = read_terragrunt_config(find_in_parent_folders("region.hcl"))
  
  environment = local.environment_vars.locals.environment
  aws_region  = local.region_vars.locals.aws_region
  cluster_name    = "${local.environment}-eks-cluster"
  cluster_version = "1.29"
}

terraform {
  source = "tfr:///terraform-aws-modules/eks/aws?version=20.36.0"
}

inputs = {
  cluster_name    = local.cluster_name
  cluster_version = local.cluster_version
  
  cluster_endpoint_public_access  = true
  cluster_endpoint_private_access = true
  
  enable_irsa = true
  
  eks_managed_node_groups = {
    general = {
      instance_types = local.environment_vars.locals.node_instance_types
      capacity_type  = local.environment_vars.locals.node_capacity_type
      
      min_size     = local.environment_vars.locals.node_min_size
      max_size     = local.environment_vars.locals.node_max_size
      desired_size = local.environment_vars.locals.node_desired_size
      
      disk_size = 50
      
      # Fix the IAM role name length issue
      iam_role_use_name_prefix = false
      iam_role_name = "${local.environment}-eks-ng"
    }
  }
}