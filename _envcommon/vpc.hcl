# COMMON VPC CONFIGURATION
# This file is REUSABLE across ALL environments (dev, test, prod)

locals {
  # Load environment-specific variables
  environment_vars = read_terragrunt_config(find_in_parent_folders("env.hcl"))
  region_vars      = read_terragrunt_config(find_in_parent_folders("region.hcl"))
  
  # Extract values for easy reference
  environment = local.environment_vars.locals.environment
  aws_region  = local.region_vars.locals.aws_region
  
  # Construct names dynamically
  vpc_name     = "${local.environment}-eks-vpc"
  cluster_name = "${local.environment}-eks-cluster"
  
  # Get VPC CIDR from environment config
  vpc_cidr = local.environment_vars.locals.vpc_cidr
  
  # Calculate availability zones
  azs = [
    "${local.aws_region}a",
    "${local.aws_region}b",
    "${local.aws_region}c"
  ]
}

# Use official AWS VPC Terraform module
terraform {
  source = "tfr:///terraform-aws-modules/vpc/aws?version=5.1.2"
}

# Inputs passed to the VPC module
inputs = {
  name = local.vpc_name
  cidr = local.vpc_cidr
  
  azs             = local.azs
  private_subnets = local.environment_vars.locals.private_subnets
  public_subnets  = local.environment_vars.locals.public_subnets
  
  # NAT Gateway configuration
  enable_nat_gateway     = true
  single_nat_gateway     = local.environment == "dev" ? true : false
  one_nat_gateway_per_az = local.environment == "dev" ? false : true
  
  # DNS support (required for EKS)
  enable_dns_hostnames = true
  enable_dns_support   = true
  
  # VPC Flow Logs (disabled in dev to save money)
  enable_flow_log                      = local.environment != "dev"
  create_flow_log_cloudwatch_iam_role  = local.environment != "dev"
  create_flow_log_cloudwatch_log_group = local.environment != "dev"
  
  # CRITICAL: Special tags for EKS Load Balancer discovery
  # These MUST match the cluster name: dev-eks-cluster
  public_subnet_tags = {
    "kubernetes.io/role/elb"                      = "1"
    "kubernetes.io/cluster/${local.cluster_name}" = "shared"
  }
  
  private_subnet_tags = {
    "kubernetes.io/role/internal-elb"             = "1"
    "kubernetes.io/cluster/${local.cluster_name}" = "shared"
  }
  
  tags = {
    Name        = local.vpc_name
    Environment = local.environment
  }
}