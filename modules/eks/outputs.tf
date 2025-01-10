output "cluster_id" {
  description = "The ID EKS cluster"
  value = module.eks.cluster_id
}

output "cluster_endpoint" {
  description = "The endpoint of the EKS cluster"
  value       = module.eks.cluster_endpoint
}

output "cluster_certificate_authority_data" {
  description = "The certificate authority data for the cluster"
  value       = module.eks.cluster_certificate_authority_data
}

output "cluster_name" {
  description = "The name of the EKS cluster"
  value       = module.eks.cluster_name
}

output "cluster_security_group_id" {
  value = module.eks.cluster_security_group_id
  description = "Security group of the EKS cluster"
}

output "node_security_group_id" {
  value = module.eks.node_security_group_id
  description = "Security group of the EKS node"
}
