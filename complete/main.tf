module "eks" {
  source = "../modules/app/eks"

  eks_name                 = format("%s-%s-%s", var.cluster_name, "cluster", var.env)
  eks_version              = "1.29"
  vpc_id                   = module.vpc.id
  subnet_ids               = module.vpc.private_subnet_ids
  control_plane_subnet_ids = module.vpc.private_subnet_ids
}

module "vpc" {
  source = "../modules/base/vpc"

  vpc_name = format("%s-%s", var.vpc_name, var.env)
  azs      = slice(data.aws_availability_zones.available.names, 0, 3)

  cidr_range = "10.0.0.0/16"

  private_subnets = ["10.0.4.0/24", "10.0.5.0/24", "10.0.6.0/24"]
  public_subnets  = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]

  enable_nat_gateway = true
  single_nat_gateway = true

  private_subnet_tags = {
    "karpenter.sh/discovery" = format("%s-%s-%s", var.cluster_name, "cluster", var.env)
  }
}

resource "helm_release" "victoriametrics" {
  namespace        = "vm"
  create_namespace = true

  name       = "vm"
  repository = "https://victoriametrics.github.io/helm-charts"
  chart      = "victoria-metrics-cluster"
  version    = "0.11.12"
  timeout    = 900

  values = [
    templatefile("./${path.module}/templates/vm.yaml", {
      nodeSelector = jsonencode(
        {
          "app" = "monitoring"
        }
      )
      tolerations = jsonencode(
        [{
          "operator" = "Equal",
          "key"      = "app",
          "value"    = "monitoring",
          "effect"   = "NoSchedule"
        }]
      )
      }
    )
  ]

  depends_on = [helm_release.karpenter]
}

resource "helm_release" "cert_manager" {
  namespace        = "cert-manager"
  create_namespace = true

  name       = "cert-manager"
  repository = "https://charts.jetstack.io"
  chart      = "cert-manager"
  version    = "v1.14.2"
  timeout    = 900

  set {
    name  = "installCRDs"
    value = "true"
  }
}

resource "helm_release" "grafana" {
  namespace        = "grafana"
  create_namespace = true

  name       = "grafana"
  repository = "https://grafana.github.io/helm-charts"
  chart      = "grafana"
  version    = "7.3.0"
  timeout    = 900

  values = [
    templatefile("${path.module}/templates/grafana.yaml", {
      nodeSelector = jsonencode(
        {
          "app" = "monitoring"
        }
      )
      tolerations = jsonencode(
        [{
          "operator" = "Equal",
          "key"      = "app",
          "value"    = "monitoring",
          "effect"   = "NoSchedule"
        }]
      )
      }
    )
  ]
  depends_on = [helm_release.karpenter]
}
