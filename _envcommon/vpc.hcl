# COMMON VPC CONFIGURATION
# This file is REUSABLE across ALL environments (dev, test, prod)
# Changes here affect all environments that include it

locals {
  # Load environment-specific variables
  environment_vars = read_terragrunt_config(find_in_parent_folders("env.hcl"))
  region_vars      = read_terragrunt_config(find_in_parent_folders("region.hcl"))
  
  # Extract values for easy reference
  environment = local.environment_vars.locals.environment
  aws_region  = local.region_vars.locals.aws_region
  
  # Construct VPC name dynamically
  # Result: "dev-eks-vpc" for dev environment
  vpc_name = "${local.environment}-eks-vpc"
  
  # Get VPC CIDR from environment config
  vpc_cidr = local.environment_vars.locals.vpc_cidr
  
  # Calculate availability zones
  # For eu-north-1: ["eu-north-1a", "eu-north-1b", "eu-north-1c"]
  azs = [
    "${local.aws_region}a",
    "${local.aws_region}b",
    "${local.aws_region}c"
  ]
}

# Use official AWS VPC Terraform module
# This module is battle-tested by thousands of users
terraform {
  source = "tfr:///terraform-aws-modules/vpc/aws?version=5.1.2"
}

# ❌ REMOVE THIS BLOCK - it causes the double include error
# include "root" {
#   path = find_in_parent_folders()
# }

# Inputs passed to the VPC module
inputs = {
  # Basic VPC settings
  name = local.vpc_name
  cidr = local.vpc_cidr
  
  # Availability zones and subnets
  azs             = local.azs
  private_subnets = local.environment_vars.locals.private_subnets
  public_subnets  = local.environment_vars.locals.public_subnets
  
  # NAT Gateway configuration
  # Dev: 1 NAT Gateway ($32/month) - saves $64/month!
  # Prod: 3 NAT Gateways ($97/month) - high availability
  enable_nat_gateway     = true
  single_nat_gateway     = local.environment == "dev" ? true : false
  one_nat_gateway_per_az = local.environment == "dev" ? false : true
  
  # DNS support (required for EKS)
  enable_dns_hostnames = true
  enable_dns_support   = true
  
  # VPC Flow Logs (disabled in dev to save money)
  # Prod: enabled for security auditing
  enable_flow_log                      = local.environment != "dev"
  create_flow_log_cloudwatch_iam_role  = local.environment != "dev"
  create_flow_log_cloudwatch_log_group = local.environment != "dev"
  
  # Special tags for EKS subnet discovery
  # EKS needs these to know where to put load balancers
  public_subnet_tags = {
    "kubernetes.io/role/elb"                    = "1"
    "kubernetes.io/cluster/${local.vpc_name}"   = "shared"
  }
  
  private_subnet_tags = {
    "kubernetes.io/role/internal-elb"           = "1"
    "kubernetes.io/cluster/${local.vpc_name}"   = "shared"
  }
  
  tags = {
    Name = local.vpc_name
  }
}