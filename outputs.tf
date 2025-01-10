output "eks_cluster_endpoint" {
  value = module.eks.cluster_endpoint
}

output "web_app_service_url" {
  value = module.k8s.web_app_service_url
}