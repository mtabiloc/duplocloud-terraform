variable "cluster_name" {
  description = "The name of the EKS cluster"
  type        = string
}

variable "cluster_id" {
  description = "The IDe EKS cluster"
  type        = string
}

variable "cluster_endpoint" {
  description = "The endpoint of the EKS cluster"
  type        = string
}

variable "cluster_certificate_authority_data" {
  description = "The certificate authority data for the cluster"
  type        = string
}

variable "aws_region" {
  description = "AWS Region"
}