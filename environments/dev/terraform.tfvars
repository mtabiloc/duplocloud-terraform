#vpc variables
vpc_name       = "duplocloud-dev-vpc"
vpc_cidr       = "10.0.0.0/16"
azs            = ["us-east-1a", "us-east-1b", "us-east-1c"]
public_subnets = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
private_subnets = ["10.0.4.0/24", "10.0.5.0/24", "10.0.6.0/24"]


#eks variables
cluster_name    = "dev-cluster"
cluster_version = "1.31" #kubernetes version
eks_managed_ng_instance_types = ["t3.small", "t2.small"]
eks_managed_ng_optimized_ami = "AL2023_x86_64_STANDARD" #mazon Linux 2023 (AL2023) for the x86_64 architecture. Since EKS 1.30, AL2023 is the default AMI.
eks_managed_ng_min_size = 2 #Should be 2 for requirements of CoreDNS addons
eks_managed_ng_max_size = 3
eks_managed_ng_desire_size = 2