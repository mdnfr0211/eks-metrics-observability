resource "aws_eks_addon" "adot" {
  cluster_name                = module.eks.cluster_name
  addon_name                  = "adot"
  addon_version               = "v0.92.1-eksbuild.1"
  resolve_conflicts_on_update = "PRESERVE"

  depends_on = [helm_release.cert_manager]
}

data "kubectl_path_documents" "adot_permission" {
  pattern = "${path.module}/templates/adot/permission.yaml"
}

resource "kubectl_manifest" "adot_permission" {
  for_each  = toset(data.kubectl_path_documents.adot_permission.documents)
  yaml_body = each.value
}

resource "kubectl_manifest" "adot" {
  yaml_body = templatefile("${path.module}/templates/adot/adot.yaml", {
    EKS_CLUSTER_NAME      = module.eks.cluster_name
    AWS_ACCOUNT_ID        = var.account_ids[0]
    AWS_REGION            = var.region
    REMOTE_WRITE_ENDPOINT = "http://vm-victoria-metrics-cluster-vminsert.vm.svc.cluster.local:8480/insert/0/prometheus"
  })
}
