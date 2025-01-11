# main.tf
module "vpc" {
  source = "./modules/vpc"
  vpc_name                = var.vpc_name
  vpc_cidr                = var.vpc_cidr
  cluster_name            = var.cluster_name
  azs = var.azs
  private_subnets = var.private_subnets
  public_subnets = var.public_subnets
}

module "eks" {
  source  = "./modules/eks"
  vpc_id          = module.vpc.vpc_id
  worker_subnet_ids = module.vpc.private_subnets
  control_plane_subnet_ids = module.vpc.public_subnets
  cluster_name    = var.cluster_name
  cluster_version = var.cluster_version
  eks_managed_ng_instance_types = var.eks_managed_ng_instance_types
  eks_managed_ng_optimized_ami = var.eks_managed_ng_optimized_ami
  eks_managed_ng_min_size = var.eks_managed_ng_min_size
  eks_managed_ng_max_size = var.eks_managed_ng_max_size
  eks_managed_ng_desire_size = var.eks_managed_ng_desire_size
  depends_on      = [module.vpc]
}

module "k8s" {
  source = "./modules/k8s"
  cluster_name = module.eks.cluster_name
  cluster_endpoint = module.eks.cluster_endpoint
  cluster_certificate_authority_data = module.eks.cluster_certificate_authority_data
  aws_region = var.aws_region
}