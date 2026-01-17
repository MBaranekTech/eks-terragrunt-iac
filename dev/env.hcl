# DEV ENVIRONMENT CONFIGURATION
# Settings specific to the development environment
# Optimized for COST and LEARNING

locals {
  environment = "dev"
  
  # ===========================
  # VPC NETWORK DESIGN
  # ===========================
  
  # Main VPC CIDR block
  # 10.0.0.0/16 = 65,536 IP addresses
  # First two octets (10.0) are fixed
  # Last two octets (.0.0 to .255.255) are usable
  vpc_cidr = "10.0.0.0/16"
  
  # Private subnets - where EKS worker nodes run
  # /24 = 256 IPs per subnet (251 usable, AWS reserves 5)
  # Spread across 3 Availability Zones for HA
  private_subnets = [
    "10.0.1.0/24",   # AZ-a: 10.0.1.1 - 10.0.1.254
    "10.0.2.0/24",   # AZ-b: 10.0.2.1 - 10.0.2.254
    "10.0.3.0/24"    # AZ-c: 10.0.3.1 - 10.0.3.254
  ]
  
  # Public subnets - for NAT Gateway and Load Balancers
  # Using different IP ranges (10.0.101.x) to easily distinguish
  public_subnets = [
    "10.0.101.0/24", # AZ-a: 10.0.101.1 - 10.0.101.254
    "10.0.102.0/24", # AZ-b: 10.0.102.1 - 10.0.102.254
    "10.0.103.0/24"  # AZ-c: 10.0.103.1 - 10.0.103.254
  ]
  
  # ===========================
  # EKS NODE CONFIGURATION
  # ===========================
  
  # Instance type for worker nodes
  # t3.medium = 2 vCPU, 4 GB RAM
  # Good for learning, small workloads
  node_instance_types = ["t3.medium"]
  
  # Capacity type: SPOT or ON_DEMAND
  # SPOT = 70% cheaper but can be interrupted
  # Perfect for dev! Not for production.
  node_capacity_type = "SPOT"
  
  # Auto-scaling configuration
  node_min_size     = 1  # Can scale down to 1 node (save money!)
  node_max_size     = 3  # Can scale up to 3 nodes
  node_desired_size = 2  # Start with 2 nodes
}
