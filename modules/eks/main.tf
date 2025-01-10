module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 20.0"
  cluster_name    = var.cluster_name
  cluster_version = var.cluster_version

  vpc_id     = var.vpc_id
  subnet_ids = var.worker_subnet_ids
  control_plane_subnet_ids =  var.control_plane_subnet_ids

  cluster_endpoint_public_access = true 

  create_iam_role = true

  #Adds the current caller identity as an administrator via cluster access entry
  enable_cluster_creator_admin_permissions = true


  cluster_addons = {
    coredns                = {}
    eks-pod-identity-agent = {}
    kube-proxy             = {}
    vpc-cni                = {}
  }
  

  eks_managed_node_groups = {
    worker_nodes = {
      ami_type       = var.eks_managed_ng_optimized_ami
      instance_types = var.eks_managed_ng_instance_types
      min_size     = var.eks_managed_ng_min_size
      max_size     = var.eks_managed_ng_max_size
      desired_size = var.eks_managed_ng_desire_size
    }
  }

  tags = {
    Environment = terraform.workspace
  }
}