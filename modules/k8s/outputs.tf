

output "web_app_service_url" {
  value = (
    length(kubernetes_service.web_app_service.status[0].load_balancer[0].ingress) > 0
  ) ? kubernetes_service.web_app_service.status[0].load_balancer[0].ingress[0].hostname : "LoadBalancer not yet available"
}

output "eks_cluster_identity" {
  value = data.aws_eks_cluster.cluster.identity
}