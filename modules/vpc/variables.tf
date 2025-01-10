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
  description = "eks cluster name"
  type        = string
}