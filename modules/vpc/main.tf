module "vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name           = var.vpc_name
  cidr           = var.vpc_cidr
  
  azs            = var.azs                 
  public_subnets = var.public_subnets      
  private_subnets = var.private_subnets 

  map_public_ip_on_launch = true
  
  enable_nat_gateway = true


  public_subnet_tags = {
    "Environment" = terraform.workspace
    Name                                        = "Public Subnets"
    "kubernetes.io/role/elb"                    = 1
    "kubernetes.io/cluster/${var.cluster_name}" = "shared"
  }

  private_subnet_tags = {
    "Environment" = terraform.workspace
    Name                                        = "Private-subnets"
    "kubernetes.io/role/internal-elb"           = 1
    "kubernetes.io/cluster/${var.cluster_name}" = "shared"
  }
  
  tags = {
    Environment = terraform.workspace  
  }
}