# k8s.tf

provider "kubernetes" {
  host                   = var.cluster_endpoint
  cluster_ca_certificate = base64decode(var.cluster_certificate_authority_data)
  token                  = data.aws_eks_cluster_auth.cluster.token
}

provider "helm" {
  kubernetes {
    host                   = var.cluster_endpoint
    cluster_ca_certificate = base64decode(var.cluster_certificate_authority_data)
    token                  = data.aws_eks_cluster_auth.cluster.token
  }
}


data "aws_caller_identity" "current" {}


data "aws_eks_cluster_auth" "cluster" {
  name = var.cluster_name
}

data "aws_eks_cluster" "cluster" {
  name = var.cluster_name
}


locals {
  oidc_provider_id = replace(data.aws_eks_cluster.cluster.identity.0.oidc.0.issuer, "https://oidc.eks.${var.aws_region}.amazonaws.com/id/", "")
}

# Create the IAM policy for the AWS Load Balancer Controller
resource "aws_iam_policy" "aws_lb_controller_policy" {
  name   = "AWSLoadBalancerControllerIAMPolicy"
  policy = file("${path.root}/files/iam_policy.json")
}


resource "random_id" "role_suffix" {
  byte_length = 8
}

# Create the IAM role for the AWS Load Balancer Controller
resource "aws_iam_role" "aws_lb_controller_role" {
  name = "aws-load-balancer-controller-role-${random_id.role_suffix.hex}"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Federated = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:oidc-provider/oidc.eks.${var.aws_region}.amazonaws.com/id/${local.oidc_provider_id}"
        }
        Action   = "sts:AssumeRoleWithWebIdentity"
        Condition = {
          StringEquals = {
            "oidc.eks.${var.aws_region}.amazonaws.com/id/${local.oidc_provider_id}:sub" = "system:serviceaccount:kube-system:aws-load-balancer-controller"
          }
        }
      }
    ]
  })
}


# Attach the IAM policy to the created role
resource "aws_iam_role_policy_attachment" "aws_lb_controller_policy_attach" {
  role       = aws_iam_role.aws_lb_controller_role.name
  policy_arn = aws_iam_policy.aws_lb_controller_policy.arn
}

# Create a ServiceAccount for the AWS Load Balancer Controller in Kubernetes
resource "kubernetes_service_account" "aws_lb_controller" {
  metadata {
    name      = "aws-load-balancer-controller"
    namespace = "kube-system"
    annotations = {
      "eks.amazonaws.com/role-arn" = aws_iam_role.aws_lb_controller_role.arn
    }
  }
  automount_service_account_token = true
}

resource "helm_release" "aws_lb_controller" {
  name       = "aws-load-balancer-controller"
  namespace  = "kube-system"
  repository = "https://aws.github.io/eks-charts"
  chart      = "aws-load-balancer-controller"
  version    = "1.11.0" 
  set {
    name  = "clusterName"
    value = var.cluster_name
  }
  set {
    name  = "serviceAccount.create"
    value = "false"
  }
  set {
    name  = "serviceAccount.name"
    value = kubernetes_service_account.aws_lb_controller.metadata[0].name
  }
}

# Create a Deployment in Kubernetes for the web application (nginx)
resource "kubernetes_deployment" "web_app" {
  metadata {
    name = "web-app"
    labels = {
      app = "web-app"
    }
  }

  spec {
    replicas = 1

    selector {
      match_labels = {
        app = "web-app"
      }
    }

    template {
      metadata {
        labels = {
          app = "web-app"
        }
      }

      spec {
        container {
          name  = "web-app"
          image = "nginx:latest"
          port {
            container_port = 80
          }
        }
      }
    }
  }
}

# Create a LoadBalancer type Service to expose the web application
resource "kubernetes_service" "web_app_service" {
  depends_on = [kubernetes_deployment.web_app]

  metadata {
    name = "web-app-service"
    annotations = {
      "service.beta.kubernetes.io/aws-load-balancer-type" = "external" 
      "service.beta.kubernetes.io/aws-load-balancer-scheme" = "internet-facing"
      "alb.ingress.kubernetes.io/scheme" = "internet-facing"  
      "service.beta.kubernetes.io/aws-load-balancer-controller" = "true"
    }
  }

  spec {
    selector = {
      app = "web-app"
    }

    port {
      port        = 80
      target_port = 80
    }

    type = "LoadBalancer"
  }
}