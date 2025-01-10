variable "vpc_id" {
  description = "The ID of the VPC to use"
  type        = string
}

variable "worker_subnet_ids" {
  description = "The subnet IDs to be used by the EKS cluster worker nodes"
  type        = list(string)
}

variable "control_plane_subnet_ids" {
  description = "The subnet IDs to be used by the EKS cluster control plane"
  type        = list(string)
}


variable "cluster_name" {
  description = "cluster name"
  type        = string
}

variable "cluster_version" {
  description = "cluster version"
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