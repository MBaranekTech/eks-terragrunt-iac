# EKS Terragrunt - DEV Environment Learning Project

A hands-on learning project for building a production-ready AWS EKS cluster in EU-North-1 (Stockholm) using Terragrunt and the `_envcommon` pattern.

![Terraform](https://img.shields.io/badge/terraform-%235835CC.svg?style=for-the-badge&logo=terraform&logoColor=white)
![AWS](https://img.shields.io/badge/AWS-%23FF9900.svg?style=for-the-badge&logo=amazon-aws&logoColor=white)
![Kubernetes](https://img.shields.io/badge/kubernetes-%23326ce5.svg?style=for-the-badge&logo=kubernetes&logoColor=white)



## 🎯 Project Goal

Learn Infrastructure as Code by **manually building** a DEV EKS environment step-by-step. No automation scripts - pure learning!

### What You'll Build

- ✅ VPC with 6 subnets across 3 availability zones
- ✅ EKS cluster with Kubernetes 1.29
- ✅ 2 Spot instances (t3.medium) for cost optimization
- ✅ Essential EKS addons (VPC-CNI, CoreDNS, kube-proxy, EBS CSI)
- ✅ Production-ready security (IRSA, encryption, security groups)
- ✅ Complete understanding of every component

### Learning Focus

This is a **learning project**, not a quick deployment. Every file is created manually to understand:
- How Terragrunt works
- How the `_envcommon` pattern enables DRY principles
- AWS networking fundamentals
- EKS architecture
- Cost optimization strategies

---

## 📋 Prerequisites

### Required Tools

| Tool | Version | Install |
|------|---------|---------|
| AWS CLI | 2.x+ | `brew install awscli` |
| Terraform | 1.6+ | `brew install terraform` |
| Terragrunt | 0.54+ | `brew install terragrunt` |
| kubectl | 1.28+ | `brew install kubectl` |
| Lens Desktop | Latest | `brew install --cask lens` |

### AWS Requirements

- AWS Account with admin access
- AWS credentials configured (`aws configure`)
- Account ID handy (run: `aws sts get-caller-identity`)

---

## 🏗️ Architecture

### What You're Building
```
DEV Environment - EU-North-1
VPC: 10.0.0.0/16 (65,536 IPs)

Public Subnets (3):
  - AZ-A: 10.0.101.0/24 [NAT Gateway]
  - AZ-B: 10.0.102.0/24
  - AZ-C: 10.0.103.0/24

Private Subnets (3):
  - AZ-A: 10.0.1.0/24 [EKS Node 1 - t3.medium SPOT]
  - AZ-B: 10.0.2.0/24 [EKS Node 2 - t3.medium SPOT]
  - AZ-C: 10.0.3.0/24

EKS Control Plane: Kubernetes 1.29 (AWS Managed)
```

### Cost Breakdown

| Component | Details | Monthly Cost |
|-----------|---------|--------------|
| EKS Control Plane | AWS Managed | €73 |
| NAT Gateway | 1x (cost optimized) | €32 |
| EC2 Spot Instances | 2x t3.medium | €18 |
| EBS Volumes | 2x 50GB gp3 | €8 |
| Data Transfer | Estimated | €5 |
| **TOTAL** | | **~€136** |

**Savings:** Using Spot instances saves €42/month (70% off) compared to On-Demand!

---

## 📁 Project Structure
```
eks-terragrunt-project/
├── README.md                    # This file
├── terragrunt.hcl              # Root configuration
│
├── _envcommon/                 # Reusable configs (DRY principle)
│   ├── vpc.hcl                # VPC configuration
│   ├── eks.hcl                # EKS configuration
│   └── eks-addons.hcl         # Addons configuration
│
├── dev/                        # DEV environment
│   ├── account.hcl            # Your AWS Account ID
│   ├── region.hcl             # Default region (eu-north-1)
│   ├── env.hcl                # DEV-specific settings
│   └── eu-north-1/            # Stockholm region
│       ├── vpc/
│       │   └── terragrunt.hcl # VPC deployment
│       ├── eks/
│       │   └── terragrunt.hcl # EKS deployment
│       └── eks-addons/
│           └── terragrunt.hcl # Addons deployment
│
└── modules/                    # Custom modules
    └── eks-addons/
        ├── main.tf
        ├── variables.tf
        └── outputs.tf
```

---

## 🚀 Deployment Steps

### Phase 1: Prepare Backend (~15 min)

Create S3 bucket and DynamoDB table for Terraform state:
```bash
aws s3 mb s3://terragrunt-state-dev-eu-north-1 --region eu-north-1

aws s3api put-bucket-versioning \
  --bucket terragrunt-state-dev-eu-north-1 \
  --versioning-configuration Status=Enabled

aws s3api put-bucket-encryption \
  --bucket terragrunt-state-dev-eu-north-1 \
  --server-side-encryption-configuration \
  '{"Rules":[{"ApplyServerSideEncryptionByDefault":{"SSEAlgorithm":"AES256"}}]}'

aws dynamodb create-table \
  --table-name terragrunt-locks-dev \
  --attribute-definitions AttributeName=LockID,AttributeType=S \
  --key-schema AttributeName=LockID,KeyType=HASH \
  --provisioned-throughput ReadCapacityUnits=5,WriteCapacityUnits=5 \
  --region eu-north-1

aws dynamodb wait table-exists \
  --table-name terragrunt-locks-dev \
  --region eu-north-1
```

### Phase 2: Deploy VPC (~5 min)
```bash
cd dev/eu-north-1/vpc
terragrunt init
terragrunt plan
terragrunt apply
```

**What was created:**
- 1 VPC (10.0.0.0/16)
- 6 Subnets (3 private, 3 public)
- 1 Internet Gateway
- 1 NAT Gateway
- Route tables and associations

### Phase 3: Deploy EKS (~20 min)
```bash
cd ../eks
terragrunt init
terragrunt plan
terragrunt apply

aws eks update-kubeconfig --name dev-eks-cluster --region eu-north-1
kubectl get nodes
```

**What was created:**
- EKS Control Plane (Kubernetes 1.29)
- IAM Roles
- Security Groups
- Auto Scaling Group
- 2 EC2 Spot instances

### Phase 4: Deploy Addons (~5 min)
```bash
cd ../eks-addons
terragrunt init
terragrunt plan
terragrunt apply

kubectl get pods -n kube-system
```

**Addons installed:**
- VPC-CNI (pod networking)
- CoreDNS (DNS resolution)
- kube-proxy (network proxy)
- EBS CSI Driver (persistent storage)

---

## ✅ Verification

### Check Everything Works
```bash
# Check nodes
kubectl get nodes

# Check system pods
kubectl get pods -A

# Deploy test application
kubectl create deployment nginx --image=nginx:latest
kubectl expose deployment nginx --port=80 --type=LoadBalancer

# Get LoadBalancer URL (wait 2-3 minutes)
kubectl get svc nginx -w

# Test
LOAD_BALANCER=$(kubectl get svc nginx -o jsonpath='{.status.loadBalancer.ingress[0].hostname}')
curl http://$LOAD_BALANCER
```

---

## 🎓 What You Learned

### Infrastructure as Code
✅ Terragrunt structure and organization
✅ `_envcommon` pattern for DRY configs
✅ Remote state with S3 + DynamoDB
✅ State locking

### AWS Networking
✅ VPC architecture
✅ CIDR notation and subnetting
✅ NAT Gateway vs Internet Gateway
✅ Multi-AZ deployment

### Kubernetes/EKS
✅ EKS architecture
✅ Managed node groups
✅ IRSA (IAM Roles for Service Accounts)
✅ EKS addons
✅ Security groups

### Cost Optimization
✅ Spot instances (70% savings)
✅ Single NAT Gateway in DEV
✅ Right-sizing instances
✅ Resource tagging

---

## 📖 Common Commands

### Terragrunt
```bash
terragrunt init          # Initialize module
terragrunt plan          # Preview changes
terragrunt apply         # Apply changes
terragrunt destroy       # Destroy resources
```

### kubectl
```bash
kubectl get nodes        # View nodes
kubectl get pods -A      # View all pods
kubectl logs -f <pod>    # View logs
kubectl exec -it <pod> -- /bin/bash  # Shell into pod
kubectl get svc          # View services
```

### AWS CLI
```bash
# Check EKS cluster
aws eks describe-cluster --name dev-eks-cluster --region eu-north-1

# List addons
aws eks list-addons --cluster-name dev-eks-cluster --region eu-north-1

# View VPC
aws ec2 describe-vpcs --filters "Name=tag:Name,Values=dev-eks-vpc" --region eu-north-1
```

---

## 🔧 Troubleshooting

### Cannot connect to cluster
```bash
aws eks update-kubeconfig --name dev-eks-cluster --region eu-north-1
aws sts get-caller-identity
```

### Nodes not ready
```bash
kubectl get nodes
kubectl describe node <node-name>
kubectl get pods -n kube-system
```

### High costs
```bash
aws ec2 describe-instances --filters "Name=instance-state-name,Values=running" --region eu-north-1
kubectl delete svc --all --field-selector spec.type=LoadBalancer
```

---

## 🧹 Cleanup

Delete in reverse order:
```bash
# 1. Delete LoadBalancer services
kubectl delete svc --all --field-selector spec.type=LoadBalancer
sleep 60

# 2. Destroy addons
cd ~/eks-terragrunt-project/dev/eu-north-1/eks-addons
terragrunt destroy

# 3. Destroy EKS
cd ../eks
terragrunt destroy

# 4. Destroy VPC
cd ../vpc
terragrunt destroy

# 5. Optional: Delete state
aws s3 rb s3://terragrunt-state-dev-eu-north-1 --force
aws dynamodb delete-table --table-name terragrunt-locks-dev --region eu-north-1
```

---

## 📚 Next Steps

1. Deploy a real application (multi-tier)
2. Add monitoring (Prometheus + Grafana)
3. Implement GitOps (ArgoCD)
4. Build TEST environment
5. Add CI/CD pipelines

### Learning Resources

- [AWS EKS Workshop](https://www.eksworkshop.com/)
- [Kubernetes Documentation](https://kubernetes.io/docs/)
- [Terragrunt Documentation](https://terragrunt.gruntwork.io/docs/)
- [kubectl Cheat Sheet](https://kubernetes.io/docs/reference/kubectl/cheatsheet/)

---

## 🎯 Success Criteria

- ✅ VPC deployed and verified
- ✅ EKS cluster running with 2 nodes
- ✅ All addons installed
- ✅ kubectl connected
- ✅ Test app deployed
- ✅ You understand every component
- ✅ Costs within €136/month

---

**Made with ❤️ for hands-on DevOps learning**