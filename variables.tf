variable "aws_region" {
  description = "AWS Region"
  default = "us-east-1"
}

#vpc variables
variable "vpc_name" {
    description = "VPC Name"
}

variable "vpc_cidr" {
    description = "VPC CIDR"
}


variable "azs" {
  description = "AZ list"
  type        = list(string)
}

variable "public_subnets" {
  description = "List of CIDR blocks for public subnets"
  type        = list(string)
}

variable "private_subnets" {
  description = "List of CIDR blocks for private subnets"
  type        = list(string)
}


variable "cluster_name" {
  description = "The name of the EKS cluster"
  type        = string
}

variable "cluster_version" {
  description = "EKS Kubernentes cluster version"
  type        = string
}

variable "eks_managed_ng_instance_types" {
  description = "Specifies List of instances types that the nodes will use in this group w"
  type        = list(string)
}

variable "eks_managed_ng_optimized_ami" {
  description = "Specifies the type of Amazon Machine Image (AMI) that will be used for the nodes in this group."
  type        = string
}

variable "eks_managed_ng_min_size" {
  description = "This defines the minimum number of nodes that should exist in the group"
  type        = number
}

variable "eks_managed_ng_max_size" {
  description = "This defines the maximum number of nodes that can exist in the group"
  type        = number
}

variable "eks_managed_ng_desire_size" {
  description = "This defines the minimum number of nodes that should exist in the group"
  type        = number
}
